# Homebrew Formula for the Notion CLI
# This script defines how Homebrew should download, install, and verify the package.
class Ns < Formula
  desc "Notion markdown sync CLI"
  homepage "https://github.com/thedwncmpy/notion-cli"
  url "https://github.com/thedwncmpy/notion-cli/archive/refs/tags/v0.1.10.tar.gz"
  sha256 "2680b81ec1a5a4d6246bec6e0056d97cc011698a8013c1c38839566d41c53e4f"
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
    # The original script assumes a relative path to the 'lib' folder.
    # Since we moved 'lib' to libexec, we must update the script to point to the new absolute path.
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
