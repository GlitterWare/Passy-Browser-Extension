# Passy Browser Extension

A powerful browser extension companion for the cross-platform offline password manager Passy.  
https://glitterware.github.io/Passy

*Notice: the connector is installed automatically starting from Passy v1.5.0 (Browser Extension update).*

## Contents

1. [Features](#features)
2. [Downloads](#downloads)
3. [Building](#building)
4. [Privacy policy](#privacy-policy)

## Features

- ⚡ Autofill – Quickly fill fields in apps and websites without having to open the app.
- 📱 2FA codes - Keep your 2FA codes safe and sound in offline storage.
- 🔒 Security – All your information is encrypted in AES and stored offline on your devices, providing highest-tier security.
- 📚 Multipurpose – Store passwords, payment cards, notes, id cards and identities, all in one place.
- ✨ More features, including synchronization and automatic backups in the main app!

## Downloads

Passy Browser Extension is fully supported starting from Passy v1.5.2.

### Chrome

https://chrome.google.com/webstore/detail/passy-password-manager-br/lndgiajgfcgocmgdiamhffipffjnpigl

### Edge

https://microsoftedge.microsoft.com/addons/detail/passy-password-manager-/khcfpejnhlonmipnjmlebjncibplamff

### Firefox

https://addons.mozilla.org/en-US/firefox/addon/passy/

## Building

Passy Browser Extension is open-source, feel free to make modifications to it and build it yourself. We're always very glad to see people exploring our projects. 👥

1. [Install Flutter](https://docs.flutter.dev/get-started/install).
2. Clone the repository or [get the source code from the latest Passy release](https://github.com/GlitterWare/Passy/releases/latest).
3. Run `./submodules/flutter/bin/flutter build web --web-renderer canvaskit --csp --pwa-strategy=none --dart-define=FLUTTER_WEB_CANVASKIT_URL=/` to build Passy Browser Extension.
4. You can then find your build at `build/web` relative to the project root.
5. The default `manifest.json` is not Firefox compatible. If you wish to use your build for Firefox, remove it from the build folder and rename `manifest_firefox.json` to `manifest.json`.

## Privacy policy

Same as the main app, read https://github.com/GlitterWare/Passy/blob/main/PRIVACY-POLICY.md.


