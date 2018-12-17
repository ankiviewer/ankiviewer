var {Socket} = require('phoenix');
var {Elm} = require('./elm.js');

// taken from: https://stackoverflow.com/questions/27078285/simple-throttle-in-js/27078401#27078401
function throttle(func, wait, options) {
  var context, args, result;
  var timeout = null;
  var previous = 0;
  if (!options) options = {};
  var later = function() {
    previous = options.leading === false ? 0 : Date.now();
    timeout = null;
    result = func.apply(context, args);
    if (!timeout) context = args = null;
  };
  return function() {
    var now = Date.now();
    if (!previous && options.leading === false) previous = now;
    var remaining = wait - (now - previous);
    context = this;
    args = arguments;
    if (remaining <= 0 || remaining > wait) {
      if (timeout) {
        clearTimeout(timeout);
        timeout = null;
      }
      previous = now;
      result = func.apply(context, args);
      if (!timeout) context = args = null;
    } else if (!timeout && options.trailing !== false) {
      timeout = setTimeout(later, remaining);
    }
    return result;
  };
};

var socket = new Socket('/socket', {params: {token: window.userToken}});

socket.connect();

var storedFlags = localStorage.getItem('ankiviewer-flags');
var flags = storedFlags ? JSON.parse(storedFlags) : null;
flags = (Object.keys(flags || {})).indexOf('collection') ? flags : null;
flags = (Object.keys(flags || {})).indexOf('rules') ? flags : null;
flags = (Object.keys(flags || {})).indexOf('excludedColumns') ? flags : null;

var app_node = document.querySelector('#app');
var app = Elm.Main.init({
  node: app_node,
  flags: flags
});

var channel = socket.channel('ankiviewer:join', {});

channel.join()
  .receive('ok', resp => { console.log('Joined successfully', resp) })
  .receive('error', resp => { console.log('Unable to join', resp) })

app.ports.startSync.subscribe(function () {
  channel.push('sync:database', {})
    .receive('ok', (msg) => console.log('ok msg:', msg) )
    .receive('error', (reasons) => console.log('create failed', reasons) )
    .receive('timeout', () => console.log('Networking issue...') )
})

channel.on('sync:msg', function (msg) {
  app.ports.syncData.send(msg);
});

channel.on('sync:done', function () {
  app.ports.syncData.send({msg: 'done', percentage: 100});
});

app.ports.startRunRule.subscribe(function (opts) {
  channel.push('rule:run', opts)
    .receive('ok', function (resp) { console.log('Joined successfully'); })
    .receive('error', function (resp) { console.log('Unable to join'); });
});

app.ports.stopRunRule.subscribe(function () {
  channel.push('rule:stop')
    .receive('ok', function (resp) { console.log('Joined successfully'); })
    .receive('error', function (resp) { console.log('Unable to join'); });
});

channel.on('rule:msg', throttle(function (msg) {
  app.ports.ruleRunData.send(msg);
}, 300));

channel.on('rule:done', function () {
  app.ports.ruleRunData.send({msg: 'done', percentage: 100, seconds: 0});

  channel.leave()
    .receive('ok', function (resp) { console.log('Left successfully'); })
    .receive('error', function (resp) { console.log('Unable to leave'); });
});

function updateLocalStorage(obj) {
  var avFlags = localStorage.getItem('ankiviewer-flags');
  var newState = avFlags ? Object.assign({excludedColumns: []}, JSON.parse(avFlags), obj) : obj;

  localStorage.setItem('ankiviewer-flags', JSON.stringify(newState));
}

app.ports.setColumns.subscribe(function(state) {
  updateLocalStorage(state);
});

app.ports.setCollection.subscribe(function(state) {
  updateLocalStorage(state);
});

app.ports.setRules.subscribe(function(state) {
  updateLocalStorage(state);
});
