import { Calendar, LockKeyhole, MessageSquare, Orbit } from 'lucide-react';
import { useI18n } from '../lib/i18n';

const icons = [MessageSquare, Orbit, Calendar, LockKeyhole];

export function AboutSection() {
  const { t } = useI18n();

  return (
    <section id="service" className="bg-fi-canvas py-16 sm:py-20">
      <div className="mx-auto max-w-[1120px] px-5 lg:px-0">
        <div className="text-center">
          <p className="text-sm font-black uppercase tracking-normal text-fi-blue">{t.about.eyebrow}</p>
          <h2 className="mt-4 text-3xl font-black text-white sm:text-[34px]">{t.about.title}</h2>
        </div>

        <div className="mt-11 grid gap-5 md:grid-cols-2 lg:grid-cols-4">
          {t.about.cards.map((card, index) => {
            const Icon = icons[index];
            return (
              <article key={card.title} className="min-h-[210px] rounded-[16px] border border-white/10 bg-card p-7 shadow-card">
                <span className="grid h-14 w-14 place-items-center rounded-full bg-fi-violet/20 text-fi-violetSoft shadow-glow">
                  <Icon className="h-6 w-6" />
                </span>
                <h3 className="mt-7 text-lg font-black text-white">{card.title}</h3>
                <p className="mt-4 text-sm font-medium leading-6 text-fi-text">{card.body}</p>
              </article>
            );
          })}
        </div>
      </div>
    </section>
  );
}
