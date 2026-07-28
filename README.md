# Homebrew Tap for IDEasy

This is the official [Homebrew](https://brew.sh/) tap for [IDEasy](https://github.com/devonfw/IDEasy) — the tool to automate the setup and updates of
development environments for any project.

## Installation

```bash
# Add the tap
brew tap devonfw/ideasy

# Install IDEasy
brew install ideasy
```

Or install directly in one command:

```bash
brew install devonfw/ideasy/ideasy
```

## Updating

```bash
brew update
brew upgrade ideasy
```

## Uninstalling

```bash
brew uninstall ideasy
brew untap devonfw/ideasy
```

## About IDEasy
IDEasy is a Tool to automate the setup and updates of a development environment for any project

- **Repository:** <https://github.com/devonfw/IDEasy>
- **Documentation:** <https://github.com/devonfw/IDEasy/blob/main/documentation/setup.adoc>
- **License:** Apache-2.0

## Troubleshooting

If you encounter issues, please check the [IDEasy issue tracker](https://github.com/devonfw/IDEasy/issues) or open a new issue in this tap repository.

## Maintainer Notes

Homebrew is a primary distribution channel for IDEasy,
so this tap is updated **synchronously as part of the IDEasy release**.
The [release workflow](https://github.com/devonfw/IDEasy/blob/main/.github/workflows/release.yml) of IDEasy calls the `Publish formula` workflow of this repository with `uses:`, which renders, verifies and pushes the formula.
Because it is called rather than dispatched, a failure fails the IDEasy release — the tap can therefore not silently fall behind.

The publishing sequence exists **once**, in `.github/workflows/publish-formula.yml`, next to the formula and the scripts it renders.
The release decides *when* to publish, this workflow defines *how*, so there is nothing to keep in sync between the two repositories.

`Formula/ideasy.rb` is **generated** and must not be edited by hand.
Edit `Formula/ideasy.rb.template` instead; CI fails if the two drift apart.

### Scripts

| Script | Purpose |
| --- | --- |
| `render-formula.sh VERSION SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64` | Renders `Formula/ideasy.rb` from the template. Every argument is validated; a missing or malformed value aborts instead of producing an incomplete formula. |
| `wait-for-central.sh VERSION [SHA...]` | Waits until all release archives are downloadable from Maven Central and reports their checksums. With checksums passed in, it verifies that Central serves exactly the released bytes. |

### Publishing manually

The same workflow can be triggered manually (`workflow_dispatch`) for recovery,
i.e. catching up after the tap fell behind or re-publishing a version whose formula needs to be regenerated.
Provide the version to publish; without checksums passed in, they are taken from Maven Central.
This runs the identical render → verify → publish sequence the release uses.
