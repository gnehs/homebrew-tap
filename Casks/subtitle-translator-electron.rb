cask "subtitle-translator-electron" do
  version "2.0.0"
  sha256 "ea2df92f5167d0af56b454898ef79f2e13d5501e058fd2b847d2654146ce6620"

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
