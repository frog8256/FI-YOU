import { CreditCard, ShieldCheck } from 'lucide-react';
import { useState } from 'react';
import { hasPaddleCheckoutConfig, openPaddleCheckout, paddleConfig } from '../lib/paddle';
import { Footer } from './Footer';
import { Header } from './Header';

export function PaddleCheckoutPage() {
  const [status, setStatus] = useState<string | null>(null);
  const [isOpening, setIsOpening] = useState(false);
  const isConfigured = hasPaddleCheckoutConfig();

  const handleCheckout = async () => {
    setIsOpening(true);
    setStatus(null);

    try {
      await openPaddleCheckout();
      setStatus('Paddle Checkout을 열었습니다.');
    } catch (error) {
      setStatus(error instanceof Error ? error.message : 'Paddle Checkout을 열지 못했습니다.');
    } finally {
      setIsOpening(false);
    }
  };

  return (
    <div className="min-h-screen bg-fi-canvas text-white">
      <Header />
      <main>
        <section className="border-t border-white/8 px-5 py-16 lg:px-0">
          <div className="mx-auto max-w-[860px]">
            <p className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.03] px-4 py-2 text-xs font-black uppercase tracking-normal text-fi-gold">
              <ShieldCheck className="h-4 w-4" />
              Paddle Checkout
            </p>
            <h1 className="mt-7 text-4xl font-black leading-tight text-white sm:text-5xl">FI-YOU 결제 테스트</h1>
            <p className="mt-5 max-w-3xl text-lg font-medium leading-8 text-fi-text">
              이 페이지는 Paddle.js 초기화와 checkout 열기 확인용입니다. 실제 API key는 서버에만 보관하고, 이 화면은 client-side token과 price ID만 사용합니다.
            </p>

            <div className="mt-10 rounded-[18px] border border-white/10 bg-card p-7 shadow-card">
              <div className="grid gap-4 text-sm font-bold text-fi-text">
                <div className="flex flex-wrap items-center justify-between gap-3 border-b border-white/8 pb-4">
                  <span>Environment</span>
                  <span className="text-white">{paddleConfig.environment}</span>
                </div>
                <div className="flex flex-wrap items-center justify-between gap-3 border-b border-white/8 pb-4">
                  <span>Client-side token</span>
                  <span className={paddleConfig.clientToken ? 'text-fi-mint' : 'text-fi-gold'}>{paddleConfig.clientToken ? 'Configured' : 'Missing'}</span>
                </div>
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <span>Price ID</span>
                  <span className={paddleConfig.priceId ? 'text-fi-mint' : 'text-fi-gold'}>{paddleConfig.priceId ? paddleConfig.priceId : 'Missing'}</span>
                </div>
              </div>

              <button
                className="mt-8 inline-flex h-14 items-center justify-center gap-3 rounded-[10px] bg-button px-8 text-base font-black text-white shadow-glow transition hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0"
                type="button"
                disabled={!isConfigured || isOpening}
                onClick={handleCheckout}
              >
                <CreditCard className="h-5 w-5" />
                {isOpening ? 'Checkout 여는 중' : 'Paddle Checkout 열기'}
              </button>

              {status && <p className="mt-5 rounded-[14px] border border-white/10 bg-white/[0.03] p-4 text-sm font-bold text-fi-text">{status}</p>}
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </div>
  );
}
