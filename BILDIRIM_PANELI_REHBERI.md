# Gemaş Mobil Uygulaması - Bildirim (Push Notification) Yönetim Paneli Entegrasyon Rehberi

Bu belge, Gemaş mobil uygulamasına web yönetim panelinizden veya sunucunuzdan anlık bildirim (Push Notification) gönderebilmeniz için gereken tüm teknik gereksinimleri, Firebase HTTP v1 API yapılandırmasını, konu (topic) listesini ve örnek kodları içermektedir.

---

## 1. Firebase Proje Bilgileri

- **Proje ID (Project ID):** `gemascompanyapp-3478b`
- **Sender ID (Project Number):** `1011766388778`
- **Android Paket Adı:** `com.tr.gemas.mobile.app`
- **iOS Bundle Identifier:** `com.tr.gemas.mobile.app`
- **Android Bildirim Kanal ID (Channel ID):** `gemas_high_importance_channel`
- **Android Bildirim Kanal Adı:** `Gemaş Bildirimleri`

---

## 2. Abone Olunan Konular (Topics)

Uygulama açıldığında kullanıcılar cihaz diline ve genel yayınlara göre aşağıdaki konulara otomatik olarak abone edilmektedir:

| Konu (Topic) Adı | Hedef Kitle | Kullanım Amacı |
|---|---|---|
| **`allUsers`** | **Tüm Kullanıcılar** | Dil fark etmeksizin tüm kullanıcılara genel duyuru ve kampanya |
| **`NewsFromGemas`** | Tüm Kullanıcılar | Şirket içi ve genel Gemaş duyuruları |
| **`newProductsTR`** | Türkçe Kullanıcılar | Yeni eklenen ürün tanıtımları (Türkçe) |
| **`newProductsEN`** | Yabancı Dil Kullanıcılar | Yeni ürün tanıtımları (İngilizce / Global) |
| **`newNewsTR`** | Türkçe Kullanıcılar | Yeni haberler ve duyurular (Türkçe) |
| **`newNewsEN`** | Yabancı Dil Kullanıcılar | Yeni haberler ve duyurular (İngilizce) |
| **`updateSparePartsTR`** | Türkçe Kullanıcılar | Yedek parça katalog güncellemeleri |
| **`updateProductPriceTR`** | Türkçe Kullanıcılar | Fiyat listesi güncellemeleri |
| **`updateDocumentationTR`** | Türkçe Kullanıcılar | Yeni teknik doküman ve kılavuz eklemeleri |

> **Öneri:** Yönetim panelinizden "Tüm Kullanıcılara Gönder" seçildiğinde hedef olarak **`allUsers`** konusunu kullanınız.

---

## 3. Bildirim Tıklama ve Derin Bağlantı (Deep Linking)

Uygulama, bildirim verisi (`data`) içerisinde bir ürün stok kodu (`stockCode`) gönderildiğinde kullanıcı bildirime tıkladığı anda doğrudan ilgili ürünün detay sayfasına gider.

### Data Parametreleri:
- **`stockCode` (String, Opsiyonel):** Ürünün stok kodu (Örn: `"011111"` veya `"021112"`).
  - Eğer `stockCode` gönderilirse: Uygulama `productByStockCode/{stockCode}` servisine istek atıp doğrudan ürünün sayfasına (`ProductPage`) yönlendirir.
  - Eğer `stockCode` boş bırakılırsa: Kullanıcı doğrudan ana sayfaya yönlendirilir.

---

## 4. Google Firebase HTTP v1 API Entegrasyonu

Google, eski "Legacy HTTP API" (FCM Server Key ile `fcm.googleapis.com/fcm/send`) desteğini sonlandırmıştır. Yönetim paneliniz Firebase **HTTP v1 API** standardını kullanmalıdır.

### 4.1. Hizmet Hesabı (Service Account) Anahtarı Alma
1. [Firebase Console](https://console.firebase.google.com/) adresine girin.
2. `gemascompanyapp-3478b` projesini seçin.
3. Sol üstteki **Proje Ayarları (Dişli simgesi) > Hizmet Hesapları (Service Accounts)** sekmesine gidin.
4. **Firebase Admin SDK** altında **"Yeni özel anahtar oluştur" (Generate new private key)** butonuna tıklayın.
5. İndirilen JSON dosyasını (`service-account.json`) web panelinizin sunucusuna güvenli bir dizine kaydedin (webden doğrudan erişilemeyen bir klasörde saklayınız).

---

## 5. Örnek İstek Gövdeleri (Payload JSON)

### Senaryo A: Tüm Kullanıcılara Genel Duyuru Gönderme

```json
{
  "message": {
    "topic": "allUsers",
    "notification": {
      "title": "2026 Ürün Kataloğumuz Yayınlandı!",
      "body": "En yeni havuz ekipmanlarımızı ve güncel kataloğumuzu hemen inceleyin."
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "gemas_high_importance_channel",
        "sound": "default",
        "icon": "ic_launcher"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1
        }
      }
    }
  }
}
```

---

### Senaryo B: Belirli Bir Ürün Tanıtımı ve Derin Bağlantı (Deep Link)

Kullanıcı bildirime tıkladığında doğrudan `011111` kodlu ürün açılır:

```json
{
  "message": {
    "topic": "allUsers",
    "notification": {
      "title": "Yeni Nesil Filtrasyon Pompası",
      "body": "Yeni filtrasyon pompamız stoklarımıza girmiştir. İncelemek için tıklayın."
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
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default"
        }
      }
    }
  }
}
```

---

## 6. Panel Backend Kod Örnekleri

### 6.1. PHP Örneği (Google Client SDK veya cURL)

Eğer yönetim paneliniz PHP tabanlı ise:

```bash
composer require google/apiclient
```

```php
<?php
require_once 'vendor/autoload.php';

use Google\Client;

function sendGemasNotification($topic, $title, $body, $stockCode = null) {
    $projectId = 'gemascompanyapp-3478b';
    $serviceAccountKeyPath = __DIR__ . '/service-account.json';

    // 1. Google OAuth2 Access Token alma
    $client = new Client();
    $client->setAuthConfig($serviceAccountKeyPath);
    $client->addScope('https://www.googleapis.com/auth/firebase.messaging');
    $token = $client->fetchAccessTokenWithAssertion()['access_token'];

    // 2. Payload hazırlama
    $message = [
        'message' => [
            'topic' => $topic,
            'notification' => [
                'title' => $title,
                'body'  => $body,
            ],
            'android' => [
                'priority' => 'high',
                'notification' => [
                    'channel_id' => 'gemas_high_importance_channel',
                    'sound'      => 'default'
                ]
            ],
            'apns' => [
                'payload' => [
                    'aps' => [
                        'sound' => 'default',
                        'badge' => 1
                    ]
                ]
            ]
        ]
    ];

    if (!empty($stockCode)) {
        $message['message']['data'] = [
            'stockCode' => (string)$stockCode
        ];
    }

    // 3. HTTP v1 API'ye POST gönderme
    $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Content-Type: application/json; UTF-8'
    ]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($message));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

// Kullanım örneği:
// $result = sendGemasNotification('allUsers', 'Gemaş 2026 Yenilikleri', 'Kataloğumuz güncellendi!', '011111');
// print_r($result);
```

---

### 6.2. Node.js Örneği (firebase-admin)

```bash
npm install firebase-admin
```

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'gemascompanyapp-3478b'
  });
}

async function sendNotification({ topic = 'allUsers', title, body, stockCode = null }) {
  const message = {
    topic: topic,
    notification: {
      title: title,
      body: body
    },
    data: stockCode ? { stockCode: String(stockCode) } : {},
    android: {
      priority: 'high',
      notification: {
        channelId: 'gemas_high_importance_channel',
        sound: 'default'
      }
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1
        }
      }
    }
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Bildirim başarıyla gönderildi:', response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Bildirim gönderilirken hata oluştu:', error);
    return { success: false, error: error.message };
  }
}

// Örnek Çağrı:
// sendNotification({
//   topic: 'allUsers',
//   title: 'Kampanya Duyurusu',
//   body: 'Seçili ürünlerde indirimler başladı.',
//   stockCode: '011111'
// });

module.exports = { sendNotification };
```

---

### 6.3. C# / .NET Örneği (FirebaseAdmin SDK)

```csharp
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;

public class PushNotificationService
{
    public static void Initialize()
    {
        if (FirebaseApp.DefaultInstance == null)
        {
            FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.FromFile("service-account.json"),
                ProjectId = "gemascompanyapp-3478b"
            });
        }
    }

    public static async Task<string> SendNotificationAsync(string topic, string title, string body, string stockCode = null)
    {
        Initialize();

        var message = new Message()
        {
            Topic = topic,
            Notification = new Notification()
            {
                Title = title,
                Body = body
            },
            Android = new AndroidConfig()
            {
                Priority = Priority.High,
                Notification = new AndroidNotification()
                {
                    ChannelId = "gemas_high_importance_channel",
                    Sound = "default"
                }
            },
            Apns = new ApnsConfig()
            {
                Aps = new Aps()
                {
                    Sound = "default",
                    Badge = 1
                }
            },
            Data = !string.IsNullOrEmpty(stockCode) ? new Dictionary<string, string> { { "stockCode", stockCode } } : null
        };

        return await FirebaseMessaging.DefaultInstance.SendAsync(message);
    }
}
```

---

## 7. Panel Arayüzü İçin Form Tasarım Önerisi

Yönetim panelinize ekleyeceğiniz bildirim formu şu alanlardan oluşmalıdır:

1. **Hedef Kitle (Selectbox / Dropdown):**
   - Tüm Kullanıcılar (`allUsers`)
   - Türkçe Kullanıcılar (`newProductsTR` veya `newNewsTR`)
   - Global / İngilizce Kullanıcılar (`newProductsEN` veya `newNewsEN`)
2. **Bildirim Başlığı (Input, Zorunlu):** Maksimum 60-70 karakter.
3. **Bildirim İçeriği (Textarea, Zorunlu):** Maksimum 150-200 karakter.
4. **Yönlendirilecek Ürün (Stok Kodu) (Input, Opsiyonel):** Kullanıcı tıkladığında doğrudan açılmasını istediğiniz ürünün stok kodu. Boş bırakılırsa ana sayfa açılır.
5. **Gönder Butonu:** Form gönderildiğinde yukarıdaki API isteğini tetikler ve dönen yanıt kodunu panelde kullanıcıya gösterir.
