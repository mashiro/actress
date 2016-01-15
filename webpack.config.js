var path = require('path');
var webpack = require('webpack');

var ExtractTextPlugin = require("extract-text-webpack-plugin");
var BowerWebpackPlugin = require("bower-webpack-plugin");

var root = process.cwd();
var argv = require('minimist')(process.argv.slice(2));

var src = path.join(root, 'assets');
var dest = path.join(root, 'public');
var bowerRoot = path.join(root, 'bower_components');

var config = {
  addVendor: function(name, path, options) {
    options = options || {};
    this.resolve.alias[name] = path;
    if (options.noParse) {
      this.module.noParse.push(new RegExp(path));
    }
    if (options.loaders) {
      this.module.loaders.push({test: new RegExp(path), loaders: options.loaders});
    }
  },
  entry: {
    actress: path.join(src, 'index.coffee')
  },
  output: {
    path: path.join(root, 'public'),
    publicPath: '/',
    filename: '[name].js',
    chunkFilename: '[id].js'
  },
  resolve: {
    root: [
      root,
      src,
      bowerRoot
    ],
    extensions: ['', '.js', '.coffee', '.css', '.scss'],
    alias: {
      highcharts: 'highcharts-release/highcharts.js'
    }
  },
  module: {
    noParse: [],
    loaders: [
      {test: /\.html$/, loader: 'html'},
      {test: /\.js/, loaders: ['ng-annotate']},
      {test: /\.coffee$/, loaders: ['ng-annotate', 'coffee']},
      {test: /\.css$/, loader: ExtractTextPlugin.extract('style', 'css!autoprefixer')},
      {test: /\.scss$/, loader: ExtractTextPlugin.extract('style', 'css!autoprefixer!sass')},
      {test: /\.(woff2?|eot|ttf|svg)$/, loader: 'file'},

      {test: /ng-table\/.*\.js$/, loader: 'imports?define=>false'},
      {test: /angular-moment\/.*\.js$/, loader: 'imports?define=>false,moment'},
      {test: /highcharts-ng\/.*\.js$/, loader: 'imports?Highcharts=highcharts'}
    ]
  },
  plugins: [
    new ExtractTextPlugin('[name].css'),
    new BowerWebpackPlugin(),
    new webpack.ProvidePlugin({
      _: 'lodash',
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
    })
  ]
};

module.exports = config;
