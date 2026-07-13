# gnehs Homebrew Tap

Homebrew Casks for macOS desktop applications maintained by [gnehs](https://github.com/gnehs).

## Install

```sh
brew install --cask gnehs/tap/subtitle-translator-electron
brew install --cask gnehs/tap/qwenasr-studio
brew install --cask gnehs/tap/moss-transcribe-studio
```

QwenASR Studio and MOSS Transcribe Studio require macOS Sonoma or later, an Apple Silicon (`arm64`) Mac, and install `ffmpeg` as a dependency. Subtitle Translator requires macOS Monterey or later.

## Upgrade

```sh
brew update
brew upgrade
```

To upgrade one cask:

```sh
brew upgrade --cask subtitle-translator-electron
brew upgrade --cask qwenasr-studio
brew upgrade --cask moss-transcribe-studio
```

## Uninstall

```sh
brew uninstall --cask subtitle-translator-electron
brew uninstall --cask qwenasr-studio
brew uninstall --cask moss-transcribe-studio
```

The QwenASR Studio and MOSS Transcribe Studio uninstalls do not remove the shared `ffmpeg` formula automatically. Remove it separately only if no other application needs it:

```sh
brew uninstall ffmpeg
```

## Limitations and security notice

- QwenASR Studio and MOSS Transcribe Studio are Apple Silicon-only and require macOS Sonoma or later.
- QwenASR Studio and MOSS Transcribe Studio install the `ffmpeg` formula automatically through Homebrew.
- The applications are distributed from their upstream GitHub Release DMG files. This tap pins each download to a SHA256 checksum for the listed release.
- All three Casks remove only `com.apple.quarantine` after installation or upgrade. The upstream applications are not currently notarized by Apple; this tap does not claim that they are signed or notarized.
- Removing quarantine does not guarantee launch: macOS security checks may still require user approval or prevent launch. Review the upstream source and release before installing.
- This tap does not provide support for upstream application bugs, model files, or third-party service configuration.
