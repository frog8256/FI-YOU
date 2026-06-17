import { Menu, Moon, X } from 'lucide-react';
import { useState } from 'react';
import { Language, useI18n } from '../lib/i18n';
import { BrandSymbol } from './BrandSymbol';

export function Header() {
  const [isOpen, setIsOpen] = useState(false);
  const { language, setLanguage, t } = useI18n();
  const closeMenu = () => setIsOpen(false);
  const languages: Array<{ label: string; value: Language }> = [
    { label: 'KR', value: 'kr' },
    { label: 'ENG', value: 'en' }
  ];

  return (
    <header className="sticky top-0 z-40 bg-fi-canvas/95 backdrop-blur-xl">
      <div className="mx-auto flex max-w-[1120px] items-center justify-between px-5 py-7 lg:px-0">
        <a href="/" onClick={closeMenu}>
          <BrandSymbol compact />
        </a>

        <nav className="hidden items-center gap-11 text-[13px] font-bold text-white/72 lg:flex" aria-label="Primary navigation">
          {t.navItems.map((item) => (
            <a key={item.href} className="relative transition hover:text-white" href={item.href}>
              {item.label}
            </a>
          ))}
        </nav>

        <div className="hidden items-center gap-3 lg:flex">
          <div className="grid grid-cols-2 rounded-[14px] border border-white/10 bg-white/[0.04] p-1">
            {languages.map((item) => (
              <button
                key={item.value}
                className={`h-9 rounded-[11px] px-3 text-[12px] font-black transition ${
                  language === item.value ? 'bg-fi-violet text-white shadow-glow' : 'text-white/55 hover:text-white'
                }`}
                type="button"
                onClick={() => setLanguage(item.value)}
              >
                {item.label}
              </button>
            ))}
          </div>

          <a
            className="h-11 items-center gap-2 rounded-[17px] bg-button px-5 text-[13px] font-black text-white shadow-glow transition hover:-translate-y-0.5 lg:inline-flex"
            href="/#download"
          >
            <Moon className="h-4 w-4" />
            {t.common.download}
          </a>
        </div>

        <button
          aria-label={isOpen ? 'Close menu' : 'Open menu'}
          className="grid h-11 w-11 place-items-center rounded-[16px] border border-white/10 bg-white/5 text-white lg:hidden"
          type="button"
          onClick={() => setIsOpen((current) => !current)}
        >
          {isOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {isOpen && (
        <nav className="grid gap-1 border-t border-white/5 bg-fi-canvas/95 px-5 py-4 text-sm font-bold text-white/80 lg:hidden" aria-label="Mobile navigation">
          <div className="mb-3 grid max-w-[190px] grid-cols-2 rounded-[14px] border border-white/10 bg-white/[0.04] p-1">
            {languages.map((item) => (
              <button
                key={item.value}
                className={`h-10 rounded-[11px] text-xs font-black transition ${
                  language === item.value ? 'bg-fi-violet text-white shadow-glow' : 'text-white/55'
                }`}
                type="button"
                onClick={() => setLanguage(item.value)}
              >
                {item.label}
              </button>
            ))}
          </div>
          {t.navItems.map((item) => (
            <a key={item.href} className="rounded-2xl px-3 py-3 hover:bg-white/8 hover:text-white" href={item.href} onClick={closeMenu}>
              {item.label}
            </a>
          ))}
        </nav>
      )}
    </header>
  );
}
