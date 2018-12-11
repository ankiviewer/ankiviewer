var {Socket} = require('phoenix');
var {Elm} = require('./elm.js');

var socket = new Socket('/socket', {params: {token: window.userToken}});

socket.connect();

var storedColumns = localStorage.getItem('ankiviewer-columns-save');
var startingColumns = storedColumns ? JSON.parse(storedColumns) : null;

var app_node = document.querySelector('#app');
var app = Elm.Main.init({
  node: app_node,
  flags: startingColumns
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

app.ports.startRunRule.subscribe(function (rid) {
  channel.push('rule:run', {rid: rid})
    .receive('ok', function (resp) { console.log('Joined successfully'); })
    .receive('error', function (resp) { console.log('Unable to join'); });
});

channel.on('rule:msg', function (msg) {
  app.ports.ruleRunData.send(msg);
});

channel.on('rule:done', function () {
  app.ports.ruleRunData.send({msg: 'done', percentage: 100, seconds: 0});

  channel.leave()
    .receive('ok', function (resp) { console.log('Left successfully'); })
    .receive('error', function (resp) { console.log('Unable to leave'); });
});

// app.ports.setColumns.subscribe(function(state) {
//   localStorage.setItem('ankiviewer-columns-save', JSON.stringify(state));
// });
