cask "subtitle-translator-electron" do
  version "2.1.0"
  sha256 "c477792f8440c1afb5f3b2368bb0d474d95ba3a8a4554528a0cea2f0b1dcca61"

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
