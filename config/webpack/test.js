process.env.NODE_ENV = process.env.NODE_ENV || 'development'
process.env.ICON_DIRECTORY = '/tmp/storage/ic/on/icon/'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
