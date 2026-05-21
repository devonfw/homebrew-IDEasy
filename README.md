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

The formula is updated automatically via a GitHub Actions workflow that checks for new releases daily. To manually update:

```bash
./update-formula.sh [VERSION]
```
