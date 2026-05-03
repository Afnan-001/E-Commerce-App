# PetsWorld App Guide

Client handover document

Prepared on 03 May 2026

## 1. App Overview

PetsWorld is a mobile shopping app for pet products and grooming items. Customers can browse products, save favourites, add items to cart, place orders, view invoices, and contact support. The same app also includes an admin area where the store team can manage products, categories, banners, coupons, orders, delivery settings, and payment settings.

The app is built with Flutter and uses Firebase for login, user data, catalog data, cart, saved items, addresses, and orders.

## 2. Main Customer Features

### Account and Login

- Customers can create an account using email and password.
- Customers can sign in with Google.
- Customers can use phone number login or signup with OTP.
- Customers can reset their password if they forget it.
- Customer profile data is stored securely in Firebase.

How to use:

1. Open the app.
2. Choose Login, Sign up, Google Sign-In, or Phone login.
3. Enter the required details.
4. After login, the customer reaches the main shopping area.

### Home Screen

- Shows the PetsWorld brand header.
- Shows admin-managed banners and promotional sections.
- Shows categories, popular products, best sellers, featured items, and new arrivals.
- Customers can tap any product or category to view more details.

How to use:

1. Open the Shop tab.
2. Scroll through banners and product sections.
3. Tap a category to browse related products.
4. Tap a product card to open product details.

### Discover and Categories

- Customers can browse products by category.
- Categories can be managed from the admin panel.
- Category browsing helps customers quickly find food, grooming, accessories, and other pet products.

How to use:

1. Tap the Discover tab.
2. Select a category.
3. View the available products.
4. Open a product to see details and buying options.

### Product Details

- Shows product images, name, brand, price, sale price, discount, description, and stock availability.
- Supports multiple product images.
- Supports pack or size options with different prices and stock.
- Shows product review information where available.
- Customers can add the product to cart or buy it immediately.

How to use:

1. Open a product.
2. Select the required pack or option if shown.
3. Check price and availability.
4. Tap Add to cart or continue to checkout.

### Saved Products

- Customers can save products they like.
- Saved products are linked to the customer account and synced with Firebase.

How to use:

1. Tap the save/bookmark icon on a product.
2. Open the Saved tab to view saved products.
3. Tap a saved item to open it again.

### Cart

- Customers can add products to cart.
- Cart items are saved per customer.
- Customers can increase or decrease quantity.
- Customers can remove products.
- The cart shows item total, delivery fee, discount, and final amount.

How to use:

1. Add products to cart.
2. Open Cart from the profile or checkout flow.
3. Review items and quantities.
4. Tap Proceed to checkout.

### Address Management

- Customers can add delivery addresses.
- Customers can choose an address during checkout.
- A default address can be shown for quick selection.

How to use:

1. Go to Profile > Addresses, or add an address during checkout.
2. Enter name, phone number, and full delivery address.
3. Save the address.
4. Select the address when placing an order.

### Checkout and Payment

- Customers can review products, delivery address, delivery charges, coupon discounts, and final total before placing an order.
- Cash on Delivery is supported.
- Razorpay online payment is supported when enabled and configured from the admin settings.
- If online payment is disabled, checkout can work as Cash on Delivery only.

How to use:

1. Open Cart and tap Proceed to checkout.
2. Select or add a delivery address.
3. Apply a coupon if available.
4. Choose the payment option shown in the app.
5. Confirm the order.

### Orders and Invoice

- Customers can view their order history.
- Orders show status such as placed, confirmed, shipped, delivered, or cancelled.
- Customers can download or open an invoice PDF.
- Customers can cancel an order where cancellation is available.

How to use:

1. Go to Profile > Orders.
2. Open the order list.
3. Tap Invoice to view the invoice.
4. Use Cancel order only if the order is still eligible for cancellation.

### Profile, Theme, and Support

- Customers can view profile details.
- Customers can switch app theme preference.
- Customers can see saved item count, cart count, and pending order count.
- Customers can contact support on WhatsApp.
- Customers can delete their account if required.

How to use:

1. Open the Profile tab.
2. Use Shopping options for Orders, Saved products, Addresses, and Cart.
3. Use Customer support to chat on WhatsApp.
4. Use Log out to safely sign out.

## 3. Admin Features

Admin access is available only for accounts marked as admin.

### Admin Dashboard

- Shows delivered revenue.
- Shows open orders.
- Shows product and category summary.
- Shows active banners.
- Shows recent orders.
- Shows category breakdown.
- Shows system health for Firebase, Cloudinary, and Razorpay setup.

How to use:

1. Log in with an admin account.
2. Go to Profile > Admin panel.
3. Review store performance and use quick actions.

### Manage Products

- Add, edit, and delete products.
- Upload up to 5 product images.
- Add product name, brand, category, description, price, sale price, discount, and stock.
- Add pack options such as different sizes or quantities.
- Mark products as featured, best seller, new arrival, active, or inactive.

How to use:

1. Open Admin panel > Products.
2. Tap Add product for a new item, or Edit for an existing item.
3. Fill product details and upload images.
4. Save the product.

### Manage Categories

- Add, edit, and delete categories.
- Add category image or icon.
- Create major categories and subcategories.
- Hide or show categories in the app.

How to use:

1. Open Admin panel > Categories.
2. Tap Add category.
3. Enter category title and image/icon details.
4. Save the category.

### Manage Home Banners

- Add, edit, and delete home page banners.
- Upload banner images.
- Show or hide banners on the home screen.
- Control what customers see first on the Shop tab.

How to use:

1. Open Admin panel > Banners.
2. Add a new banner or edit an existing banner.
3. Upload the banner image.
4. Enable Show banner on home.
5. Save.

### Manage Home Sections

- Create custom home page product sections.
- Select products for each section.
- Show or hide sections.
- Apply section discounts where required.

How to use:

1. Open Admin panel > Home sections.
2. Tap Add section.
3. Enter section title and select products.
4. Save and enable the section.

### Manage Coupons

- Create flat amount or percentage discount coupons.
- Apply coupons to all products, selected categories, or selected products.
- Set minimum cart value.
- Set expiry date.
- Set usage limit.
- Turn coupons active or inactive.

How to use:

1. Open Admin panel > Coupons.
2. Tap Add coupon.
3. Enter coupon code and discount details.
4. Choose where the coupon applies.
5. Save the coupon.

### Manage Orders

- View all customer orders.
- See customer details, delivery address, products, quantities, and payment amount.
- Update order status: placed, confirmed, shipped, delivered, or cancelled.
- Generate invoice.
- Export orders to Excel for reporting.

How to use:

1. Open Admin panel > Orders.
2. Select an order.
3. Review the order details.
4. Update status as the order moves through fulfilment.
5. Use Export when a report is needed.

### Store Settings

- Set WhatsApp support number.
- Enable or disable Razorpay online payment.
- Add Razorpay key ID, backend URL, currency, merchant name, and checkout description.
- Set delivery fee.
- Set free delivery order value.

How to use:

1. Open Admin panel > Delivery or Store settings.
2. Update WhatsApp support, payment, and delivery values.
3. Save settings.

## 4. Backend and Services Used

- Firebase Authentication: customer and admin login.
- Cloud Firestore: users, products, categories, cart, saved items, addresses, coupons, banners, home sections, settings, and orders.
- Cloudinary: product, category, and banner image uploads.
- Razorpay: optional online payment checkout.
- PDF generation: invoice generation for orders.

## 5. Simple Customer Journey

1. Customer signs up or logs in.
2. Customer browses products from Shop or Discover.
3. Customer opens product details and selects a pack option.
4. Customer adds product to cart.
5. Customer selects delivery address.
6. Customer applies coupon if available.
7. Customer chooses Cash on Delivery or Razorpay if enabled.
8. Customer places order.
9. Customer views order status and invoice from Profile > Orders.

## 6. Simple Admin Journey

1. Admin logs in with an admin account.
2. Admin opens Profile > Admin panel.
3. Admin adds categories and products.
4. Admin uploads product and banner images.
5. Admin creates home banners, sections, and coupons.
6. Admin checks new orders.
7. Admin updates order status until delivered.
8. Admin exports order data when needed.

## 7. Notes for the Client

- Product, category, banner, coupon, and order data are managed from the admin panel.
- A user must have the admin role to access admin features.
- Online payment requires both the app settings and a matching secure backend for Razorpay order creation and signature verification.
- Cloudinary must be configured before image uploads work.
- The WhatsApp support button works after a valid support number is saved in store settings.
- The app supports light, dark, and device theme preference.

