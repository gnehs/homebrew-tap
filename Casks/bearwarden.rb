cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.11"
  sha256 arm:   "500ef753490784c0739454efe4ce74c7caa1bc48d5ae193481d11a9db1f271fa",
         intel: "8f3af97454b832e8bfc6087c9e2392263fe317e1c3a839472d9f4e2f99ba9b41"

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
