import { useI18n } from '../lib/i18n';
import { BrandSymbol } from './BrandSymbol';

export function Footer() {
  const { t } = useI18n();

  return (
    <footer className="border-t border-white/10 bg-fi-canvas">
      <div className="mx-auto grid max-w-[1120px] gap-10 px-5 py-12 lg:grid-cols-[1.25fr_0.8fr_0.8fr_0.8fr_300px] lg:px-0">
        <div>
          <BrandSymbol />
          <p className="mt-5 text-sm font-medium leading-7 text-fi-text">{t.common.brandSubtitle}</p>
          <p className="mt-5 text-sm font-medium text-fi-muted">© 2026 FI-YOU. All rights reserved.</p>
        </div>

        <div>
          <h3 className="text-sm font-black text-white">{t.footer.service}</h3>
          <nav className="mt-4 grid gap-3 text-sm font-medium text-fi-text">
            <a href="/#u-map">U-Map</a>
            <a href="/#service">{t.footer.diary}</a>
            <a href="/#android-launch">{t.footer.report}</a>
          </nav>
        </div>

        <div>
          <h3 className="text-sm font-black text-white">{t.footer.company}</h3>
          <nav className="mt-4 grid gap-3 text-sm font-medium text-fi-text">
            <a href="/#service">{t.footer.about}</a>
            <a href="/#download">{t.footer.launch}</a>
          </nav>
        </div>

        <div>
          <h3 className="text-sm font-black text-white">{t.footer.support}</h3>
          <nav className="mt-4 grid gap-3 text-sm font-medium text-fi-text">
            <a href="mailto:hello@fi-you.app">{t.footer.contact}</a>
            <a href="/terms">{t.footer.terms}</a>
            <a href="/privacy">{t.footer.privacy}</a>
            <a href="/disclaimer">{t.footer.disclaimer}</a>
            <a href="/refund">{t.footer.refund}</a>
          </nav>
        </div>

        <div className="flex items-start lg:justify-end">
          <img
            className="-mt-8 w-[240px] max-w-full opacity-85 mix-blend-screen lg:w-[300px]"
            src="/dna-white.png"
            alt="DNA Studio"
            loading="lazy"
          />
        </div>
      </div>
    </footer>
  );
}
