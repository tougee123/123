# CI build

This workflow builds an unsigned IPA with a minimum deployment target of iOS 12.

Files:

- `.github/workflows/build-ios12-ipa.yml`
- `ci/build_unsigned_ios12.sh`

How it works:

1. Runs on `macos-14`
2. Selects `Xcode 15.4`
3. Uses `CmdCode_20260317/` if that directory exists
4. Otherwise unzips `CmdCode_20260317_fixed.zip`
5. Runs `pod install`
6. Archives without signing
7. Uploads the IPA and `.xcarchive` as artifacts

Artifacts:

- `CmdCode-ios12-unsigned-ipa`
- `CmdCode-ios12-xcarchive`
