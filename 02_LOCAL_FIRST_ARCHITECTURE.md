# 02 - Local First Architecture

## Mimari Kararı

EvApp ilk sürümde **local-first** geliştirilecektir.

Yani uygulamanın ana verisi önce cihazda tutulur.

Kullanılacak ana yapı:

```text
Flutter UI
   ↓
State Management
   ↓
Repository Layer
   ↓
Local Data Source
   ↓
Hive Database
```

İleride Firebase/backend eklendiğinde mimari şöyle genişletilir:

```text
Flutter UI
   ↓
State Management
   ↓
Repository Layer
   ↓
Local Data Source + Remote Data Source
   ↓
Hive + Firebase / Backend
```

---

## Neden Local-First?

### Avantajlar

- İnternet olmadan çalışır.
- Başlangıçta öğrenmesi kolaydır.
- Firebase karmaşıklığı projeye erken girmez.
- Uygulama mantığı daha rahat kurulur.
- Veri modelleri oturduktan sonra backend’e geçmek daha kolaydır.
- Kişisel kullanım için yeterlidir.

### Dezavantajlar

- Otomatik cihazlar arası senkronizasyon yoktur.
- Telefon bozulursa yedek alınmadıysa veri kaybı yaşanabilir.
- Ev arkadaşı aynı anda kendi cihazından veri göremez.
- Push notification server üzerinden gelmez.

Bu dezavantajlar ileride Firebase/backend ile çözülebilir.

---

## Ana Mimari Katmanlar

### 1. Presentation Layer

Kullanıcı arayüzüdür.

İçerik:

- Pages
- Screens
- Widgets
- Forms
- Dialogs
- Bottom sheets

Bu katman şunları bilmemelidir:

- Hive box adı
- JSON dosya formatı
- Firebase koleksiyon adı
- Backend endpoint URL’si

Sadece controller veya provider ile konuşmalıdır.

---

### 2. State Management Layer

Uygulama durumunu yönetir.

Önerilen seçenek:

```text
Riverpod
```

Başlangıçta daha basit gitmek istenirse:

```text
setState + ChangeNotifier
```

Ama proje büyüyeceği için Riverpod daha mantıklıdır.

Görevleri:

- Liste verilerini tutmak
- Loading durumunu yönetmek
- Error durumunu yönetmek
- Form submit işlemlerini yönetmek
- Repository çağırmak

---

### 3. Domain / Model Layer

Uygulamanın temel veri modellerini içerir.

Örnek modeller:

- `Expense`
- `Person`
- `BillType`
- `MonthlyBill`
- `Subscription`
- `BudgetGoal`
- `ShoppingItem`
- `HouseholdTask`
- `DebtEntry`

Bu modeller uygulamanın kalbidir.

---

### 4. Repository Layer

UI ile veri kaynağı arasında köprü kurar.

Örnek:

```dart
abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses();
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
```

Başlangıçta implementasyon:

```dart
class LocalExpenseRepository implements ExpenseRepository {
  // Hive kullanır
}
```

İleride:

```dart
class FirebaseExpenseRepository implements ExpenseRepository {
  // Firestore kullanır
}
```

veya:

```dart
class SyncExpenseRepository implements ExpenseRepository {
  // Hem Hive hem Firebase kullanır
}
```

---

### 5. Data Source Layer

Verinin gerçekten okunduğu/yazıldığı yerdir.

Başlangıç:

```text
HiveLocalDataSource
```

İleride:

```text
FirebaseRemoteDataSource
CustomBackendRemoteDataSource
```

---

## Önerilen Flutter Klasör Yapısı

```text
lib/
 ├── main.dart
 ├── app/
 │    ├── app.dart
 │    ├── router.dart
 │    └── theme.dart
 ├── core/
 │    ├── constants/
 │    ├── errors/
 │    ├── extensions/
 │    ├── helpers/
 │    ├── notifications/
 │    └── utils/
 ├── shared/
 │    ├── widgets/
 │    ├── dialogs/
 │    └── components/
 ├── features/
 │    ├── dashboard/
 │    │    ├── presentation/
 │    │    └── providers/
 │    ├── expenses/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── bills/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── subscriptions/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── budgets/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── shopping/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    ├── tasks/
 │    │    ├── data/
 │    │    ├── domain/
 │    │    └── presentation/
 │    └── settings/
 │         ├── data/
 │         └── presentation/
 └── bootstrap.dart
```

---

## Feature İç Yapısı

Örnek `expenses` feature’ı:

```text
features/expenses/
 ├── domain/
 │    ├── models/
 │    │    └── expense.dart
 │    ├── repositories/
 │    │    └── expense_repository.dart
 │    └── services/
 │         └── expense_calculator.dart
 ├── data/
 │    ├── data_sources/
 │    │    └── expense_hive_data_source.dart
 │    ├── repositories/
 │    │    └── local_expense_repository.dart
 │    └── adapters/
 │         └── expense_adapter.dart
 └── presentation/
      ├── pages/
      │    ├── expenses_page.dart
      │    └── add_expense_page.dart
      ├── widgets/
      │    └── expense_card.dart
      └── providers/
           └── expense_providers.dart
```

---

## Repository Pattern Neden Önemli?

Kötü kullanım:

```dart
final box = Hive.box('expenses');
box.add(expense);
```

Bunu doğrudan sayfanın içinde yaparsan, ileride Firebase’e geçerken tüm sayfaları değiştirmen gerekir.

Doğru kullanım:

```dart
await expenseRepository.addExpense(expense);
```

Sayfa verinin nereden geldiğini bilmez.

---

## Local Notification Mimarisi

İlk sürümde fatura ve abonelik hatırlatmaları local notification ile yapılacaktır.

Kullanılacak paket:

```text
flutter_local_notifications
```

Mantık:

```text
BillReminderService
   ↓
BillRepository'den beklenen faturaları alır
   ↓
Bu ay girilmemiş fatura var mı kontrol eder
   ↓
Hatırlatma günü geldiyse local notification planlar
```

Bildirimler:

- Fatura tutarı girilene kadar devam eder.
- Fatura ödendi olunca iptal edilir.
- Kullanıcı reminder kapatırsa durur.

---

## Uygulama Başlangıç Akışı

```text
main.dart
   ↓
WidgetsFlutterBinding.ensureInitialized()
   ↓
Hive init
   ↓
Hive adapters register
   ↓
Hive boxes open
   ↓
Notification service init
   ↓
Run App
```

---

## Paket Önerileri

İlk sürüm:

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^4.0.0
  intl: ^0.19.0
  flutter_local_notifications: ^17.0.0
  file_picker: ^8.0.0
  path_provider: ^2.1.0
  share_plus: ^9.0.0
```

State management kullanılırsa:

```yaml
flutter_riverpod: ^2.5.0
```

Kod üretimi kullanılacaksa:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
```

---

## ID Stratejisi

Tüm kayıtlarda benzersiz id kullanılmalıdır.

Öneri:

```text
uuid
```

Örnek:

```dart
final id = const Uuid().v4();
```

Neden önemli?

- Hive’da kayıt ayırt etmek için
- JSON export/import sırasında çakışmayı önlemek için
- Firebase’e geçince document id olarak kullanmak için

---

## Tarih Stratejisi

Her ana modelde şu alanlar bulunmalıdır:

```text
createdAt
updatedAt
deletedAt
```

`deletedAt` soft delete için kullanılır.

İleride sync yapılırken silinen kayıtları yönetmek kolaylaşır.

---

## Soft Delete Stratejisi

Veriler tamamen silinmek yerine ilk aşamada soft delete yapılabilir.

Örnek:

```text
isDeleted: true
deletedAt: 2026-07-02
```

Avantaj:

- Geri alma yapılabilir.
- JSON yedeklerde veri kaybı azalır.
- Firebase sync sırasında silme işlemleri daha güvenli yönetilir.

---

## Sync Hazırlığı

Backend şimdilik yok ama modeller sync’e hazır tutulmalıdır.

Her modelde şu alanlar olabilir:

```text
syncStatus: localOnly | synced | pendingCreate | pendingUpdate | pendingDelete
lastSyncedAt
remoteId
```

İlk sürümde bu alanlar aktif kullanılmayabilir, ama modelde bulunması ileride geçişi kolaylaştırır.

---

## Ana Mimari Kural

> UI hiçbir zaman doğrudan Hive kullanmamalı.

Doğru akış:

```text
Page → Provider/Controller → Repository → DataSource → Hive
```

Bu kurala uyulursa uygulama büyüdüğünde yönetilebilir kalır.
