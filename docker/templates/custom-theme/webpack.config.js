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
      styles: "./assets/css/styles.css",
      scripts: "./assets/js/scripts.js"
    },
    output: {
      path: path.resolve(__dirname, outputPath),
      filename: isProduction ? "[name].min.js" : "[name].js",
      clean: true,
    },
    mode: isProduction ? "production" : "development",
    devtool: "source-map",
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
            {
              loader: "css-loader",
              options: {
                importLoaders: 1,
                sourceMap: true
              }
            },
            {
              loader: "postcss-loader",
              options: {
                sourceMap: true,
                postcssOptions: {
                  plugins: [
                    require("postcss-import"),
                    [require("@tailwindcss/postcss"), {
                      content: [
                        "./views/**/*.twig",
                        "./*.php",
                        "./assets/js/**/*.js",
                        "./tailwind-safelist.txt"
                      ]
                    }],
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
          proxy: "localhost:8080",
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
            compress: {
              drop_console: true, // Retire les console.log en production
              drop_debugger: true,
              pure_funcs: ['console.log', 'console.info', 'console.debug'], // Retire ces fonctions
              passes: 2, // Plusieurs passes d'optimisation
            },
            mangle: {
              safari10: true, // Compatibilité Safari 10
            },
            format: {
              comments: false, // Retire tous les commentaires
            },
          },
          extractComments: false, // Pas de fichier .LICENSE.txt séparé
          parallel: true, // Utilise plusieurs processeurs
        }),
        new CssMinimizerPlugin({
          minimizerOptions: {
            preset: [
              "default",
              {
                discardComments: { removeAll: true },
                normalizeWhitespace: true,
                colormin: true, // Optimise les couleurs
                convertValues: true, // Convertit les valeurs (px -> rem si plus court)
                discardDuplicates: true, // Retire les règles dupliquées
                discardEmpty: true, // Retire les règles vides
                mergeRules: true, // Fusionne les règles identiques
                minifySelectors: true, // Optimise les sélecteurs
              },
            ],
          },
          parallel: true, // Utilise plusieurs processeurs
        }),
      ] : [],
      // Tree shaking pour supprimer le code mort
      usedExports: isProduction,
      sideEffects: false, // Indique que vos modules n'ont pas d'effets de bord
    },
    // Alertes de performance en production
    performance: isProduction ? {
      hints: "warning",
      maxEntrypointSize: 500000, // 500KB
      maxAssetSize: 300000, // 300KB
    } : false,
    watch: argv.mode === "development",
    watchOptions: {
      aggregateTimeout: 300,
      poll: 1000,
      ignored: /node_modules/,
    },
  };
};
