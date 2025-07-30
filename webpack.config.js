const path = require("path")
const webpack = require("webpack")
const { VueLoaderPlugin } = require('vue-loader')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
  mode: process.env.NODE_ENV === "production" ? "production" : "development",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js",
    "not-logged-in": "./app/javascript/stylesheets/not-logged-in.sass",
    paper: "./app/javascript/stylesheets/paper.sass",
    lp: "./app/assets/stylesheets/lp.scss"
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [
              "@babel/preset-env",
              "@babel/preset-react"
            ],
            plugins: [
              "@babel/plugin-transform-nullish-coalescing-operator",
              "@babel/plugin-transform-optional-chaining"
            ]
          }
        }
      },
      {
        test: /\.vue$/,
        loader: "vue-loader",
        options: {
          loaders: {
            'pug': 'pug-plain-loader'
          }
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"]
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          "sass-loader"
        ]
      },
      {
        test: /\.(png|jpe?g|gif|svg|woff|woff2|ttf|eot|ico)$/,
        use: {
          loader: "file-loader",
          options: {
            name: "[name].[ext]",
            outputPath: "assets/"
          }
        }
      }
    ]
  },
  resolve: {
    extensions: [".js", ".jsx", ".vue"],
    modules: [
      path.resolve(__dirname, "app/javascript"),
      path.resolve(__dirname, "app/assets"),
      "node_modules"
    ],
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    },
    fallback: {
      "buffer": require.resolve("buffer"),
      "process": require.resolve("process/browser"),
      "stream": require.resolve("stream-browserify"),
      "util": require.resolve("util/"),
      "crypto": require.resolve("crypto-browserify"),
      "path": require.resolve("path-browserify"),
      "fs": false,
      "os": require.resolve("os-browserify/browser"),
      "constants": require.resolve("constants-browserify")
    }
  },
  plugins: [
    new VueLoaderPlugin(),
    new MiniCssExtractPlugin({
      filename: '[name].css'
    }),
    new webpack.ProvidePlugin({
      Buffer: ['buffer', 'Buffer'],
      process: 'process/browser',
    }),
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}
