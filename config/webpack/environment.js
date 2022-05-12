const { environment } = require('@rails/webpacker');
const { VueLoaderPlugin } = require('vue-loader');
const vue = require('./loaders/vue');
const pug = require('./loaders/pug')

environment.config.merge({
  resolve: {
    alias: {
      vue: '@vue/compat',
    },
  },
});

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vue);
environment.loaders.prepend('pug', pug)
module.exports = environment;
