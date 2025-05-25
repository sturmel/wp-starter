const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const BrowserSyncPlugin = require("browser-sync-webpack-plugin");

module.exports = (env, argv) => {
  const isProduction = argv.mode === "production";
  const outputPath = isProduction ? "dist" : "dev_build";

  return {
    entry: {
      scripts: "./assets/js/scripts.js"
    },
    output: {
      path: path.resolve(__dirname, outputPath),
      filename: isProduction ? "[name].min.js" : "[name].js",
      clean: true,
    },
    mode: isProduction ? "production" : "development",
    devtool: isProduction ? false : "source-map",
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
            options: {
              presets: ["@babel/preset-env"]
            }
          }
        },
        {
          test: /\.css$/,
          use: [
            MiniCssExtractPlugin.loader,
            "css-loader",
            {
              loader: "postcss-loader",
              options: {
                postcssOptions: {
                  plugins: [
                    require("postcss-import"),
                    require("@tailwindcss/postcss"),
                    require("autoprefixer"),
                  ],
                },
              },
            },
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: isProduction ? "styles.min.css" : "styles.css",
      }),
      ...(argv.mode === "development" ? [
        new BrowserSyncPlugin({
          proxy: "localhost:{{WORDPRESS_HOST_PORT}}",
          files: [
            "**/*.php",
            "**/*.twig",
            outputPath + "/**/*.css",
            outputPath + "/**/*.js"
          ],
          port: 3000,
          notify: false,
          ui: {
            port: 3001
          }
        })
      ] : [])
    ],
    optimization: {
      minimizer: isProduction ? [
        new TerserPlugin({
          terserOptions: {
            compress: true,
            mangle: true,
          },
        }),
        new CssMinimizerPlugin({
          minimizerOptions: {
            preset: [
              "default",
              {
                discardComments: { removeAll: true },
              },
            ],
          },
        }),
      ] : [],
    },
    watch: argv.mode === "development",
    watchOptions: {
      aggregateTimeout: 300,
      poll: 1000,
      ignored: /node_modules/,
    },
  };
};
