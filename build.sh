#! /bin/bash
cd $(dirname 0)
export PATH="$PATH:$PWD/submodules/flutter/bin"
./submodules/flutter/bin/flutter build web --web-renderer html --csp
rm -rf build/firefox
cp -r build/web build/firefox
rm build/firefox/manifest.json
mv build/firefox/manifest_firefox.json build/firefox/manifest.json
echo 'All done.'
echo "Chromium: $PWD/build/web"
echo "Firefox: $PWD/build/firefox"
