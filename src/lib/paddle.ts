import { initializePaddle, type Paddle } from '@paddle/paddle-js';

let paddleInstance: Paddle | undefined;
let paddlePromise: Promise<Paddle | undefined> | undefined;

export const paddleConfig = {
  environment: import.meta.env.VITE_PADDLE_ENV === 'sandbox' ? 'sandbox' : 'production',
  clientToken: import.meta.env.VITE_PADDLE_CLIENT_TOKEN ?? '',
  priceId: import.meta.env.VITE_PADDLE_PRICE_ID ?? ''
} as const;

export function hasPaddleCheckoutConfig() {
  return Boolean(paddleConfig.clientToken && paddleConfig.priceId);
}

export async function getPaddle() {
  if (!paddleConfig.clientToken) {
    return undefined;
  }

  if (paddleInstance) {
    return paddleInstance;
  }

  paddlePromise ??= initializePaddle({
    environment: paddleConfig.environment,
    token: paddleConfig.clientToken
  }).then((paddle) => {
    paddleInstance = paddle;
    return paddle;
  });

  return paddlePromise;
}

export async function openPaddleCheckout() {
  if (!hasPaddleCheckoutConfig()) {
    throw new Error('Paddle checkout is missing VITE_PADDLE_CLIENT_TOKEN or VITE_PADDLE_PRICE_ID.');
  }

  const paddle = await getPaddle();

  if (!paddle) {
    throw new Error('Paddle could not be initialized.');
  }

  paddle.Checkout.open({
    items: [
      {
        priceId: paddleConfig.priceId,
        quantity: 1
      }
    ]
  });
}
