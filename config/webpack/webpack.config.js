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

// Add file loader for image assets
webpackConfig.module.rules.push({
  test: /\.(png|jpg|jpeg|gif|svg)$/,
  type: 'asset/resource',
  generator: {
    filename: 'images/[hash][ext][query]'
  }
})

// Fix process is not defined error for browser environment
webpackConfig.plugins = webpackConfig.plugins || []
webpackConfig.plugins.push(
  new webpack.DefinePlugin({
    'process.env': JSON.stringify(process.env || {})
  })
)

// Provide React and ReactDOM globally for compatibility
webpackConfig.plugins.push(
  new webpack.ProvidePlugin({
    React: 'react'
  })
)

module.exports = webpackConfig
