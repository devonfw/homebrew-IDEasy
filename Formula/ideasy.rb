# typed: false
# frozen_string_literal: true

# ATTENTION: This file is generated from Formula/ideasy.rb.template by render-formula.sh.
# Do not edit Formula/ideasy.rb directly - your changes will be overwritten by the next
# release of devonfw/IDEasy. Edit the template instead.

# Homebrew formula for IDEasy - Development Environment Automation Tool
# Homepage: https://github.com/devonfw/IDEasy
# License: Apache-2.0

class Ideasy < Formula
  desc "Automate setup and updates of a development environment for any project"
  homepage "https://github.com/devonfw/IDEasy"
  version "2026.07.002"
  license "Apache-2.0"

  depends_on "bash"
  depends_on "git"

  # Platform-specific downloads from Maven Central.
  #
  # Homebrew's FormulaAudit/Urls requires the search.maven.org form for Maven Central artifacts, and
  # it cannot be overridden (a tap level .rubocop.yml is not picked up and inline directives are
  # rejected by Style/DisableCopsWithinSourceCodeDirective). The URLs redirect permanently to
  # repo1.maven.org, which is the host the release verifies availability against.
  on_macos do
    on_arm do
      url "https://search.maven.org/remotecontent?filepath=com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-arm64.tar.gz"
      sha256 "8ff84081202209163bb998e00ca8ac28c8888225f846cbd5ea852cf4419bd458"
    end
    on_intel do
      url "https://search.maven.org/remotecontent?filepath=com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-x64.tar.gz"
      sha256 "60969a02d1d26f4b08e4c540dbba347e72f572bd992918135fa1b81de18b951a"
    end
  end

  on_linux do
    on_arm do
      url "https://search.maven.org/remotecontent?filepath=com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-linux-arm64.tar.gz"
      sha256 "dd34348f6d895ef5e99e3dfcbafd3db0e790163e025841ecf637710248296b62"
    end
    on_intel do
      url "https://search.maven.org/remotecontent?filepath=com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-linux-x64.tar.gz"
      sha256 "f03c8a0b1b29223d5a259160b51b86bfbddd3bd7cbfd40e50d6d5a03ab807ebc"
    end
  end

  def install
    # The IDEasy archive contains:
    #   bin/ideasy   - the main CLI binary
    #   functions    - shell functions
    #   setup        - setup script
    #   internal/    - internal resources
    #   system/      - system-specific configs
    #   IDEasy.pdf   - documentation
    #   gui/         - files required for gui

    # Install everything into libexec to keep it self-contained
    libexec.install Dir["*"]

    # Make the binary executable
    chmod 0755, libexec/"bin/ideasy"

    # Symlink the actual binary (named 'ideasy') into Homebrew's bin
    bin.install_symlink libexec/"bin/ideasy"

    # Also create an 'ide' convenience alias pointing to the same binary
    bin.install_symlink libexec/"bin/ideasy" => "ide"
  end

  def caveats
    <<~EOS
      IDEasy has been installed. To get started:

        1. Run 'ideasy --version' to verify the installation
        2. Run 'ideasy create <project-name>' to set up a new project
        3. Visit https://github.com/devonfw/IDEasy/blob/main/documentation/setup.adoc
           for full documentation

      Both 'ideasy' and 'ide' commands are available on your PATH.

      Note: You may need to restart your terminal for the commands to be available.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ideasy --version 2>&1")
  end
end
