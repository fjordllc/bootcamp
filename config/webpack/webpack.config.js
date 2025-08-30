// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')
const webpack = require('webpack')
const path = require('path')

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

// Add file loader for image assets
webpackConfig.module.rules.push({
  test: /\.(png|jpg|jpeg|gif|svg)$/,
  type: 'asset/resource',
  generator: {
    filename: 'images/[hash][ext][query]'
  }
})

// Add fallbacks for Node.js core modules
webpackConfig.resolve.fallback = {
  ...webpackConfig.resolve.fallback,
  'react-dom/client': false,
  'util': require.resolve('util/')
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
