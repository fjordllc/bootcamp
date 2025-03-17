/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.slim',
    './app/components/**/*.html.slim',
    './app/javascript/**/*.{js,vue,jsx}'
  ],
  theme: {
    extend: {}
  },
  plugins: [],
  important: true
}
