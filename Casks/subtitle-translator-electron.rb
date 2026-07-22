cask "subtitle-translator-electron" do
  version "2.0.2"
  sha256 "0fcca4c37289b11866c451ed1124d4bacb0ab6eda6d11ea8e097f5f272a1cc28"

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
