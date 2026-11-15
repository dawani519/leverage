# Leverage

A peer-to-peer marketplace mobile app for Nigeria with escrow-style payments and a wallet. It is a Flutter app backed by Firebase, with a small Python service for verifying Paystack payments. A Laravel rebuild of the platform lives in a separate repository, `leverage-web`.

## Stack

- Flutter (Dart) for Android, iOS, web, Windows and Linux targets
- Firebase: Authentication, Cloud Firestore, Storage, Cloud Messaging, Analytics and Crashlytics
- Payments: Paystack (`flutter_paystack_plus`, `pay_with_paystack`) and Flutterwave
- `functions/`: a Flask service (`main.py`) that verifies Paystack payments and credits the user in Firestore

## Features

- Sign-up and sign-in, a welcome flow, and user profiles
- Marketplace: browse listings, product details, search, and selling
- Chat between users, with notifications
- Wallet: deposit, withdraw and transaction history
- Become a broker application and broker page
- Nigerian state and LGA pickers, light and dark mode

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install).
2. Create your own Firebase project and run `flutterfire configure`. This generates `lib/firebase_options.dart` and `android/app/google-services.json`, which are not stored in this repository.
3. Install dependencies and run:

   ```bash
   flutter pub get
   flutter run
   ```

### Payment verification service

```bash
cd functions
pip install -r requirements.txt
```

Before running `main.py`:

- Set your Paystack **secret** key in place of the `YOUR_PAYSTACK_SECRET_KEY` placeholder, preferably from an environment variable rather than in source.
- Point it at your own Firebase service-account key file.

## Security

- Never commit a Firebase service-account key (`*-firebase-adminsdk-*.json` or similar) or a Paystack secret key. If one was ever exposed, revoke and replace it in the Firebase or Paystack dashboard.
- Verify payments on the server only, and never trust the client to report a payment as successful.

## Related

`leverage-web` is the Laravel + Livewire rebuild, with a double-entry ledger and an escrow state machine, intended to become the API for this app.
