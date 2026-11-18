# Contributing to Microsoft AI (MAI) Developer Samples

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

## Code of conduct

Help us keep this project open and inclusive. Please read and follow our
[Code of Conduct](CODE_OF_CONDUCT.md).

## Issues and feature requests

Search existing [issues](https://github.com/microsoft-foundry/microsoft-ai-samples/issues)
and [pull requests](https://github.com/microsoft-foundry/microsoft-ai-samples/pulls)
before opening a new one.

For bugs, include the sample or workshop path, steps to reproduce, expected and actual behavior,
runtime and dependency versions, and relevant error messages. Remove credentials and sensitive
information from logs and screenshots. See [SUPPORT.md](SUPPORT.md) for help.

For substantial new samples or features, open an issue to discuss the proposal before implementation.
Small fixes can be submitted directly as pull requests.

**Do not report security vulnerabilities in public issues or pull requests.**
Follow [SECURITY.md](SECURITY.md) to report them privately.

## Preparing a contribution

1. Fork the repository and create a branch for your changes.
2. Follow the [getting started instructions](README.md#getting-started) and the README for the
   affected sample or workshop. The dev container provides a shared Python environment and tools.
3. Keep changes focused and follow the existing structure and coding conventions. Put standalone
   samples in `samples/`, workshops in `workshops/`, and reusable scenario data in `data/`.
4. Update related documentation, prerequisites, dependency files, and `.env.example` files when
   configuration or behavior changes.
5. Run the affected tests or build where available, and verify changed notebook cells with your
   own authorized model access. Model calls may incur charges.
6. Clear notebook outputs and execution counts before committing. Do not commit credentials,
   local environment files, private recordings, consent recordings, personal voice profile IDs,
   or sensitive generated content.

Only contribute code, data, and media you have the right to share. Preserve applicable upstream
copyright notices, licenses, and attribution, and document the provenance of reused material.
Use only data you are authorized to send to a model endpoint.

## Submitting a pull request

Commit your changes with a descriptive message, push your branch to your fork, and open a pull
request against `main`. Describe the change, link any related issue, and explain how you verified
it. State any validation you could not perform, such as calls requiring a gated model.

Follow the CLA bot's instructions and respond to maintainer feedback. Contributions are reviewed
for correctness, clarity, documentation, and suitability for developer learning.
