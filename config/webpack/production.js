process.env.NODE_ENV = process.env.NODE_ENV || 'production'
process.env.ICON_DIRECTORY = `https://storage.googleapis.com/${process.env.GCS_BUCKET}/icon/`

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
