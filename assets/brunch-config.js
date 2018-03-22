exports.config = {
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css"
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    assets: /^(static)/
  },

  paths: {
    watched: ["static", "css", "js", "elm", "vendor"],
    public: "../priv/static"
  },

  plugins: {
    elmBrunch: {
      mainModules: ["elm/Main.elm"],
      elmFolder: ".",
      executablePath: "node_modules/elm/binwrappers",
      outputFolder: "js",
      outputFile: "main.js"
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true
  }
};
