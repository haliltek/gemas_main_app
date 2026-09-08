# Gemaş Mobile App - Push Notification Admin Panel Guide

This guide describes how to send push notifications to Gemaş Mobile App users via Firebase Cloud Messaging (FCM HTTP v1 API) from your custom Admin Panel.

See Turkish version for in-depth details: [BILDIRIM_PANELI_REHBERI.md](BILDIRIM_PANELI_REHBERI.md).

---

## 1. Firebase Project Details
- **Project ID:** `gemascompanyapp-3478b`
- **Sender ID:** `1011766388778`
- **Package Name:** `com.tr.gemas.mobile.app`
- **Android Notification Channel ID:** `gemas_high_importance_channel`
- **Android Notification Channel Name:** `Gemaş Bildirimleri`

---

## 2. Topic List
- `allUsers`: Broadcast to all app users (Recommended for general announcements).
- `NewsFromGemas`: General announcements and company news.
- `newProductsTR` / `newProductsEN`: New product alerts.
- `newNewsTR` / `newNewsEN`: News & announcements by language.
- `updateSparePartsTR` / `updateSparePartsEN`: Spare parts catalog updates.
- `updateProductPriceTR` / `updateProductPriceEN`: Price list updates.
- `updateDocumentationTR` / `updateDocumentationEN`: Document updates.

---

## 3. Deep Linking via `stockCode`
When you include `"stockCode"` in the `data` payload:
```json
{
  "message": {
    "topic": "allUsers",
    "notification": {
      "title": "New Product Available",
      "body": "Check out our newest filtration pump!"
    },
    "data": {
      "stockCode": "011111"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "gemas_high_importance_channel",
        "sound": "default"
      }
    }
  }
}
```
The app will automatically open `https://gemas.com.tr/api/v1/{lang}/productByStockCode/{stockCode}` and display the `ProductPage` directly to the user upon clicking the notification.
