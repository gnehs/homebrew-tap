cask "subtitle-translator-electron" do
  version "2.0.1"
  sha256 "ededf1c29780ffefe941b2b41ccf5db98b28346731d80e2d557cbbbc715cc2c5"

  url "https://github.com/gnehs/subtitle-translator-electron/releases/download/#{version}/subtitle-translator_#{version}.dmg"
  name "Subtitle Translator"
  desc "Translate subtitle files using OpenAI-compatible APIs"
  homepage "https://github.com/gnehs/subtitle-translator-electron"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "Subtitle Translator.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/Subtitle Translator.app"],
                   must_succeed: false
  end
end
