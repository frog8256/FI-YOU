import { MessageSquare, Orbit, Star, TrendingUp } from 'lucide-react';
import { useI18n } from '../lib/i18n';

const icons = [MessageSquare, Orbit, TrendingUp, Star];

export function HowItWorks() {
  const { t } = useI18n();

  return (
    <section id="how-it-works" className="bg-fi-canvas py-16 sm:py-20">
      <div className="mx-auto max-w-[1120px] px-5 lg:px-0">
        <div className="text-center">
          <p className="text-sm font-black uppercase tracking-normal text-fi-blue">{t.how.eyebrow}</p>
          <h2 className="mt-4 text-3xl font-black text-white sm:text-[34px]">{t.how.title}</h2>
        </div>

        <div className="mt-12 grid gap-8 md:grid-cols-4">
          {t.how.steps.map((step, index) => {
            const Icon = icons[index];
            return (
              <article key={step.title} className="relative text-center">
                {index < t.how.steps.length - 1 && <span className="absolute left-[58%] top-9 hidden h-px w-[84%] border-t border-dashed border-white/20 md:block" />}
                <div className="relative mx-auto grid h-20 w-20 place-items-center rounded-full border border-white/10 bg-fi-violet/12 shadow-card">
                  <Icon className="h-8 w-8 text-fi-blue" />
                </div>
                <p className="mt-6 text-sm font-black text-fi-violetSoft">{String(index + 1).padStart(2, '0')}</p>
                <h3 className="mt-3 text-lg font-black text-white">{step.title}</h3>
                <p className="mx-auto mt-3 max-w-[190px] text-sm font-medium leading-6 text-fi-text">{step.body}</p>
              </article>
            );
          })}
        </div>
      </div>
    </section>
  );
}
