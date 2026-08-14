# FLUTTER HOTEL & RESORT BOOKING PORTAL — SYSTEM ARCHITECTURE

## 1. Executive Summary
The Flutter Hotel & Resort Booking Portal is an enterprise-grade multi-property reservation management platform built with Flutter, Firebase Authentication, Cloud Firestore, Cloud Functions, and Firebase Cloud Messaging (FCM).

---

## 2. Technology Stack
- **Frontend Framework**: Flutter (Dart)
- **Database**: Firebase Cloud Firestore
- **Authentication**: Firebase Authentication
- **Security**: Firestore Security Rules (Field-level & Property-level access control)
- **State Management & Data Flow**: Service-Repository-Model Modular Architecture

---

## 3. Database Schema Overview (28 Collections)
1. `users`: Guest profile data & authentication mapping.
2. `admins`: Administrative accounts with multi-property scoping (`propertyIds`) and role hierarchy (`superAdmin`, `propertyAdmin`, `manager`, `receptionist`, `bookingManager`, `contentManager`).
3. `properties`: Multi-property records (Lansdowne, Agra, Jaipur, etc.).
4. `roomTypes`: Property room categories with base prices, weekend prices, max occupancy, and extra adult rates.
5. `rooms`: Physical room inventory instances linked to `roomTypes` with live status (`available`, `reserved`, `occupied`, `cleaning`, `maintenance`, `blocked`).
6. `roomInventory`: Date-wise room availability matrix.
7. `bookings`: Master reservation records with human-readable ID (`HTL-YYYYMMDD-XXXXXX`), check-in/out dates, guest details, paid/remaining amounts, and `pricingSnapshot`.
8. `reservationAllocations`: Atomic physical room allocations per night.
9. `bookingEvents`: Audit log of booking state transitions.
10. `payments`: Verified transaction records with gateway order/payment IDs, signature verification status, and payment types (`bookingPayment`, `balancePayment`, `manualPayment`).
11. `paymentOrders`: Temporary server-side payment order tracking.
12. `refunds`: Full and partial refund requests and disbursements with refundable balance enforcement.
13. `paymentEvents`: Webhook event log for idempotency verification.
14. `offers`: Promotional discount campaigns with stacking limits and priority rules.
15. `coupons`: Discount codes with uppercase normalization and usage caps.
16. `couponUsages`: Per-user coupon redemption audit trail.
17. `packages`: Vacation, honeymoon, and festival bundles.
18. `addons`: Guest-purchased extras (Airport Pickup, Extra Bed, Spa).
19. `pricingRules`: Seasonal, weekend, and date-specific rate rules.
20. `priceQuotes`: Temporary 15-minute verified price quotes.
21. `invoices`: Formal invoice records (`INV-YYYY-XXXXXX`).
22. `bookingCharges`: Extra room charges (food, laundry, room service).
23. `reviews`: Guest stay ratings and moderation statuses.
24. `cmsBanners`: Homepage hero carousel banners.
25. `cmsFAQs`: Categorized FAQ entries.
26. `cmsLegal`: Version-controlled legal documents (Terms, Cancellation policy).
27. `notifications`: Inbox and push notifications.
28. `auditLogs`: System audit trail.
