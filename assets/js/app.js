var {Elm} = require('./elm.js');

var storedColumns = localStorage.getItem('ankiviewer-columns-save');
var startingColumns = storedColumns ? JSON.parse(storedColumns) : null;

var app_node = document.querySelector('#app');
var app = Elm.Main.init({
  node: app_node,
  flags: startingColumns
});

// app.ports.setColumns.subscribe(function(state) {
//   localStorage.setItem('ankiviewer-columns-save', JSON.stringify(state));
// });
