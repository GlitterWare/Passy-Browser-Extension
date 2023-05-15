if (typeof importScripts != 'undefined') importScripts("browser-polyfill.min.js");
const myId = browser.runtime.id;

var cliProcesses = {};
var onProcessFinished = {};
var connectingFuture;
var port;
var currentUsername = null;

function onCliMessage(response) {
  var id = response.id;
  if (id == null) return;
  var part = response.part;
  if (part == null) return;
  var partsTotal = response.partsTotal;
  if (partsTotal == null) return;
  var data = response.data;
  if (data == null) return;
  if (cliProcesses[id] == null) cliProcesses[id] = '';
  cliProcesses[id] += data;
  if (part == partsTotal) {
    var callback = onProcessFinished[id];
    if (callback != null) {
      callback(cliProcesses[id]);
      delete onProcessFinished[id];
    }
    delete cliProcesses[id];
  }
}

function callPassyCli(command) {
  port.postMessage({ command: command });
}

async function isConnectorFound() {
  if (port != null) return true;
  var shouldSetPort = false;
  if (connectingFuture == null) {
    shouldSetPort = true;
    connectingFuture = browser.runtime.sendNativeMessage('io.github.glitterware.passy_cli', { command: ['help'] });
  }
  try {
    await connectingFuture;
    connectingFuture = null;
  } catch (e) {
    connectingFuture = null;
    port = null;
    return false;
  }
  if (port == null) {
    if (shouldSetPort) {
      port = browser.runtime.connectNative('io.github.glitterware.passy_cli');
      port.onMessage.addListener(onCliMessage);
      port.onDisconnect.addListener((_) => port = null);
    }
  }
  return true;
}

browser.runtime.onMessage.addListener(function(request, sender, sendResponse) {
  if (sender.id != myId) return;
  if (request.args == null) return;
  if (request.args.length == null) return;
  if (request.args.length == 0) return;
  switch (request.args[0]) {
    case 'is_connector_found':
      isConnectorFound().then((value) => sendResponse({ response: value }));
      return true;
    case 'passy_cli':
      if (request.args.length == 1) return;
      switch (request.args[1]) {
        case 'run':
          if (request.args.length < 4) return;
          var id = request.args[3];
          onProcessFinished[id] = (response) => sendResponse({ response: response });
          callPassyCli(request.args[2]);
          return true;
      }
      return;
    case 'current_username':
      if (request.args.length == 1) return;
      switch (request.args[1]) {
        case 'get':
          sendResponse({ response: currentUsername });
          return;
        case 'set':
          if (request.args.length == 2) return;
          currentUsername = request.args[2];
          return;
      }
      return;
    case 'get_active_page_url':
      browser.tabs.query({'active': true, 'lastFocusedWindow': true}).then((tabs) => sendResponse({ response: tabs[0].url }));
      return true; 
  }
});
