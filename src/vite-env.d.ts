/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_PADDLE_CLIENT_TOKEN?: string;
  readonly VITE_PADDLE_PRICE_ID?: string;
  readonly VITE_PADDLE_ENV?: 'sandbox' | 'production';
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
