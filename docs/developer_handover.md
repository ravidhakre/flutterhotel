# DEVELOPER HANDOVER & DEPLOYMENT GUIDE

## 1. Project Overview
This repository contains the backend architecture, administrative control center, commercial pricing engine, payment verification services, and security foundation for the Flutter Hotel & Resort Booking Portal.

---

## 2. Directory Layout
```text
lib/
├── admin/               # Admin Control Center UI Screens
│   ├── screens/         # Dashboard, Front Desk, Bookings, Commercial, Payments, Analytics, CMS, Reviews, Reports
├── core/                # Constants, Errors, Loggers, Config, Validators
├── firebase/            # Firebase Services Initialization
├── models/              # 23 Data Models (Booking, Payment, Offer, Coupon, Package, Addon, Review, CMS, etc.)
├── repositories/        # 18 Data Access Repositories
└── services/            # 22 Modular Backend Services (Booking, Pricing, Availability, Payment, Refund, Analytics, etc.)
```

---

## 3. Environment Configuration & Deployment
- Deploy Security Rules: `firebase deploy --only firestore:rules`
- Deploy Query Indexes: `firebase deploy --only firestore:indexes`

---

## 4. Payment Gateway Webhook Integration
1. Set Payment Secret in Firebase Secrets Manager: `firebase functions:secrets:set RAZORPAY_SECRET`
2. Configure Webhook URL in Gateway Dashboard pointing to `https://us-central1-<project-id>.cloudfunctions.net/handlePaymentWebhook`

---

## 5. Security Principles Enforced
- **Zero Client Secrets**: No API keys or webhook secrets in Flutter source code.
- **Price Tamper Protection**: Server recalculates booking totals using stored room rate logic.
- **Double-Booking Prevention**: Double-booking prevented via Firestore transactions in `createBookingHoldTransaction()`.
