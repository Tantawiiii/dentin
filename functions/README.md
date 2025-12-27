# Firebase Cloud Functions - Push Notifications

هذا المجلد يحتوي على Cloud Functions لإرسال push notifications تلقائياً عند إنشاء إشعار جديد في Firebase Realtime Database.

## 📋 المتطلبات

1. Node.js 18 أو أحدث
2. Firebase CLI: `npm install -g firebase-tools`
3. Firebase project مع Realtime Database مفعّل

## 🚀 الإعداد والتشغيل

### 1. تسجيل الدخول إلى Firebase

```bash
firebase login
```

### 2. تهيئة المشروع (إذا لم يكن مُهيأ)

```bash
firebase init functions
```

اختر:
- Language: JavaScript
- ESLint: Yes
- Install dependencies: Yes

### 3. تثبيت المتطلبات

```bash
cd functions
npm install
```

### 4. نشر Cloud Functions

```bash
firebase deploy --only functions
```

أو لنشر function محدد:

```bash
firebase deploy --only functions:sendPushNotification
```

## 📱 كيف يعمل النظام

### في Flutter App:

1. **حفظ FCM Token**: عند تسجيل الدخول، يتم حفظ FCM token للمستخدم في:
   ```
   users/{userId}/fcm_tokens/{token}
   ```

2. **إنشاء إشعار**: عند حدوث تفاعل (إعجاب، رد، تعليق)، يتم حفظ الإشعار في:
   ```
   notifications/{receiverId}/{notificationId}
   ```

### في Cloud Functions:

1. **الاستماع**: Cloud Function يستمع تلقائياً لإنشاء إشعار جديد
2. **الحصول على FCM Tokens**: يجلب جميع FCM tokens للمستخدم المستقبل
3. **إرسال Push Notification**: يرسل push notification لجميع أجهزة المستخدم

## 📊 بنية البيانات

### FCM Token في Firebase:
```json
{
  "users": {
    "123": {
      "fcm_tokens": {
        "token_abc123": {
          "token": "token_abc123",
          "updated_at": 1234567890,
          "platform": "flutter"
        }
      }
    }
  }
}
```

### Notification في Firebase:
```json
{
  "notifications": {
    "123": {
      "notif_1234567890": {
        "id": "notif_1234567890",
        "type": "comment_like",
        "title": "Comment Liked",
        "message": "User liked your comment...",
        "sender_id": 456,
        "sender_name": "John Doe",
        "sender_image": "https://...",
        "post_id": 789,
        "comment_id": "comment_123",
        "timestamp": 1234567890,
        "read": false,
        "sender_type": "user"
      }
    }
  }
}
```

## 🔧 التخصيص

يمكنك تعديل `functions/index.js` لتخصيص:
- محتوى الإشعار
- صوت الإشعار
- بيانات الإشعار الإضافية
- معالجة الأخطاء

## 📝 ملاحظات

- Cloud Functions تحتاج إلى Firebase Blaze plan (paid plan)
- الإشعارات تُرسل تلقائياً عند إنشاء إشعار جديد في Firebase
- يتم إزالة FCM tokens غير صالحة تلقائياً
- يمكن للمستخدم الحصول على إشعارات على عدة أجهزة

## 🐛 استكشاف الأخطاء

### التحقق من الـ logs:
```bash
firebase functions:log
```

### اختبار محلي:
```bash
firebase emulators:start --only functions
```

### التحقق من FCM Tokens:
افتح Firebase Console > Realtime Database > `users/{userId}/fcm_tokens`

