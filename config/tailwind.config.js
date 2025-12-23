const defaultTheme = require('tailwindcss/defaultTheme')
const flowbite = require('flowbite-react/tailwind')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,jsx}',
    './app/views/**/*.{erb,haml,html,slim}',
    './node_modules/flowbite/**/*.js',
    flowbite.content(),
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        markdownAnchorBlue: '#0969da',
      },
    },
  },
  plugins: [
    require('flowbite/plugin'),
    flowbite.plugin(),
  ],
}
