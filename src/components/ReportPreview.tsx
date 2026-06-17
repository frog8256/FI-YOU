import { BookOpen, Orbit, Sparkles } from 'lucide-react';
import { useI18n } from '../lib/i18n';

const icons = [Orbit, BookOpen, Sparkles];

export function ReportPreview() {
  const { t } = useI18n();

  return (
    <section id="android-launch" className="bg-fi-canvas py-16 sm:py-20">
      <div className="mx-auto max-w-[1120px] px-5 lg:px-0">
        <div className="text-center">
          <p className="text-sm font-black text-fi-blue">{t.stories.eyebrow}</p>
          <h2 className="mt-4 text-3xl font-black text-white sm:text-[34px]">{t.stories.title}</h2>
        </div>

        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {t.stories.cards.map((item, index) => {
            const Icon = icons[index];

            return (
              <article key={item.title} className="rounded-[16px] border border-white/10 bg-card p-7 shadow-card">
                <span className="grid h-11 w-11 place-items-center rounded-full bg-gradient-to-br from-fi-blue to-fi-purple text-sm font-black text-white">
                  <Icon className="h-5 w-5" />
                </span>
                <p className="mt-6 text-xs font-black uppercase tracking-normal text-fi-violetSoft">{item.status}</p>
                <h3 className="mt-3 text-lg font-black text-white">{item.title}</h3>
                <p className="mt-4 min-h-[120px] text-sm font-medium leading-7 text-fi-text">{item.body}</p>
              </article>
            );
          })}
        </div>
      </div>
    </section>
  );
}
