// ============================================================
// BAB VI PENGUJIAN DAN EVALUASI
// Bukti pengujian bersumber dari RLS_REVIEW.md dan TECHNICAL_DESIGN_V2.md pada repositori proyek.
// ============================================================

#import "../../template/lib.typ": *

// Tabel pada bab ini: huruf 9,5 pt dan rata kiri; judul tabel menempel pada baris pertama.
#show figure.where(kind: table): it => {
  show figure.caption: set block(sticky: true)
  it
}
#set table.cell(breakable: false)
#show table: set text(size: 9.5pt)
#show table: set par(justify: false)
#set table(inset: 4pt)

= PENGUJIAN DAN EVALUASI

Bab ini menjelaskan tahap pengujian terhadap sistem yang dikerjakan selama kerja praktik.

== Tujuan Pengujian

Pengujian bertujuan memastikan bahwa pengunjung dan setiap peran staf hanya dapat mengakses
data dan tindakan yang menjadi haknya, bahwa aturan bisnis pada server (harga, kapasitas
tanggal, kuota voucher, pembayaran, dan penomoran invoice) berjalan benar termasuk saat
permintaan datang bersamaan, serta bahwa situs tetap dapat dipakai saat layanan basis data
tidak tersedia dan pada layar ponsel. Pengujian difokuskan pada keamanan dan logika bisnis
karena kesalahan pada keduanya merugikan pelanggan dan usaha secara langsung.

== Kriteria Pengujian

Penilaian atas pencapaian tujuan pengujian memperhatikan kriteria berikut:

+ *K1.* Pengunjung anonim tidak dapat membaca tabel non-publik dan tidak dapat menulis selain
  menambah _lead_ dan memanggil fungsi yang dibuka secara eksplisit.
+ *K2.* Setiap peran staf hanya dapat melakukan tindakan sesuai hak aksesnya, dan eskalasi hak
  ditolak.
+ *K3.* Harga dihitung server, kapasitas tanggal dan kuota voucher tidak terlampaui, dan nomor
  invoice unik walau dua pencatatan berjalan bersamaan.
+ *K4.* Pembayaran, bukti transfer, dan invoice konsisten: pembayaran salah catat dapat
  dibatalkan dan bukti tidak dapat diakses publik.
+ *K5.* Situs tetap berfungsi tanpa _backend_ dan dapat dipakai pada layar ponsel.
+ *K6.* Perubahan skema yang menambah tabel atau fungsi tidak membuka akses baru.

== Skenario Pengujian

Aturan akses ditinjau dalam tiga lapis karena masing-masing menangkap hal yang tidak terlihat
oleh lapis lain: tinjauan sumber kebijakan terhadap matriks akses rancangan, pemeriksaan
permukaan akses anonim dengan kunci publik pada proyek Supabase terkelola, dan uji perilaku
tiap peran dengan sesi nyata pada tumpukan Supabase lokal. Data contoh diisi lebih dulu karena
nol baris pada tabel kosong bukan bukti perlindungan, dan penulisan dinilai dari jumlah baris
sebelum dan sesudah karena PostgREST menjawab `204` baik untuk `DELETE` yang berhasil maupun
yang tidak mengenai baris. Setiap migrasi yang menambah tabel atau fungsi diuji ulang dengan
cara yang sama dan dicatat sebagai _addendum_ pada dokumen tinjauan. Skenario yang dijalankan
dirangkum pada @tbl-skenario.

#allow-table-break[#figure(
  caption: [Skenario pengujian],
  table(
    columns: (0.9cm, 1fr, 1.6cm),
    align: (center, left, center),
    table.header([*No*], [*Skenario*], [*Kriteria*]),
    [1.], [Membaca `orders`, `payments`, `invoices`, `leads`, `profiles`, `audit_log`, `order_items`, `slot_claims`, dan `gate_events` sebagai anonim.], [K1],
    [2.], [Menyisipkan, mengubah, dan menghapus pada tabel inti serta _view_ publik sebagai anonim, dinilai dari jumlah baris sebelum dan sesudah.], [K1],
    [3.], [Operator, admin, dan superadmin mencoba membaca, menulis, dan menaikkan hak sendiri.], [K2],
    [4.], [Edge Function `manage-users` dipanggil tanpa kredensial, dengan sesi operator, dengan tindakan tidak valid, untuk mengundang, dan untuk menghapus superadmin terakhir.], [K2],
    [5.], [Voucher berkuota satu dipakai dua pesanan, dua staf mencatat pembayaran pada pesanan yang sama, paket _custom_ dibuat anonim, dan jadwal dipindah ke tanggal penuh atau ditutup.], [K3],
    [6.], [Transfer tanpa bukti, bukti yang belum diunggah, akses anonim ke _bucket_ bukti, pembatalan pembayaran, dan token invoice yang salah.], [K4],
    [7.], [Pemanggilan langsung fungsi internal dan fungsi staf lewat API oleh anonim.], [K1, K6],
    [8.], [Galeri tanpa foto terbit, pengukuran limpahan sel tabel panel pada lebar 320 sampai 1536 piksel, alur pemesanan enam langkah dengan voucher pada peramban, dan pemakaian seluruh situs pada iPhone 15 dan Galaxy A32 selama pengembangan.], [K5],
  ),
) <tbl-skenario>]

== Evaluasi Pengujian

Hasil pengujian dirangkum pada @tbl-hasil.

#allow-table-break[#figure(
  caption: [Hasil Evaluasi Pengujian],
  table(
    columns: (1.5cm, 2.6cm, 1fr),
    align: (center, left, left),
    table.header([*Kriteria*], [*Hasil Pengujian*], [*Bukti ringkas*]),
    [K1], [Terpenuhi], [Sembilan tabel non-publik mengembalikan nol baris, penyisipan ke tujuh tabel inti ditolak (`401`), dan jumlah baris tidak berubah setelah `DELETE` (misalnya `orders` 43 menjadi 43 dan `locations` 3 menjadi 3).],
    [K2], [Terpenuhi], [Operator dan admin tidak dapat menaikkan peran sendiri karena ditolak pemicu, dan `manage-users` menjawab `401`, `403`, `400`, `200`, dan `409` sesuai kasus.],
    [K3], [Terpenuhi], [Pada voucher berkuota satu, pesanan kedua ditolak dan `times_redeemed` tetap satu. Dua pencatatan bersamaan menghasilkan nomor invoice berbeda, dan pemindahan jadwal ke tanggal penuh atau ditutup ditolak.],
    [K4], [Terpenuhi], [Transfer tanpa bukti atau dengan bukti pembayaran lain ditolak, _bucket_ `payment-proofs` tidak terbaca anonim, dan token yang salah menghasilkan `NULL`.],
    [K5], [Terpenuhi], [Home memakai 15 foto cadangan saat tidak ada foto terbit, tabel panel tidak melimpah pada 320 sampai 1536 piksel, alur pemesanan dengan voucher menghasilkan baris pesanan yang benar, dan seluruh situs dicoba pada iPhone 15 dan Galaxy A32 selama pengembangan.],
    [K6], [Terpenuhi setelah perbaikan], [Lima temuan keamanan ditemukan dan diperbaiki (@tbl-temuan), dan migrasi sesudahnya memuat pemeriksaan otomatis atas hak akses.],
  ),
) <tbl-hasil>]

Pengujian menemukan lima temuan keamanan dan tiga temuan fungsional yang seluruhnya sudah
diperbaiki, seperti pada @tbl-temuan. Dua temuan tidak terlihat dari membaca kebijakan saja:
_view_ publik yang ternyata dapat ditulis anonim, dan hak `EXECUTE` bawaan `PUBLIC` yang tidak
tersentuh oleh pencabutan dari `anon`. Keduanya baru ditemukan setelah pengujian diperluas dari
membaca menjadi menulis dan dari membaca migrasi menjadi membaca katalog basis data.

#allow-table-break[#figure(
  caption: [Temuan pengujian dan perbaikannya],
  table(
    columns: (0.8cm, 1fr, 1.7cm, 1fr),
    align: (center, left, left, left),
    table.header([*No*], [*Temuan*], [*Tingkat*], [*Perbaikan*]),
    [1.], [_View_ publik dapat diubah dan dihapus anonim, sehingga satu permintaan dapat menghapus kalender sebuah kota.], [Tinggi], [Hak tulis dicabut dari _view_ dan migrasi diberi pemeriksaan (migrasi 7).],
    [2.], [Pada penerapan Vercel, berkas rancangan dan migrasi dapat diunduh siapa pun.], [Tinggi], [`.vercelignore` dan header keamanan.],
    [3.], [Admin dapat menulis `orders` dan `payments` langsung tanpa melewati aturan bisnis.], [Sedang], [Kebijakan tulis dihapus (migrasi 19).],
    [4.], [`EXECUTE` bawaan `PUBLIC` membuat `next_order_code()` dapat dipanggil anonim.], [Sedang], [Hak dicabut dari `PUBLIC` disertai pemeriksaan (migrasi 23).],
    [5.], [_Lead_ dapat tiba dengan status sudah dihubungi sehingga tidak muncul sebagai baru.], [Rendah], [Kebijakan sisip diperketat (migrasi 24).],
    [6.], [Pemicu kapasitas gagal bagi operator sehingga pencatatan pemesanan luar situs ditolak.], [Fungsional], [Fungsi berstatus `SECURITY DEFINER`.],
    [7.], [Penyisipan _lead_ gagal karena klien meminta baris dikembalikan, padahal anonim tidak boleh membaca.], [Fungsional], [Permintaan pengembalian baris dihapus dari klien.],
    [8.], [Pendaftaran mandiri pada Auth ternyata masih menyala saat diperiksa pada 30 September.], [Fungsional], [Dimatikan dan diverifikasi.],
  ),
) <tbl-temuan>]

Beberapa hal diterima sebagai sisa risiko yang tercatat. Fungsi pembaca tanpa efek samping
seperti `dp_minimum()` tetap dapat dipanggil anonim, `voucher_lookup()` dapat dipakai menebak
kode sehingga pertahanannya adalah kuota satu dan kode yang sulit ditebak, dan penghitung
`gate_events` dapat digelembungkan. Pengujian juga terbatas: berupa skrip _probe_ sekali pakai
dan sesi manual, bukan rangkaian uji otomatis, tanpa uji beban maupun uji kegunaan dengan
pelanggan nyata, dan untuk migrasi 25 sampai 31 pengujian yang menulis data hanya dijalankan
pada tumpukan lokal, sedangkan proyek terkelola diperiksa lewat pembacaan anonim. Dengan
demikian seluruh kriteria terpenuhi setelah perbaikan, dan tinjauan RLS dinyatakan lulus dengan
sisa risiko yang diterima melalui sembilan _addendum_ sampai 30 September 2026.
