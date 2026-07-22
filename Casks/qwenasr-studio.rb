cask "qwenasr-studio" do
  version "0.1.4"
  sha256 "720d21e083ea7f1ae8ebf83aacb6ff2232da6214f5b496df5212d7be5e674b63"

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
