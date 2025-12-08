/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{html,erb}',
    './app/javascript/**/*.js',
    './node_modules/flowbite/**/*.js',
  ],
  theme: {
    extend: {},
  },
  safelist: [
    // Flowbite modal backdrop classes that are created dynamically by JavaScript
    // These must be safelisted because they're not found in source files
    'bg-gray-900',
    'bg-opacity-50',
    'dark:bg-opacity-80',
    'fixed',
    'inset-0',
    'z-40',
    'z-50',
    // Backdrop transition classes
    'transition-opacity',
    'duration-300',
    'ease-in-out',
  ],
}

