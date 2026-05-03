# Firebase Hosting for Privacy Policy

This repo is configured so the `docs` folder can be deployed to Firebase Hosting.

## What will be public

- `https://<your-site>.web.app/`
- `https://<your-site>.firebaseapp.com/`

Both will open `privacy-policy.html`.

## Deploy

Run from the project root:

```powershell
firebase deploy --only hosting --project pet-shop-app-ee6f2
```

If Firebase asks to enable Hosting first, accept it.

## Recommended Play Store URL

Use one of these in Play Console after deploy:

- `https://pet-shop-app-ee6f2.web.app/`
- `https://pet-shop-app-ee6f2.firebaseapp.com/`

## Note

If you later add a custom domain, update Play Console to that final URL.
