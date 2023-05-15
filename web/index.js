const myId = browser.runtime.id;

const serviceName = 'io.github.glitterware.passy_browser_extension';

function isEmbed() {
  return window.top !== window.self;
}

function unloadEmbed() {
  if (window.top == null) return;
  if (!isEmbed()) return;
  return window.top.postMessage({ service: serviceName, args: [ 'unload_embed' ] }, '*');
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
  if (window.top == null) return;
  if (!isEmbed()) return;
  return window.top.postMessage({ service: serviceName, args: [ 'autofill', 'password', username, email, password ] }, '*');
}

async function isConnectorFound() {
  const response = await browser.runtime.sendMessage({ args: ['is_connector_found'] });
  if (response.response == null) return false;
  return response.response;
}

async function sendCommand(command) {
  const response = await browser.runtime.sendMessage({ args: command });
  if (response == null) return null;
  return response.response;
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
