cask "moss-transcribe-studio" do
  version "0.1.1"
  sha256 "ca3e771695b57cc5ab71666bdb37b73078ed40cdd2ec53b4f916b198ff441ea0"

  url "https://github.com/gnehs/moss-transcribe-tauri/releases/download/0.1.1/MOSS.Transcribe.Studio_0.1.1_aarch64.dmg"
  name "MOSS Transcribe Studio"
  desc "Local long-form transcription app with timestamps and speaker diarization"
  homepage "https://github.com/gnehs/moss-transcribe-tauri"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on formula: "ffmpeg"
  depends_on macos: :sonoma

  app "MOSS Transcribe Studio.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/MOSS Transcribe Studio.app"],
        must_succeed: false
  end
end
