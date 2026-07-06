# Ev Masraflari App

Flutter ile gelistirilen local-first ev masrafi ve fatura takip uygulamasi.

## Guncel Durum

Calisan temel akislari:

- Kisi sistemi: `Ben` kaydi ve ev arkadasi ekleme.
- Masraf sistemi:
  - Sadece bana ait masraf.
  - Ortak esit masraf.
  - Masraf silme.
- Dashboard ozeti:
  - Bana yazilan toplam.
  - Ortak masraflar.
  - Benim ortak payim.
  - Sadece benim masraflarim.
  - Bu ay girilen toplam.
- Fatura sistemi:
  - Fatura turu ekleme.
  - Ev faturasi / kisisel fatura ayrimi.
  - Aylik tekrarlayan fatura kaydi.
  - Sabit tutarli fatura.
  - Tutar bekleniyor / odenmeye hazir / odendi durumlari.
  - Fatura odendiginde otomatik masraf kaydi olusturma.
  - Aylik fatura silindiginde bagli masrafi da silme.
  - Fatura turu silindiginde eski odenmis aylik kayitlari koruma.
- Backup sistemi:
  - JSON yedek disa aktarma.
  - JSON yedek ice aktarma.
  - Import oncesi kullanici uyarisi.
  - `Replace All` import davranisi.
- Shopping list:
  - Urun ekleme.
  - Urun listeleme.
  - Satin alindi isaretleme.
  - Urun silme.
  - Durum filtresi.
  - Kisa liste ozeti.

## Hesaplama Karari

Uygulama settlement hesabi yapmaz.

Ana metrik `Bana yazilan toplam`dir:

```text
Bana yazilan toplam =
  Ortak masraflardaki benim payim
  + sadece bana ait masraflar
```

`Ortak esit` secilirse kullanicinin payi toplam tutarin yarisidir. Bu karar masraflar ve faturalardan otomatik olusan masraf kayitlari icin ayni sekilde uygulanir.

## Dogrulama

Son dogrulama:

```bash
dart format lib test
flutter analyze
flutter test
```

Son test durumunda 29 test basarili gecmistir.

## Commit Kurali

AI proje icinde `git commit` calistirmaz. Commit atma isi proje sahibine aittir.

Kullanici commit isterse AI sadece commit mesaji ve komut onerisi verir.

## Dokumanlar

Detayli proje dokumanlari:

- `docs/PROJECT_PLAN.md`
- `docs/README_DOCS.md`
- `docs/01_PROJECT_OVERVIEW.md`
- `docs/02_LOCAL_FIRST_ARCHITECTURE.md`
- `docs/03_DATA_MODELS_AND_STORAGE.md`
- `docs/04_FEATURE_SPECIFICATIONS.md`
- `docs/05_BACKUP_RESTORE_AND_MIGRATION.md`
- `docs/06_DEVELOPMENT_ROADMAP.md`
- `docs/07_FUTURE_BACKEND_FIREBASE_PLAN.md`
- `docs/AI_TRACKING.md`

## Siradaki Adim

Onerilen siradaki teknik adim:

1. Dashboard icin biten ay ozet arsivini eklemek.
2. Ay kartina tiklayinca acilan birlesik aylik rapor akisini kurmak.
3. Sonra shopping list icin kategori filtresi ve duzenleme akisina donmek.

Backup icin sonra ele alinacak hardening isleri:

- import oncesi otomatik on-yedek
- import/export sonrasi detayli ozet
- daha siki JSON sema dogrulamasi
