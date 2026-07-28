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
The [release workflow](https://github.com/devonfw/IDEasy/blob/main/.github/workflows/release.yml) of IDEasy renders, verifies and pushes the formula itself.
If any of that fails, the IDEasy release fails — the tap can therefore not silently fall behind.

`Formula/ideasy.rb` is **generated** and must not be edited by hand.
Edit `Formula/ideasy.rb.template` instead; CI fails if the two drift apart.

### Scripts

| Script | Purpose |
| --- | --- |
| `render-formula.sh VERSION SHA_MAC_ARM64 SHA_MAC_X64 SHA_LINUX_ARM64 SHA_LINUX_X64` | Renders `Formula/ideasy.rb` from the template. Every argument is validated; a missing or malformed value aborts instead of producing an incomplete formula. |
| `wait-for-central.sh VERSION [SHA...]` | Waits until all release archives are downloadable from Maven Central and reports their checksums. With checksums passed in, it verifies that Central serves exactly the released bytes. |

### Publishing manually

For catching up or re-publishing a version outside of a release,
run the **Publish formula** workflow (`workflow_dispatch`) with the version to publish.
It performs the same render → verify → publish sequence,
sourcing the checksums from Maven Central.
