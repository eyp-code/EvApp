# 05 - Backup, Restore and Migration

## Guncel Karar Notu - 2026-07-05

JSON backup / restore temel akisi artik calisiyor.

Mevcut aktif kapsam:

- `Yedek disari aktar`
- `Yedek ice aktar`
- JSON parse/validate
- `Replace All` import davranisi
- import oncesi kullanici uyarisi

Simdilik ertelenen kisim:

- import oncesi otomatik on-yedek

Bu karar urun sahibi tarafindan alindi. Yani backup tamamen rafa kalkmadi; temel surum var, sadece hardening adimi sonraya birakildi.

Bu dosyada gecen otomatik on-yedek adimlari sonraki iyilestirme backlog'u olarak okunmali, mevcut aktif davranis olarak degil.

## Guncel Uygulama Plani - 2026-07-03

Siradaki gelistirme adimi bu dosyadaki JSON backup / restore kapsamidir.

Ilk implementasyon kapsami:

- `BackupService`
- Export JSON modeli
- Import JSON parse/validate akisi
- Ayarlar ekraninda:
  - `Yedek disari aktar`
  - `Yedek ice aktar`
- Testler:
  - Export JSON beklenen alanlari icerir.
  - Import kisileri geri yukler.
  - Import masraflari geri yukler.
  - Import fatura turlerini ve aylik faturalarini geri yukler.
  - Soft delete alanlari korunur.

Ilk surumda export edilecek veri setleri:

```text
persons
expenses
billTypes
monthlyBills
```

Ilk surumda import stratejisi:

```text
Replace All
```

Yani mevcut ilgili Hive box verileri temizlenir ve JSON icindeki kayitlar ayni id'lerle geri yazilir.

## Amaç

İlk sürümde veriler Hive ile cihazda tutulacağı için başka cihaza otomatik geçmez.

Bu nedenle uygulamada manuel yedekleme sistemi bulunmalıdır.

Ana özellikler:

```text
Verileri dışa aktar
Verileri içe aktar
Yedek dosyası oluştur
Başka cihaza taşı
```

---

## Neden JSON Backup?

Hive dosyasını doğrudan taşımak yerine JSON kullanmak daha güvenlidir.

### Hive Dosyasını Direkt Taşımanın Riskleri

- Cihaz path’i farklı olabilir.
- Hive sürümü değişebilir.
- Adapter typeId çakışabilir.
- Model değişirse eski dosya açılmayabilir.
- Dosya bozulursa veriler kurtarılamayabilir.

### JSON’un Avantajları

- Okunabilir.
- Platform bağımsızdır.
- Gerekirse elle kontrol edilebilir.
- Eski versiyonlardan yeni versiyonlara dönüştürülebilir.
- Firebase/backend’e veri taşıma için de kullanılabilir.

---

## Backup Akışı

```text
Kullanıcı Ayarlar ekranına gider.
   ↓
Verileri Dışa Aktar butonuna basar.
   ↓
Uygulama tüm Hive box’larını okur.
   ↓
Verileri tek JSON yapısına çevirir.
   ↓
Dosya oluşturur.
   ↓
Kullanıcı dosyayı paylaşır veya kaydeder.
```

---

## Backup Dosya İsmi

Önerilen format:

```text
evapp_backup_YYYY_MM_DD_HH_mm.json
```

Örnek:

```text
evapp_backup_2026_07_02_14_30.json
```

---

## Backup JSON Formatı

```json
{
  "appName": "EvApp",
  "backupVersion": 1,
  "createdAt": "2026-07-02T14:30:00.000Z",
  "deviceInfo": {
    "platform": "android",
    "appVersion": "1.0.0"
  },
  "data": {
    "persons": [],
    "expenses": [],
    "billTypes": [],
    "monthlyBills": [],
    "subscriptions": [],
    "budgetGoals": [],
    "shoppingItems": [],
    "householdTasks": [],
    "settings": {}
  }
}
```

---

## Restore Akışı

```text
Kullanıcı Ayarlar ekranına gider.
   ↓
Verileri İçe Aktar butonuna basar.
   ↓
JSON dosyası seçer.
   ↓
Uygulama dosya formatını doğrular.
   ↓
Backup version kontrol edilir.
   ↓
Kullanıcıya uyarı gösterilir.
   ↓
Mevcut veriler yedeklenir.
   ↓
Yeni veriler Hive’a yazılır.
   ↓
Uygulama yeniden yüklenir.
```

---

## Import Güvenlik Kuralları

### 1. Dosya Doğrulama

Dosya şunları içermelidir:

```text
appName == EvApp
backupVersion var
createdAt var
data alanı var
```

### 2. Kullanıcı Uyarısı

Import öncesi gösterilecek mesaj:

```text
Bu işlem mevcut verilerinin üzerine yedek dosyasındaki verileri yazabilir.
Devam etmeden önce mevcut verilerinin otomatik yedeği alınacak.
Devam etmek istiyor musun?
```

### 3. Otomatik Ön Yedek

Import işleminden hemen önce mevcut verilerin yedeği alınmalıdır.

Örnek:

```text
evapp_auto_backup_before_import_2026_07_02_14_35.json
```

---

## İlk Sürüm Restore Stratejisi

İlk sürümde en basit yöntem kullanılacaktır:

```text
Replace All
```

Yani:

- Mevcut veriler silinir.
- JSON dosyasındaki veriler yüklenir.

Bu yöntem başlangıç için kolay ve güvenilirdir.

---

## İleride Merge Stratejisi

Daha gelişmiş versiyonda merge eklenebilir.

Kural:

```text
Aynı id varsa updatedAt yeni olan kazanır.
Yeni id varsa eklenir.
Silinmiş kayıt varsa isDeleted durumuna göre işlenir.
```

---

## Version Migration

Backup version zamanla değişebilir.

Örnek:

```text
backupVersion: 1
```

İleride:

```text
backupVersion: 2
```

Yeni model alanları eklendiğinde eski yedekler dönüştürülmelidir.

### Örnek Migration

Version 1’de `Expense` içinde `currency` yoktur.

Version 2’de `currency` eklenmiştir.

Migration:

```text
Eğer currency yoksa TRY olarak ata.
```

---

## Backup Service Tasarımı

```dart
class BackupService {
  Future<String> exportBackup();
  Future<void> importBackup(String filePath);
  Future<bool> validateBackup(String filePath);
}
```

---

## Backup Repository Kullanımı

Backup service doğrudan Hive box’larına ulaşabilir ama daha temiz yapı için repository’leri kullanabilir.

Basit başlangıç:

```text
BackupService → Hive boxes
```

Daha temiz yapı:

```text
BackupService → Repositories → DataSources → Hive
```

İlk sürümde hız için doğrudan Hive box okumak kabul edilebilir.

---

## Başka Cihaza Taşıma Senaryosu

### Eski Cihaz

```text
Ayarlar
   ↓
Verileri dışa aktar
   ↓
evapp_backup_2026_07_02.json oluştur
   ↓
Google Drive / WhatsApp / Telegram / USB ile gönder
```

### Yeni Cihaz

```text
EvApp kurulur.
   ↓
Ayarlar
   ↓
Verileri içe aktar
   ↓
Backup dosyası seçilir.
   ↓
Veriler yüklenir.
```

---

## Firebase’e Geçişte Backup’ın Rolü

İleride Firebase eklenirse JSON backup şu işe yarar:

```text
Local Hive verileri JSON’a çevrilir.
JSON verileri Firestore’a yüklenir.
Kullanıcı hesabına bağlanır.
```

Yani backup sistemi sadece yedekleme değil, aynı zamanda migration altyapısıdır.

---

## Backend Migration Planı

İleride backend’e geçerken şu adımlar izlenir:

```text
1. Kullanıcı login olur.
2. Local Hive verileri okunur.
3. Her kaydın id’si korunur.
4. Veriler Firestore/backend’e yazılır.
5. Başarılı olursa syncStatus = synced yapılır.
6. Sonraki değişiklikler hem local hem remote kaydedilir.
```

---

## Dikkat Edilecek Noktalar

- JSON dosyası kişisel veri içerir.
- Kullanıcıya dosyayı güvenli saklaması söylenmelidir.
- İleride şifreli backup eklenebilir.
- Büyük dosyalarda import süresi uzayabilir.
- Import sırasında uygulama kapatılırsa veri bozulmasını önlemek için ön yedek alınmalıdır.

---

## Gelecek Özellik: Şifreli Backup

İleride JSON dosyası şifrelenebilir.

Örnek:

```text
Kullanıcı backup için şifre belirler.
JSON dosyası AES ile şifrelenir.
Restore ederken şifre gerekir.
```

İlk sürümde bu zorunlu değildir.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
