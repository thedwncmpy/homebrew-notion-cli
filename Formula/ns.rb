# Homebrew Formula for the Notion CLI
# This script defines how Homebrew should download, install, and verify the package.
class Ns < Formula
  desc "Notion markdown sync CLI"
  homepage "https://github.com/thedwncmpy/notion-cli"
  url "https://github.com/thedwncmpy/notion-cli/archive/refs/tags/v0.1.12.tar.gz"
  sha256 "b608f26f9bff98bfda371bf3debc1ca5214362f339d2ab5b015d23db38e52802"
  license "MIT"

  # Core dependencies required for the CLI to function
  depends_on "jq"
  depends_on "python@3.12"

  def install
    # 1. Install internal libraries to libexec (private to this formula)
    # This prevents the library files from cluttering the user's global PATH.
    libexec.install "lib"

    # 2. Install the main executable to the standard bin directory
    bin.install "bin/ns"

    # 3. Fix the internal path resolution.
    # Current launcher executes the zsh script directly; older versions sourced it.
    # Keep both replacements for compatibility so packaging doesn't break across tags.
    inreplace bin/"ns",
              'exec "$ZSH_BIN" "$SCRIPT_DIR/../lib/notion_cli.zsh" "$@"',
              "exec \"$ZSH_BIN\" \"#{libexec}/lib/notion_cli.zsh\" \"$@\""
    inreplace bin/"ns", 'source "$SCRIPT_DIR/../lib/notion_cli.zsh"',
                             "source \"#{libexec}/lib/notion_cli.zsh\""
  end


  def caveats
    <<~EOS
      Enable shell completion:
        zsh (~/.zshrc): eval "$(ns completion zsh)"
        bash (~/.bashrc): eval "$(ns completion bash)"
    EOS
  end

  # A simple check to ensure the binary is installed correctly and runs
  test do
    assert_match "Usage: ns <command>", shell_output("#{bin}/ns help")
  end
end
