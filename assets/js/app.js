import Elm from './elm.js';

var router = new Navigo();

var app_node = document.querySelector('#app');
var app = Elm.Main.embed(app_node);

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
