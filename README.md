# Phoenix JB 1.0

Phoenix JB is a SwiftUI preview app for managing jailbreak-related resources.

## Included in 1.0
- Dark SwiftUI interface.
- Device and iOS version display.
- Sileo / Zebra preference selector.
- Locally saved package-source list.
- Unsigned IPA build through GitHub Actions.

## Important limitations
This release is **not a jailbreak** and does not contain an exploit, bootstrap, package installer, or an unsigned-app runtime such as LiveContainer. Adding a repository URL only saves the address; it does not fetch package indexes or install packages.

The generated IPA is unsigned. A supported signing/installation method is still required to install it on a device.

## Build
GitHub Actions builds the app on macOS. Pushing a tag beginning with `v` (for example, `v1.0`) triggers a build and attaches the resulting IPA to the matching GitHub Release.
