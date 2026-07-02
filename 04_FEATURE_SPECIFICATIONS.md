# 04 - Feature Specifications

Bu dosya EvApp özelliklerinin detaylı davranışlarını açıklar.

---

# 1. Dashboard

## Amaç

Kullanıcı uygulamayı açtığında evin genel finans ve görev durumunu hızlıca görmelidir.

## Gösterilecek Bilgiler

### Aylık Finans Özeti

- Toplam ev masrafı
- Benim payım
- Benim kişisel harcamam
- Benim toplam giderim
- Ev arkadaşımın payı
- Net borç durumu

Örnek:

```text
Temmuz 2026 Özeti
Toplam Ev Masrafı: 24.300 TL
Benim Payım: 12.150 TL
Benim Kişisel Harcamam: 2.400 TL
Benim Toplam Giderim: 14.550 TL
```

### Fatura Özeti

- Bu ay beklenen faturalar
- Tutarı girilmemiş faturalar
- Ödenmemiş faturalar
- Geciken faturalar

### Bütçe Özeti

- Kategori bütçeleri
- Kullanılan tutar
- Kalan tutar
- Aşılan bütçeler

### Diğer Özetler

- Aktif abonelikler
- Yaklaşan abonelik ödemeleri
- Alınacak ürün sayısı
- Bekleyen ev görevleri

---

# 2. Expense Management

## Amaç

Kullanıcı her harcamayı kaydedebilmeli ve uygulama bu harcamanın toplam ev masrafına ve kullanıcının kişisel payına etkisini hesaplamalıdır.

## Harcama Ekleme Alanları

- Harcama adı
- Toplam tutar
- Kategori
- Tarih
- Kim ödedi
- Paylaşım tipi
- Not
- Ev toplamına dahil edilsin mi?

## Paylaşım Tipleri

### Sadece Benim

Harcama sadece kullanıcıya aittir.

```text
Toplam: 300 TL
Benim payım: 300 TL
Ev toplamı: 0 TL
Borç: Yok
```

### Sadece Ev Arkadaşımın

Kullanıcı takip amaçlı ekleyebilir ama kendi giderine dahil edilmez.

```text
Toplam: 300 TL
Benim payım: 0 TL
Ev arkadaşımın payı: 300 TL
```

### Ortak Eşit Böl

Masraf kişi sayısına göre eşit bölünür.

```text
Toplam: 1000 TL
Ben: 500 TL
Ev arkadaşım: 500 TL
```

### Ortak Özel Oran

Kullanıcı yüzde belirler.

```text
Toplam: 1000 TL
Ben: %60 = 600 TL
Ev arkadaşım: %40 = 400 TL
```

### Ortak Özel Tutar

Kullanıcı doğrudan tutar girer.

```text
Toplam: 1000 TL
Ben: 700 TL
Ev arkadaşım: 300 TL
```

## Validasyon Kuralları

- Tutar 0’dan büyük olmalıdır.
- Başlık boş olamaz.
- Ortak harcamada en az iki kişi olmalıdır.
- Özel oran toplamı %100 olmalıdır.
- Özel tutar toplamı toplam harcamaya eşit olmalıdır.
- Ödeyen kişi seçilmelidir.

---

## Örnek

````text
Kira: 20.000 TL
Ödeyen: Ben
Paylaşım: Eşit
Benim payım: 10.000 TL
Ev arkadaşımın payı: 10.000 TL

Net durum:

```text
Ev arkadaşım bana 500 TL borçlu.
Ben ev arkadaşıma 300 TL borçluyum.
Net: Ev arkadaşım bana 200 TL borçlu.
````

# 4. Bill System

## Amaç

Faturalar her ay değişen tutarlarla takip edilmelidir.

## Temel Ayrım

```text
BillType = Fatura türü
MonthlyBill = O ayın faturası
```

Örnek:

```text
BillType: Su
MonthlyBill: Temmuz 2026 Su Faturası
```

## Fatura Türü Oluşturma

Alanlar:

- Fatura adı
- Kategori
- Aylık mı?
- Beklenen ödeme günü
- Hatırlatma açık mı?
- Kaç günde bir hatırlatılacak?
- Varsayılan ortak mı?
- Varsayılan paylaşım tipi

## Aylık Fatura Kaydı

Alanlar:

- Fatura türü
- Ay
- Yıl
- Tutar
- Son ödeme tarihi
- Durum
- Kim ödedi
- Paylaşım tipi
- Not

## Fatura Durumları

```text
waitingAmount: Bu ay fatura bekleniyor ama tutar girilmedi.
amountEntered: Tutar girildi ama ödenmedi.
paid: Ödendi.
overdue: Son ödeme tarihi geçti.
skipped: Bu ay bu fatura yok sayıldı.
```

## Önemli Kural

Bir ayın faturası başka ayın üzerine yazılmamalıdır.

Yanlış:

```text
Su faturası tutarı her ay aynı kaydı güncelliyor.
```

Doğru:

```text
Haziran Su Faturası ayrı kayıt.
Temmuz Su Faturası ayrı kayıt.
Ağustos Su Faturası ayrı kayıt.
```

---

# 5. Bill Reminder System

## Amaç

Kullanıcı fatura girmeyi veya ödemeyi unutmasın.

## İlk Sürüm Teknolojisi

```text
flutter_local_notifications
```

## Hatırlatma Senaryosu

Örnek:

```text
Su faturası her ay bekleniyor.
Temmuz ayı geldi.
Temmuz su faturası için tutar girilmedi.
Hatırlatma aralığı: 5 gün.
```

Uygulama bildirim gönderir:

```text
Temmuz su faturanı girdin mi?
```

## Bildirim Ne Zaman Durur?

- Tutar girilirse durabilir veya “ödendi mi?” hatırlatmasına dönüşebilir.
- Fatura ödendi yapılırsa tamamen durur.
- Kullanıcı bu fatura türü için hatırlatmayı kapatırsa durur.
- Kullanıcı ayı `skipped` yaparsa durur.

## Bildirim Tipleri

### Tutar Girilmedi Bildirimi

```text
Temmuz su faturanı girdin mi?
```

### Ödeme Bekliyor Bildirimi

```text
Su faturası girildi ama henüz ödenmedi.
```

### Gecikmiş Fatura Bildirimi

```text
Su faturasının son ödeme tarihi geçti.
```

---

# 6. Subscription Tracking

## Amaç

Kullanıcı düzenli aboneliklerini takip edebilmelidir.

## Abonelik Örnekleri

- Netflix
- Spotify
- YouTube Premium
- iCloud
- Google One
- Gym
- Domain / hosting
- Eğitim platformları

## Alanlar

- Abonelik adı
- Tutar
- Ödeme periyodu
- Ödeme günü
- Kategori
- Aktif mi?
- Kim ödüyor?
- Ortak mı?
- Paylaşım tipi
- Hatırlatma açık mı?

## Paylaşım Mantığı

Abonelik kişisel olabilir:

```text
Spotify: 60 TL
Benim payım: 60 TL
```

Ortak olabilir:

```text
Netflix: 250 TL
Ben: 125 TL
Ev arkadaşım: 125 TL
```

## Abonelik Raporu

Dashboard’da gösterilebilir:

```text
Aylık abonelik toplamı: 750 TL
Benim payım: 425 TL
Yaklaşan ödeme: Netflix - 15 Temmuz
```

---

# 7. Budget Goals

## Amaç

Kullanıcı aylık harcama limitleri koyabilmelidir.

## Bütçe Türleri

### Kategori Bazlı

```text
Market: 8000 TL
Temizlik: 1500 TL
Faturalar: 3000 TL
```

### Benim Payım Bazlı

```text
Bu ay benim toplam giderim 15000 TL’yi geçmesin.
```

### Toplam Ev Masrafı Bazlı

```text
Bu ay ev toplam masrafı 30000 TL’yi geçmesin.
```

### Kişisel Harcama Bazlı

```text
Bu ay kişisel harcamam 5000 TL’yi geçmesin.
```

## Bütçe Uyarıları

- %80’e gelince uyarı
- %100 geçince uyarı
- Aşım miktarını göster

Örnek:

```text
Market bütçesi: 8000 TL
Harcanan: 8500 TL
Aşım: 500 TL
```

---

# 8. Shopping List

## Amaç

Ev için alınacak ürünleri takip etmek.

## Alanlar

- Ürün adı
- Kategori
- Tahmini fiyat
- Öncelik
- Not
- Alındı mı?

## Kategoriler

- Market
- Temizlik
- Mutfak
- Banyo
- Mobilya
- Elektronik
- Diğer

## Ek Özellik

Bir ürün alındı olarak işaretlendiğinde kullanıcı isterse masraf kaydı oluşturabilir.

Örnek:

```text
Bulaşık deterjanı alındı.
Masraf olarak eklensin mi?
```

---

# 9. Household Tasks

## Amaç

Ev görevlerinin unutulmamasını sağlamak.

## Görev Örnekleri

- Çöp çıkar
- Banyo temizle
- Bulaşık yıka
- Süpür
- Cam sil
- Market alışverişi yap

## Alanlar

- Görev adı
- Sorumlu kişi
- Durum
- Son tarih
- Tekrar tipi
- Not

## Durumlar

```text
todo
inProgress
completed
cancelled
```

## Tekrar Tipleri

```text
none
daily
weekly
monthly
custom
```

---

# 10. Settings

## Amaç

Kullanıcı uygulama ayarlarını yönetebilmelidir.

## Ayarlar

- Para birimi
- Bildirimler açık/kapalı
- Varsayılan fatura hatırlatma aralığı
- Tema seçimi
- JSON yedek dışa aktar
- JSON yedek içe aktar
- Tüm verileri sil

---

# 11. Reports and Analytics

İlk sürümde basit raporlar yeterlidir.

## Aylık Rapor

- Toplam ev masrafı
- Benim payım
- Kişisel harcamam
- Faturalar toplamı
- Abonelik toplamı
- Kategori bazlı harcama

## Gelecek Özellikler

- Pie chart
- Bar chart
- Ay karşılaştırması
- Yıllık toplamlar
- Ortalama fatura tutarları

---

# 12. Edge Cases

## Ev Arkadaşı Silinirse

Geçmiş kayıtlar bozulmamalıdır.

Çözüm:

- Person soft delete yapılır.
- Geçmiş kayıtlarda personId kalır.
- UI’da “Silinen kişi” veya eski adı gösterilir.

## Fatura Bu Ay Gelmediyse

Kullanıcı `skipped` seçebilir.

Örnek:

```text
Bu ay doğalgaz faturası gelmedi.
```

## Harcama Bölüşümü Hatalıysa

Özel tutar toplamı toplam harcamaya eşit değilse kayıt yapılmaz.

## JSON Import Yarım Kalırsa

Import işleminden önce mevcut verinin yedeği alınmalıdır.

## Tarih Değişirse

Fatura ve bütçe hesapları cihaz tarihine göre değil, kayıt tarihine göre yapılmalıdır.
