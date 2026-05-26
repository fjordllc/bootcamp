// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')
const webpack = require('webpack')

const webpackConfig = generateWebpackConfig()

// Add custom configuration for Tagify JavaScript files
webpackConfig.module.rules.push({
  test: /\.js$/,
  include: /node_modules\/@yaireo\/tagify/,
  use: {
    loader: 'babel-loader',
    options: {
      presets: ['@babel/preset-env']
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
// Only expose necessary environment variables to client
const allowedEnvKeys = ['NODE_ENV', 'RAILS_ENV']
const safeEnv = allowedEnvKeys.reduce((acc, key) => {
  if (process.env[key]) {
    acc[key] = JSON.stringify(process.env[key])
  }
  return acc
}, {})

webpackConfig.plugins = webpackConfig.plugins || []
webpackConfig.plugins.push(
  new webpack.DefinePlugin({
    'process.env': safeEnv
  })
)

webpackConfig.resolve = webpackConfig.resolve || {}
webpackConfig.resolve.alias = webpackConfig.resolve.alias || {}
webpackConfig.resolve.fallback = {
  ...webpackConfig.resolve.fallback,
  buffer: require.resolve('buffer/'),
  util: require.resolve('util/')
}

webpackConfig.plugins.push(
  new webpack.ProvidePlugin({
    Buffer: ['buffer', 'Buffer']
  })
)

module.exports = webpackConfig
