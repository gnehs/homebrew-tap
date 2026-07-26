cask "qwenasr-studio" do
  version "0.1.5"
  sha256 "4d825d9fae88769a75e3b01b0cc71ea24df0efaadccf1ee1bd11d416f4fcfe85"

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
