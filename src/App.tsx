import { AboutSection } from './components/AboutSection';
import { ExplorationAreas } from './components/ExplorationAreas';
import { FinalCTA } from './components/FinalCTA';
import { Footer } from './components/Footer';
import { Header } from './components/Header';
import { Hero } from './components/Hero';
import { HowItWorks } from './components/HowItWorks';
import { LegalPage, LegalPageType } from './components/LegalPage';
import { PaddleCheckoutPage } from './components/PaddleCheckoutPage';
import { PhilosophySection } from './components/PhilosophySection';
import { ReportPreview } from './components/ReportPreview';
import { LanguageProvider } from './lib/i18n';

export function App() {
  return (
    <LanguageProvider>
      <AppRoutes />
    </LanguageProvider>
  );
}

function AppRoutes() {
  const pathname = window.location.pathname;
  const legalRoutes: Record<string, LegalPageType> = {
    '/terms': 'terms',
    '/privacy': 'privacy',
    '/disclaimer': 'disclaimer',
    '/refund': 'refund'
  };

  if (pathname in legalRoutes) {
    return <LegalPage type={legalRoutes[pathname]} />;
  }

  if (pathname === '/checkout') {
    return <PaddleCheckoutPage />;
  }

  return (
    <div className="min-h-screen bg-fi-canvas text-fi-ink">
      <Header />
      <main>
        <Hero />
        <AboutSection />
        <ExplorationAreas />
        <HowItWorks />
        <ReportPreview />
        <PhilosophySection />
        <FinalCTA />
      </main>
      <Footer />
    </div>
  );
}
