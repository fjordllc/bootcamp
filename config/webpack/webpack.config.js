// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')
const sassEmbedded = require('sass-embedded')
const webpack = require('webpack')

const webpackConfig = generateWebpackConfig()

// Ensure all sass-loader instances use the modern Sass API
webpackConfig.module.rules.forEach(rule => {
  if (!rule.use) return
  const useEntries = Array.isArray(rule.use) ? rule.use : (rule.use = [rule.use])
  useEntries.forEach((loaderConfig, index) => {
    const loaderPath = typeof loaderConfig === 'string' ? loaderConfig : loaderConfig.loader
    if (loaderPath && loaderPath.includes('sass-loader')) {
      if (typeof loaderConfig === 'string') {
        useEntries[index] = {
          loader: loaderConfig,
          options: {}
        }
        loaderConfig = useEntries[index]
      }
      const target = loaderConfig
      target.options = target.options || {}
      target.options.implementation = sassEmbedded
      target.options.api = 'modern'
      const existingSassOptions = target.options.sassOptions || {}
      const silenced = new Set(existingSassOptions.silenceDeprecations || [])
      ;['legacy-js-api', 'import', 'global-builtin', 'color-functions'].forEach(id => silenced.add(id))
      target.options.sassOptions = {
        ...existingSassOptions,
        silenceDeprecations: Array.from(silenced)
      }
    }
  })
})

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

// Fix markdown-it-purifier CommonJS parsing
webpackConfig.module.rules.push({
  test: /markdown-it-purifier[\/\\]dist[\/\\]index\.browser\.js$/,
  type: 'javascript/auto'
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

// Provide React and ReactDOM globally for compatibility
// Also provide process and util polyfills for browser environment
webpackConfig.plugins.push(
  new webpack.ProvidePlugin({
    React: 'react',
    process: 'process/browser.js',
    Buffer: ['buffer', 'Buffer']
  })
)

// Fix markdown-it-purifier CommonJS/ESM compatibility issue
webpackConfig.resolve = webpackConfig.resolve || {}
webpackConfig.resolve.alias = webpackConfig.resolve.alias || {}
webpackConfig.resolve.alias['markdown-it-purifier'] = require.resolve('markdown-it-purifier/dist/index.browser.js')

// Add fallbacks for Node.js core modules in browser environment
webpackConfig.resolve.fallback = {
  ...webpackConfig.resolve.fallback,
  process: require.resolve('process/browser.js'),
  util: require.resolve('util/'),
  buffer: require.resolve('buffer/')
}

module.exports = webpackConfig
