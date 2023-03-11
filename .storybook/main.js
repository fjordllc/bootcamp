// mini-css-extract-pluginは@rails/webpackerと違うバージョンを使用するためにpackage.js内のresolutionsでバージョン指定しています https://github.com/storybookjs/storybook/issues/18257
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const custom = require('../config/webpack/development.js')
const path = require('path')

module.exports = {
  "stories": [
    "../app/javascript/components/**/*.stories.mdx",
    "../app/javascript/components/**/*.stories.@(js|jsx)"
  ],
  "addons": [
    "@storybook/addon-links",
    "@storybook/addon-essentials",
    "@storybook/addon-interactions",
    "@storybook/addon-postcss"
  ],
  "framework": "@storybook/react",
  webpackFinal: async (config) => {
    config.module.rules.push({
      test: /\.(s?css|sass)$/, // （css|sass|scss）が対象になる正規表現
      use: ['style-loader', 'css-loader', 'sass-loader'],
      include: path.resolve(__dirname, '../'),
    });
    return {
      ...config,
      module: { ...config.module, rules: custom.module.rules },
      plugins: [
        new MiniCssExtractPlugin({
            filename: "[name].[contenthash].css",
        }),
        ...config.plugins
      ],
      resolve: {
        ...config.resolve,
        // css内でurl（）関数で読み込む画像パスの追加
        modules: [...config.resolve.modules, 'app/assets/images'],
      }
    }
  },
  staticDirs: ['../public'],
}
