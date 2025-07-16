const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const pug = require('./loaders/pug')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.prepend('pug', pug)

// Fix sass-loader to handle Rails asset helpers
const sassLoader = environment.loaders.get('sass')
const sassLoaderConfig = sassLoader.use.find(use => use.loader === 'sass-loader')
if (sassLoaderConfig) {
  sassLoaderConfig.options = sassLoaderConfig.options || {}
  sassLoaderConfig.options.sassOptions = sassLoaderConfig.options.sassOptions || {}
  sassLoaderConfig.options.sassOptions.functions = {
    'image-url($path)': function(path) {
      const sass = require('sass')
      const pathValue = path.getValue().replace(/['"]/g, '')
      return new sass.types.String(`url("~${pathValue}")`)
    }
  }
}
module.exports = environment

function hotfixPostcssLoaderConfig (subloader) {
  const subloaderName = subloader.loader
  if (subloaderName === 'postcss-loader') {
    if (subloader.options.postcssOptions) {
      console.log(
        '\x1b[31m%s\x1b[0m',
        'Remove postcssOptions workaround in config/webpack/environment.js'
      )
    } else {
      subloader.options.postcssOptions = subloader.options.config;
      delete subloader.options.config;
    }
  }
}

environment.loaders.keys().forEach(loaderName => {
  const loader = environment.loaders.get(loaderName);
  loader.use.forEach(hotfixPostcssLoaderConfig);
})
