module.exports = {
  proxy: "localhost:8080",
  files: [
    "**/*.css",
    "**/*.php",
    "**/*.twig",
    "**/*.js"
  ],
  port: 3000,
  notify: false,
  ui: {
    port: 3001
  }
};
