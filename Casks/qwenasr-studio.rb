cask "qwenasr-studio" do
  version "0.1.3"
  sha256 "51b15d04ce28d0f32e678ac814d82ed946764465379012772f10bc14e725b231"

  url "https://github.com/gnehs/QwenASR-tauri/releases/download/#{version}/QwenASR.Studio_#{version}_aarch64.dmg",
      verified: "github.com/gnehs/QwenASR-tauri/"
  name "QwenASR Studio"
  desc "Local speech-to-text desktop app powered by Qwen3-ASR"
  homepage "https://github.com/gnehs/QwenASR-tauri"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: :sonoma
  depends_on arch: :arm64
  depends_on formula: "ffmpeg"

  app "QwenASR Studio.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/QwenASR Studio.app"],
                   must_succeed: false
  end
end
