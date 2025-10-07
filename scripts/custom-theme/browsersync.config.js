module.exports = {
  proxy: "localhost:{{WORDPRESS_HOST_PORT}}",
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
