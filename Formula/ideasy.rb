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
  # repo.maven.apache.org is the canonical Maven Central host - it is the `central` repository of
  # Maven's own super POM. It serves the artifacts directly, without any redirect.
  #
  # Do not "simplify" this to repo1.maven.org: Homebrew's FormulaAudit/Urls cop matches
  # %r{https?://(?:central|repo\d+)\.maven\.org/maven2/(.+)$} and demands the legacy
  # search.maven.org/remotecontent redirector instead, failing `brew test-bot --only-tap-syntax`.
  # That cop cannot be silenced: `brew style` forces --config on Homebrew's own Library/.rubocop.yml
  # so a tap level .rubocop.yml is ignored, inline disable directives are rejected by
  # Style/DisableCopsWithinSourceCodeDirective, and a mirror is audited just like the url.
  # repo.maven.apache.org matches no cop pattern and is used the same way by the spotbugs, rhino
  # and allure formulae in homebrew-core.
  on_macos do
    on_arm do
      url "https://repo.maven.apache.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-arm64.tar.gz"
      sha256 "8ff84081202209163bb998e00ca8ac28c8888225f846cbd5ea852cf4419bd458"
    end
    on_intel do
      url "https://repo.maven.apache.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-mac-x64.tar.gz"
      sha256 "60969a02d1d26f4b08e4c540dbba347e72f572bd992918135fa1b81de18b951a"
    end
  end

  on_linux do
    on_arm do
      url "https://repo.maven.apache.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-linux-arm64.tar.gz"
      sha256 "dd34348f6d895ef5e99e3dfcbafd3db0e790163e025841ecf637710248296b62"
    end
    on_intel do
      url "https://repo.maven.apache.org/maven2/com/devonfw/tools/IDEasy/ide-cli/#{version}/ide-cli-#{version}-linux-x64.tar.gz"
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

    # Symlink the only executable of the release into Homebrew's bin.
    #
    # 'ide' and 'icd' are deliberately NOT linked here. They are shell functions defined in
    # 'functions' and registered in ~/.bashrc and ~/.zshrc by 'ideasy install'. They change the
    # directory of the calling shell and eval the project environment into it, which an
    # executable cannot do. Linking 'ide' as a binary would shadow nothing for users who ran the
    # setup, and silently drop the cd and all exported variables for users who did not.
    bin.install_symlink libexec/"bin/ideasy"
  end

  def caveats
    <<~EOS
      IDEasy has been installed. To get started:

        1. Run 'ideasy --version' to verify the installation
        2. Run 'ideasy install' to set up IDE_ROOT and register the IDEasy shell
           functions ('ide', 'icd') in ~/.bashrc and ~/.zshrc
        3. Open a new terminal (or run 'source ~/.bashrc'), then use 'ide create <project-name>'
        4. Visit https://github.com/devonfw/IDEasy/blob/main/documentation/setup.adoc
           for full documentation

      Only 'ideasy' is placed on your PATH. 'ide' and 'icd' are shell functions and become
      available after step 2, in newly started shells.
    EOS
  end

  test do
    # A first run prompts for the license agreement on stdin, which is fine for the interactive
    # use the caveats describe but hangs here with no stdin. ensureLicenseAgreement in
    # AbstractIdeContext treats the presence of ~/.ide/.license.agreement as prior acceptance and
    # skips the prompt unconditionally, so pre-creating it avoids the hang - flags and piped input
    # were both tried and did not.
    assert_match version.to_s,
                 shell_output("mkdir -p ~/.ide && touch ~/.ide/.license.agreement && #{bin}/ideasy --version 2>&1")
  end
end
