# Homebrew Formula for the Notion CLI
# This script defines how Homebrew should download, install, and verify the package.
class Ns < Formula
  desc "Notion markdown sync CLI"
  homepage "https://github.com/thedwncmpy/notion-cli"
  url "https://github.com/thedwncmpy/notion-cli/archive/refs/tags/v0.1.8.tar.gz"
  sha256 "ae10372214a9e9bc4bc34024ce204b91e0f4098d0b70cb6a5507d2b0447b243e"
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
      Enable zsh completion by adding this line to your ~/.zshrc:
        eval "$(ns completion zsh)"
    EOS
  end

  # A simple check to ensure the binary is installed correctly and runs
  test do
    assert_match "Usage: ns <command>", shell_output("#{bin}/ns help")
  end
end
