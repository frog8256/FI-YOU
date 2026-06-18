import React from 'react';
import ReactDOM from 'react-dom/client';
import { App } from './App';
import './index.css';

if (typeof window !== 'undefined' && 'serviceWorker' in window.navigator) {
  window.addEventListener('load', () => {
    window.navigator.serviceWorker.getRegistrations().then((registrations) => {
      registrations.forEach((registration) => registration.unregister());
    });
    if ('caches' in window) {
      window.caches.keys().then((keys) => {
        keys.forEach((key) => window.caches.delete(key));
      });
    }
  });
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
