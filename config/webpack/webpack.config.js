// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')
const webpack = require('webpack')

const webpackConfig = generateWebpackConfig()

// Add custom configuration for JSX files
webpackConfig.module.rules.push({
  test: /\.jsx?$/,
  include: /node_modules\/@yaireo\/tagify/,
  use: {
    loader: 'babel-loader',
    options: {
      presets: ['@babel/preset-env', '@babel/preset-react']
    }
  }
})

// Add fallback for react-dom/client (React 17 doesn't have this module)
webpackConfig.resolve = webpackConfig.resolve || {}
webpackConfig.resolve.fallback = {
  ...webpackConfig.resolve.fallback,
  'react-dom/client': false
}

// Ignore the warning for react-dom/client
webpackConfig.plugins = webpackConfig.plugins || []
webpackConfig.plugins.push(
  new webpack.IgnorePlugin({
    resourceRegExp: /react-dom\/client$/,
    contextRegExp: /react_ujs/
  })
)

module.exports = webpackConfig
