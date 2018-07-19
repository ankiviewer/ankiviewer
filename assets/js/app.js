import Elm from './elm.js';

var router = new Navigo();

var storedColumns = localStorage.getItem('ankiviewer-columns-save');
var startingColumns = storedColumns ? JSON.parse(storedColumns) : null;

var app_node = document.querySelector('#app');
var app = Elm.Main.embed(app_node, startingColumns);

app.ports.setColumns.subscribe(function(state) {
  localStorage.setItem('ankiviewer-columns-save', JSON.stringify(state));
});

var urlMap = {
  'HomeView': '/',
  'SearchView': '/search'
}

router
  .on({
    '/': function () {
      app.ports.urlIn.send({view: '/'});
    },
    '/search': function () {
      app.ports.urlIn.send({view: '/search'});
    }
  })
  .resolve();

app.ports.urlOut.subscribe(function (url) {
  router.navigate(urlMap[url.view] || '/');
});
