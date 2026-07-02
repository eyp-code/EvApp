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
