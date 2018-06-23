import Elm from './elm.js';

var app_node = document.querySelector('#app');
var app = Elm.Main.embed(app_node);

app.ports.url.subscribe(function (url) {
  console.log(url);
});

app.ports.url.send({url: '/'});
