module.exports = {
  content: [
    "_layouts/**/*.html",
    "_pages/**/*.html",
    "_includes/**/*.html",
    "_posts/**/*.md",
    "*.html",  // Include root index.html
    "*.md"     // Include root markdown files
  ],
  theme: {
    extend: {
      colors: {
        primary: '#0a3d0a',
        secondary: '#1a7f1a',
        accent: '#00d9ff',
        dark: '#0a1f0a',
        light: '#e8f5e8',
        bg: '#161616',
        white: '#ffffff',
        rossi: {
          950: '#4d0000',
          600: '#cc0000',
          50: '#fff0f0',
        },
        viola: {
          950: '#1a0033',
          600: '#7b2d8e',
          50: '#f5f0ff',
        },
      },
      fontFamily: {
        display: ['JetBrains Mono', 'Courier New', 'monospace'],
        body: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      spacing: {
        'xs': '0.5rem',
        'sm': '1rem',
        'md': '1.5rem',
        'lg': '2rem',
        'xl': '4rem',
      },
      borderRadius: {
        'DEFAULT': '8px',
      },
      boxShadow: {
        'sm': '0 2px 8px rgba(10, 63, 10, 0.1)',
        'md': '0 4px 16px rgba(10, 63, 10, 0.15)',
        'lg': '0 8px 24px rgba(26, 127, 26, 0.3)',
      },
      transitionDuration: {
        'fast': '150ms',
        'base': '300ms',
        'slow': '600ms',
      },
    },
  },
  plugins: [],
}
