# EvApp AI Tracking

Bu dosya proje boyunca AI ile yapılan kararları, kod değişikliklerini ve gerekçeleri takip etmek için tutulur. Her geliştirme adımında buraya kısa ama net kayıt eklenecek.

## Kullanım Kuralı

- Her önemli adımda yeni kayıt eklenecek.
- Kayıtlarda ne yaptık, neden yaptık, nasıl kodladık ve sonraki adım ne olacak soruları cevaplanacak.
- Mimari kararlar burada özetlenecek; detay dokümanları kaynak olarak kalacak.
- Kod değişikliklerinde ilgili dosyalar ve doğrulama komutları yazılacak.
- Commit atma işi proje sahibine aittir. AI proje içinde asla `git commit` çalıştırmayacak.
- Bu dosya hem proje sahibi hem de AI için okunabilir tutulacak; kararların nedeni basit dille açıklanacak.

## Proje Temel Kararları

- Uygulama Flutter ile geliştirilecek.
- İlk sürüm local-first olacak; backend kullanılmayacak.
- Ana veri kaynağı Hive olacak.
- UI katmanı doğrudan Hive bilmeyecek.
- Doğru akış: Page -> Provider/Controller -> Repository -> DataSource -> Hive.
- Veriler JSON export/import ile yedeklenebilir olacak.
- Modeller ileride Firebase/backend sync için id, tarih, soft delete ve sync alanlarına hazır tasarlanacak.
- MVP odağı: person sistemi, masraf ekleme, ortak gider bölme, fatura takibi, dashboard özet, local kayıt ve JSON yedekleme.
- Masraf paylaşımı olacak ama borç/alacak takibi olmayacak. Uygulama "kim kime borçlu" veya "net borç" hesabı göstermeyecek.
- Masraflarda "kim ödedi" bilgisi tutulabilir; bu bilgi sadece kayıt, filtreleme ve raporlama için kullanılacak.

## İncelenen Dokümanlar

- `PROJECT_PLAN.md`
- `README_DOCS.md`
- `01_PROJECT_OVERVIEW.md`
- `02_LOCAL_FIRST_ARCHITECTURE.md`
- `03_DATA_MODELS_AND_STORAGE.md`
- `04_FEATURE_SPECIFICATIONS.md`
- `05_BACKUP_RESTORE_AND_MIGRATION.md`
- `06_DEVELOPMENT_ROADMAP.md`
- `07_FUTURE_BACKEND_FIREBASE_PLAN.md`

## Günlük Kayıtlar

### 2026-07-02 - Başlangıç İncelemesi

**Ne yaptık**

- Proje dokümantasyonunu ve mevcut Flutter yapısını inceledik.
- Projenin henüz default Flutter counter template seviyesinde olduğunu gördük.
- `pubspec.yaml` içinde şu an sadece temel Flutter ve `cupertino_icons` bağımlılığı olduğunu gördük.
- Yol haritasında önce temel Flutter iskeleti, sonra Hive local storage ve person/expense akışına geçmenin planlandığını doğruladık.

**Nasıl düşündük**

- İlk iş olarak doğrudan masraf formuna dalmak yerine uygulama iskeletini kurmak daha doğru.
- Çünkü navigation, tema, klasör yapısı ve sayfa ayrımı oturmadan repository ve storage kodu büyürse proje erken dağılır.
- Ancak iskeleti fazla büyütmeden kurmak gerekiyor; MVP için kullanılacak ekranları boş/placeholder olarak açmak yeterli.

**Önerilen ilk teknik adım**

Phase 1 ile başlamak:

1. `lib/main.dart` içindeki counter template'i kaldırmak.
2. `lib/app/app.dart`, `lib/app/theme.dart` ve temel feature sayfalarını oluşturmak.
3. Bottom navigation ile şu ekranları bağlamak: Dashboard, Masraflar, Faturalar, Alışveriş, Görevler, Ayarlar.
4. Uygulamayı çalıştırıp sayfalar arası gezinmenin sorunsuz olduğunu doğrulamak.

**Sonraki kayıt için beklenen konu**

- Temel Flutter iskeleti kodlandığında hangi dosyalar oluşturuldu, navigation nasıl kuruldu ve hangi doğrulama yapıldı buraya eklenecek.

### 2026-07-02 - Phase 1 Temel Flutter İskeleti

**Ne yaptık**

- Default Flutter counter template kaldırıldı.
- Uygulamanın ana sınıfı `EvApp` olarak ayrıldı.
- `lib/app/` altında app ve theme dosyaları oluşturuldu.
- `MainShell` ile bottom navigation kuruldu.
- MVP için ilk ana ekranlar eklendi:
  - Dashboard / Ev Özeti
  - Masraflar
  - Faturalar
  - Alışveriş
  - Görevler
  - Ayarlar
- Ortak placeholder kart widget'ı eklendi.
- Widget testi counter testinden çıkarılıp yeni navigation yapısını kontrol edecek hale getirildi.

**Nasıl kodladık**

- `lib/main.dart` sadece uygulamayı başlatacak şekilde sade tutuldu.
- `lib/app/app.dart` içinde `MaterialApp`, tema ve ana shell bağlandı.
- `lib/app/theme.dart` içinde sade bir Material 3 tema tanımlandı.
- `lib/features/shell/presentation/main_shell.dart` içinde `NavigationBar` ve `IndexedStack` kullanıldı.
- `IndexedStack` seçildi çünkü tab değiştirirken ekran state'lerini ileride korumak daha kolay olacak.
- Şimdilik Riverpod, Hive veya başka paket eklenmedi; ilk adım sadece uygulama iskeleti.

**Neden böyle yaptık**

- Uygulama büyümeden önce klasör yapısı ve ekran ayrımı otursun istedik.
- UI doğrudan veri katmanına bağlanmadan önce kullanıcı akışını belirledik.
- Masraf, fatura ve diğer özellikler artık kendi feature klasörlerinin içine eklenebilecek.

**Değişen dosyalar**

- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/theme.dart`
- `lib/features/shell/presentation/main_shell.dart`
- `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- `lib/features/expenses/presentation/pages/expenses_page.dart`
- `lib/features/bills/presentation/pages/bills_page.dart`
- `lib/features/shopping/presentation/pages/shopping_page.dart`
- `lib/features/tasks/presentation/pages/tasks_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/shared/widgets/section_placeholder.dart`
- `test/widget_test.dart`

**Doğrulama durumu**

- Sandbox içinde `dart format` ve `flutter analyze` komutları başlatıldı ama `dart` süreci cevap vermediği için timeout oldu.
- Dış izinle bir kez `flutter analyze` çalıştı ve eski widget testinin `MyApp` araması nedeniyle hata verdi.
- Bu hata düzeltildi: test artık `EvApp` ile açılış ve tab geçişini kontrol ediyor.
- Flutter/Dart sürümü veya dependency versiyonları değiştirilmedi.

**Commit kuralı**

- AI bu adımda commit atmadı.
- Proje boyunca commit atma işi proje sahibinde kalacak.

**Sonraki adım**

- Phase 1 doğrulaması tamamlandıktan sonra Phase 2'ye geçilecek: Hive paketleri, local storage bootstrap akışı ve ilk `Person` modeli.

### 2026-07-02 - Phase 2 Local Storage Temeli ve Person Seed

**Ne yaptık**

- Local storage için Hive altyapısı eklendi.
- `uuid` eklendi; kayıt id'leri rastgele ve benzersiz üretilecek.
- Uygulama açılışı `bootstrapApp()` ile hazır hale getirildi.
- İlk domain modeli olarak `Person` oluşturuldu.
- Uygulama ilk açıldığında Hive içinde `isMe == true` kişi yoksa otomatik `Ben` kaydı oluşturuluyor.
- Dashboard ekranında local kişi kaydı görünür hale getirildi.
- Ayarlar ekranında Hive içinde kaç kişi kaydı olduğu gösterildi.
- Widget testi fake `PersonRepository` kullanacak şekilde güncellendi.

**Nasıl kodladık**

- `lib/bootstrap.dart` uygulamanın başlangıç hazırlığını yönetiyor:
  - `Hive.initFlutter()`
  - `persons_box` açılışı
  - datasource ve repository oluşturma
  - default `Ben` kişisini seed etme
- `Person` modeli `toJson/fromJson` destekli yazıldı.
- Şimdilik Hive adapter/code generation kullanmadık; modeli JSON map olarak saklıyoruz.
- Bunun nedeni başlangıçta daha anlaşılır ve daha az karmaşık ilerlemek.
- Repository sınırı korundu:
  - UI -> `PersonRepository`
  - Repository -> `PersonLocalDataSource`
  - DataSource -> Hive box

**Neden böyle yaptık**

- UI'ın Hive'ı doğrudan bilmemesi kuralını ilk gerçek veri modelinden itibaren uyguladık.
- `Person` modeli masraf paylaşımı için temel olacak; "Ben" ve sonra "Ev arkadaşı" bu yapıdan gelecek.
- `toJson/fromJson` ileride JSON backup/restore ve Firebase geçişi için temel hazırlık.

**Değişen dosyalar**

- `pubspec.yaml`
- `pubspec.lock`
- `lib/main.dart`
- `lib/app/app.dart`
- `lib/bootstrap.dart`
- `lib/core/storage/hive_box_names.dart`
- `lib/features/people/domain/models/person.dart`
- `lib/features/people/domain/repositories/person_repository.dart`
- `lib/features/people/data/data_sources/person_local_data_source.dart`
- `lib/features/people/data/repositories/local_person_repository.dart`
- `lib/features/shell/presentation/main_shell.dart`
- `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `test/widget_test.dart`

**Doğrulama**

- `flutter pub get` başarılı.
- `dart format lib test` başarılı.
- `flutter analyze` başarılı, issue yok.
- `flutter test` başarılı, tüm testler geçti.

**Önemli not**

- Flutter SDK sürümü değiştirilmedi.
- Commit atılmadı. Commit atma işi proje sahibinde.

**Sonraki adım**

- Phase 3: Person / Roommate sistemi.
- Bu adımda ev arkadaşı ekleme, kişi listeleme ve ileride masraf formunda kullanılacak kişi seçimi için temel UI kurulacak.

### 2026-07-02 - Bootstrap Dependency Hatası Düzeltmesi

**Gelen hata**

- Emulator üzerinde şu tip hata görüldü:
  - `type Null is not a subtype of type AppDependencies of function result`

**Neden oldu**

- Önceki yapıda `main.dart` içinde `bootstrapApp()` çalışıyor, sonra sonuç `EvApp(dependencies: dependencies)` olarak uygulamaya veriliyordu.
- Bu doğru bir yöntem olabilir ama geliştirme sırasında hot reload/hot restart eski widget bilgisini taşıyınca `EvApp` için beklenen dependency alanı null kalabiliyor.
- Yani problem Flutter sürümü değil; uygulama başlangıç şeklinin geliştirme sırasında kırılgan kalmasıydı.

**Nasıl düzelttik**

- `main.dart` tekrar sade hale getirildi:
  - `WidgetsFlutterBinding.ensureInitialized()`
  - `runApp(const EvApp())`
- `EvApp` artık kendi içinde bootstrap sürecini yönetiyor.
- `EvApp` açılınca:
  1. `bootstrapApp()` çağrılıyor.
  2. Hive hazırlanıyor.
  3. Repository'ler oluşturuluyor.
  4. Hazırlık bitince `MainShell` açılıyor.
- Hazırlık sürerken loading ekranı gösteriliyor.
- Hazırlıkta hata olursa kırmızı crash yerine okunabilir hata ekranı gösteriliyor.

**Hiç bilmeyen biri için mantık**

- `main.dart` uygulamanın kapısıdır. Burada mümkün olduğunca az iş yapıyoruz.
- `bootstrapApp()` uygulama açılmadan önce gerekli hazırlıkları yapar.
- Hive, telefonun içindeki küçük yerel veritabanı gibi düşünülebilir.
- `persons_box`, Hive içinde kişi kayıtlarını koyduğumuz kutudur.
- `Person` bizim kişi modelimizdir. İlk kayıt olarak `Ben` oluşturulur.
- `Repository`, ekranların veriyle konuştuğu kapıdır.
- Ekranlar Hive'ı bilmez. Ekran sadece "bana kişileri ver" der; repository gerisini halleder.

**Test düzeltmesi**

- `EvApp` artık açılışta önce loading frame'i gösterebildiği için widget testinde bir frame bekletildi.
- Test gerçek Hive kullanmıyor; fake `PersonRepository` veriliyor.
- Böylece test hızlı ve bağımsız kalıyor.

**Doğrulama**

- `dart format test lib` başarılı.
- `flutter analyze` başarılı, issue yok.
- `flutter test` başarılı, tüm testler geçti.

**Commit kuralı**

- Commit atılmadı.
- Commit atma işi proje sahibinde kalmaya devam ediyor.

### 2026-07-02 - Borç/Alacak Kapsamdan Çıkarıldı

**Ürün kararı**

- Ev arkadaşı ve ortak masraf paylaşımı kalacak.
- Kullanıcı bir masrafı ikiye bölebilecek veya farklı paylarla bölebilecek.
- Kullanıcı "kim ödedi?" bilgisini seçebilecek.
- Uygulama borç/alacak takibi yapmayacak.
- Dashboard veya raporlarda "kim kime borçlu", "bana borçlu", "ben ona borçluyum", "net borç" gibi alanlar olmayacak.

**Neden**

- Bu uygulamanın hedefi ev masraflarını ve kişinin kendi payını takip etmek.
- Borç takibi ayrı bir finans/settlement sistemi gibi davranır ve ürünü gereksiz karmaşıklaştırır.
- Şimdilik yeterli bilgiler:
  - Toplam ev masrafı
  - Benim payım
  - Kişisel harcamam
  - Ev arkadaşının payı
  - Kategori/fatura/abonelik toplamları

**Kodda yapılan düzeltme**

- Dashboard placeholder metnindeki `net borç` ifadesi kaldırıldı.
- Yerine `kişisel harcamam` ifadesi kullanıldı.

**Gelecek geliştirme notu**

- ExpenseCalculator yazılırken debt/net debt fonksiyonları eklenmeyecek.
- `paidByPersonId` alanı yine tutulabilir, ama borç üretmek için değil; sadece "bu kaydı kim ödedi?" bilgisini saklamak için.
- AI ileride eski dokümanlarda borç ifadesi görürse bu tracking kararını daha güncel kaynak kabul edecek.
### 2026-07-03 - Phase 3 Person / Roommate Sistemi Başlangıcı

**Ne yaptık**

- `Person` modeli ev arkadaşı oluşturma, isim güncelleme ve soft delete akışını destekleyecek şekilde genişletildi.
- `PersonRepository` sözleşmesine `updatePerson` ve `deletePerson` eklendi.
- Hive data source içine id ile kişi okuma desteği eklendi.
- Local repository içinde `Ben` kaydının silinmesini engelleyen soft delete davranışı yazıldı.
- Ayarlar ekranında gerçek kişi yönetimi bölümü oluşturuldu:
  - Mevcut kişiler listeleniyor.
  - Ev arkadaşı eklenebiliyor.
  - Kişi ismi düzenlenebiliyor.
  - Ev arkadaşı silinebiliyor.
- Widget testine ev arkadaşı ekleme akışı eklendi.

**Nasıl kodladık**

- UI yine doğrudan Hive kullanmıyor; Ayarlar ekranı sadece `PersonRepository` ile konuşuyor.
- Silme işlemi fiziksel kayıt silme değil, `isDeleted`, `deletedAt` ve `pendingDelete` alanlarını güncelleyen soft delete olarak kaldı.
- `Person.createRoommate`, `renamed` ve `markedDeleted` helper'ları model üzerinde tutuldu; böylece tarih ve sync alanları tek yerde güncelleniyor.
- Dialog içindeki `TextEditingController` ayrı stateful dialog içinde yönetildi. Testte yakalanan dispose zamanlaması hatası bu şekilde düzeltildi.

**Neden böyle yaptık**

- Masraf MVP'ye geçmeden önce kişi listesinin gerçek local veriden gelmesi gerekiyor.
- Masraf formunda "kim ödedi?" ve "kimlerin payı var?" seçimleri bu repository üzerinden beslenecek.
- Soft delete geçmiş masraf kayıtlarının ileride bozulmaması için şimdiden doğru varsayılan davranış.

**Değişen dosyalar**

- `lib/features/people/domain/models/person.dart`
- `lib/features/people/domain/repositories/person_repository.dart`
- `lib/features/people/data/data_sources/person_local_data_source.dart`
- `lib/features/people/data/repositories/local_person_repository.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `test/widget_test.dart`
- `AI_TRACKING.md`

**Doğrulama**

- `dart format lib test` başarılı.
- `flutter analyze` başarılı, issue yok.
- `flutter test` başarılı, tüm testler geçti.

**Sonraki adım**

- Phase 3'ü küçük bir tamamlayıcı adımla güçlendirmek: kişi düzenleme/silme akışları için ek widget testleri eklenebilir.
- Ardından Phase 4 Expense MVP'ye geçilecek: `Expense`, `ExpenseShare`, ilk split tipleri ve masraf ekleme/listeleme ekranı.
### 2026-07-03 - Phase 4 Expense MVP İlk Parça

**Ne yaptık**

- Masraf takibi için ilk domain modelleri eklendi:
  - `Expense`
  - `ExpenseShare`
  - `SplitType`
- `expenses_box` Hive box adı tanımlandı.
- Expense data source ve repository katmanı eklendi.
- `AppDependencies` içine `ExpenseRepository` bağlandı.
- Bootstrap sırasında `expenses_box` açılacak hale getirildi.
- Masraflar ekranı placeholder olmaktan çıkarıldı:
  - Masraf listesi gösteriliyor.
  - Boş state gösteriliyor.
  - Masraf ekleme dialog'u açılıyor.
  - Başlık, kategori, tutar, ödeyen kişi ve paylaşım tipi seçiliyor.
  - İlk split tipleri: `Sadece benim` ve `Ortak eşit`.
  - Liste kartında toplam tutar, ödeyen kişi, kategori ve benim payım görünüyor.
- Widget testine "sadece benim" masraf ekleme senaryosu eklendi.

**Nasıl kodladık**

- UI yine doğrudan Hive kullanmıyor; `ExpensesPage` sadece `PersonRepository` ve `ExpenseRepository` ile konuşuyor.
- Masraf paylaşım tutarları `Expense.create` içinde hesaplanıyor.
- `Sadece benim` masrafta pay doğrudan `Ben` kişisine yazılıyor.
- `Ortak eşit` masrafta tutar mevcut kişi sayısına eşit bölünüyor.
- Borç/alacak hesabı eklenmedi; yalnızca pay bilgisi tutuluyor.

**Neden böyle yaptık**

- MVP için önce masrafın local olarak kaydedilip listelenmesi gerekiyor.
- Pay hesabını modelde toplamak, ileride dashboard ve rapor ekranlarının aynı veriyi tekrar hesaplamadan kullanmasını sağlar.
- İlk parçada düzenleme/silme/filtreleme eklenmedi; kapsam bilinçli olarak küçük tutuldu.

**Değişen dosyalar**

- `lib/core/storage/hive_box_names.dart`
- `lib/bootstrap.dart`
- `lib/features/shell/presentation/main_shell.dart`
- `lib/features/expenses/domain/models/expense.dart`
- `lib/features/expenses/domain/models/expense_share.dart`
- `lib/features/expenses/domain/models/split_type.dart`
- `lib/features/expenses/domain/repositories/expense_repository.dart`
- `lib/features/expenses/data/data_sources/expense_local_data_source.dart`
- `lib/features/expenses/data/repositories/local_expense_repository.dart`
- `lib/features/expenses/presentation/pages/expenses_page.dart`
- `test/widget_test.dart`
- `AI_TRACKING.md`

**Doğrulama**

- `dart format lib test` başarılı.
- `flutter analyze` başarılı, issue yok.
- `flutter test` başarılı, tüm testler geçti.

**Sonraki adım**

- Masraf MVP'nin ikinci parçası: ortak eşit bölme için manuel test/test kapsamı, masraf silme ve dashboard finans özetine gerçek toplamların bağlanması.
### 2026-07-03 - Phase 4 Expense MVP İkinci Parça

**Ne yaptık**

- Masraf silme akışı eklendi.
- `Expense` modeline `copyWith` ve `markedDeleted` eklendi.
- `ExpenseRepository` sözleşmesine `deleteExpense` eklendi.
- Expense Hive data source içine id ile masraf okuma desteği eklendi.
- Local expense repository silmeyi soft delete olarak uyguluyor.
- Masraf kartına silme ikonu eklendi.
- Dashboard finans özeti gerçek masraf kayıtlarına bağlandı:
  - Toplam ev masrafı
  - Benim payım
  - Kişisel harcamam
- Dashboard'a `ExpenseRepository` dependency olarak verildi.
- Widget testlerine masraf silme ve dashboard özet senaryoları eklendi.

**Nasıl kodladık**

- Silme fiziksel kayıt silme değil; `isDeleted`, `deletedAt` ve `pendingDelete` güncellemesiyle soft delete.
- Dashboard, `PersonRepository.getMe()` ve `ExpenseRepository.getExpenses()` sonuçlarını birlikte okuyarak toplamları hesaplıyor.
- Borç/alacak hesabı eklenmedi; `paidByPersonId` sadece kişisel harcamam hesabı için kullanıldı.
- Test dosyası UTF-8 metinlerle temiz yeniden yazıldı.

**Neden böyle yaptık**

- Kullanıcı yanlış masraf girebilir; MVP'nin kullanılabilir olması için silme gerekir.
- Dashboard'ın gerçek veriye bağlanması masraf ekleme akışını görünür ve doğrulanabilir hale getirir.
- Soft delete ileride backup/restore ve sync davranışını kolaylaştırır.

**Değişen dosyalar**

- `lib/features/expenses/domain/models/expense.dart`
- `lib/features/expenses/domain/repositories/expense_repository.dart`
- `lib/features/expenses/data/data_sources/expense_local_data_source.dart`
- `lib/features/expenses/data/repositories/local_expense_repository.dart`
- `lib/features/expenses/presentation/pages/expenses_page.dart`
- `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- `lib/features/shell/presentation/main_shell.dart`
- `test/widget_test.dart`
- `AI_TRACKING.md`

**Doğrulama**

- `dart format lib test` başarılı.
- `flutter analyze` başarılı, issue yok.
- `flutter test` başarılı, tüm testler geçti.

**Sonraki adım**

- Ortak eşit bölme akışını manuel ve otomatik testlerle güçlendirmek.
- Ardından masraf düzenleme veya fatura sistemi MVP'sine geçmeden önce dashboard tarih filtresi ihtiyacını netleştirmek.
### 2026-07-03 - Dashboard Kişisel Harcamam Hesabı Düzeltmesi

**Ne değişti**

- Dashboard içindeki `Kişisel harcamam` hesabı düzeltildi.
- Önce bu alan `paidByPersonId == Ben` olan masrafların toplamıydı.
- Artık `Kişisel harcamam`, `Benim payım` ile aynı değeri gösteriyor.

**Neden**

- Bu uygulamada amaç kasadan kimin ne kadar ödediğini borç/alacak gibi takip etmek değil.
- Kullanıcının görmek istediği kişisel harcama, kendi payına düşen harcama tutarı.
- Bu yüzden ev arkadaşı ödemiş olsa bile ortak eşit masrafta kullanıcının kişisel harcaması kendi payı kadar olmalı.

**Örnek**

- Market masrafı: 1200 TL
- Ödeyen: Ev arkadaşı
- Paylaşım: Ortak eşit
- Toplam ev masrafı: 1200 TL
- Benim payım: 600 TL
- Kişisel harcamam: 600 TL

**Doğrulama**

- Dashboard widget testi ortak eşit masraf senaryosuna güncellendi.
- `dart format lib test` başarılı.
- `flutter analyze` başarılı, issue yok.
- `flutter test` başarılı, tüm testler geçti.
### 2026-07-03 - Benim Payım ve Kişisel Harcamam Ayrımı

**Ürün kararı**

- `Benim payım` yalnızca ortak bölünen masraflardan kullanıcıya düşen tutarı gösterecek.
- `Kişisel harcamam`, ortak masraflardaki kullanıcı payı + sadece kullanıcıya ait masrafların toplamı olacak.
- `paidByPersonId` borç/alacak hesabı üretmeyecek; sadece "bu kaydı kim ödedi?" bilgisi olarak kalacak.

**Örnek**

- Ortak market: 1200 TL, iki kişi eşit bölündü.
- Sadece benim kahve: 200 TL.
- Toplam ev masrafı: 1400 TL.
- Benim payım: 600 TL.
- Kişisel harcamam: 800 TL.

**Kod değişikliği**

- Dashboard hesaplamasında `myShare`, sadece `SplitType.equal` masraflardaki kullanıcı payından hesaplanıyor.
- Dashboard hesaplamasında `personalExpense`, tüm masraflardaki kullanıcı payı toplamından hesaplanıyor.
- Dashboard widget testi bu örnek senaryoya göre güncellendi.

**Doküman güncellemesi**

- `PROJECT_PLAN.md` güncellendi.
- `06_DEVELOPMENT_ROADMAP.md` güncellendi.
- `AI_TRACKING.md` güncellendi.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
### 2026-07-03 - Dashboard Hesaplama Dilinin Netleştirilmesi

**Ürün kararı**

- Dashboard'da ana sayı artık `Bana yazılan toplam` olacak.
- `Bana yazılan toplam` = ortak masraflardaki benim payım + sadece bana ait masraflar.
- `Ortak masraflar` ikiye/eşit bölünen masrafların toplamını gösterir.
- `Benim ortak payım` yalnızca ortak masraflardan bana düşen tutarı gösterir.
- `Sadece benim masraflarım` ortak olmayan, doğrudan bana ait masrafları gösterir.
- `Bu ay girilen toplam` uygulamaya girilen tüm masrafların toplamını gösterir.
- Borç/alacak ve net borç hesabı yine kapsam dışıdır.

**Örnek**

- Ortak market: 1200 TL.
- Sadece bana ait kahve: 200 TL.
- Bana yazılan toplam: 800 TL.
- Ortak masraflar: 1200 TL.
- Benim ortak payım: 600 TL.
- Sadece benim masraflarım: 200 TL.
- Bu ay girilen toplam: 1400 TL.

**Kod değişikliği**

- Dashboard özet kartı yeni isimler ve yeni hesap alanlarıyla düzenlendi.
- Masraf formundaki split etiketi `Sadece bana ait` olarak güncellendi.
- Dashboard widget testi yeni hesaplama dili ve örnek senaryoya göre güncellendi.
- Tüm markdown dokümanlarının başına güncel Dashboard hesaplama dili notu eklendi.
### 2026-07-03 - Ara Sonrası Devam Planı

**Mevcut durum**

- Phase 3 Person / Roommate sistemi temel olarak çalışıyor.
- Phase 4 Expense MVP temel akışı çalışıyor:
  - Masraf ekleme
  - Masraf listeleme
  - Masraf silme
  - `Sadece bana ait` ve `Ortak eşit` split tipleri
  - Dashboard masraf özeti
- Güncel Dashboard dili:
  - `Bana yazılan toplam`
  - `Ortak masraflar`
  - `Benim ortak payım`
  - `Sadece benim masraflarım`
  - `Bu ay girilen toplam`
- Borç/alacak ve net borç hesabı kapsam dışı.

**Ara sonrası önerilen sıra**

1. Mevcut Expense MVP manuel test edilecek ve commitlenecek.
2. Kısa sağlamlaştırma adımı:
   - Ortak eşit masraf ekleme manuel olarak doğrulanacak.
   - Gerekirse masraf kartlarında tarih/kategori görünümü sadeleştirilecek.
   - Form validasyon mesajları eklenecek.
3. Sonra iki yoldan biri seçilecek:
   - Seçenek A: Masraf düzenleme ve kategori iyileştirmesi.
   - Seçenek B: Phase 6 Bill System MVP'ye geçiş.

**Önerim**

- Önce küçük sağlamlaştırma adımı yapılmalı.
- Ardından fatura sistemi MVP'ye geçmek daha mantıklı.
- Çünkü uygulamanın ana omurgası masraf + kişi + dashboard olarak çalışır hale geldi; sıradaki büyük MVP parçası fatura takibi.

### 2026-07-03 - Expense MVP Saglamlastirma

**Ne yaptik**

- Masraf ekleme formu `Form` ve `TextFormField` yapisina alindi.
- Bos baslik ve gecersiz tutar icin kullaniciya validasyon mesaji gosteriliyor.
- Masraf kartina harcama tarihi eklendi.
- Ortak esit masraf ekleme akisi widget testiyle dogrulandi.
- Form validasyon mesajlari icin widget testi eklendi.

**Neden boyle yaptik**

- Expense MVP artik sadece mutlu yolu degil, hatali form girislerini de kullaniciya acik sekilde yonetiyor.
- Ortak esit bolme, dashboard hesaplarinin temel girdisi oldugu icin otomatik test kapsamina alindi.
- Masraf tarihinin kartta gorunmesi fatura sistemine gecmeden once liste okunabilirligini artirdi.

**Degisen dosyalar**

- `lib/features/expenses/presentation/pages/expenses_page.dart`
- `test/widget_test.dart`
- `AI_TRACKING.md`

**Dogrulama**

- `dart format lib test` basarili.
- `flutter analyze` basarili, issue yok.
- `flutter test` basarili, tum testler gecti.

**Sonraki adim**

- Phase 6 Bill System MVP'ye gecilecek:
  - `BillType` ve `MonthlyBill` modelleri.
  - Hive box isimleri.
  - Bill datasource/repository.
  - Fatura turu ekleme.
  - Aylik fatura ekleme ve odendi isaretleme.
