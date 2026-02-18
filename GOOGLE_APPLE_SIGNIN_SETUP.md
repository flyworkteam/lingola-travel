# Google & Apple Sign In Entegrasyon Rehberi

Bu dokümantasyon, Google ve Apple Sign In entegrasyonu için gerekli adımları içermektedir.

## ✅ YAPILAN İŞLER

### 1. Flutter Tarafı
- ✅ `auth_service.dart` oluşturuldu (Google, Apple, Facebook Sign In yönetimi)
- ✅ `sign_in_view.dart` güncellendi (Tüm sosyal login butonları aktif)
- ✅ `splash_view.dart` güncellendi (Auto-login kontrolü)
- ✅ `profile_view.dart` güncellendi (Logout fonksiyonu)
- ✅ `auth_repository.dart` zaten hazırdı (Backend API çağrıları)

### 2. Backend Tarafı
- ✅ Backend zaten hazır (`/auth/google`, `/auth/apple`, `/auth/facebook` endpoints)
- ✅ MySQL tabloları mevcut

## 🔧 YAPILMASI GEREKENLER

### A. Google Sign In Konfigürasyonu

#### 1. Google Cloud Console Kurulumu
1. [Google Cloud Console](https://console.cloud.google.com/) açın
2. Yeni proje oluşturun veya mevcut projeyi seçin
3. **APIs & Services > Credentials** bölümüne gidin

#### 2. OAuth 2.0 Client IDs Oluşturma

##### Android için:
1. **Create Credentials > OAuth client ID** seçin
2. Application type: **Android**
3. Package name: `com.flywork.lingolatravel`
4. SHA-1 certificate fingerprint almak için:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   veya
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. SHA-1'i yapıştırın ve oluşturun

##### iOS için:
1. **Create Credentials > OAuth client ID** seçin
2. Application type: **iOS**
3. Bundle ID: `com.flywork.lingolatravel` (Info.plist'ten kontrol edin)
4. iOS URL scheme otomatik oluşturulacak

##### Web için: (Backend için)
1. **Create Credentials > OAuth client ID** seçin
2. Application type: **Web application**
3. Authorized redirect URIs:
   - `http://localhost:3000/auth/google/callback`
   - `https://yourdomain.com/auth/google/callback`

#### 3. google-services.json (Android için)
1. [Firebase Console](https://console.firebase.google.com/) açın
2. Projeyi seçin veya oluşturun
3. **Project Settings > Your apps** bölümünde Android uygulaması ekleyin
4. Package name: `com.flywork.lingolatravel`
5. `google-services.json` dosyasını indirin
6. Dosyayı şuraya kopyalayın: `/android/app/google-services.json`

#### 4. Android build.gradle.kts Güncellemesi
`/android/app/build.gradle.kts` dosyasının en üstüne ekleyin:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // BU SATIRI EKLEYİN
}
```

`/android/build.gradle.kts` dosyasına ekleyin:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### 5. iOS Info.plist Güncellemesi
`/ios/Runner/Info.plist` dosyasına Google Client ID'yi ekleyin:
```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### 6. Backend .env Güncellemesi
`/lingola_travel_backend/.env` dosyasını güncelleyin:
```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID_IOS=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
GOOGLE_CLIENT_ID_ANDROID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
GOOGLE_CLIENT_ID_WEB=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

---

### B. Apple Sign In Konfigürasyonu

#### 1. Apple Developer Console Kurulumu
1. [Apple Developer](https://developer.apple.com/account/) açın
2. **Certificates, Identifiers & Profiles** bölümüne gidin

#### 2. App ID Yapılandırması
1. **Identifiers** seçin
2. App ID'nizi bulun: `com.flywork.lingolatravel`
3. **Sign In with Apple** capability'sini aktif edin
4. Save

#### 3. Service ID Oluşturma (Backend için)
1. **Identifiers** > **+** > **Services IDs**
2. Description: `Lingola Travel Sign In`
3. Identifier: `com.flywork.lingolatravel.service`
4. **Sign In with Apple** seçin ve Configure
5. Primary App ID: `com.flywork.lingolatravel`
6. Website URLs:
   - Domain: `yourdomain.com`
   - Return URL: `https://yourdomain.com/auth/apple/callback`
   - veya test için: `http://localhost:3000/auth/apple/callback`

#### 4. Key Oluşturma (Backend için)
1. **Keys** > **+**
2. Key Name: `Lingola Travel Sign In Key`
3. **Sign In with Apple** seçin ve Configure
4. Primary App ID seçin
5. Continue > Register
6. Key'i indirin (.p8 dosyası)
7. Key ID'yi not edin

#### 5. Backend .env Güncellemesi
`/lingola_travel_backend/.env` dosyasını güncelleyin:
```env
# Apple Sign In Configuration
APPLE_CLIENT_ID=com.flywork.lingolatravel.service
APPLE_TEAM_ID=YOUR_TEAM_ID
APPLE_KEY_ID=YOUR_KEY_ID
APPLE_PRIVATE_KEY_PATH=./keys/apple_private_key.p8
```

#### 6. Private Key Kaydetme
Backend klasöründe `keys` klasörü oluşturun:
```bash
cd /Users/ismaildundar/Documents/androidCalismalari/lingola_travel_backend
mkdir keys
```

İndirdiğiniz `.p8` dosyasını `keys/apple_private_key.p8` olarak kaydedin.

#### 7. iOS Runner Entitlement Ekleme
Xcode'da projeyi açın ve:
1. Runner target'ı seçin
2. **Signing & Capabilities** sekmesine gidin
3. **+ Capability** > **Sign In with Apple** ekleyin

---

### C. Facebook Sign In Konfigürasyonu (Opsiyonel)

#### 1. Facebook Developer Console
1. [Facebook Developers](https://developers.facebook.com/) açın
2. Uygulama oluşturun
3. **Settings > Basic** bölümünden App ID ve App Secret alın

#### 2. Android Ayarları
1. **Settings > Basic** > **Add Platform** > **Android**
2. Package Name: `com.flywork.lingolatravel`
3. Class Name: `com.flywork.lingolatravel.MainActivity`
4. Key Hash almak için:
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
   ```

#### 3. iOS Ayarları
1. **Settings > Basic** > **Add Platform** > **iOS**
2. Bundle ID: `com.flywork.lingolatravel`

#### 4. Backend .env Güncellemesi
```env
# Facebook Configuration
FACEBOOK_APP_ID=YOUR_FACEBOOK_APP_ID
FACEBOOK_APP_SECRET=YOUR_FACEBOOK_APP_SECRET
```

---

## 🚀 TEST ETME

### Backend'i Başlatma
```bash
cd /Users/ismaildundar/Documents/androidCalismalari/lingola_travel_backend
npm install
npm run dev
```

Backend şu adreste çalışacak: `http://localhost:3000`

### Flutter Uygulamasını Çalıştırma
```bash
cd /Users/ismaildundar/Documents/androidCalismalari/lingola_travel
flutter pub get
flutter run
```

### Test Senaryoları
1. ✅ Google ile giriş yapın
2. ✅ Kullanıcı bilgilerinin çekildiğini kontrol edin
3. ✅ Profil sayfasına gidin ve bilgileri görün
4. ✅ Logout yapın
5. ✅ Tekrar giriş yapın (otomatik login)
6. ✅ Apple Sign In test edin (iOS cihazda)

---

## 📝 NOTLAR

### Geliştirme Ortamı
- Android Emulator kullanıyorsanız: Backend URL `http://10.0.2.2:3000/api`
- iOS Simulator kullanıyorsanız: Backend URL `http://localhost:3000/api`
- Fiziksel cihaz kullanıyorsanız: Backend URL `http://YOUR_LOCAL_IP:3000/api`

### Production için
- Backend'i bir sunucuya deploy edin (Heroku, AWS, DigitalOcean vb.)
- `.env` dosyalarında production URL'leri kullanın
- SSL sertifikası ekleyin (HTTPS)
- Firebase'de production modu aktif edin

### Güvenlik
- `.env` dosyalarını `.gitignore`'a ekleyin
- API key'leri asla GitHub'a commit etmeyin
- Production'da güçlü JWT secret'ları kullanın

---

## 🐛 Sorun Giderme

### Google Sign In Hataları
- SHA-1 fingerprint'in doğru olduğundan emin olun
- `google-services.json` doğru yerde mi kontrol edin
- Package name'in her yerde aynı olduğundan emin olun

### Apple Sign In Hataları
- Bundle ID'nin her yerde aynı olduğundan emin olun
- Apple Developer hesabınızın aktif olduğunu kontrol edin
- Service ID'nin doğru yapılandırıldığından emin olun

### Backend Bağlantı Hataları
- Backend'in çalıştığından emin olun (`npm run dev`)
- Doğru URL'yi kullandığınızdan emin olun
- Firewall/antivirus'ün bağlantıyı engellemediğini kontrol edin

---

## ✅ İŞ LİSTESİ

- [ ] Google Cloud Console'da OAuth client ID'ler oluştur
- [ ] `google-services.json` indir ve yerleştir
- [ ] Android `build.gradle.kts` güncelle
- [ ] iOS `Info.plist` güncelle
- [ ] Apple Developer'da App ID'ye Sign In with Apple ekle
- [ ] Apple Service ID oluştur
- [ ] Apple Private Key oluştur ve kaydet
- [ ] Backend `.env` dosyasını güncelle
- [ ] Backend'i başlat ve test et
- [ ] Flutter uygulamasını test et
- [ ] Production'a deploy et

---

Bu adımları takip ederek Google ve Apple Sign In entegrasyonunu tamamlayabilirsiniz!
