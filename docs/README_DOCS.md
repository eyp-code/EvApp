# EvApp Dokümantasyon Paketi

Bu klasör, **EvApp** projesi için hazırlanmış detaylı proje planı dosyalarını içerir.

EvApp; ev masraflarını, faturaları, abonelikleri, alışveriş listesini, ev görevlerini ve ev arkadaşıyla ortak gider paylaşımını takip etmek için geliştirilecek bir Flutter uygulamasıdır.

Bu versiyonun ana kararı:

> İlk sürümde backend kullanılmayacak. Veriler cihazda local olarak tutulacak. Daha sonra Firebase veya özel backend eklenebilecek şekilde mimari kurulacak.

---

## Guncel Dokuman Durumu - 2026-07-05

Dokumanlar mevcut calisan urun durumuna gore guncellendi:

- Masraf ve fatura MVP'si aktif.
- JSON backup / restore temel akisi aktif.
- Shopping list sade MVP'si aktif:
  - urun ekleme
  - durum filtresi
  - alindi isaretleme
  - silme
- Shopping listte fiyat akisi bilerek kaldirildi.

Guncel okuma sirasi:

1. `README.md`
2. `PROJECT_PLAN.md`
3. `06_DEVELOPMENT_ROADMAP.md`
4. `05_BACKUP_RESTORE_AND_MIGRATION.md`
5. `AI_TRACKING.md`

Commit kurali:

- AI `git commit` calistirmaz.
- Commit atma isi proje sahibine aittir.
- AI sadece commit mesaji ve komut onerisi verir.

Siradaki teknik hedef:

- Shopping list icin urun duzenleme akisini eklemek.
- Kategori filtresi eklemek.
- Sonra Household Tasks MVP'ye gecmek.

## Dosyalar

| Dosya                                | Amaç                                                                          |
| ------------------------------------ | ----------------------------------------------------------------------------- |
| `PROJECT_PLAN.md`                    | Tüm planın tek dosyada birleşmiş ana versiyonu                                |
| `01_PROJECT_OVERVIEW.md`             | Projenin amacı, kapsamı, hedef kullanıcıları ve ana özellikleri               |
| `02_LOCAL_FIRST_ARCHITECTURE.md`     | Flutter mimarisi, local-first yaklaşım, Repository Pattern                    |
| `03_DATA_MODELS_AND_STORAGE.md`      | Hive veri modelleri, local storage yapısı, JSON formatları                    |
| `04_FEATURE_SPECIFICATIONS.md`       | Masraf, fatura, abonelik, bütçe, görev, alışveriş gibi özelliklerin detayları |
| `05_BACKUP_RESTORE_AND_MIGRATION.md` | Verileri başka cihaza taşıma, JSON export/import, ileride backend geçişi      |
| `06_DEVELOPMENT_ROADMAP.md`          | Aşamalar halinde geliştirme planı                                             |
| `07_FUTURE_BACKEND_FIREBASE_PLAN.md` | İleride Firebase veya backend ekleme stratejisi                               |

---

## Önerilen Proje Klasör Yapısı

```text
evapp/
 ├── lib/
 ├── assets/
 ├── test/
 ├── docs/
 │    ├── README_DOCS.md
 │    ├── PROJECT_PLAN.md
 │    ├── 01_PROJECT_OVERVIEW.md
 │    ├── 02_LOCAL_FIRST_ARCHITECTURE.md
 │    ├── 03_DATA_MODELS_AND_STORAGE.md
 │    ├── 04_FEATURE_SPECIFICATIONS.md
 │    ├── 05_BACKUP_RESTORE_AND_MIGRATION.md
 │    ├── 06_DEVELOPMENT_ROADMAP.md
 │    └── 07_FUTURE_BACKEND_FIREBASE_PLAN.md
 └── pubspec.yaml
```

---

## Proje Kararı

Bu proje başlangıçta şu mantıkla geliştirilecek:

```text
Flutter UI
   ↓
Controller / State Management
   ↓
Repository Layer
   ↓
Hive Local Database
```

İleride Firebase veya özel backend eklendiğinde UI tarafı bozulmadan şu yapıya geçilebilecek:

```text
Flutter UI
   ↓
Controller / State Management
   ↓
Repository Layer
   ↓
Local Hive + Remote Firebase / Backend
```

---

## İlk Hedef

İlk hedef, internetsiz çalışan sağlam bir MVP geliştirmektir:

- Masraf ekleme
- Benim payım / toplam ev masrafı ayrımı
- Ev arkadaşıyla gider bölme
- Fatura türü oluşturma
- Aylık fatura kaydı oluşturma
- Abonelik takibi
- Aylık bütçe hedefi
- Alışveriş listesi
- Ev görevleri
- Local bildirimler
- JSON yedek alma / geri yükleme

---

## Geliştirme Mantığı

Bu dokümanlardaki amaç, projenin kodlamasına başlamadan önce net bir yol haritası oluşturmaktır.

Kod yazarken ana kural:

> Sayfalar doğrudan Hive, Firebase veya başka bir veri kaynağını bilmemeli. Sayfalar sadece Repository katmanıyla konuşmalı.

Bu sayede ileride backend eklendiğinde tüm uygulamayı baştan yazmak gerekmez.
> Güncel Dashboard hesaplama dili: Ana takip metriği `Bana yazılan toplam`dır. Bu değer ortak masraflardaki benim payım + sadece bana ait masraflardan oluşur. `Ortak masraflar`, `Benim ortak payım`, `Sadece benim masraflarım` ve `Bu ay girilen toplam` ayrı gösterilir. Borç/alacak veya net borç hesabı yapılmaz.
