class Sfb < Formula
  desc "Smart File Browser for macOS terminal with safe guardrails"
  homepage "https://github.com/henkas/sfb"
  url "https://github.com/henkas/sfb/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "981b13483c844cae2d8d1e440a18b6d6d4ba69e2c7f432078ca1d2b03d210bee"
  license "MIT"

  depends_on "fzf"
  depends_on "trash"

  def install
    bin.install "bin/sfb"
    lib.install Dir["lib/*.sh"]
    bash_completion.install "completions/sfb.bash" => "sfb"
    zsh_completion.install "completions/_sfb"
    prefix.install "README.md"
  end

  test do
    assert_match "Smart File Browser", shell_output("#{bin}/sfb help")
  end
end
