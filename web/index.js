const myId = browser.runtime.id;

const serviceName = 'io.github.glitterware.passy_browser_extension';

function isEmbed() {
  try {
    return window.top.origin !== window.origin;
  } catch (_) {
    return true;
  }
}

function unloadEmbed() {
  if (window.parent == null) return;
  if (!isEmbed()) return;
  return window.parent.postMessage({ service: serviceName, args: [ 'unload_embed' ] }, '*');
}

async function getPageUrl() { 
  if (typeof browser.tabs == 'undefined') {
    var response = await browser.runtime.sendMessage({ args: [ 'get_active_page_url' ] });
    if (response.response == null) return '';
    return response.response;
  }
  const tabs = await browser.tabs.query({'active': true, 'lastFocusedWindow': true});
  return tabs[0].url; 
}

function autofillPassword(username, email, password) {
  if (window.parent == null) return;
  if (!isEmbed()) return;
  return window.parent.postMessage({ service: serviceName, args: [ 'autofill', 'password', username, email, password ] }, '*');
}

function isConnectorFound() {
  return browser.runtime.sendMessage({ args: ['is_connector_found'] });
}

function runCommand(command) {
  return browser.runtime.sendMessage({ args: command });
}

async function getLastUsername() {
  const response = await browser.storage.sync.get('lastUsername');
  if (response == null) return null;
  if (response.lastUsername == null) return null;
  return response.lastUsername;
}

function setLastUsername(username) {
  return browser.storage.sync.set({ 'lastUsername': username })
}

async function getCurrentUsername() {
  var response = await browser.runtime.sendMessage({ args: ['current_username', 'get'] });
  if (response == null) return null;
  return response.response;
}

function setCurrentUsername(username) {
  return browser.runtime.sendMessage({ args: ['current_username', 'set', username] });
}

async function getCurrentEntry() {
  const response = await browser.storage.local.get('currentEntry');
  if (response == null) return null;
  if (response.currentEntry == null) return null;
  return response.currentEntry;
}

function setCurrentEntry(currentEntry) {
  return browser.storage.local.set({ 'currentEntry': currentEntry })
}

function createTab(url) {
  browser.tabs.create({url: url});
}


function compareFavicons(a, b) {
  // If both are vector graphics, use URL length as tie-breaker
  if (a.url.endsWith('.svg') && b.url.endsWith('.svg')) {
    return a.url.length < b.url.length ? -1 : 1;
  }

  // Sort vector graphics before bitmaps
  if (a.url.endsWith('.svg')) return -1;
  if (b.url.endsWith('.svg')) return 1;

  // If bitmap size is the same, use URL length as tie-breaker
  if (a.data.byteLength == b.data.byteLength) {
    return a.url.length < b.url.length ? -1 : 1;
  }

  // Sort on bitmap size
  return (a.data.byteLength > b.data.byteLength) ? -1 : 1;
}

async function getAllFavicons(url, suffixes) {
  var favicons = [];
  var iconUrls = [];

  var parser = new DOMParser();
  var html = await (await fetch(url)).text();
  var doc = parser.parseFromString(html, "text/html");
  const uri = new URL(url);

  // Look for icons in tags
  rels = ['icon', 'shortcut icon'];
  for (i in rels) {
    rel = rels[i];
    query = doc.querySelectorAll('link[rel="' + rel + '"]');
    for (let j = 0; j < query.length; j++) {
      iconTag = query[j]
      href = iconTag.getAttribute('href');
      if (href != null) {
        var iconUrl = href.trim();

        // Fix scheme relative URLs
        if (iconUrl.startsWith('//')) {
          iconUrl = uri.protocol + iconUrl;
        }

        // Fix relative URLs
        if (iconUrl.startsWith('/')) {
          iconUrl = uri.protocol + '//' + uri.hostname + iconUrl;
        }

        // Fix naked URLs
        if (!iconUrl.startsWith('http')) {
          iconUrl = uri.protocol + '//' + uri.hostname + '/' + iconUrl;
        }

        // Remove query strings
        iconUrl = iconUrl.split('?')[0];

        // Verify so the icon actually exists
        if (await _verifyImage(iconUrl)) {
          iconUrls.push(iconUrl);
        }
      }
    }
  }

  // Look for icon by predefined URL
  var iconUrl = uri.protocol + '//' + uri.hostname + '/favicon.ico';
  if (await _verifyImage(iconUrl)) {
    iconUrls.push(iconUrl);
  }

  // Deduplicate
  iconUrls = [...new Set(iconUrls)];

  // Filter on suffixes
  if (suffixes != null) {
    iconUrls = iconUrls.filter((url) => {
      const urlSplit = url.split('.');
      return suffixes.includes(urlSplit[urlSplit.length - 1]);
    });
  }

  // Fetch dimensions
  for (i in iconUrls) {
    var iconUrl = iconUrls[i];
    var image = await (await fetch(iconUrl)).arrayBuffer();
    if (image != null) {
      favicons.push({ url: iconUrl, data: image });
    }
  }

  favicons.sort(compareFavicons);
  return favicons;
}

async function getBestFavicon(url, suffixes) {
  var favicons = await getAllFavicons(url, suffixes);
  return favicons.length == 0 ? null : favicons[0].url;
}

function _numToUint8Array(num) {
  let arr = new Uint8Array(8);
  for (let i = 7; i != 0; i--) {
    arr[i] = num % 256;
    num = Math.floor(num / 256);
  }
  return arr;
};

async function _verifyImage(url) {
  var response = await fetch(url);

  var contentType = response.headers.get('content-type');
  if (contentType == null || !contentType.includes('image')) return false;

  contentLength = response.headers.get('content-length');
  if (contentLength == null) {
    contentLength = 0;
  } else { 
    contentLength = Number(contentLength);
  }

  // Take extra care with ico's since they might be constructed manually
  if (url.endsWith('.ico')) {
    if (contentLength < 4) return false;
    data = new Uint8Array(await response.arrayBuffer());

    // Check if ico file contains a valid image signature
    if (!_verifySignature(data, _numToUint8Array(256).slice(4, 8)) // ICO
          && !_verifySignature(data, _numToUint8Array(9894494448401390090))) { // PNG
      return false;
    }
  }

  return response.status == 200 &&
      contentLength > 0 &&
      contentType.includes('image');
}

function _verifySignature(bodyBytes, signature) {
  var fileSignature = bodyBytes.slice(0, signature.length);
  for (let i = 0; i < fileSignature.length; i++) {
    if (fileSignature[i] != signature[i]) return false;
  }
  return true;
}

async function fetchFile(url) {
  var file;
  try {
    file = new Uint8Array(await (await fetch(url)).arrayBuffer());
  } catch (e) {
    return null;
  }
  return file;
}

async function localGet(key) {
  return (await browser.storage.local.get(key))[key];
}

function localSet(key, value) {
  val = {}
  val[key] = value;
  return browser.storage.local.set(val);
}

window.addEventListener('load', function (ev) {
  // Download main.dart.js
  _flutter.loader.loadEntrypoint({
    onEntrypointLoaded: async function(engineInitializer) {
      // Initialize the Flutter engine
      let appRunner = await engineInitializer.initializeEngine({useColorEmoji: true});
      // Run the app
      await appRunner.runApp();
    }
  });
});
