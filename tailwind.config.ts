import type { Config } from 'tailwindcss';

export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        fi: {
          canvas: '#020714',
          night: '#070B18',
          panel: '#0E1426',
          panelDeep: '#090E1C',
          ink: '#FFFFFF',
          text: '#AAB2C8',
          muted: '#737C95',
          line: 'rgba(255, 255, 255, 0.10)',
          violet: '#8B5CF6',
          violetSoft: '#BCA7FF',
          purple: '#A855F7',
          blue: '#7EA6FF',
          cyan: '#63F2D1',
          gold: '#F8C66C'
        }
      },
      boxShadow: {
        glow: '0 0 42px rgba(139, 92, 246, 0.55)',
        card: '0 24px 70px rgba(0, 0, 0, 0.28), inset 0 1px rgba(255, 255, 255, 0.06)',
        phone: '0 34px 90px rgba(0, 0, 0, 0.58)'
      },
      backgroundImage: {
        hero:
          'radial-gradient(circle at 22% 16%, rgba(139, 92, 246, 0.18), transparent 34%), radial-gradient(circle at 82% 32%, rgba(80, 68, 255, 0.20), transparent 30%), linear-gradient(180deg, #020714 0%, #050A17 48%, #030713 100%)',
        card:
          'linear-gradient(145deg, rgba(255, 255, 255, 0.075), rgba(255, 255, 255, 0.025))',
        button: 'linear-gradient(135deg, #7C5CFF, #B55CFF)'
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'Apple SD Gothic Neo', 'Segoe UI', 'sans-serif']
      }
    }
  },
  plugins: []
} satisfies Config;
