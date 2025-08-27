const { environment } = require('@rails/webpacker')

// Add resolve alias for images
const path = require('path')
environment.config.resolve.alias = {
  ...environment.config.resolve.alias,
  'images': path.resolve(__dirname, '../../app/assets/images')
}

// Configure public path for CSS assets - use relative path in production
environment.config.output.publicPath = '/packs/'

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
      return new sass.types.String(`url("~images/${pathValue}")`)
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
