import { useI18n } from '../lib/i18n';

type BrandSymbolProps = {
  compact?: boolean;
};

export function BrandSymbol({ compact = false }: BrandSymbolProps) {
  const { t } = useI18n();

  return (
    <div className="flex items-center gap-3" aria-label="FI-YOU">
      <div className="grid h-8 w-8 place-items-center rounded-[13px] bg-button text-xs font-black text-white shadow-glow" aria-hidden="true">
        <span className="h-2 w-2 rounded-full border border-white/80" />
      </div>
      <div className="leading-none">
        <span className="block text-lg font-black text-white">FI-YOU</span>
        {!compact && <span className="mt-1 block text-xs font-semibold text-fi-muted">{t.common.brandSubtitle}</span>}
      </div>
    </div>
  );
}
