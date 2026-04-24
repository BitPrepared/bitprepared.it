tailwind.config = {
  theme: {
    extend: {
      colors: {
        primary: '#0a3d0a',
        secondary: '#1a7f1a',
        accent: '#00d9ff',
        dark: '#0a1f0a',
        light: '#e8f5e8',
        white: '#ffffff',
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
    }
  }
}
