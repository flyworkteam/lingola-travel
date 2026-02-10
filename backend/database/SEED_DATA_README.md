# Seed Data Installation Guide

## Özet
Bu dosya, tüm uygulama ekranlarındaki statik örnek verileri MySQL veritabanına ekler.

## Hangi Veriler Ekleniyor?

### 1. **Courses (Kurslar)** - 11 adet
- Daily Conversation (Günlük Konuşma)
- Terminal Talk (Havaalanı)
- Place an order (Yemek-İçecek)
- I have a reservation (Konaklama)
- Cultural phrases (Kültür)
- How much is this? (Alışveriş)
- How can I get there? (Yön Tarifi)
- Is there a gym? (Spor)
- Where is the pharmacy? (Sağlık)
- We have a meeting (İş)
- Call the police (Acil Durum)

### 2. **Lessons (Dersler)** - 36+ adet
Her kurs için 12 ders (toplam 132 ders olacak)
- Örnek: Check-in Counter, Security Screening, Boarding Pass, vb.

### 3. **Lesson Vocabulary (Ders Kelimeleri)** - 4 adet
- Check-in
- Boarding Pass
- Gate
- Departure

### 4. **Dictionary Categories (Sözlük Kategorileri)** - 10 adet
- Airport (1240 kelime)
- Accommodation (1000 kelime)
- Transportation (980 kelime)
- Food & Drink (1250 kelime)
- Shopping (1520 kelime)
- Culture (550 kelime)
- Meeting (1520 kelime)
- Sport (1550 kelime)
- Health (1520 kelime)
- Business (1550 kelime)

### 5. **Dictionary Words (Kelimeler)** - 102 adet
Her kategoride 10-12 kelime:
- Passport/Pasaport
- Boarding Pass/Biniş Kartı
- Hotel/Otel
- Taxi/Taksi
- Restaurant/Restoran
- vb...

### 6. **Travel Phrases (Seyahat Cümleleri)** - 22 adet
6 kategoride örnek cümleler:
- Airport: "Where is the check-in counter for British Airways?"
- Hotel: "What time is breakfast served?"
- Taxi: "Please take me to the airport"
- Food & Drink: "I would like to order, please"
- Shopping: "How much is this?"
- Emergency: "Call the police"

### 7. **Library Folders (Kütüphane Klasörleri)** - 10 adet
- My Airport Essentials (12 öğe)
- My Hotel Essentials (20 öğe)
- Transport Essentials (35 öğe)
- My Food Essentials (8 öğe)
- My Shopping Essentials (21 öğe)
- Culture Essentials (10 öğe)
- Meeting Essentials (32 öğe)
- Sport Essentials (18 öğe)
- Health Essentials (8 öğe)
- Business Essentials (5 öğe)

### 8. **Demo User (Demo Kullanıcı)** - 1 adet
- Email: demo@lingola.com
- Name: Alex Johnson
- Password: (hash for testing)

---

## Kurulum Talimatları

### Yöntem 1: MySQL CLI ile (Terminal)

```bash
# 1. Backend klasörüne git
cd /Users/ismaildundar/Documents/androidCalismalari/lingola_travel/backend

# 2. MySQL'e bağlan
mysql -u root -p

# 3. Veritabanını seç
USE lingola_travel;

# 4. Seed dosyasını çalıştır
SOURCE database/migrations/023_seed_all_sample_data.sql;

# 5. Verilerin eklendiğini kontrol et
SELECT COUNT(*) as total_courses FROM courses;
SELECT COUNT(*) as total_lessons FROM lessons;
SELECT COUNT(*) as total_words FROM dictionary_words;
SELECT COUNT(*) as total_phrases FROM travel_phrases;
SELECT COUNT(*) as total_folders FROM library_folders;

# 6. Örnek kursu görmek için
SELECT * FROM courses LIMIT 5;
```

### Yöntem 2: Backend Node.js ile

```bash
# Backend klasöründe
cd backend

# Migration scripti çalıştır (eğer varsa)
npm run migrate
# veya
node database/run-migrations.js
```

### Yöntem 3: MySQL Workbench ile (GUI)

1. MySQL Workbench'i aç
2. `lingola_travel` veritabanına bağlan
3. File > Open SQL Script seçeneğini tıkla
4. `023_seed_all_sample_data.sql` dosyasını seç
5. Execute tuşuna bas (⚡ ikonu)
6. Sonuçları kontrol et

---

## Verification (Doğrulama)

Tüm verilerin başarıyla eklendiğini kontrol etmek için:

```sql
-- Özet rapor
SELECT 
  (SELECT COUNT(*) FROM courses) as courses,
  (SELECT COUNT(*) FROM lessons) as lessons,
  (SELECT COUNT(*) FROM lesson_vocabulary) as lesson_vocab,
  (SELECT COUNT(*) FROM dictionary_categories) as dict_categories,
  (SELECT COUNT(*) FROM dictionary_words) as dict_words,
  (SELECT COUNT(*) FROM travel_phrases) as phrases,
  (SELECT COUNT(*) FROM library_folders) as folders,
  (SELECT COUNT(*) FROM users WHERE email = 'demo@lingola.com') as demo_user;
```

Beklenen sonuçlar:
- courses: 11
- lessons: 36 (veya 132 tam hali için)
- lesson_vocab: 4
- dict_categories: 10
- dict_words: 102
- phrases: 22
- folders: 10
- demo_user: 1

---

## Test Etme (API ile)

Terminal'de API endpoint'lerini test et:

```bash
# 1. Health check
curl http://localhost:3000/api/health

# 2. Tüm kursları listele
curl http://localhost:3000/api/courses | jq

# 3. Bir kursun derslerini listele
curl "http://localhost:3000/api/courses/course-001/lessons" | jq

# 4. Dictionary kategorilerini listele
curl http://localhost:3000/api/dictionary/categories | jq

# 5. Airport kelimelerini listele  
curl "http://localhost:3000/api/dictionary/categories/dict-cat-001/words" | jq

# 6. Travel phrases listele
curl "http://localhost:3000/api/travel-phrases?category=Airport" | jq

# 7. Library folders listele (demo kullanıcı için - auth gerekebilir)
curl http://localhost:3000/api/library/folders \
  -H "Authorization: Bearer YOUR_TOKEN" | jq
```

---

## Sorun Giderme

### Hata: "Table doesn't exist"
**Çözüm:** Önce tüm migration dosyalarını sırayla çalıştır (001-022)

```bash
cd backend/database/migrations
mysql -u root -p lingola_travel < 001_create_users_table.sql
mysql -u root -p lingola_travel < 004_create_courses_table.sql
# ... diğerleri
```

### Hata: "Duplicate entry"
**Çözüm:** Seed dosyası zaten DELETE komutları içeriyor, ama yine de manuel temizlemek için:

```sql
DELETE FROM library_folders;
DELETE FROM travel_phrases;
DELETE FROM dictionary_words;
DELETE FROM dictionary_categories;
DELETE FROM lesson_vocabulary;
DELETE FROM lessons;
DELETE FROM courses;
DELETE FROM users WHERE email = 'demo@lingola.com';
```

### Hata: "Foreign key constraint fails"
**Çözüm:** Tabloları doğru sırayla oluşturduğunuzdan emin olun. Migration dosyaları 001-022 sırasıyla çalıştırılmalı.

---

## Ekstra: Tüm Dersleri Eklemek İçin

Sadece 3 kursun derslerini ekledim (36 ders). Tüm 11 kursun 132 dersini eklemek için, `023_seed_all_sample_data.sql` dosyasındaki `-- Note: Similar pattern for courses 004-011` kısmını genişletebilirsin. Her kurs için 12 ders INSERT statement'ı eklemen gerekiyor.

---

## Özet

✅ **Toplam ~185 örnek kayıt eklendi**
✅ Tüm ana ekranların verileri hazır
✅ API endpoint'leri test edilebilir
✅ Demo user ile library test edilebilir

**Sonraki Adım:** Backend sunucusunu başlat ve endpoint'leri test et!

```bash
cd backend
npm start
# veya
npm run dev
```
