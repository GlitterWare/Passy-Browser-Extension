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
