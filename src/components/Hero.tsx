import { ArrowRight, BrainCircuit, CirclePlay, Home, PenSquare, User, Waypoints } from 'lucide-react';
import { useI18n } from '../lib/i18n';

export function Hero() {
  const { t } = useI18n();

  return (
    <section className="relative overflow-hidden bg-fi-canvas">
      <div className="hero-orbits" aria-hidden="true">
        <span />
        <span />
      </div>

      <div className="mx-auto grid min-h-[690px] max-w-[1120px] items-center gap-10 px-5 pb-20 pt-14 lg:grid-cols-[0.98fr_1.02fr] lg:px-0">
        <div className="relative z-10">
          <p className="inline-flex items-center gap-2 rounded-full border border-white/12 bg-white/[0.025] px-4 py-2 text-xs font-bold text-white/78">
            <Waypoints className="h-4 w-4 text-fi-violetSoft" />
            {t.hero.badge}
          </p>
          <h1 className="mt-8 max-w-[620px] text-5xl font-black leading-[1.14] text-white sm:text-6xl lg:text-[56px]">
            {t.hero.titleTop}
            <span className="block bg-gradient-to-r from-fi-blue via-fi-violetSoft to-fi-purple bg-clip-text text-transparent">{t.hero.titleBottom}</span>
          </h1>
          <p className="mt-7 max-w-[470px] text-lg font-medium leading-8 text-fi-text">
            {t.hero.description}
          </p>

          <div className="mt-9 flex flex-col gap-4 sm:flex-row">
            <a className="inline-flex h-14 items-center justify-center gap-3 rounded-[16px] bg-button px-7 text-sm font-black text-white shadow-glow transition hover:-translate-y-0.5" href="#download">
              {t.hero.primaryCta}
              <ArrowRight className="h-4 w-4" />
            </a>
            <a className="inline-flex h-14 items-center justify-center gap-3 rounded-[16px] border border-white/14 bg-white/[0.025] px-7 text-sm font-black text-white transition hover:bg-white/[0.06]" href="#service">
              {t.hero.secondaryCta}
              <CirclePlay className="h-4 w-4" />
            </a>
          </div>

        </div>

        <div className="relative z-10 mx-auto w-full max-w-[300px]">
          <div className="phone-shell relative min-h-[520px] rounded-[42px] border-[5px] border-black/70 p-4 shadow-phone ring-1 ring-white/20">
            <div className="phone-notch" />
            <div className="relative flex items-center justify-between pt-3 text-[10px] font-black text-white">
              <span>9:41</span>
              <span>5G 100%</span>
            </div>

            <div className="relative mt-8">
              <p className="text-xs font-black text-fi-violetSoft">{t.hero.phoneEyebrow}</p>
              <h2 className="mt-2 text-xl font-black leading-tight text-white">{t.hero.phoneTitle}</h2>

              <div className="mt-5 rounded-[18px] border border-white/10 bg-white/[0.04] p-4 shadow-card">
                <div className="flex gap-3">
                  <span className="grid h-11 w-11 place-items-center rounded-[16px] bg-fi-cyan/10 text-fi-cyan">
                    <BrainCircuit className="h-5 w-5" />
                  </span>
                  <div>
                    <p className="text-xs font-black text-fi-cyan">Next Question</p>
                    <h3 className="mt-1 text-base font-black text-white">{t.hero.nextQuestion}</h3>
                  </div>
                </div>
                <div className="mt-5 h-2 overflow-hidden rounded-full bg-white/12">
                  <span className="block h-full w-2/3 rounded-full bg-gradient-to-r from-fi-violet to-fi-purple" />
                </div>
              </div>

              <div id="u-map" className="mt-5 rounded-[18px] border border-white/10 bg-white/[0.04] p-5 shadow-card">
                <p className="text-xs font-black text-white/70">U-Map Preview</p>
                <div className="mini-u-map">
                  <span className="mini-u-map-disc" />
                  <span className="mini-u-map-core" />
                  <span className="mini-u-map-node one" />
                  <span className="mini-u-map-node two" />
                  <span className="mini-u-map-node three" />
                </div>
              </div>

              <div className="mt-5 grid grid-cols-5 gap-2 text-[9px] font-bold text-fi-muted">
                {[Home, PenSquare, Waypoints, BrainCircuit, User].map((Icon, index) => (
                  <span key={index} className="grid justify-items-center gap-1">
                    <Icon className={`h-4 w-4 ${index === 2 ? 'text-fi-violetSoft' : 'text-fi-muted'}`} />
                    {t.hero.navLabels[index]}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
