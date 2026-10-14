cask "herdnotch" do
  version "0.1.0"
  sha256 "8c102c735f766a99313433a1b8430b7a7d717adb02539196256414dee534b88c"

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

  # Quitting runs the app's own shutdown, which turns lid-closed mode back off before the rule is removed.
  uninstall quit:   "com.boringherd.HerdNotch",
            delete: "/etc/sudoers.d/herdnotch-lidsleep"

  zap trash: [
    "~/Library/Caches/com.boringherd.HerdNotch",
    "~/Library/Caches/HerdNotch",
    "~/Library/Preferences/com.boringherd.HerdNotch.plist",
  ]

  caveats <<~EOS
    HerdNotch is not notarized. If macOS refuses to open it, run:
      xattr -dr com.apple.quarantine "#{appdir}/HerdNotch.app"
  EOS
end
