class Sfb < Formula
  desc "Smart File Browser for macOS terminal with safe guardrails"
  homepage "https://github.com/henkas/homebrew-sfb"
  url "https://github.com/henkas/homebrew-sfb/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "8e6433a07e50d3e3570248e7e1567287177cadd18b547a7b855cdef74a6a758b"
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
