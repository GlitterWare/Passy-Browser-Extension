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
var collapsed = false;

function loadEmbed() {
  const autofillPopup = document.getElementById('passy-autofill-popup');
  if (collapsed) return;
  if (autofillPopup != null) return;
  document.body.insertAdjacentHTML('beforeend', `<div id="passy-autofill-popup" style="visibility: visible !important; position: absolute !important; top: 401px !important; left: 557px !important; z-index: 100000 !important ; border-radius: 24px !important"><iframe src="${indexUrl}"
      style="border-radius: 24px !important"
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
}

function collapse() {
  var autofillPopup = document.getElementById('passy-autofill-popup');
  if (autofillPopup != null) autofillPopup.remove();
  collapsed = true;
  document.body.insertAdjacentHTML('beforeend', `<div id="passy-autofill-popup" style="visibility: visible !important; position: absolute !important; top: 401px !important; left: 557px !important; z-index: 100000 !important"><div
      title="Passy"
      data-toggle="tooltip"
      display="block"
      style="background-color: black !important ; width: 40px !important ; height: 40px !important ; cursor: pointer !important ; border-radius: 10px !important"
      frameborder="0" 
      marginheight="0" 
      marginwidth="0" 
      scrolling="auto"
      onclick="expand()"><img
        display="block"
        style="width: 40px !important ; height: 40px !important ; padding: 5px !important ; box-sizing: border-box"
        src="${extensionPathUrl}/icons/Icon-48.png"
        alt="Passy"
      /></div></div>`);
  autofillPopup = document.getElementById('passy-autofill-popup');
  autofillPopup.addEventListener('click', function handleClick(event) {
    expand();
  });
  if (lastElement == null) return;
  const rect = getOffset(lastElement);
  autofillPopup.style.left = `${rect.left + lastElement.clientWidth - 40}px`;
  autofillPopup.style.top = `${rect.top + lastElement.clientHeight}px`;
  lastElement.focus();
}

function expand() {
  var autofillPopup = document.getElementById('passy-autofill-popup');
  if (autofillPopup != null) autofillPopup.remove();
  collapsed = false;
  loadEmbed();
  autofillPopup = document.getElementById('passy-autofill-popup');
  autofillPopup.style.visibility = 'visible';
  const rect = getOffset(lastElement);
  if (lastElement.clientWidth < 355) {
    autofillPopup.style.left = `${rect.left}px`;
  } else {
    autofillPopup.style.left = `${rect.left + lastElement.clientWidth - 355}px`;
  }
  autofillPopup.style.top = `${rect.top + lastElement.clientHeight}px`;
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
      collapse();
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
              input.dispatchEvent(new Event('input', { bubbles: true }));
              lastElement = input;
              continue;
            }
            if (elementCheck(input, emailQuery)) {
              input.value = email;
              input.dispatchEvent(new Event('input', { bubbles: true }));
              lastElement = input;
              continue;
            }
            if (elementCheck(input, usernameQuery)) {
              input.value = username;
              input.dispatchEvent(new Event('input', { bubbles: true }));
              lastElement = input;
              continue;
            }
          }
          collapse();
          return;
      }
      collapse();
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
    if (!document.contains(lastElement)) {
      lastElement = null;
      unloadEmbed();
    }
  }
  if (el.tagName.toLowerCase() != 'input') return;
  if (!elementCheck(el)) {
    return;
  }
  lastElement = el;
  collapse();
  var autofillPopup = document.getElementById('passy-autofill-popup');
  autofillPopup.style.visibility = 'visible';
  const rect = getOffset(el);
  if (collapsed) {
    autofillPopup.style.left = `${rect.left + el.clientWidth - 40}px`;
  } else {
    if (el.clientWidth < 355) {
      autofillPopup.style.left = `${rect.left}px`;
    } else {
      autofillPopup.style.left = `${rect.left + el.clientWidth - 355}px`;
    }
  }
  autofillPopup.style.top = `${rect.top + el.clientHeight}px`;
}

function onFocusout(_) {
  if (lastElement != null) {
    const autofillPopup = document.getElementById('passy-autofill-popup');
    if (autofillPopup == null) {
      lastElement = null;
      return;
    }
    if (!document.contains(lastElement)) {
      lastElement = null;
      unloadEmbed();
    }
  }
}

function onResize(_) {
  if (lastElement == null) return;
  var autofillPopup = document.getElementById('passy-autofill-popup');
  if (autofillPopup == null) return;
  autofillPopup.style.visibility = 'visible';
  const rect = getOffset(lastElement);
  if (collapsed) {
    autofillPopup.style.left = `${rect.left + lastElement.clientWidth - 40}px`;
  } else {
    if (lastElement.clientWidth < 355) {
      autofillPopup.style.left = `${rect.left}px`;
    } else {
      autofillPopup.style.left = `${rect.left + lastElement.clientWidth - 355}px`;
    }
  }
  autofillPopup.style.top = `${rect.top + lastElement.clientHeight}px`;
}

onFoucsin();
// not using innerHTML as it would break js event listeners of the page
document.addEventListener('focusin', onFoucsin);
document.addEventListener('focusout', onFocusout);
window.addEventListener('resize', onResize);
