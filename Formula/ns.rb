# Homebrew Formula for the Notion CLI
# This script defines how Homebrew should download, install, and verify the package.
class Ns < Formula
  desc "Notion markdown sync CLI"
  homepage "https://github.com/thedwncmpy/notion-cli"
  url "https://github.com/thedwncmpy/notion-cli/archive/refs/tags/v0.1.30.tar.gz"
  sha256 "52d8ddcc6bd4a4b6f99d8519d6ec8c054b40f46d3d34986ec8e4d2abf15b93a5"
  license "MIT"

  head "https://github.com/thedwncmpy/notion-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Core dependencies required for the CLI to function
  depends_on "jq"
  depends_on "python@3.12"

  def install
    # 1. Install internal libraries to libexec (private to this formula)
    # This prevents the library files from cluttering the user's global PATH.
    libexec.install "lib"

    inreplace libexec/"lib/common.zsh", "__NS_VERSION__", version.to_s

    # 2. Rewrite launcher before install so the staged file is installed once.
    ns_src = buildpath/"bin/ns"
    ns_content = ns_src.read
    ns_content.gsub!('exec "$ZSH_BIN" "$SCRIPT_DIR/../lib/notion_cli.zsh" "$@"',
                     "exec \"$ZSH_BIN\" \"#{libexec}/lib/notion_cli.zsh\" \"$@\"")
    ns_content.gsub!('source "$SCRIPT_DIR/../lib/notion_cli.zsh"',
                     "source \"#{libexec}/lib/notion_cli.zsh\"")

    # 3. Install rewritten executable from a distinct staged file.
    # Using a different source filename avoids Homebrew treating this as
    # an overwrite of the original staged `bin/ns`.
    rewritten = buildpath/"ns-homebrew-launcher"
    rewritten.write(ns_content)
    bin.install rewritten => "ns"
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
