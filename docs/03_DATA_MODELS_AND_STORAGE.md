# 03 - Data Models and Local Storage

## Guncel Model Notu - 2026-07-05

Kodda calisan masraf/fatura veri modeli su sekildedir:

- `Expense`
  - `splitType` degerleri aktif olarak `onlyMe` ve `equal` kullanir.
  - `onlyMe` tam tutari kullanici payina yazar.
  - `equal` ortak esit paylasimdir ve kullanici payina toplam tutarin yarisini yazar.
  - Faturadan olusan harcamalar da ayni `Expense.create` yolunu kullanir.
- `BillType`
  - Fatura sablonudur.
  - Ev faturasi / kisisel fatura kategorisini tutar.
  - Aylik tekrarlama ve sabit tutar bilgisini tutar.
  - Soft delete ile silinir.
- `MonthlyBill`
  - Belirli ay/yil icin fatura kaydidir.
  - `billTypeName` snapshot alani sayesinde fatura turu silinse bile eski odenmis kayit adini korur.
  - `generatedExpenseId` ile odeme sirasinda uretilen masraf kaydina baglanir.
  - Aylik fatura silinirse bu bagli masraf kaydi da soft delete edilir.
- `ShoppingItem`
  - Urun adini, kategori bilgisini ve alinma durumunu tutar.
  - Soft delete ile silinir.
  - Liste ekraninda alinacak/alindi filtrelerine gore kullanilir.

Aktif Hive box'lari:

```text
persons_box
expenses_box
bill_types_box
monthly_bills_box
shopping_items_box
```

Siradaki model/storage adimi:

- `ShoppingItem` modeli icindeki artik kullanilmayan fiyat/oncelik alanlarini temizleme ihtiyacini yeniden degerlendirmek.
- `HouseholdTask` modeli ve buna ait Hive box tasarimini eklemek.

## Genel Veri Yaklaşımı

EvApp ilk sürümde verileri local olarak saklayacaktır.

Kullanılacak teknoloji:

```text
Hive
```

Ana karar:

> Her ana özellik kendi Hive box’ında saklanacak.

---

## Hive Box Planı

```text
persons_box
homes_box
expenses_box
bill_types_box
monthly_bills_box
subscriptions_box
budget_goals_box
shopping_items_box
household_tasks_box
settings_box
backup_logs_box
```

İlk sürümde tek ev kullanılacaksa `homes_box` zorunlu değildir ama ileride çoklu ev desteği için hazır tutulabilir.

---

## Ortak Model Alanları

Tüm ana modellerde ortak alanlar bulunmalıdır:

```dart
class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
}
```

### Alan Açıklamaları

| Alan | Açıklama |
|---|---|
| `id` | Benzersiz kayıt id’si |
| `createdAt` | Oluşturulma zamanı |
| `updatedAt` | Son güncelleme zamanı |
| `isDeleted` | Soft delete durumu |
| `deletedAt` | Silinme zamanı |
| `syncStatus` | İleride backend sync için durum |
| `lastSyncedAt` | İleride backend sync zamanı |

---

## Sync Status Değerleri

```text
localOnly
synced
pendingCreate
pendingUpdate
pendingDelete
```

İlk local sürümde genellikle `localOnly` kullanılacaktır.

---

## Person Model

Evdeki kişileri temsil eder.

Örnek kişiler:

- Ben
- Ev arkadaşım

```dart
class Person {
  final String id;
  final String name;
  final bool isMe;
  final String? avatarColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### İş Kuralları

- Uygulamada en az bir `isMe == true` kişi olmalıdır.
- Ev arkadaşı sonradan eklenebilir.
- Ev arkadaşı silinirse eski harcamalar bozulmamalıdır.
- Silinen kişinin geçmiş kayıtlardaki adı korunmalıdır.

---

## Expense Model

Her masraf kaydını temsil eder.

```dart
class Expense {
  final String id;
  final String title;
  final double totalAmount;
  final String categoryId;
  final DateTime date;
  final String paidByPersonId;
  final SplitType splitType;
  final List<ExpenseShare> shares;
  final String? note;
  final bool includeInHouseTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### ExpenseShare

```dart
class ExpenseShare {
  final String personId;
  final double amount;
  final double? percentage;
  final bool isSettled;
}
```

### SplitType

```text
personalMine
personalOther
sharedEqual
sharedCustomAmount
sharedCustomPercentage
```

### Örnek 1 - Ortak Market

```json
{
  "id": "expense_001",
  "title": "Market alışverişi",
  "totalAmount": 1200,
  "categoryId": "market",
  "paidByPersonId": "person_me",
  "splitType": "sharedEqual",
  "shares": [
    { "personId": "person_me", "amount": 600, "percentage": 50, "isSettled": true },
    { "personId": "person_roommate", "amount": 600, "percentage": 50, "isSettled": false }
  ],
  "includeInHouseTotal": true
}
```

Sonuç:

```text
Toplam ev masrafı: 1200 TL
Benim payım: 600 TL
Ev arkadaşımın payı: 600 TL
Ev arkadaşım bana 600 TL borçlu
```

### Örnek 2 - Kişisel Harcama

```json
{
  "title": "Kahve",
  "totalAmount": 200,
  "splitType": "personalMine",
  "shares": [
    { "personId": "person_me", "amount": 200, "percentage": 100 }
  ],
  "includeInHouseTotal": false
}
```

Sonuç:

```text
Toplam ev masrafına eklenmez.
Benim kişisel harcamama eklenir.
Borç oluşmaz.
```

---

## BillType Model

Fatura türünü temsil eder.

Fatura türü sabittir; aylık tutar değişir.

Örnek:

- Su
- Elektrik
- Doğalgaz
- İnternet
- Kira
- Aidat

```dart
class BillType {
  final String id;
  final String name;
  final String categoryId;
  final bool isRecurring;
  final RecurrenceType recurrenceType;
  final int? expectedDayOfMonth;
  final bool reminderEnabled;
  final int reminderEveryDays;
  final bool isSharedDefault;
  final SplitType defaultSplitType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### Alan Açıklamaları

| Alan | Açıklama |
|---|---|
| `name` | Fatura adı, örn: Su |
| `expectedDayOfMonth` | Genelde ayın kaçında gelir/ödenir |
| `reminderEnabled` | Hatırlatma açık mı |
| `reminderEveryDays` | Kaç günde bir hatırlatılacak |
| `isSharedDefault` | Varsayılan ortak mı |
| `defaultSplitType` | Varsayılan bölüşüm tipi |

---

## MonthlyBill Model

Her ayın fatura kaydını temsil eder.

```dart
class MonthlyBill {
  final String id;
  final String billTypeId;
  final int month;
  final int year;
  final double? amount;
  final BillStatus status;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? paidByPersonId;
  final SplitType splitType;
  final List<ExpenseShare> shares;
  final DateTime? lastReminderAt;
  final int reminderCount;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### BillStatus

```text
waitingAmount
amountEntered
paid
overdue
skipped
```

### Örnek - Temmuz Su Faturası Henüz Girilmedi

```json
{
  "billTypeId": "billtype_water",
  "month": 7,
  "year": 2026,
  "amount": null,
  "status": "waitingAmount",
  "lastReminderAt": null,
  "reminderCount": 0
}
```

### Örnek - Temmuz Su Faturası Ödendi

```json
{
  "billTypeId": "billtype_water",
  "month": 7,
  "year": 2026,
  "amount": 430,
  "status": "paid",
  "paidByPersonId": "person_me",
  "shares": [
    { "personId": "person_me", "amount": 215, "percentage": 50 },
    { "personId": "person_roommate", "amount": 215, "percentage": 50 }
  ]
}
```

---

## Subscription Model

Abonelikleri temsil eder.

```dart
class Subscription {
  final String id;
  final String name;
  final double amount;
  final SubscriptionPeriod period;
  final int paymentDay;
  final String categoryId;
  final bool isActive;
  final bool reminderEnabled;
  final DateTime? lastPaidAt;
  final String paidByPersonId;
  final SplitType splitType;
  final List<ExpenseShare> shares;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### SubscriptionPeriod

```text
weekly
monthly
yearly
custom
```

### Örnek

```json
{
  "name": "Netflix",
  "amount": 250,
  "period": "monthly",
  "paymentDay": 15,
  "paidByPersonId": "person_me",
  "splitType": "sharedEqual",
  "shares": [
    { "personId": "person_me", "amount": 125 },
    { "personId": "person_roommate", "amount": 125 }
  ]
}
```

---

## BudgetGoal Model

Aylık bütçe hedeflerini temsil eder.

```dart
class BudgetGoal {
  final String id;
  final int month;
  final int year;
  final String categoryId;
  final double limitAmount;
  final BudgetType budgetType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### BudgetType

```text
houseTotal
myShare
personalOnly
categoryBased
```

### Örnek

```json
{
  "month": 7,
  "year": 2026,
  "categoryId": "market",
  "limitAmount": 8000,
  "budgetType": "myShare"
}
```

Anlamı:

```text
Temmuz ayında market kategorisinde benim payım 8000 TL’yi geçmesin.
```

---

## ShoppingItem Model

Alınacak ürünleri temsil eder.

```dart
class ShoppingItem {
  final String id;
  final String name;
  final String categoryId;
  final double? estimatedPrice;
  final ShoppingPriority priority;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### ShoppingPriority

```text
low
medium
high
urgent
```

---

## HouseholdTask Model

Ev görevlerini temsil eder.

```dart
class HouseholdTask {
  final String id;
  final String title;
  final String? assignedPersonId;
  final TaskStatus status;
  final TaskRecurrence recurrence;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}
```

### TaskStatus

```text
todo
inProgress
completed
cancelled
```

### TaskRecurrence

```text
none
daily
weekly
monthly
custom
```

---

## Settings Model

Uygulama ayarlarını tutar.

```dart
class AppSettings {
  final String currencyCode;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final int defaultReminderEveryDays;
  final bool backupReminderEnabled;
  final DateTime? lastBackupAt;
}
```

---

## Hesaplama Kuralları

### Toplam Ev Masrafı

Sadece `includeInHouseTotal == true` olan kayıtlar toplanır.

```text
Toplam Ev Masrafı = Ortak harcamalar + evle ilgili harcamalar
```

### Benim Payım

Kayıtlardaki `shares` listesinden `isMe == true` kişinin payı toplanır.

```text
Benim Payım = Tüm kayıtların içinde benim share amount toplamım
```

### Kişisel Harcamam

`splitType == personalMine` olan kayıtlar toplanır.

```text
Benim Kişisel Harcamam = Sadece bana ait harcamalar
```

### Borç Hesaplama

Kural:

```text
Bir kişi masrafı ödediyse ve diğer kişilerin payı varsa,
diğer kişiler ödeyen kişiye borçlanır.
```

Örnek:

```text
Toplam: 1000 TL
Ödeyen: Ben
Benim payım: 500 TL
Ev arkadaşımın payı: 500 TL

Ev arkadaşım bana 500 TL borçlu.
```

Ters örnek:

```text
Toplam: 1000 TL
Ödeyen: Ev arkadaşım
Benim payım: 500 TL
Ev arkadaşımın payı: 500 TL

Ben ev arkadaşıma 500 TL borçluyum.
```

---

## JSON Backup Formatı

Dışa aktarılacak dosya yapısı:

```json
{
  "appName": "EvApp",
  "backupVersion": 1,
  "createdAt": "2026-07-02T12:00:00.000Z",
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
```

---

## Backup Version Neden Var?

İleride model yapısı değişebilir.

Örnek:

```text
Version 1: Expense içinde shares var.
Version 2: Expense içinde attachments eklendi.
```

`backupVersion` sayesinde eski yedekler yeni uygulamaya dönüştürülebilir.

---

## Import Çakışma Stratejisi

Yedek geri yüklenirken aynı id’ye sahip veri varsa seçenekler:

### 1. Replace All

Mevcut verileri sil, yedekteki verileri yükle.

Başlangıç için en kolay yöntem budur.

### 2. Merge

Aynı id varsa `updatedAt` değeri yeni olanı kullan.

İleride eklenebilir.

### 3. Import as New

Yedekteki verileri yeni id’lerle içeri al.

Şimdilik gerek yoktur.

---

## İlk Sürüm Import Kararı

İlk sürümde şu kullanılacak:

```text
Replace All
```

Kullanıcıya uyarı gösterilir:

```text
Bu işlem mevcut verilerinin üzerine yedek dosyasındaki verileri yazacak. Devam etmek istiyor musun?
```
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
