---
kind: scenario
slug: mai-image-family-walkthrough
title: "MAI-Image-2.5 family walkthrough"
summary: "Compare MAI-Image-2.5, Flash, and Pro on identical prompts"
last_updated: "2026-08-12"
scope: publisher
publisher: microsoft-ai
models:
  - publisher: microsoft-ai
    model: mai-image-2.5-flash
    role: "Fast concurrent generation — resale listing backgrounds and mood boards"
  - publisher: microsoft-ai
    model: mai-image-2.5
    role: "Image editing and before/after comparisons"
  - publisher: microsoft-ai
    model: mai-image-2.5-pro
    role: "Text-to-image and character-consistency evaluation"
capabilities: [image-generation]
dependencies: [requests, python-dotenv, pillow, ipywidgets]
domains: [e-commerce, marketing, creative-media]
notebooks:
  - path: mai-image-family-walkthrough.ipynb
    title: "Compare MAI-Image-2.5, Flash, and Pro side by side"
    concepts:
      - choosing between family variants for a task
      - concurrent generation with shared helpers
      - editing and character consistency
---

# MAI-Image-2.5 Publisher — Scenario

> Originally created by [Nitya Narasimhan](https://github.com/nitya) in [nitya/model-releases](https://github.com/nitya/model-releases/tree/e2d0f011d2f735ae018cfbd61a43393e0b992380/models/microsoft-ai/multi-model-scenarios/mai-image-family-walkthrough). Setup steps that mention `scripts/` or the quickstart use [that repo's setup scripts](https://github.com/nitya/model-releases/tree/e2d0f011d2f735ae018cfbd61a43393e0b992380/scripts); you can also create the Foundry deployments in the portal and fill in `.env` from `.env.example`.

**Publisher:** [Microsoft AI](https://github.com/nitya/model-releases/blob/e2d0f011d2f735ae018cfbd61a43393e0b992380/models/microsoft-ai/README.md) · **Capability:** Image Generation

The three MAI-Image-2.5 variants overlap enough that picking one is a real decision. This scenario runs all three against realistic tasks in a single notebook, so you can see where the differences actually show up.

## Before You Begin

| Detail | Value |
|---|---|
| Capsules covered | [MAI-Image-2.5](../mai-image-generate-and-edit/) · [MAI-Image-2.5-Flash](../mai-image-flash-batch-generation/) · [MAI-Image-2.5-Pro](../mai-image-pro-portraits-and-text/) |
| Deployments needed | All three, in the same Foundry project |

See [models/quickstart/](https://github.com/nitya/model-releases/blob/e2d0f011d2f735ae018cfbd61a43393e0b992380/models/quickstart/README.md) for first-time Foundry project setup.

**Required env variables:**

```
MICROSOFT_FOUNDRY_ENDPOINT             # e.g. https://<resource>.services.ai.azure.com
MICROSOFT_FOUNDRY_API_KEY              # AIServices API key
AZURE_MAI_IMAGE_25_DEPLOYMENT          # your MAI-Image-2.5 deployment name
AZURE_MAI_IMAGE_25_FLASH_DEPLOYMENT    # your MAI-Image-2.5-Flash deployment name
AZURE_MAI_IMAGE_25_PRO_DEPLOYMENT      # your MAI-Image-2.5-Pro deployment name
```

## Notebook

| Notebook | Concepts |
|---|---|
| [mai-image-family-walkthrough.ipynb](mai-image-family-walkthrough.ipynb) | Choosing a variant · Concurrent generation · Editing and character consistency |

Cells run top to bottom — the credential and helper cells set up state that every later section reuses.

## What each variant covers

| Variant | In this notebook |
|---|---|
| **Flash** | Six resale-listing backgrounds and six mood boards, generated concurrently — the throughput case |
| **Base** | Image editing with a static before/after showcase — the iteration case |
| **Pro** | Text-to-image with a character-consistency evaluation — the fidelity case |

## Next steps

Each variant has its own capsule with a deeper single-model notebook — start with [MAI-Image-2.5](../mai-image-generate-and-edit/) for the baseline generation and editing APIs.
