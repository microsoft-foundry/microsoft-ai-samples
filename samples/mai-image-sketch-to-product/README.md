# Sketch to campaign

This sample uses MAI Image 2.7 Flash and MAI Image 2.7 to turn sketches into
product concepts, campaign scenes and branded social posts. Images in
`examples` are reference examples only; new runs save their results in `outputs`.

## Model information

- [MAI Image 2.7 model card](https://ai.azure.com/catalog/models/MAI-Image-2.7)
- [MAI Image 2.7 Flash model card](https://ai.azure.com/catalog/models/MAI-Image-2.7-Flash)
- [MAI Image 2.7 on Microsoft AI](https://microsoft.ai/models/mai-image-2-7/)

## Get started

1. Copy `.env.example` to `.env` and set your Foundry resource endpoint and
   deployment names. The example endpoint is a placeholder, not a live resource.
2. Sign in with `az login` and select your subscription if needed.
3. Open `sketch-to-campaign-with-mai.ipynb`, choose a Python 3.10+ kernel and
   run its cells in order. The first code cell installs the required packages.
   Run from this folder or its parent. Pause to choose a concept before the
   campaign cells.

The supplied sketches produce 18 model images: 12 concepts, three campaign
scenes and three branded posts. API requests may incur charges. Check the
model-generated text and imagery before sharing.

Keep `.env`, notebook execution outputs and generated `outputs` out of your
repository. Do not copy credentials into this folder.
