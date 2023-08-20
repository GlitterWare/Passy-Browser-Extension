const myId = browser.runtime.id;

const serviceName = 'io.github.glitterware.passy_browser_extension';

function getOffset(el) {
  const rect = el.getBoundingClientRect();
  return {
    left: rect.left + window.scrollX,
    top: rect.top + window.scrollY
  };
}

//document.body.insertAdjacentHTML('beforeend', '<div style="position: absolute !important; top: 401px !important; left:557px !important"><input title="test" type="text" aria-invalid="false" name="username" value=""></div>');

const attributesToCheck = ['name', 'title', 'class', 'id', 'type'];
const emailQuery = ['email', 'address'];
const usernameQuery = emailQuery.concat(['username','login','phone', 'account']);
const passwordQuery = ['password','pass'];
const allQuery = usernameQuery.concat(passwordQuery);
const indexUrl = browser.runtime.getURL('index.html');
var extensionPathUrl = browser.runtime.getURL('');
extensionPathUrl = extensionPathUrl.substring(0, extensionPathUrl.length - 1);
var lastElement = null;

function loadEmbed() {
  const autofillPopup = document.getElementById('passy-autofill-popup');
  if (autofillPopup != null) return;
  document.body.insertAdjacentHTML('beforeend', `<div id="passy-autofill-popup" style="visibility: visible !important; position: absolute !important; top: 401px !important; left: 557px !important; z-index: 100000 !important"><iframe src="${indexUrl}"
      frameborder="0" 
      marginheight="0" 
      marginwidth="0" 
      scrolling="auto"
      width="355"
      height="350"></iframe></div>`);
}

function unloadEmbed() {
  const autofillPopup = document.getElementById('passy-autofill-popup');
  if (autofillPopup == null) return;
  autofillPopup.remove();
  if (lastElement != null) lastElement.focus();
}

function elementCheck(element, query = null) {
  if (query == null) query = allQuery;
  if (element == null) return false;
  var valuesToCheck = [];
  for (const attr of element.attributes) {
    if (attributesToCheck.includes(attr.name)) valuesToCheck.push(attr.value);
  }
  if (element.parentElement != null) {
    for (const attr of element.parentElement.attributes) {
      if (attributesToCheck.includes(attr.name)) valuesToCheck.push(attr.value);
    }
  }
  for (let i = 0; i != valuesToCheck.length; i++) {
    for (let j = 0; j != query.length; j++) {
      if (valuesToCheck[i].toLowerCase().includes(query[j])) return true;
    }
  }
  return false;
}

async function handleEmbedMessage(event) {
  if (event.data == null) return;
  if (event.data.service != serviceName) return;
  if (event.origin != extensionPathUrl) return;
  if (event.data.args == null) return;
  if (event.data.args.length == null) return;
  if (event.data.args.length == 0) return;
  switch (event.data.args[0]) {
    case 'unload_embed':
      unloadEmbed();
      return;
    case 'autofill':
      if (event.data.args.length == 1) return;
      switch (event.data.args[1]) {
        case 'password':
          if (event.data.args.length < 5) return;
          lastElement = null;
          const username = event.data.args[2];
          const email = event.data.args[3];
          const password = event.data.args[4];
          const inputs = document.getElementsByTagName('input');
          for (let i = 0; i != inputs.length; i++) {
            const input = inputs[i];
            if (elementCheck(input, passwordQuery)) {
              input.value = password;
              continue;
            }
            if (elementCheck(input, emailQuery)) {
              input.value = email;
              continue;
            }
            if (elementCheck(input, usernameQuery)) {
              input.value = username;
              continue;
            }
          }
          return;
      }
      return;
  }
}

window.addEventListener("message", handleEmbedMessage);

function onFoucsin(_) {
  const el = document.activeElement;
  if (lastElement != null) {
    const autofillPopup = document.getElementById('passy-autofill-popup');
    if (autofillPopup == null) {
      lastElement = null;
      return;
    }
    lastElement = el;
  }
  if (el.tagName.toLowerCase() != 'input') return;
  if (!elementCheck(el)) {
    unloadEmbed(); 
    return;
  }
  lastElement = el;
  loadEmbed();
  var autofillPopup = document.getElementById('passy-autofill-popup');
  autofillPopup.style.visibility = 'visible';
  const rect = getOffset(el);
  autofillPopup.style.left = `${rect.left}px`;
  autofillPopup.style.top = `${rect.top + el.clientHeight}px`;
}
onFoucsin();
// not using innerHTML as it would break js event listeners of the page
document.addEventListener('focusin', onFoucsin);
window.addEventListener('resize', onFoucsin);
