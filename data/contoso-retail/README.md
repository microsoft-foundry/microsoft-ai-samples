# Contoso Retail dataset

A small, reusable product catalog for **Contoso Outdoors**, a made-up retailer of camping and hiking gear. Workshops and samples in this repository reference it directly, so the same products, manuals and photos show up everywhere.

| What | Count | Size |
| --- | --- | --- |
| Products | 20 (5 categories × 4) | `products.json` |
| Product manuals | 20 Markdown files | `manuals/` |
| Product photos | 102 WebP images, 800 × 800 | `images/` (~10 MB) |
| Customer avatar | 1 WebP image | `people/` |

<br/>

## Layout

```text
contoso-retail/
├── products.json            # The catalog. One record per product
├── manuals/<slug>.md        # Product manual: features, specs, user guide, warranty, reviews
├── images/<slug>/NN.webp    # Product photos, 01.webp first
├── people/sarah-lee.webp    # Customer avatar
└── build.py                 # Rebuilds everything here from upstream, then validates it
```

Each record in `products.json` looks like this. Paths are relative to this folder:

```json
{
  "id": 1,
  "slug": "trailmaster-x4-tent",
  "name": "TrailMaster X4 Tent",
  "price": 250.0,
  "category": "Tents",
  "brand": "OutdoorLiving",
  "description": "Unveiling the TrailMaster X4 Tent from OutdoorLiving, ...",
  "manual": "manuals/trailmaster-x4-tent.md",
  "images": ["images/trailmaster-x4-tent/01.webp", "..."]
}
```

<br/>

## Use it

From a notebook or script anywhere in the repo:

```python
import json
from pathlib import Path

DATA = next(p for p in (Path.cwd(), *Path.cwd().parents) if (p / "data" / "contoso-retail").is_dir()) / "data" / "contoso-retail"
products = json.loads((DATA / "products.json").read_text(encoding="utf-8"))
tent = next(p for p in products if p["slug"] == "trailmaster-x4-tent")
manual = (DATA / tent["manual"]).read_text(encoding="utf-8")
```

<br/>

## Provenance

| | |
| --- | --- |
| **Source** | [Azure-Samples/contoso-web](https://github.com/Azure-Samples/contoso-web) (archived) |
| **Commit** | [`e13b0d3`](https://github.com/Azure-Samples/contoso-web/tree/e13b0d346bdc0f2139552df6b9268cbe71b5b644) (2024-03-12) |
| **License** | MIT, Copyright (c) Microsoft Corporation |
| **Files used** | `public/products.json`, `public/manuals/product_info_{1..20}.md`, `public/images/{1..20}/*.png`, `public/people/sarahlee.jpg` |
| **Not copied** | `brands.json`, `categories.json` (web-app navigation data), hero banners, screenshots |

**Every change from upstream** (all made by [`build.py`](build.py)):

| Change | Why |
| --- | --- |
| Images resized from 1024 px PNG to 800 px WebP (quality 80): 312 MB → ~10 MB | Keeps the repo light |
| Files renamed by product slug (`product_info_1.md` → `trailmaster-x4-tent.md`; UUID image names → `01.webp`…) | Readable, stable paths |
| 7 chat-style lines removed from 6 manuals (e.g. *"Certainly! Here's a sample warranty information…"*) | Leftovers from the generator that wrote the manuals |
| Trailing whitespace trimmed in manuals | Clean diffs |
| `sarahlee.jpg` converted to `people/sarah-lee.webp` | Same format as the other images |
| `products.json` fields renamed (`manual`, `images` now relative paths) | Paths resolve from this folder |

Names, prices, brands, categories, descriptions and all other manual text are unchanged.

<br/>

## Known quirks (kept on purpose)

The manuals were machine-generated, so they're imperfect in ways real product documentation is too. These are **left in**, because they make good teaching moments:

| Quirk | Example |
| --- | --- |
| A manual contradicts itself | `trailmaster-x4-tent.md` says *"Water-resistant construction to withstand light rain"* and, a few lines later, *"Waterproof: Yes"* |
| Reviews make stronger claims than the specs | A TrailMaster X4 review says the tent kept them dry in *heavy* rain |
| Contact details look real but aren't | Phone numbers, emails and websites in the warranty sections are made up |

When sources disagree, the safe choice is the weaker claim.

<br/>

## Rebuild or check it

```bash
.venv/bin/python data/contoso-retail/build.py --check   # validate the committed data
.venv/bin/python data/contoso-retail/build.py           # rebuild from the pinned upstream commit (needs Pillow)
```

`--check` confirms every manual matches `products.json` on name, price, brand and category, that no chat-style leftovers remain, and that every image exists.

Contoso Outdoors and its products, people and reviews are fictitious. Any resemblance to real companies or products is coincidental.
