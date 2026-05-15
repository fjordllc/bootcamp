const { environment } = require('shakapacker')

// Add resolve alias for images
const path = require('path')
environment.config.resolve.alias = {
  ...environment.config.resolve.alias,
  'images': path.resolve(__dirname, '../../app/assets/images')
}

// Configure public path for CSS assets - use relative path in production
environment.config.output.publicPath = '/packs/'

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
