# Lingola Travel - Flutter Mobile App

Seyahat ederken İngilizce öğrenmenizi sağlayan interaktif mobil uygulama.

## 🎯 Proje Özeti

Bu proje, kullanıcıların seyahat sırasında ihtiyaç duyabilecekleri İngilizce kelime ve cümleleri öğrenmelerini sağlayan kapsamlı bir mobil uygulamadır. Flutter ile geliştirilmiş olup, Node.js + MySQL backend ile entegre çalışır.

## 🏗️ Mimari

```
lib/
├── Core/
│   ├── Config/          # App konfigürasyonları
│   ├── Routes/          # Navigation routes
│   └── Theme/           # Tema ve renkler
├── Models/              # Data modelleri
├── Repositories/        # API çağrıları ve data işlemleri
├── Services/            # Cross-cutting servisler
├── Riverpod/
│   ├── Controllers/     # StateNotifier controllers
│   └── Providers/       # Global providers
├── View/                # UI ekranları (her ekran kendi klasöründe)
└── Widgets/
    └── Common/          # Paylaşılan widget'lar
```

## 📦 Teknoloji Stack

### Frontend (Flutter)
- **State Management:** flutter_riverpod
- **Responsive Design:** flutter_screenutil (393x852 design size)
- **Networking:** dio
- **Storage:** flutter_secure_storage, shared_preferences
- **UI:** google_fonts (Nunito Sans)
- **Social Auth:** google_sign_in, sign_in_with_apple, flutter_facebook_auth
- **Push Notifications:** onesignal_flutter
- **Audio:** audioplayers, flutter_tts

### Backend
- **Runtime:** Node.js
- **Database:** MySQL
- **Authentication:** JWT (access + refresh tokens)

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (latest stable)
- Dart SDK
- Node.js 18+
- MySQL 8+

### Flutter Kurulumu

1. Dependencies'leri yükleyin:
```bash
flutter pub get
```

2. iOS için (macOS):
```bash
cd ios && pod install && cd ..
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## ⚙️ Konfigürasyon

Gerekli tüm konfigürasyonlar için `.env.example` dosyasını `.env` olarak kopyalayın ve değerleri doldurun.

### Önemli TODO'lar

#### API Configuration
- `lib/Core/Config/app_config.dart` içinde `baseUrl`'i production URL ile değiştirin

#### OneSignal Setup
- OneSignal App ID'yi edinin ve `app_config.dart` içine ekleyin

#### Social Auth Credentials
- **Google:** iOS, Android ve Web için client ID'ler
- **Apple:** Team ID, Client ID, Redirect URI
- **Facebook:** App ID ve Client Token

#### RevenueCat (Store onayından sonra)
- iOS ve Android için API key'leri

## 📱 Özellikler

### Tamamlanan
- ✅ Temel mimari kurulumu
- ✅ Theme ve renk sistemi
- ✅ Responsive design (ScreenUtil)
- ✅ API client ve error handling
- ✅ Secure storage servisi
- ✅ Shared widgets (buttons, text fields, loaders)
- ✅ Splash screen & intro slider

### Devam Eden
- 🔄 Onboarding akışı
- 🔄 Authentication (Google, Apple, Facebook, Anonymous)
- 🔄 Premium gating logic
- 🔄 Travel Vocabulary module
- 🔄 Dictionary module
- 🔄 Quiz module
- 🔄 Courses module
- 🔄 Library module
- 🔄 Profile module
- 🔄 Notifications

## 🎨 Design System

### Renkler
Tüm renkler `lib/Core/Theme/my_colors.dart` içinde tanımlıdır:
- Primary: #6C5CE7
- Secondary: #FF6B9D
- Background: #F2F5FC
- Premium: #FFD700

### Typography
- Font Family: Nunito Sans (via Google Fonts)
- Responsive font sizes (.sp extension)

### Spacing
ScreenUtil extensions kullanılır:
- `.w` - width
- `.h` - height
- `.sp` - font size
- `.r` - radius

## 📁 Asset Yönetimi

```
assets/
├── images/     # Görseller
│   ├── splash_1.png
│   ├── splash_2.png
│   └── splash_3.png
├── icons/      # İkonlar
└── audio/      # Ses dosyaları
```

## 🔐 Güvenlik

- JWT token'lar secure storage'da saklanır
- API çağrıları interceptor ile merkezi şekilde yönetilir
- Sosyal login token'ları backend'de doğrulanır
- Hassas veriler asla log'lanmaz

## 📖 Kod Standartları

- **Naming:**
  - snake_case: dosya isimleri
  - PascalCase: class isimleri
  - camelCase: variable/method isimleri
  
- **Structure:**
  - View'lar sadece UI render eder
  - Controller'lar business logic içerir
  - Repository'ler API çağrıları yapar
  - Service'ler cross-cutting concerns

- **State Management:**
  - PageModel'lar controller dosyası içinde
  - Global model'lar Models/ klasöründe
  - Provider'lar all_providers.dart'ta export edilir

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

## 📦 Build

### Android
```bash
flutter build apk --release
# veya
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Katkıda Bulunma

1. Branch oluşturun (`git checkout -b feature/amazing-feature`)
2. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
3. Push yapın (`git push origin feature/amazing-feature`)
4. Pull Request açın

## 📄 Lisans

Bu proje özel mülkiyettedir.

---

**Not:** Bu README, proje geliştikçe güncellenecektir. Tüm TODO'ları ve eksiklikleri düzenli olarak kontrol edin.
