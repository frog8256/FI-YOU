import { Bell, Play } from 'lucide-react';
import { useI18n } from '../lib/i18n';

export function FinalCTA() {
  const { t } = useI18n();

  return (
    <section id="download" className="bg-fi-canvas py-14">
      <div className="mx-auto max-w-[1120px] px-5 lg:px-0">
        <div className="grid gap-8 rounded-[20px] border border-fi-violet/35 bg-gradient-to-r from-fi-violet/22 to-fi-blue/10 p-8 shadow-glow md:grid-cols-[1fr_auto] md:items-center">
          <div>
            <h2 className="text-3xl font-black text-white">{t.finalCta.title}</h2>
            <p className="mt-4 text-lg font-medium text-fi-text">{t.finalCta.body}</p>
          </div>
          <div className="flex flex-col gap-4 sm:flex-row">
            <a className="inline-flex h-14 items-center justify-center gap-3 rounded-[10px] border border-white/12 bg-black/45 px-8 text-base font-black text-white" href="mailto:hello@fi-you.app?subject=FI-YOU%20Android%20waitlist">
              <Bell className="h-5 w-5" />
              {t.finalCta.primaryCta}
            </a>
            <a className="inline-flex h-14 items-center justify-center gap-3 rounded-[10px] border border-white/12 bg-black/45 px-8 text-base font-black text-white" href="#android-launch">
              <Play className="h-5 w-5" />
              {t.finalCta.secondaryCta}
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
