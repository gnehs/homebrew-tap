cask "subtitle-translator-electron" do
  version "1.8.0"
  sha256 "6201be4c33e933a8bdcd136989f1ad69d61a4fb1db015ae8d4a20631a3de49d0"

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
