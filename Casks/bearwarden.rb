cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.16"
  sha256 arm:   "1d90c6b417a3272333ccf359f7f6a03e67a0d3baf931ada46f18c0c07720e3cc",
         intel: "187e364fff4a5adbe83a40edaf94a0c5465bb01b53864eeab152bebba7730594"

  url "https://github.com/gnehs/BearWarden/releases/download/#{version}/bearwarden-#{version}-#{arch}.dmg",
      verified: "github.com/gnehs/BearWarden/"
  name "BearWarden"
  desc "Experimental local-first desktop password manager"
  homepage "https://github.com/gnehs/BearWarden"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: :tahoe

  app "BearWarden.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/BearWarden.app"],
                   must_succeed: false
  end
end
