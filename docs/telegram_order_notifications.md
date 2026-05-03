# Telegram Order Notifications

PetsWorld can send a Telegram message to the admin whenever a new order is created in Firestore.

## What this does

- Watches the `orders` collection
- Sends a Telegram bot message when a new order arrives
- Keeps the Telegram bot token out of the Flutter app

## Setup

1. Create a Telegram bot with `@BotFather`
2. Copy the bot token
3. Create or choose a private Telegram chat/group where the admin should receive notifications
4. Add the bot to that chat/group
5. Find the Telegram chat ID

## Set Firebase function secrets

Run these commands from the project root:

```bash
firebase functions:secrets:set TELEGRAM_BOT_TOKEN
firebase functions:secrets:set TELEGRAM_CHAT_ID
```

Then deploy the function:

```bash
firebase deploy --only functions
```

## Notes

- The function is defined in `functions/index.js`
- It triggers only when a new Firestore order document is created
- Telegram messages include order ID, customer, phone, address, payment details, total, and items

## Important

- This setup keeps the bot token server-side, which is safer than storing it in the mobile app
- Firebase Functions may require enabling billing on your Firebase project, even if your usage stays very low
