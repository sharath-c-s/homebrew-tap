cask "herdnotch" do
  version "0.1.6"
  sha256 "46e7a508e2b54e8ba7ec401c3fc50ec1e242b374a10bfa744242b2d044e47e47"

  url "https://github.com/sharath-c-s/herdnotch/releases/download/v#{version}/HerdNotch-#{version}.zip"
  name "HerdNotch"
  desc "Notch app for AI coding agents, usage meters, keep awake and now playing"
  homepage "https://github.com/sharath-c-s/herdnotch"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "HerdNotch.app"

  # Not notarized: drop the download quarantine flag so macOS lets it open. Steps cannot interpolate
  # appdir, so a custom --appdir skips this; see caveats.
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "/Applications/HerdNotch.app"],
        must_succeed:   false,
        writable_paths: ["HerdNotch.app"],
        writable_base:  :appdir
  end

  # Quitting runs the app's own shutdown, which turns lid-closed mode back off. The lid-mode sudoers rule is
  # only removed on zap (or from the app's Settings), so upgrades never need a password.
  uninstall quit: "com.boringherd.HerdNotch"

  zap delete: "/etc/sudoers.d/herdnotch-lidsleep",
      trash:  [
        "~/Library/Caches/com.boringherd.HerdNotch",
        "~/Library/Caches/HerdNotch",
        "~/Library/Preferences/com.boringherd.HerdNotch.plist",
      ]

  caveats <<~EOS
    HerdNotch is not notarized. If macOS refuses to open it, run:
      xattr -dr com.apple.quarantine "#{appdir}/HerdNotch.app"
  EOS
end
