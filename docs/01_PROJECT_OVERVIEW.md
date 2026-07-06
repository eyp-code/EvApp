# 01 - Project Overview

## Guncel Kapanis Notu - 2026-07-05

Bugun itibariyla masraf, fatura, backup ve shopping listin sade MVP parcasi calisan noktaya geldi.

Tamamlanan ana akislari:

- Kisi / ev arkadasi sistemi.
- Masraf ekleme, listeleme ve silme.
- `Sadece bana ait` ve `Ortak esit` hesaplama.
- Dashboard finans ozeti.
- Fatura turu ekleme.
- Aylik tekrarlayan fatura kaydi.
- Sabit tutarli fatura.
- Fatura odendiginde otomatik masraf olusturma.
- Aylik fatura silindiginde bagli masrafi da silme.
- JSON backup disa aktarma / ice aktarma.
- Shopping list:
  - urun ekleme
  - alinacak / alindi filtreleme
  - alindi isaretleme
  - urun silme

Siradaki gelistirme hedefi:

- Dashboard icin aylik ozet arsivi akisini netlestirmek.
- Biten aylar icin tiklanabilir rapor kartlari eklemek.
- Sonra shopping list duzenleme ve kategori filtresine donmek.

Bu siralama bilincli: shopping listte gunluk kullanim ergonomisini tamamlayip sonra yeni modula gecilecek.

## Proje Adı

**EvApp**

## Kısa Tanım

EvApp, ev yaşamını tek yerden yönetmek için geliştirilecek bir Flutter uygulamasıdır.

Uygulama ile kullanıcı:

- Ev masraflarını takip eder.
- Kendi kişisel payını görür.
- Toplam ev masrafını görür.
- Ev arkadaşıyla ortak harcamaları böler.
- Faturaları aylık olarak takip eder.
- Kira ve aidatı takip eder.
- Abonelikleri takip eder.
- Aylık bütçe hedefleri belirler.
- Alınacakları listeler.
- Ev görevlerini takip eder.
- Verilerini local olarak saklar.
- İsterse verilerini JSON yedeği olarak dışa aktarır.

---

## Ana Problem

Ev masrafları genellikle farklı yerlerde takip edilir:

- Faturalar banka uygulamasında
- Market harcamaları notlarda
- Ay sonu özetleri farklı yerlerde kalır
- Alınacaklar WhatsApp’ta
- Ev görevleri akılda
- Abonelikler unutulmuş durumda

Bu durum karışıklık oluşturur.

EvApp’in çözmek istediği temel problem:

> Evde ne harcandı, benim payıma ne düştü, hangi fatura unutuldu ve biten ay nasıl kapandı?

---

## Vizyon

EvApp, kişisel kullanım için başlayıp ileride gerçek bir ürüne dönüşebilecek, sade ama güçlü bir ev yönetim uygulaması olacaktır.

Uygulamanın vizyonu:

```text
Evdeki tüm masraf, fatura, görev ve ihtiyaç takibini tek uygulamada toplamak.
```

---

## İlk Sürüm Stratejisi

İlk sürümde backend kullanılmayacaktır.

Kullanılacak yapı:

```text
Flutter + Hive + Local Notifications + JSON Backup
```

Sebep:

- Öğrenmesi daha kolay.
- İnternetsiz çalışır.
- Backend karmaşıklığı başlamaz.
- Uygulama mantığı önce sağlamlaşır.
- Sonradan Firebase veya backend eklemek daha kontrollü olur.

---

## Hedef Kullanıcılar

### 1. Tek Başına Yaşayan Kullanıcı

Bu kullanıcı:

- Kirasını takip eder.
- Faturalarını takip eder.
- Market harcamalarını yazar.
- Aylık bütçe hedefi koyar.
- Aboneliklerini takip eder.

### 2. Ev Arkadaşıyla Yaşayan Kullanıcı

Bu kullanıcı:

- Ortak masrafları ikiye böler.
- Kira ve faturaları paylaştırır.
- Toplam ev masrafı ve kendi payını ayrı takip eder.

### 3. Öğrenci / Yeni Mezun Kullanıcı

Bu kullanıcı:

- Az bütçeyle ev yönetir.
- Harcamalarını görmek ister.
- Faturaları unutmamak ister.
- Basit ve hızlı bir uygulama ister.

---

## Ana Özellikler

### Dashboard

Ana sayfada aylık özet gösterilir:

- Toplam ev masrafı
- Benim payım
- Benim kişisel harcamam
- Ev arkadaşımın payı
- Bekleyen faturalar
- Girilmemiş faturalar
- Yaklaşan abonelikler
- Bütçe durumu
- Alınacak ürün sayısı
- Bekleyen ev görevleri

Ana sayfada ayrıca biten aylar için aşağı doğru biriken bir özet arşivi bulunabilir:

- Haziran 2026 özeti
- Mayıs 2026 özeti
- Nisan 2026 özeti

Her özet kartına tıklanınca o aya ait dashboard bilgileri, masraf toplamları ve fatura durumu tek raporda açılır.

---

### Masraf Takibi

Her masraf kaydı şu bilgileri içerir:

- Başlık
- Tutar
- Kategori
- Tarih
- Not
- Kim ödedi
- Paylaşım tipi
- Benim payım
- Ev arkadaşının payı

Önemli ayrım:

```text
Toplam Ev Masrafı ≠ Benim Masrafım
```

Örnek:

```text
Market alışverişi: 1200 TL
Paylaşım: Eşit
Benim payım: 600 TL
Ev arkadaşımın payı: 600 TL
```

---

### Fatura Takibi

Faturalar iki katmanlı düşünülür:

```text
Fatura Türü
Aylık Fatura Kaydı
```

Örnek:

```text
Fatura Türü: Su
Aylık Kayıt: Temmuz 2026 Su Faturası
Tutar: 430 TL
Durum: Ödendi
```

Bu sayede her ayın faturası ayrı saklanır.

---

### Girilmemiş Fatura Hatırlatması

Örnek:

```text
Su faturası her ay bekleniyor.
Temmuz 2026 için tutar girilmedi.
Uygulama 5 günde bir hatırlatır.
```

Bildirim örneği:

```text
Temmuz su faturanı girdin mi?
```

İlk sürümde bu sistem **local notification** ile yapılacaktır.

---

### Abonelik Takibi

Aylık veya yıllık abonelikler takip edilir:

- Netflix
- Spotify
- YouTube Premium
- iCloud
- Google One
- Gym üyeliği
- İnternet servisleri

Abonelikler kişisel veya ortak olabilir.

---

### Aylık Bütçe Hedefi

Kullanıcı aylık limit belirler:

```text
Market bütçesi: 8000 TL
Fatura bütçesi: 3000 TL
Kişisel harcama bütçesi: 5000 TL
```

Uygulama harcamaları takip eder ve aşım varsa uyarır.

---

### Alışveriş Listesi

Kullanıcı ev için alınacakları ekler:

- Ürün adı
- Kategori
- Öncelik
- Alındı / alınmadı durumu

---

### Ev Görevleri

Ev işleri takip edilir:

- Çöp çıkar
- Banyo temizle
- Bulaşık yıka
- Süpür
- Market alışverişi yap

Görevler tek seferlik veya tekrar eden olabilir.

---

## Başarı Kriterleri

MVP başarılı sayılırsa:

- Kullanıcı masraf ekleyebiliyor.
- Harcama eşit veya özel oranla bölünebiliyor.
- Benim payım doğru hesaplanıyor.
- Fatura türü oluşturulabiliyor.
- Aylık fatura kaydı girilebiliyor.
- Girilmemiş fatura için hatırlatma mantığı çalışıyor.
- Abonelik takibi yapılabiliyor.
- Bütçe hedefi görüntülenebiliyor.
- Veriler Hive’da kalıcı olarak saklanıyor.
- JSON yedek alınıp geri yüklenebiliyor.

---

## MVP Dışında Kalanlar

İlk sürümde şu özellikler yapılmayabilir:

- Firebase Auth
- Gerçek zamanlı ev arkadaşı senkronizasyonu
- Cloud Functions
- FCM push notification
- OCR ile fiş okuma
- Banka entegrasyonu
- PDF rapor export
- Çoklu ev desteği

Bunlar ileriki sürümlere bırakılacaktır.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Settlement hesabı yapılmaz.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Settlement hesabı yapılmaz.

