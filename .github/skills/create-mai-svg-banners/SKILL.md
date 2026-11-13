---
name: create-mai-svg-banners
description: Generate SVG banners, headers, covers, and thumbnails in a warm Microsoft AI-inspired palette, locally and without an image model. Takes a size, wording, and an illustration (preset or custom SVG), then writes a ready-to-commit SVG with exact text. Use for README or notebook banners, workshop headers, or any MAI-styled graphic that needs exact, editable text.
---

# create-mai-svg-banners

Build MAI-styled banners as hand-authored SVG. The text stays exact and editable, the
output is small and diff-friendly, and no image model, credentials, or network is needed.

Use the companion [create-mai-banners](../create-mai-banners/SKILL.md) skill instead
when you want an image-model prompt for painterly artwork. Both skills share its palette,
typography, and layout rules; this one turns them into code.

## What's here

| Path | Purpose |
| --- | --- |
| [scripts/make_banner.py](./scripts/make_banner.py) | Generator. Python standard library only |
| [art/](./art/) | Reusable illustrations, each a standalone 680 × 680 SVG |
| [examples/repo-readme.json](./examples/repo-readme.json) | Sample: the repository README banner, restyled. Output: [art/examples/repo-readme-banner.svg](./art/examples/repo-readme-banner.svg) |
| [examples/workshop-mai-multimodal-product-launch.json](./examples/workshop-mai-multimodal-product-launch.json) | The six workshop notebook banners |

## 1. Gather the brief

Use what the user already gave; ask only for what's missing:

- **Size:** width × height in pixels. Width ≥ height gives a side-by-side layout (text left,
  art right). Taller than wide gives a stacked layout (text on top, art below).
- **Wording:** any of eyebrow label, title, subtitle, and footer. Use the user's exact
  strings, capitalization, and punctuation. Don't invent slogans, labels, or endorsements.
- **Art:** a preset from [art/](./art/), a new illustration, or none.
- **Background:** `light` (parchment, the default) or `dark` (deep teal).

## 2. Write a spec

One banner, or a `defaults` object plus a `banners` list. Each banner merges over `defaults`.

| Field | Required | Notes |
| --- | --- | --- |
| `out` | yes | Output path, relative to `--out-dir` (default: the spec's folder) |
| `width`, `height` | yes | Pixels |
| `title` | yes | String (auto-wrapped) or list of lines (exact breaks) |
| `subtitle` | no | String or list of lines; set in italic serif |
| `eyebrow`, `footer` | no | Small monospace labels |
| `art` | no | Preset name (for example `tent-lake`) or a path to an `.svg` |
| `background` | no | `light` or `dark` |
| `alt` | no | Accessible label. Defaults to eyebrow, title, and subtitle |
| `scale` | no | Multiply the text size, for example `0.9` |
| `frame`, `grain` | no | Set `false` to drop the thin frame or the paper grain |

Prefer explicit line lists for final banners: auto-wrap uses a width *estimate* and can
leave a lone word on the last line.

## 3. Generate and check

Run from the repository root so `out` paths resolve against it:

```bash
python .github/skills/create-mai-svg-banners/scripts/make_banner.py SPEC.json --out-dir . --preview /tmp/banner-previews
```

`--preview` writes 800px-wide PNGs if `rsvg-convert` is installed
(`sudo apt-get install librsvg2-bin`). **Look at every preview before finishing.**
Treat each `warning:` line as a defect to fix: shorten text, break lines differently,
use a larger canvas, or lower `scale`.

When the banner replaces an existing image, keep the file name so links don't change,
and update the `alt` text wherever the image is embedded.

### Example: the repository README banner

[examples/repo-readme.json](./examples/repo-readme.json) restyles the README banner at its
original 1280 × 360, with the same wording. It writes a **sample** to
[art/examples/repo-readme-banner.svg](./art/examples/repo-readme-banner.svg) and does not
touch `assets/mai-developer-samples-banner.svg`:

```json
{
  "out": "../art/examples/repo-readme-banner.svg",
  "width": 1280,
  "height": 360,
  "background": "light",
  "art": "multimodal-samples",
  "eyebrow": "MICROSOFT AI (MAI)",
  "title": "Developer Samples",
  "subtitle": "Build with MAI models. Learn by doing.",
  "footer": "SCENARIOS - SAMPLES - WORKSHOPS",
  "alt": "Microsoft AI (MAI) Developer Samples — Build with MAI models. Learn by doing."
}
```

```bash
python .github/skills/create-mai-svg-banners/scripts/make_banner.py \
  .github/skills/create-mai-svg-banners/examples/repo-readme.json --preview /tmp/readme-banner
```

Without `--out-dir`, relative `out` paths resolve from the spec's folder.
`art/examples/` holds finished sample banners; only SVGs directly in `art/` are presets.

The text scales to the largest size that still clears the footer, so a short, wide
strip like this keeps a readable title.

## Palette and type

These come from the companion skill. They are a **Microsoft AI-inspired treatment**,
not an official brand specification.

| Role | Light | Dark |
| --- | --- | --- |
| Canvas | Parchment `#FEF9ED` | Deep teal `#2E4D4D` |
| Title | Walnut `#5D524B` | Parchment `#FEF9ED` |
| Subtitle | Cedar `#72675B` | Bone `#F5F0E4` |
| Labels | Cedar `#72675B` | Linen `#CEC7BC` |
| Frame | Linen `#CEC7BC` | Parchment at 30% |
| Accent rule | Faded rose `#8C5462` | Apricot `#FBD3BE` |

Illustrations may also use bone `#F5F0E4`, apricot `#FBD3BE`, and slate lilac `#666583`.
Stick to parchment, walnut, and teal plus one or two quiet accents. No neon,
saturated primaries, rainbow gradients, glossy 3D, or heavy shadows.

Type: titles use a Bradford LL-inspired serif stack (`Source Serif 4`, `Lora`, `Georgia`).
Subtitles use the same stack in italic. Labels use a Red Hat Mono-inspired monospace
stack. When an SVG is displayed through an `<img>` tag, as on GitHub and in notebooks,
it can't load web fonts, so readers see the first installed fallback, usually Georgia
and Menlo.

## Adding an illustration

Create `art/<name>.svg` as a standalone SVG with `viewBox="0 0 680 680"`. Use hex colors
from the palette directly, so the file previews on its own.

- Keep the subject inside a circle of radius about 320 around the center (340, 340).
  The generator scales the box to fit, and dark mode draws a parchment disc behind it.
- Flat layered shapes, 4px walnut outlines, fine linen detail lines, and an optional
  apricot backdrop circle (`r="250"` at 60% opacity) to match the presets.
- Give any `id` a unique prefix (for example `tent-lake-clip`). All art shares one document.
- Depict the actual subject; don't add robots, circuitry, or sci-fi UI unless asked.

Current presets: `tent-lake`, `image-formats`, `microphone`, `speech-to-transcript`,
`sketch-to-website`, `open-book`, `multimodal-samples`.
