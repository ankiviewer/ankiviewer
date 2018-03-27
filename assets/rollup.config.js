import commonjs from 'rollup-plugin-commonjs';

export default {
  input: 'js/app.js',
  output: {
    file: '../priv/static/js/app.js',
    format: 'iife',
    name: 'app',
    sourcemap: true
  },
  plugins: [ commonjs({ include: 'js/elm.js' }) ]
}
