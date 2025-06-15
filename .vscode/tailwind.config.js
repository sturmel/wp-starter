// Configuration fake pour Tailwind CSS IntelliSense avec Tailwind v4
// Ce fichier est uniquement pour l'aide de VS Code, la vraie config est dans assets/css/styles.css
module.exports = {
  // Chemins pour l'extension VS Code
  content: [
    "./views/**/*.twig",
    "./*.php",
    "./assets/js/**/*.js"
  ],
  // Configuration minimale pour que l'extension reconnaisse vos couleurs personnalisées
  theme: {
    extend: {

    },
  },
  plugins: [],
  // Indiquer que c'est pour l'aide VS Code uniquement
  corePlugins: {
    // Toutes les fonctionnalités sont dans le CSS v4
  }
}
