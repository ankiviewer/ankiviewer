var {Socket} = require('phoenix');
var {Elm} = require('./elm.js');

var socket = new Socket('/socket', {params: {token: window.userToken}});

socket.connect();

var channel;

var storedColumns = localStorage.getItem('ankiviewer-columns-save');
var startingColumns = storedColumns ? JSON.parse(storedColumns) : null;

var app_node = document.querySelector('#app');
var app = Elm.Main.init({
  node: app_node,
  flags: startingColumns
});

app.ports.startSync.subscribe(function () {
  channel = socket.channel('sync:database', {});

  channel.join()
    .receive('ok', function (resp) { console.log('Joined successfully'); })
    .receive('error', function (resp) { console.log('Unable to join'); });

  channel.on('sync:msg', function (msg) {
    console.log(msg);
    app.ports.syncData.send(msg);
  });

  channel.on('done', function () {
    app.ports.syncData.send({msg: 'done', percentage: 100});

    channel.leave()
      .receive('ok', function (resp) { console.log('Left successfully'); })
      .receive('error', function (resp) { console.log('Unable to leave'); });
  });
});

app.ports.startRunRule.subscribe(function (rid) {
  channel = socket.channel('rule:run', {rid: rid});

  channel.join()
    .receive('ok', function (resp) { console.log('Joined successfully'); })
    .receive('error', function (resp) { console.log('Unable to join'); });

  channel.on('rule:msg', function (msg) {
    app.ports.ruleRunData.send(msg);
  });

  channel.on('done', function () {
    app.ports.ruleRunData.send({msg: 'done', percentage: 100, seconds: 0});

    channel.leave()
      .receive('ok', function (resp) { console.log('Left successfully'); })
      .receive('error', function (resp) { console.log('Unable to leave'); });
  });
});

// app.ports.setColumns.subscribe(function(state) {
//   localStorage.setItem('ankiviewer-columns-save', JSON.stringify(state));
// });
