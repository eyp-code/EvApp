# Dokumanlar

Bu klasor Ev Masraflari App icin public repoda tutulabilecek teknik dokumanlari icerir. Dosyalar urun kapsamindan mimariye, veri modellerinden backup/restore akisina kadar ana karar noktalarini ozetler.

## Okuma Sirasi

1. `01_PROJECT_OVERVIEW.md`
2. `02_LOCAL_FIRST_ARCHITECTURE.md`
3. `03_DATA_MODELS_AND_STORAGE.md`
4. `04_FEATURE_SPECIFICATIONS.md`
5. `05_BACKUP_RESTORE_AND_MIGRATION.md`
6. `06_DEVELOPMENT_ROADMAP.md`
7. `07_FUTURE_BACKEND_FIREBASE_PLAN.md`

## Dosyalar

| Dosya | Icerik |
| --- | --- |
| `01_PROJECT_OVERVIEW.md` | Projenin amaci, kapsam ve temel urun kararlari |
| `02_LOCAL_FIRST_ARCHITECTURE.md` | Flutter katmanlari, local-first yaklasim ve repository sinirlari |
| `03_DATA_MODELS_AND_STORAGE.md` | Hive veri modeli, JSON alanlari ve storage yaklasimi |
| `04_FEATURE_SPECIFICATIONS.md` | Masraf, fatura, alisveris listesi ve gorev akislari |
| `05_BACKUP_RESTORE_AND_MIGRATION.md` | JSON export/import, veri tasima ve migration notlari |
| `06_DEVELOPMENT_ROADMAP.md` | Tamamlanan ve planlanan gelistirme adimlari |
| `07_FUTURE_BACKEND_FIREBASE_PLAN.md` | Ileride backend veya Firebase eklenirse izlenecek strateji |

## Ana Mimari Karar

Uygulama ilk surumde local-first calisir. UI katmani dogrudan Hive veya uzak servis bilmez; veri erisimi repository arayuzleri uzerinden yapilir.

```text
Flutter UI
  -> Feature pages
  -> Repository interfaces
  -> Local data sources
  -> Hive storage
```

Bu sinir, ileride Firebase veya ozel backend eklense bile UI tarafinin buyuk oranda korunmasini hedefler.
