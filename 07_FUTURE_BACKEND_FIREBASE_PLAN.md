# 07 - Future Backend and Firebase Plan

Bu dosya, EvApp’in ileride Firebase veya özel backend’e nasıl geçirileceğini açıklar.

İlk sürümde backend kullanılmayacaktır.

Başlangıç:

```text
Flutter + Hive
```

İleride:

```text
Flutter + Hive + Firebase
```

veya:

```text
Flutter + Hive + Custom Backend
```

---

## Backend’e Ne Zaman Geçilmeli?

Backend’e geçmek için acele edilmemelidir.

Önce şu sistemler local olarak çalışmalıdır:

- Masraf ekleme
- Benim payım hesaplama
- Ev arkadaşı paylaşımı
- Borç hesabı
- Fatura türleri
- Aylık fatura kayıtları
- Abonelik takibi
- Bütçe hedefleri
- Backup/restore

Bunlar oturmadan Firebase’e geçmek projeyi karmaşıklaştırır.

---

## Firebase Kullanılırsa

Firebase ile şu özellikler gelir:

- Kullanıcı girişi
- Cloud database
- Cihazlar arası senkronizasyon
- Ev arkadaşı davet sistemi
- Gerçek zamanlı ortak ev takibi
- Cloud backup
- Push notification

Kullanılacak servisler:

```text
Firebase Authentication
Cloud Firestore
Firebase Cloud Messaging
Cloud Functions
Firebase Storage
```

---

## Firebase Mimari Yapısı

```text
Flutter UI
   ↓
Riverpod / Controller
   ↓
Repository
   ↓
Local Data Source + Remote Data Source
   ↓
Hive + Firestore
```

---

## Firestore Koleksiyon Planı

```text
users
homes
homes/{homeId}/members
homes/{homeId}/expenses
homes/{homeId}/billTypes
homes/{homeId}/monthlyBills
homes/{homeId}/subscriptions
homes/{homeId}/budgetGoals
homes/{homeId}/shoppingItems
homes/{homeId}/householdTasks
homes/{homeId}/settings
```

---

## User Document

```json
{
  "id": "user_001",
  "name": "Eyüp",
  "email": "example@gmail.com",
  "createdAt": "2026-07-02T12:00:00Z",
  "updatedAt": "2026-07-02T12:00:00Z"
}
```

---

## Home Document

```json
{
  "id": "home_001",
  "name": "Bizim Ev",
  "ownerId": "user_001",
  "createdAt": "2026-07-02T12:00:00Z",
  "updatedAt": "2026-07-02T12:00:00Z"
}
```

---

## Member Document

```json
{
  "userId": "user_001",
  "displayName": "Eyüp",
  "role": "owner",
  "joinedAt": "2026-07-02T12:00:00Z"
}
```

Roller:

```text
owner
member
viewer
```

---

## Sync Stratejisi

İleride sync için her modelde şu alanlar kullanılacaktır:

```text
id
createdAt
updatedAt
isDeleted
syncStatus
lastSyncedAt
```

### SyncStatus

```text
localOnly
synced
pendingCreate
pendingUpdate
pendingDelete
conflict
```

---

## İlk Firebase Geçiş Akışı

```text
1. Kullanıcı Firebase Auth ile giriş yapar.
2. Uygulama local Hive verilerini okur.
3. Kullanıcıdan onay alınır: "Local verilerini buluta taşımak istiyor musun?"
4. Local veriler Firestore’a yazılır.
5. Başarılı olan kayıtlar syncStatus = synced yapılır.
6. Bundan sonra veri hem local hem remote saklanır.
```

---

## Offline + Online Kullanım

En iyi uzun vadeli yapı:

```text
Local Hive = hızlı okuma ve offline kullanım
Firestore = cloud sync ve cihazlar arası veri
```

Yani uygulama her zaman önce local veriyi gösterir.

İnternet varsa arka planda Firebase ile eşitler.

---

## Conflict Çözümü

Aynı veri iki cihazda değişirse conflict oluşabilir.

Basit ilk çözüm:

```text
updatedAt en yeni olan kazanır.
```

Daha gelişmiş çözüm:

```text
Kullanıcıya iki versiyon gösterilir.
Hangisi kalsın diye sorulur.
```

İlk Firebase sürümünde `updatedAt wins` yeterlidir.

---

## Firebase Bildirim Sistemi

Local sürümde fatura bildirimleri cihaz üzerinde planlanır.

Firebase sürümünde daha güçlü yapı kurulabilir:

```text
Cloud Functions her gün çalışır.
Firestore’daki beklenen faturaları kontrol eder.
Girilmemiş/ödenmemiş faturalar için FCM gönderir.
```

---

## Cloud Function Mantığı

```text
Her gün saat 09:00’da çalış.
Tüm aktif home kayıtlarını gez.
BillType kayıtlarını kontrol et.
Bu ay MonthlyBill var mı bak.
Yoksa veya waitingAmount durumundaysa reminderEveryDays kontrol et.
Uygunsa FCM bildirimi gönder.
lastReminderAt güncelle.
```

Bildirim:

```text
Temmuz su faturanı girdin mi?
```

---

## Ev Arkadaşı Davet Sistemi

Firebase’e geçince şu özellik eklenebilir:

```text
Ev sahibi davet kodu oluşturur.
Ev arkadaşı kodu girer.
Aynı home içine member olarak eklenir.
```

Davet kodu örneği:

```text
EV-7K4P2Q
```

---

## Custom Backend Kullanılırsa

Firebase yerine özel backend istenirse önerilen yapı:

```text
NestJS + PostgreSQL + Prisma
```

Servisler:

- Auth
- Users
- Homes
- Expenses
- Bills
- Subscriptions
- Budgets
- Tasks
- Notifications

---

## REST API Örnekleri

```text
POST /auth/register
POST /auth/login
GET /homes
POST /homes
GET /homes/:homeId/expenses
POST /homes/:homeId/expenses
GET /homes/:homeId/bills
POST /homes/:homeId/bills
```

---

## PostgreSQL Tablo Planı

```text
users
homes
home_members
expenses
expense_shares
bill_types
monthly_bills
monthly_bill_shares
subscriptions
subscription_shares
budget_goals
shopping_items
household_tasks
notification_logs
```

---

## Firebase mi Custom Backend mi?

### Firebase Avantajları

- Daha hızlı başlanır.
- Flutter ile uyumludur.
- Auth hazırdır.
- Firestore realtime çalışır.
- Push notification kolaydır.

### Firebase Dezavantajları

- İleri seviye sorgular sınırlı olabilir.
- Maliyet takibi gerekir.
- Veritabanı ilişkisel değildir.

### Custom Backend Avantajları

- Tam kontrol sağlar.
- SQL ile güçlü raporlama yapılır.
- Profesyonel backend öğrenilir.

### Custom Backend Dezavantajları

- Daha zordur.
- Daha fazla zaman ister.
- Hosting, auth, security, deployment gerekir.

---

## Önerilen Uzun Vadeli Yol

```text
1. Flutter + Hive
2. JSON backup/restore
3. Firebase Auth
4. Firestore cloud sync
5. FCM notifications
6. Cloud Functions
7. İstenirse ileride özel backend
```

---

## Mimariyi Geleceğe Hazır Tutmak İçin Kurallar

- UI doğrudan Hive kullanmamalı.
- Her işlem Repository üzerinden yapılmalı.
- Her modelde id olmalı.
- Her modelde createdAt/updatedAt olmalı.
- Soft delete kullanılmalı.
- JSON serialization desteklenmeli.
- DataSource ayrımı korunmalı.
- Hesaplama mantığı UI içine yazılmamalı.

Bu kurallara uyulursa backend’e geçiş çok daha kolay olur.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
