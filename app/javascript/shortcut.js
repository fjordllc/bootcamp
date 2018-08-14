import hotkeys from 'hotkeys-js';

hotkeys.filter = function(event){
  var tagName = (event.target || event.srcElement).tagName;
  hotkeys.setScope(/^(INPUT|TEXTAREA|SELECT)$/.test(tagName) ? 'input' : 'other');
  return true;
}

const isMac = function() {
  return navigator.userAgent.toLowerCase().indexOf('mac') > 0;
};

const wip = function() {
  const button = document.querySelector('#js-shortcut-wip');
	if (button) {
    button.click();
  }
};

const save = function() {
  const button = document.querySelector('#js-shortcut-submit');
	if (button) {
    button.click();
  }
};

const moveEditPage = function() {
  const button = document.querySelector('#js-shortcut-edit');
	if (button) {
    button.click();
  }
};

if (isMac()) {
  hotkeys('⌘+s', 'input', function(event, handler){
    console.log('⌘+s');
    event.preventDefault();
    wip();
  });

  hotkeys('⌘+enter', 'input', function(event, handler){
    console.log('⌘+enter');
    event.preventDefault();
    save();
  });

  hotkeys('⌘+e', 'all', function(event, handler){
    console.log('⌘+e');
    event.preventDefault();
    moveEditPage();
  });
} else {
  hotkeys('ctrl+s', 'input', function(event, handler){
    console.log('ctrl+s');
    event.preventDefault();
    wip();
  });

  hotkeys('ctrl+enter', 'input', function(event, handler){
    console.log('ctrl+enter');
    event.preventDefault();
    save();
  });

  hotkeys('ctrl+e', 'all', function(event, handler){
    console.log('ctrl+e');
    event.preventDefault();
    moveEditPage();
  });
}
