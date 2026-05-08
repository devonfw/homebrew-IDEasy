# typed: false
# frozen_string_literal: true

# Homebrew formula for IDEasy - Development Environment Automation Tool
# Homepage: https://github.com/devonfw/IDEasy
# License: Apache-2.0

class Ideasy < Formula
  desc "Tool to automate the setup and updates of a development environment for any project"
  homepage "https://github.com/devonfw/IDEasy"
  license "Apache-2.0"
  version "2026.04.002"

  # Platform-specific downloads from Maven Central
  on_macos do
    on_arm do
      url "https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-arm64.tar.gz"
      sha256 "c252864ce597cf0a0f23578a37cc4c2fd086974ae847c025289811c849f69bb8"
    end
    on_intel do
      url "https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-x64.tar.gz"
      sha256 "91453d7314c39db60b0e45772755e6c288e205d2661fc1b5999e77c02653a104"
    end
  end

  on_linux do
    on_intel do
      url "https://repo1.maven.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-linux-x64.tar.gz"
      sha256 "5c7102b7a0405a03dd04cd1b92ef1007af41f5499af01cc0167d2b974c2b568b"
    end
  end

  depends_on "git"
  depends_on "bash"

  def install
    # The IDEasy archive contains:
    #   bin/ideasy   - the main CLI binary
    #   functions    - shell functions
    #   setup        - setup script
    #   internal/    - internal resources
    #   system/      - system-specific configs
    #   IDEasy.pdf   - documentation

    # Install everything into libexec to keep it self-contained
    libexec.install Dir["*"]

    # Make the binary executable
    chmod 0755, libexec/"bin/ideasy"

    # Symlink the actual binary (named 'ideasy') into Homebrew's bin
    bin.install_symlink libexec/"bin/ideasy"

    # Also create an 'ide' convenience alias pointing to the same binary
    ln_s libexec/"bin/ideasy", bin/"ide"
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
