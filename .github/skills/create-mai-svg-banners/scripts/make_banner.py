#!/usr/bin/env python3
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

"""Generate MAI-palette SVG banners from a JSON spec. Standard library only.

Usage:
    python make_banner.py SPEC.json [--out-dir DIR] [--preview DIR]

SPEC is either one banner object or {"defaults": {...}, "banners": [{...}, ...]}.
See ../SKILL.md for the field reference.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from xml.sax.saxutils import escape

SKILL_DIR = Path(__file__).resolve().parent.parent
ART_DIR = SKILL_DIR / "art"

PALETTE = {
    "parchment": "#FEF9ED", "bone": "#F5F0E4", "walnut": "#5D524B", "cedar": "#72675B",
    "linen": "#CEC7BC", "teal": "#2E4D4D", "apricot": "#FBD3BE", "rose": "#8C5462",
    "lilac": "#666583",
}
P = PALETTE
THEMES = {
    "light": {"bg": P["parchment"], "frame": P["linen"], "frame_opacity": 1, "rule": P["rose"],
              "title": P["walnut"], "subtitle": P["cedar"], "label": P["cedar"], "art_disc": None},
    "dark": {"bg": P["teal"], "frame": P["parchment"], "frame_opacity": 0.3, "rule": P["apricot"],
             "title": P["parchment"], "subtitle": P["bone"], "label": P["linen"], "art_disc": P["parchment"]},
}

SERIF = "'Source Serif 4', 'Lora', Georgia, 'Times New Roman', serif"
MONO = "'Red Hat Mono', 'SFMono-Regular', Menlo, Consolas, 'DejaVu Sans Mono', monospace"

# Approximate glyph advance as a fraction of font size; used only for wrapping and overflow warnings.
ADVANCE = {"serif": 0.55, "italic": 0.52, "mono": 0.62}

# Layout in design units (1 unit = 1px on a 1600 x 900 landscape canvas).
EYEBROW_DY, TITLE_DY, TITLE_DY_NO_EYEBROW = 54, 120, 110
TITLE_LH, SUB_GAP, SUB_LH = 104, 90, 52
FOOTER_FROM_BOTTOM = 108


def text_width(s: str, size: float, kind: str, tracking: float = 0) -> float:
    return len(s) * (size * ADVANCE[kind] + tracking)


def wrap(value, size: float, kind: str, width: float) -> list[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    lines, line = [], ""
    for word in value.split():
        trial = f"{line} {word}".strip()
        if line and text_width(trial, size, kind) > width:
            lines.append(line)
            line = word
        else:
            line = trial
    return lines + ([line] if line else [])


def load_art(art: str | None, spec_dir: Path) -> tuple[str, str] | None:
    """Return (viewBox, inner markup) for an art preset name or an SVG file path."""
    if not art:
        return None
    path = Path(art)
    if path.suffix != ".svg":
        path = ART_DIR / f"{art}.svg"
    elif not path.is_absolute():
        path = spec_dir / path
    if not path.exists():
        presets = ", ".join(p.stem for p in sorted(ART_DIR.glob("*.svg")))
        sys.exit(f"Art not found: {art}. Presets: {presets}")
    src = path.read_text(encoding="utf-8")
    m = re.search(r"<svg\b([^>]*)>(.*)</svg>", src, re.S)
    vb = re.search(r'viewBox="([^"]+)"', m.group(1)) if m else None
    if not vb:
        sys.exit(f"Art must be an SVG with a viewBox: {path}")
    return vb.group(1), m.group(2)


def tspans(lines, x, y0, dy):
    return "".join(f'<tspan x="{x:g}" y="{y0 + i * dy:g}">{escape(s)}</tspan>' for i, s in enumerate(lines))


def block_units(n_title: int, n_sub: int, eyebrow: bool) -> float:
    units = (EYEBROW_DY + TITLE_DY if eyebrow else TITLE_DY_NO_EYEBROW) + TITLE_LH * (n_title - 1)
    return units + (SUB_GAP + SUB_LH * (n_sub - 1) if n_sub else 0)


def build(spec: dict, spec_dir: Path) -> tuple[str, list[str]]:
    w, h = int(spec["width"]), int(spec["height"])
    if w <= 0 or h <= 0:
        sys.exit("width and height must be positive integers")
    theme = THEMES[spec.get("background", "light")]
    art = load_art(spec.get("art"), spec_dir)
    eyebrow, footer = spec.get("eyebrow"), spec.get("footer")
    mx, my = 0.08 * w, 0.08 * h
    landscape = w >= h
    warnings: list[str] = []

    def column(u):
        if not landscape:
            return w - 2 * mx
        if not art:
            return w - 2 * mx
        art_size = min(0.756 * h, 0.425 * w)
        return 0.735 * w - art_size / 2 - mx - 40 * u

    def wrapped(u):
        col = column(u)
        return wrap(spec["title"], 96 * u, "serif", col), wrap(spec.get("subtitle"), 36 * u, "italic", col)

    if landscape:
        # Largest scale (capped at 1600-wide proportions) whose text block plus footer fits vertically.
        u = w / 1600
        for _ in range(3):
            title, subtitle = wrapped(u)
            # Centered block (offset 18u up) must clear the footer baseline by 60u.
            needed = block_units(len(title), len(subtitle), bool(eyebrow)) + 2 * (FOOTER_FROM_BOTTOM + 60 - 18)
            u = min(w / 1600, h / needed)
        u *= float(spec.get("scale", 1))
    else:
        u = w / 1100 * float(spec.get("scale", 1))
    title, subtitle = wrapped(u)
    col = column(u)

    sizes = {"eyebrow": 22 * u, "title": 96 * u, "subtitle": 36 * u, "footer": 18 * u}
    track = 3 * u
    block = block_units(len(title), len(subtitle), bool(eyebrow)) * u
    rule_y = h / 2 - block / 2 - 18 * u if landscape else my + 40 * u
    eyebrow_y = rule_y + (EYEBROW_DY * u if eyebrow else 0)
    title_y = eyebrow_y + (TITLE_DY if eyebrow else TITLE_DY_NO_EYEBROW) * u
    last_title = title_y + TITLE_LH * u * (len(title) - 1)
    sub_y = last_title + SUB_GAP * u
    text_bottom = sub_y + SUB_LH * u * (len(subtitle) - 1) if subtitle else last_title
    footer_y = h - FOOTER_FROM_BOTTOM * u if landscape else h - my

    art_size = art_cx = art_cy = 0
    if art and landscape:
        art_size = min(0.756 * h, 0.425 * w)
        art_cx, art_cy = 0.735 * w, h / 2
    elif art:
        top, bottom = text_bottom + 60 * u, footer_y - (50 * u if footer else 0)
        art_size = max(0, min(w - 2 * mx, bottom - top))
        art_cx, art_cy = w / 2, (top + bottom) / 2
        if art_size < 0.3 * w:
            warnings.append("little room left for art; shorten the text or use a taller canvas")

    for label, lines, size, kind, tr in (
        ("eyebrow", [eyebrow] if eyebrow else [], sizes["eyebrow"], "mono", track),
        ("title", title, sizes["title"], "serif", 0),
        ("subtitle", subtitle, sizes["subtitle"], "italic", 0),
    ):
        for line in lines:
            if text_width(line, size, kind, tr) > col * 1.02:
                warnings.append(f"{label} line may overflow its column: {line!r}")
    if footer and text_bottom > footer_y - 50 * u:
        warnings.append("text block runs into the footer; shorten the text")

    alt = spec.get("alt") or " — ".join(
        filter(None, [eyebrow, " ".join(title) + (": " + " ".join(subtitle) if subtitle else "")])
    )
    alt = escape(alt, {'"': "&quot;"})
    t = theme
    inset = 40 * u
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-label="{alt}">',
        f"  <title>{alt}</title>",
        "  <defs>",
        '    <filter id="grain" x="0" y="0" width="100%" height="100%">',
        '      <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" stitchTiles="stitch"/>',
        '      <feColorMatrix values="0 0 0 0 0.36  0 0 0 0 0.32  0 0 0 0 0.29  0 0 0 0.05 0"/>',
        "    </filter>",
        "  </defs>",
        f'  <rect width="{w}" height="{h}" fill="{t["bg"]}"/>',
    ]
    if spec.get("frame", True):
        parts.append(
            f'  <rect x="{inset:g}" y="{inset:g}" width="{w - 2 * inset:g}" height="{h - 2 * inset:g}" rx="{6 * u:g}" '
            f'fill="none" stroke="{t["frame"]}" stroke-opacity="{t["frame_opacity"]}" stroke-width="{2 * u:g}"/>'
        )
    if art:
        viewbox, inner = art
        if t["art_disc"]:
            parts.append(f'  <circle cx="{art_cx:g}" cy="{art_cy:g}" r="{art_size / 2:g}" fill="{t["art_disc"]}"/>')
        parts.append(
            f'  <svg x="{art_cx - art_size / 2:g}" y="{art_cy - art_size / 2:g}" width="{art_size:g}" height="{art_size:g}" '
            f'viewBox="{viewbox}" preserveAspectRatio="xMidYMid meet" overflow="visible">{inner}</svg>'
        )
    parts.append(
        f'  <path d="M{mx:g} {rule_y:g} H{mx + 56 * u:g}" stroke="{t["rule"]}" stroke-width="{3 * u:g}" stroke-linecap="round"/>'
    )
    if eyebrow:
        parts.append(
            f'  <text x="{mx:g}" y="{eyebrow_y:g}" font-family="{MONO}" font-size="{sizes["eyebrow"]:g}" '
            f'letter-spacing="{track:g}" fill="{t["label"]}">{escape(eyebrow)}</text>'
        )
    parts.append(
        f'  <text font-family="{SERIF}" font-size="{sizes["title"]:g}" letter-spacing="{-1.5 * u:g}" '
        f'fill="{t["title"]}">{tspans(title, mx, title_y, TITLE_LH * u)}</text>'
    )
    if subtitle:
        parts.append(
            f'  <text font-family="{SERIF}" font-style="italic" font-size="{sizes["subtitle"]:g}" '
            f'fill="{t["subtitle"]}">{tspans(subtitle, mx, sub_y, SUB_LH * u)}</text>'
        )
    if footer:
        parts.append(
            f'  <text x="{mx:g}" y="{footer_y:g}" font-family="{MONO}" font-size="{sizes["footer"]:g}" '
            f'letter-spacing="{track:g}" fill="{t["label"]}">{escape(footer)}</text>'
        )
    if spec.get("grain", True):
        parts.append(f'  <rect width="{w}" height="{h}" filter="url(#grain)"/>')
    parts.append("</svg>\n")
    return "\n".join(parts), warnings


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("spec", type=Path)
    ap.add_argument("--out-dir", type=Path, help="base folder for relative 'out' paths (default: the spec's folder)")
    ap.add_argument("--preview", type=Path, help="also render 800px-wide PNG previews here (needs rsvg-convert)")
    args = ap.parse_args()

    spec_dir = args.spec.resolve().parent
    data = json.loads(args.spec.read_text(encoding="utf-8"))
    defaults = data.get("defaults", {}) if "banners" in data else {}
    banners = data["banners"] if "banners" in data else [data]
    base = args.out_dir or spec_dir
    renderer = shutil.which("rsvg-convert") if args.preview else None
    if args.preview and not renderer:
        print("warning: rsvg-convert not found; skipping previews", file=sys.stderr)

    for item in banners:
        spec = {**defaults, **item}
        svg, warnings = build(spec, spec_dir)
        out = Path(spec["out"])
        out = out if out.is_absolute() else base / out
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(svg, encoding="utf-8")
        print(f"wrote {out}")
        for msg in warnings:
            print(f"  warning: {msg}", file=sys.stderr)
        if renderer:
            args.preview.mkdir(parents=True, exist_ok=True)
            png = args.preview / f"{out.stem}.png"
            subprocess.run([renderer, "-w", "800", str(out), "-o", str(png)], check=True)
            print(f"  preview {png}")


if __name__ == "__main__":
    main()
