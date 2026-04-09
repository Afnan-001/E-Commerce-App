# PetsWorld - Flutter + Firebase Pet Store App

PetsWorld is a pet products and grooming eCommerce app built with Flutter.

It includes:
- User app (catalog, cart, saved items, checkout, orders)
- Admin panel inside the same app (role-based access)
- Firebase Auth + Firestore backend
- Cloudinary image uploads for product/banner media
- COD-only order flow
- Light / Dark / Device theme mode

## Core Features

### User
- Email/password login and signup
- Google Sign-In
- Phone number signup/login with OTP verification
- Home with dynamic admin-managed banner
- Category and product browse from Firestore
- Product details and reviews
- Saved items synced to Firestore per user
- Cart synced to Firestore per user
- Checkout (Cash on Delivery)
- Order history and pending/completed order states
- PDF invoice generation after order

### Admin
- Admin login via user role check
- Add/edit/delete categories and products
- Upload product/banner images to Cloudinary
- View all orders
- Update order status (Pending / Completed)

## Firestore Model (Current)

### `users/{uid}`
- `uid`
- `name`
- `email`
- `phoneNumber`
- `role` (`user` or `admin`)
- `createdAt`

### `products/{productId}`
- `name`
- `price`
- `category`
- `imageUrl`
- `description`
- `isFeatured`

### `orders/{orderId}`
- `userId`
- `items[]`
- `totalPrice`
- `paymentStatus` (`COD`)
- `orderStatus`
- `timestamp`

## Tech Stack
- Flutter
- Provider (state management)
- Firebase Auth
- Cloud Firestore
- Cloudinary
- `pdf` + `printing`

## Project Structure (High-level)

```
lib/
  core/
  models/
  providers/
  repositories/
  route/
  screens/
  theme/
```

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Configure Firebase:
- Add Android/iOS Firebase app configs
- Ensure Auth providers are enabled:
  - Email/Password
  - Google
  - Phone

3. Android SHA setup (required for Google/Phone auth):
- Add SHA-1 and SHA-256 in Firebase console for your Android app

4. Firestore rules:
- Use your `firestore.rules` aligned to your security requirements

5. Cloudinary:
- Update Cloudinary values in:
  - `lib/core/config/cloudinary_config.dart`

6. Run app:
```bash
flutter run
```

## Notes
- Cart/saved/orders are user-scoped and synced with Firestore.
- On checkout success, cart items are cleared from Firestore.
- If phone-auth users do not have email in Firebase Auth, profile email is still editable and stored in Firestore profile data.

## Current App Name
- `PetsWorld`
