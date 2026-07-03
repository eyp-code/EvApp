# 06 - Development Roadmap

Bu dosya EvApp’in hangi sırayla geliştirileceğini açıklar.

Ana prensip:

> Önce küçük ve çalışan parçalar yapılacak. Sonra özellikler büyütülecek.

> Güncel ürün kararı: Masraf paylaşımı olacak, fakat borç/alacak takibi olmayacak. Roadmap içinde eski borç/net borç ifadeleri görülürse bunlar kapsam dışı kabul edilecek.

---

---

# Phase 1 - Temel Flutter Yapısı

## Amaç

Uygulamanın iskeletini kurmak.

## Yapılacaklar

- Theme oluştur
- App colors belirle
- App text styles belirle
- Bottom navigation oluştur
- Ana sayfa boş kartlarını oluştur
- Klasör yapısını kur

## Ekranlar

```text
DashboardPage
ExpensesPage
BillsPage
ShoppingPage
TasksPage
SettingsPage
```

## Tamamlanma Kriteri

Uygulama açılır, sayfalar arasında gezilebilir.

---

# Phase 2 - Local Storage Kurulumu

## Amaç

Hive altyapısını kurmak.

## Yapılacaklar

- Hive paketlerini ekle
- Hive init yap
- Box isimlerini tanımla
- Base model alanlarını belirle
- İlk model olarak Person oluştur
- İlk kişi olarak “Ben” kaydı oluştur

## Paketler

```yaml
hive: ^2.2.3
hive_flutter: ^1.1.0
uuid: ^4.0.0
intl: ^0.19.0
```

## Tamamlanma Kriteri

Uygulama kapanıp açıldığında local veri kalıcı kalır.

---

# Phase 3 - Person / Roommate Sistemi

## Amaç

Evdeki kişileri tanımlamak.

## Yapılacaklar

- Person model
- Person repository
- Person Hive datasource
- Kişi listeleme
- Ev arkadaşı ekleme
- Ev arkadaşı düzenleme
- Soft delete

## Kurallar

- En az bir “Ben” kişisi olmalı.
- Ev arkadaşı eklemek opsiyonel olmalı.
- Silinen kişi geçmiş kayıtlarda bozulmamalı.

## Tamamlanma Kriteri

Kullanıcı kendini ve ev arkadaşını ekleyebilir.

---

# Phase 4 - Expense MVP

## Amaç

Masraf ekleme ve listeleme sistemini yapmak.

## Yapılacaklar

- Expense model
- ExpenseShare model
- SplitType enum
- Expense repository
- AddExpensePage
- ExpenseListPage
- ExpenseCard
- Kategori seçimi
- Tarih seçimi
- Kim ödedi seçimi

## İlk Split Tipleri

- Sadece benim
- Ortak eşit böl

Diğer split tipleri sonraki phase’de eklenebilir.

## Tamamlanma Kriteri

Kullanıcı market masrafı ekler, uygulama benim payımı hesaplar ve listede gösterir.

---

# Phase 5 - Shared Expense Logic

## Amaç

Benim payım, toplam ev masrafı ve borç hesabını doğru yapmak.

## Yapılacaklar

- ExpenseCalculator service
- My share hesaplama
- House total hesaplama
- Roommate share hesaplama
- Debt hesaplama
- Net debt hesaplama

## Senaryolar

- Ben ödedim, ortak bölündü.
- Ev arkadaşım ödedi, ortak bölündü.
- Sadece benim harcamam.
- Özel oranla bölme.
- Özel tutarla bölme.

## Tamamlanma Kriteri

Dashboard’da şu değerler doğru görünür:

```text
Toplam Ev Masrafı
Benim Payım
Kişisel Harcamam
Net Borç
```

---

# Phase 6 - Bill System MVP

## Amaç

Fatura türleri ve aylık fatura kayıtlarını oluşturmak.

## Yapılacaklar

- BillType model
- MonthlyBill model
- Bill repository
- Fatura türü ekleme
- Aylık fatura ekleme
- Tutar girme
- Ödendi işaretleme
- Fatura listesi

## İlk Fatura Türleri

Varsayılan olarak önerilebilir:

- Su
- Elektrik
- Doğalgaz
- İnternet
- Kira
- Aidat

Kullanıcı bunları değiştirebilir.

## Tamamlanma Kriteri

Kullanıcı “Temmuz Su Faturası” için tutar girip ödendi işaretleyebilir.

---

# Phase 7 - Local Bill Reminder

## Amaç

Girilmemiş faturalar için hatırlatma sistemi kurmak.

## Yapılacaklar

- flutter_local_notifications ekle
- NotificationService oluştur
- BillReminderService oluştur
- Girilmemiş fatura kontrolü yap
- 5 günde bir bildirim mantığı kur
- Fatura girilince bildirimi iptal et

## Tamamlanma Kriteri

Temmuz su faturası girilmediyse kullanıcıya belirlenen aralıkta local bildirim planlanır.

---

# Phase 8 - Subscription Tracking

## Amaç

Abonelikleri takip etmek.

## Yapılacaklar

- Subscription model
- Subscription repository
- Abonelik ekleme
- Abonelik listeleme
- Aylık/yıllık periyot
- Ortak abonelik paylaşımı
- Abonelik hatırlatma

## Tamamlanma Kriteri

Kullanıcı Netflix aboneliğini ekleyip aylık toplamda görebilir.

---

# Phase 9 - Budget Goals

## Amaç

Aylık bütçe hedefleri oluşturmak.

## Yapılacaklar

- BudgetGoal model
- Budget repository
- Kategori bazlı bütçe
- Benim payım bazlı bütçe
- Dashboard bütçe kartı
- %80 ve %100 uyarı mantığı

## Tamamlanma Kriteri

Kullanıcı market için 8000 TL limit koyar ve harcama durumunu görür.

---

# Phase 10 - Shopping List

## Amaç

Ev için alınacakları takip etmek.

## Yapılacaklar

- ShoppingItem model
- Shopping repository
- Ürün ekleme
- Ürün listeleme
- Alındı işaretleme
- Öncelik sistemi
- Tahmini fiyat

## Tamamlanma Kriteri

Kullanıcı alınacakları ekleyip alındı olarak işaretleyebilir.

---

# Phase 11 - Household Tasks

## Amaç

Ev görevlerini takip etmek.

## Yapılacaklar

- HouseholdTask model
- Task repository
- Görev ekleme
- Görev listeleme
- Tamamlandı işaretleme
- Sorumlu kişi seçimi
- Tekrar eden görev altyapısı

## Tamamlanma Kriteri

Kullanıcı ev görevleri oluşturup takip edebilir.

---

# Phase 12 - Backup / Restore

## Amaç

Verileri başka cihaza taşımak için JSON export/import eklemek.

## Yapılacaklar

- BackupService
- Export JSON
- Import JSON
- Dosya seçici
- SharePlus ile dosya paylaşma
- Import öncesi uyarı
- Import öncesi otomatik yedek

## Tamamlanma Kriteri

Kullanıcı eski telefondan yedek alıp yeni telefonda içe aktarabilir.

---

# Phase 13 - UI Polish

## Amaç

Uygulamayı daha kullanışlı hale getirmek.

## Yapılacaklar

- Boş state tasarımları
- Loading state
- Error state
- Form validasyon mesajları
- Kart tasarımları
- Renk sistemi
- Dark mode
- Daha iyi navigation

---

# Phase 14 - Reports

## Amaç

Aylık rapor ekranını geliştirmek.

## Yapılacaklar

- Aylık harcama özeti
- Kategori bazlı toplamlar
- Fatura toplamları
- Abonelik toplamları
- Benim payım raporu
- Ev toplamı raporu

İlk sürümde grafik zorunlu değildir.

---

# Phase 15 - Test ve Refactor

## Amaç

Kod kalitesini artırmak.

## Yapılacaklar

- Calculator unit testleri
- Repository testleri
- Form validasyon testleri
- Backup import/export testleri
- Kod temizliği
- Tekrarlayan kodları azaltma

---

# MVP Tanımı

MVP için gerekli minimum özellikler:

```text
Person sistemi
Masraf ekleme
Ortak masraf bölme
Benim payım hesaplama
Fatura türü
Aylık fatura kaydı
Abonelik takibi
Bütçe hedefi
Dashboard özet
Hive local kayıt
JSON backup/export
```

---

# Öncelik Sırası

Mutlak öncelik:

```text
1. Masraf sistemi
2. Paylaşım ve borç hesabı
3. Fatura sistemi
4. Local kayıt
5. Backup
```

Sonra:

```text
6. Abonelik
7. Bütçe
8. Alışveriş
9. Görevler
10. Raporlar
```

---

# Geliştirme Tavsiyesi
> Güncel hesaplama kararı: `Benim payım` yalnızca ortak bölünen masraflardan kullanıcıya düşen tutardır. `Kişisel harcamam`, ortak pay + sadece bana ait masraflar toplamıdır. Borç/alacak ve net borç hesapları kapsam dışıdır.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
## Ara Sonrası Devam Notu - 2026-07-03

Mevcut çalışan temel:

- Person / roommate sistemi.
- Expense MVP:
  - Masraf ekleme
  - Masraf listeleme
  - Masraf silme
  - `Sadece bana ait`
  - `Ortak eşit`
- Dashboard masraf özeti:
  - `Bana yazılan toplam`
  - `Ortak masraflar`
  - `Benim ortak payım`
  - `Sadece benim masraflarım`
  - `Bu ay girilen toplam`

Ara sonrası önerilen sıra:

1. Mevcut Expense MVP manuel test edilip commitlenecek.
2. Küçük sağlamlaştırma yapılacak:
   - Ortak eşit senaryo kontrolü
   - Form validasyon mesajları
   - Masraf kartında tarih/kategori görünümü
3. Sonra fatura sistemi MVP'ye geçilecek.

Borç/alacak ve net borç hesabı kapsam dışı kalmaya devam edecek.
