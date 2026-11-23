![Microsoft AI (MAI) Developer Samples — Build with MAI models. Learn by doing.](.github/skills/create-mai-svg-banners/art/examples/repo-readme-banner.svg)

<p align="center">
  <a href="https://microsoft.ai/models/mai-image-2-7/"><img src="https://img.shields.io/badge/MAI_Image-2.7-F06B5C?style=flat-square" alt="MAI Image 2.7" /></a>&nbsp;&nbsp;
  <a href="https://microsoft.ai/models/mai-voice-2/"><img src="https://img.shields.io/badge/MAI_Voice-2.1-5FA463?style=flat-square" alt="MAI Voice 2.1" /></a>&nbsp;&nbsp;
  <a href="https://microsoft.ai/models/mai-transcribe-2/"><img src="https://img.shields.io/badge/MAI_Transcribe-2-9B7FD4?style=flat-square" alt="MAI Transcribe 2" /></a>&nbsp;&nbsp;
  <a href="https://microsoft.ai/models/mai-realtime-1/"><img src="https://img.shields.io/badge/MAI_Realtime-1-3FB8AF?style=flat-square" alt="MAI Realtime 1" /></a>&nbsp;&nbsp;
  <a href="https://microsoft.ai/models/mai-code-2/"><img src="https://img.shields.io/badge/MAI_Code-2-72A7FF?style=flat-square" alt="MAI Code 2" /></a>&nbsp;&nbsp;
  <a href="https://microsoft.ai/models/mai-cyber-2-flash/"><img src="https://img.shields.io/badge/MAI_Cyber-2_Flash-E8A0BF?style=flat-square" alt="MAI Cyber 2 Flash" /></a>&nbsp;&nbsp;
  <a href="https://microsoft.ai/models/mai-thinking-1/"><img src="https://img.shields.io/badge/MAI_Thinking-1-F2B33D?style=flat-square" alt="MAI Thinking 1" /></a>
</p>

---

# Microsoft AI (MAI) Developer Samples

Code samples and reusable assets to help you build with **Microsoft AI (MAI) models**.

Explore practical developer scenarios through runnable code, notebooks, and hands-on workshops. Each sample calls a MAI model deployment to demonstrate model capabilities, with step-by-step setup instructions you can follow, learn from, and adapt for your own projects.

## Featured samples and workshops

| Type | Name | What you'll build | MAI models |
| --- | --- | --- | --- |
| Sample | [Sketch to campaign](samples/mai-image-sketch-to-product/) | Product concepts, campaign scenes and branded social posts generated from sketches | MAI Image 2.7 Flash, MAI Image 2.7 |
| Workshop | [Multimodal Product Launch](workshops/mai-multimodal-product-launch/) | A launch kit for a retail product: posters and ads, a radio spot, checked transcripts, and a new storefront | MAI-Image-2.6, MAI Voice 2.1, MAI Transcribe 2, MAI Code Flash |
| Sample | [Text to speech with MAI-Voice](samples/mai-voice-text-to-speech/) | A podcast opening generated from a script, with voices, speaking styles and SSML | MAI Voice 2.1, MAI Voice 2.1 Flash |
| Sample | [Speech to text with MAI-Transcribe](samples/mai-transcribe-speech-to-text/) | A podcast transcript with speaker diarization, word timestamps and keyword hints | MAI Transcribe 2 |
| Sample | [Multi-model podcast studio](samples/multi-model-podcast-studio/) | Narrated, source-checked decks and podcasts generated from model release announcements | MAI Voice 2.1, MAI-Image-2.6, MAI-Image-2.6-Flash, MAI Transcribe 2 (+ Microsoft-Decision-1, GPT-6 Sol) |
| Dataset | [Contoso Retail](data/contoso-retail/) | Shared product catalog (20 products, manuals, photos) for retail scenarios | — |

Find the rest of the catalog in [`samples/`](samples/), [`workshops/`](workshops/), and [`data/`](data/). More notebooks and workshops will be added as they become available.

## Repository structure

Content is organized into three top-level locations:

```text
.
├── workshops/   # End-to-end workshops
├── samples/     # Notebook samples
└── data/        # Scenario-specific data
```

| Folder | What it contains | Status |
| --- | --- | --- |
| [`workshops/`](workshops/) | End-to-end, hands-on learning paths that take you from setup to a working solution, with guided exercises. Each workshop lives in its own subfolder with a README, `requirements.txt` and `infra/` for its Azure resources. | 1 workshop |
| [`samples/`](samples/) | Self-contained Jupyter notebooks for exploring MAI models and focused, practical use cases. | 10 samples |
| [`data/`](data/) | Sample datasets and input files used by specific scenarios. Data is grouped by scenario so workshops and notebooks can share it. | 1 dataset |

The [`assets/`](assets/) folder holds images and other files used by repository documentation. The [`.devcontainer/`](.devcontainer/) sets up Python, Node.js, the Azure CLI and the Azure Developer CLI, and installs every workshop's requirements into a shared `.venv`.

## Access MAI models

**Use MAI in your coding workflow through GitHub Copilot, or integrate MAI into your application through Microsoft Foundry, Azure Speech, or OpenRouter.**

| Developer goal | Where | How to access |
| --- | --- | --- |
| Code with MAI | [GitHub Copilot](https://docs.github.com/en/copilot/reference/ai-models/supported-models) | Select an available MAI coding model ([MAI Code 2](https://microsoft.ai/pdf/MAI-Code-2-And-MAI-Code-2-Flash-Model-Card.pdf) or [MAI Code 2 Flash](https://microsoft.ai/pdf/MAI-Code-2-And-MAI-Code-2-Flash-Model-Card.pdf)) in Copilot's model picker. Availability depends on your plan, Copilot surface, and organization policies. |
| Build an app on Azure | [Microsoft Foundry](https://ai.azure.com/) / [Azure Speech](https://learn.microsoft.com/azure/ai-services/speech-service/mai-voices) | Use your Azure subscription to set up a supported model or service, authenticate, and call its API. Start with the [reasoning](https://learn.microsoft.com/azure/foundry/foundry-models/how-to/use-foundry-models-mai-thinking), [image](https://learn.microsoft.com/azure/foundry/foundry-models/how-to/use-foundry-models-mai-image), or [voice](https://learn.microsoft.com/azure/ai-services/speech-service/mai-voices) guide. |
| Build an app through a unified third-party API | [OpenRouter](https://openrouter.ai/microsoft/) | Create an OpenRouter API key, choose a listed MAI model ID, and follow that model's API guide. |

> Model availability, pricing, and data-handling terms vary by platform. **Copilot access does not provide an API key for your application**, and not every MAI model is available on every platform. Check the linked documentation for current models, regions, preview restrictions, and any additional access requirements.

## Getting started

1. **Open the repo in GitHub Codespaces or a VS Code dev container** to get every tool preinstalled.
2. **Choose a notebook in [`samples/`](samples/) or a workshop in [`workshops/`](workshops/)** that matches what you want to build.
3. **Follow its README** to install prerequisites and dependencies.
4. **Configure model access** using your own credentials and the environment variables documented by that sample.
5. **Run, explore, and adapt** the code for your own project.

Requirements, supported models, endpoint configuration, and environment variable names will be documented per sample. Access to a model deployment is required; any usage charges depend on your endpoint provider and account.

## Model access and credentials

Samples connect to MAI model deployments through publicly available endpoints. You supply your own credentials through environment variables.

- Never put credentials directly in source code or notebooks.
- Never commit secrets, local credential files, or notebook outputs containing sensitive information.
- Use only data you are authorized to send to your configured model endpoint.

This repository contains **sample code and documentation only**. It does not include model weights, customer data, internal source code, or secrets.

## Resources

- Additional Foundry Model Samples: [https://github.com/microsoft-foundry/model-releases](https://github.com/microsoft-foundry/model-releases)
- MAI in the Microsoft Ignite Keynote: [Watch the keynote segment](https://www.youtube.com/watch?v=ZR4v1c4CClc&t=5697s)
- MAI Model Release Blog Thread: [Read the thread](https://x.com/MicrosoftAI/status/2122778863235178806)


## Project status

This repository is under active preparation. The sample catalog and contribution guidance will grow as content is published.

## Maintainers

Maintained by **Microsoft Developer Relations** in partnership with the **Microsoft AI (MAI) team**, and hosted in the [Microsoft Foundry GitHub organization](https://github.com/microsoft-foundry).

## Support and community

See [Support](SUPPORT.md) for sample issues and help. Report security vulnerabilities privately using the instructions in [Security](SECURITY.md), not through public issues.

This project has adopted the [Microsoft Open Source Code of Conduct](CODE_OF_CONDUCT.md).

## License

The sample code and documentation in this repository are licensed under the [MIT License](LICENSE). The license does not grant access to MAI models or change the terms of your configured model endpoint.
