cask "qwenasr-studio" do
  version "0.1.2"
  sha256 "f3d26d63fd3ccda933037eb09b29a22309fb1cee799dbc3e44485677e8a5e5c9"

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
