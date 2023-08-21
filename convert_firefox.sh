cd $(dirname $0)
cat ./web/manifest.json | jq 'del(.key)' | jq 'del(.background.service_worker)' | jq '. + {"browser_specific_settings": {"gecko": {"id": "glitterware.passy_browser_extension@github.io"}}}' | jq '.background += {"scripts": ["background.js"]}' | jq '.action.default_popup = "popup.html"' > web/manifest_firefox.json
