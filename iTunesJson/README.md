iTunesJson is an Xcode wrapper for [itunes_json](https://github.com/bolsinga/itunes_json).

It is required so that macOS Sequoia will remember that the user has granted access to the Music Library between launches. It does this by giving it a bundle identifier and `NSAppleMusicUsageDescription` in an Info.plist.
