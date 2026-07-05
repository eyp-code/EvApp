# EvApp - Local First Project Plan

## Guncel Proje Durumu - 2026-07-05

Bu noktada calisan MVP parcasi:

- Local-first Flutter uygulama iskeleti.
- Hive tabanli local storage.
- Kisi / ev arkadasi sistemi.
- Masraf ekleme, listeleme ve silme.
- `Sadece bana ait` ve `Ortak esit` paylasim mantigi.
- Dashboard finans ozeti.
- Fatura turu ekleme.
- Aylik fatura kaydi olusturma.
- Tutar bekleyen fatura akisi.
- Fatura odeme ve otomatik masraf olusturma.
- Sabit tutarli kisisel fatura.
- Aylik fatura silme ve bagli masrafi dashboard toplamindan dusme.
- Fatura turu silinince eski odenmis aylik kayitlari koruma.
- JSON backup disa aktarma / ice aktarma.
- Shopping list sade akisi:
  - urun ekleme
  - alinacak / alindi filtreleme
  - alindi isaretleme
  - urun silme

Guncel urun kararlari:

- Borc/alacak veya net borc hesabi yok.
- Ana takip metrigi `Bana yazilan toplam`.
- Ortak/esit harcamalar ve ev faturalari ikiye bolunur.
- Kisisel masraflar ve kisisel faturalar tam tutari kullaniciya yazar.
- AI proje icinde commit atmaz; commit karari ve uygulamasi proje sahibine aittir.
- AI, istenirse sadece commit mesaji ve komut onerisi verir.

Son dogrulama:

```text
dart format lib test
flutter analyze
flutter test
```

29 test basarili gecmistir.

Siradaki onerilen adim:

- Shopping list icin urun duzenleme ve kategori filtresi.
- Sonra Household Tasks MVP'ye gecmek.

## Tamamlanan Gelistirme Sureci - JSON Backup / Restore

Amac:

- Local-first uygulamada verinin kaybolmasini onlemek.
- Mevcut Hive verilerini okunabilir bir JSON dosyasi olarak disari aktarmak.
- Kullanici isterse bu dosyayi tekrar ice aktarabilmek.

Ilk kapsam:

- `persons`
- `expenses`
- `billTypes`
- `monthlyBills`

Ilk import stratejisi:

- `Replace All`
- Mevcut ilgili box verileri temizlenir.
- Yedekteki veriler geri yuklenir.

Kabul kriterleri:

- Export JSON icinde backup versiyonu, olusturulma tarihi ve tum aktif model listeleri bulunur.
- Import sonrasi kisi, masraf, fatura turu ve aylik fatura kayitlari geri gelir.
- Soft delete ve sync alanlari korunur.
- Import hatasinda kullaniciya anlasilir hata gosterilir.
- Backup/restore icin unit veya widget testleri eklenir.

> Ev masrafı, fatura, abonelik, bütçe, alışveriş ve ev görevi takip uygulaması.

Bu dosya EvApp projesinin ana planıdır. Diğer `.md` dosyaları bu planın detaylarını içerir.

> Güncel karar: EvApp borç/alacak takibi yapmayacak. Ortak masraf paylaşımı, benim payım, ev arkadaşının payı ve toplam ev masrafı hesaplanacak; ancak "kim kime borçlu" veya "net borç" ekranı olmayacak. `paidByPersonId` sadece kayıt ve raporlama amacıyla tutulacak.

---

## 1. Proje Özeti

EvApp, ev yaşamını ve ev masraflarını yönetmek için geliştirilecek bir Flutter uygulamasıdır.

Uygulamanın temel sorusu:

```text
Evde toplam ne harcandı?
Benim payıma ne düştü?
Kim kime ne kadar borçlu?
Hangi faturalar unutuldu?
Bu ay bütçeyi aştım mı?
```

---

## 2. Ana Karar

İlk sürümde backend kullanılmayacaktır.

Başlangıç teknolojileri:

```text
Flutter
Dart
Hive
Local Notifications
JSON Backup / Restore
```

İleride:

```text
Firebase veya özel backend
```

eklenebilir.

---

## 3. Neden Önce Local?

Çünkü bu proje başlangıçta öğrenme ve kişisel kullanım amaçlı geliştirilecek.

Önce local başlamak şu avantajları sağlar:

- Daha kolay öğrenilir.
- İnternetsiz çalışır.
- Backend karmaşıklığı olmaz.
- Uygulama mantığı daha hızlı oturur.
- Sonradan Firebase/backend eklemek daha kontrollü olur.

---

## 4. Ana Özellikler

### Dashboard

- Toplam ev masrafı
- Benim payım
- Kişisel harcamam
- Ev arkadaşımın payı
- Net borç durumu
- Bekleyen faturalar
- Girilmemiş faturalar
- Yaklaşan abonelikler
- Bütçe durumu

### Masraf Takibi

- Harcama ekleme
- Harcama düzenleme
- Harcama silme
- Kategori seçme
- Kim ödedi seçme
- Benim payımı hesaplama
- Toplam ev masrafını hesaplama

### Ortak Ev / Ev Arkadaşı Sistemi

- Ev arkadaşı ekleme
- Ortak harcama bölme
- Eşit bölme
- Özel oranla bölme
- Özel tutarla bölme
- Kim kime borçlu hesaplama

### Fatura Sistemi

- Fatura türü oluşturma
- Her ay ayrı fatura kaydı tutma
- Tutar girme
- Ödendi işaretleme
- Geciken fatura gösterme
- Girilmemiş fatura hatırlatma

### Abonelik Takibi

- Netflix, Spotify gibi abonelikleri takip etme
- Aylık/yıllık periyot
- Ortak veya kişisel abonelik
- Yaklaşan ödeme hatırlatma

### Aylık Bütçe Hedefleri

- Kategori bazlı bütçe
- Benim payım bazlı bütçe
- Toplam ev masrafı bazlı bütçe
- Bütçe aşımı uyarısı

### Alışveriş Listesi

- Ürün ekleme
- Kategori seçme
- Öncelik
- Alındı işaretleme

### Ev Görevleri

- Görev ekleme
- Sorumlu kişi seçme
- Tekrar eden görevler
- Tamamlandı işaretleme

### Backup / Restore

- JSON yedek alma
- JSON yedekten geri yükleme
- Başka cihaza veri taşıma

---

## 5. Mimari

Uygulama şu katmanlarla geliştirilecektir:

```text
Presentation Layer
State Management Layer
Repository Layer
Data Source Layer
Hive Local Database
```

UI doğrudan Hive kullanmayacaktır.

Doğru akış:

```text
Page → Provider/Controller → Repository → DataSource → Hive
```

---

## 6. Klasör Yapısı

```text
lib/
 ├── main.dart
 ├── app/
 ├── core/
 ├── shared/
 ├── features/
 │    ├── dashboard/
 │    ├── expenses/
 │    ├── bills/
 │    ├── subscriptions/
 │    ├── budgets/
 │    ├── shopping/
 │    ├── tasks/
 │    └── settings/
 └── bootstrap.dart
```

---

## 7. Veri Modelleri

Ana modeller:

```text
Person
Expense
ExpenseShare
BillType
MonthlyBill
Subscription
BudgetGoal
ShoppingItem
HouseholdTask
AppSettings
```

Her modelde mümkünse şu alanlar bulunacaktır:

```text
id
createdAt
updatedAt
isDeleted
deletedAt
syncStatus
lastSyncedAt
```

Bu alanlar ileride backend sync için önemlidir.

---

## 8. Hive Box Yapısı

```text
persons_box
expenses_box
bill_types_box
monthly_bills_box
subscriptions_box
budget_goals_box
shopping_items_box
household_tasks_box
settings_box
```

---

## 9. Masraf Hesaplama Mantığı

Her masrafta şu bilgiler tutulur:

```text
Toplam tutar
Kim ödedi
Kimlerin payı var
Benim payım
Ev arkadaşımın payı
```

Örnek:

```text
Market: 1200 TL
Ödeyen: Ben
Paylaşım: Eşit
Benim payım: 600 TL
Ev arkadaşımın payı: 600 TL
Ev arkadaşım bana 600 TL borçlu
```

---

## 10. Fatura Mantığı

Faturalar iki parçadan oluşur:

```text
BillType: Su
MonthlyBill: Temmuz 2026 Su Faturası
```

Her ay ayrı kayıt tutulur.

Bu sayede:

- Geçmiş fatura tutarları saklanır.
- Ortalama hesaplanır.
- Aylık rapor çıkarılır.
- Fatura unutulmaz.

---

## 11. Bildirim Mantığı

İlk sürümde local notification kullanılacaktır.

Örnek:

```text
Temmuz su faturası henüz girilmedi.
5 günde bir bildirim gönder.
```

Bildirim şu durumlarda durur:

- Tutar girildiğinde
- Fatura ödendiğinde
- Kullanıcı hatırlatmayı kapattığında
- Ay skipped yapıldığında

---

## 12. Backup Mantığı

Hive verileri JSON dosyasına çevrilir.

Kullanıcı dosyayı başka cihaza aktarabilir.

Yeni cihazda dosya içe aktarılır.

Bu sistem Firebase’e geçişte de kullanılabilir.

---

## 13. MVP

İlk tamamlanması gereken minimum sürüm:

```text
Person sistemi
Masraf ekleme
Ortak harcama bölme
Benim payım hesaplama
Borç hesaplama
Fatura türü oluşturma
Aylık fatura kaydı
Abonelik ekleme
Bütçe hedefi
Dashboard özet
Hive local kayıt
JSON backup/restore
```

---

## 14. Geliştirme Roadmap

```text
Phase 0: Proje kurulumu
Phase 1: Temel Flutter yapısı
Phase 2: Hive local storage
Phase 3: Person / roommate sistemi
Phase 4: Expense MVP
Phase 5: Shared expense logic
Phase 6: Bill system
Phase 7: Local bill reminders
Phase 8: Subscription tracking
Phase 9: Budget goals
Phase 10: Shopping list
Phase 11: Household tasks
Phase 12: Backup / restore
Phase 13: UI polish
Phase 14: Reports
Phase 15: Test ve refactor
```

---

## 15. Gelecekte Backend Planı

Backend’e geçiş için önerilen yol:

```text
1. Flutter + Hive
2. JSON backup/restore
3. Firebase Auth
4. Firestore cloud sync
5. FCM notifications
6. Cloud Functions
```

Alternatif:

```text
NestJS + PostgreSQL + Prisma
```

---

## 16. Kodlama Kuralları

- UI doğrudan Hive kullanmayacak.
- Tüm veri işlemleri Repository üzerinden yapılacak.
- Hesaplama mantığı ayrı service içinde olacak.
- Her model JSON’a çevrilebilir olacak.
- Her modelde benzersiz id olacak.
- Soft delete desteklenecek.
- Backend düşünülerek `syncStatus` alanları hazır tutulacak.

---

## 17. Sonuç

EvApp başlangıçta kişisel kullanım için local çalışan bir uygulama olacak.

Ama mimari doğru kurulursa ileride Firebase veya özel backend ile gerçek zamanlı, çok cihazlı ve ev arkadaşlı bir ürüne dönüşebilecek.
> Güncel hesaplama kararı: `Benim payım` yalnızca ortak bölünen masraflardan kullanıcıya düşen tutarı gösterir. `Kişisel harcamam`, ortak masraflardaki kullanıcı payı + sadece kullanıcıya ait masrafların toplamıdır. `paidByPersonId` bu iki hesabı borç/alacak hesabına dönüştürmez.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
