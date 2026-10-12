// ============================================================
// BAB VII KESIMPULAN DAN SARAN
// Kesimpulan menjawab lima rumusan masalah pada Bab I; saran bersumber dari batasan
// pekerjaan (Bab I), keputusan yang ditunda (Bab IV), dan keterbatasan pengujian (Bab VI).
// ============================================================

#import "../../template/lib.typ": *
#let data = yaml("../../data.yaml")

// Daftar bernomor dirapatkan ke tepi agar bab ini cukup dua halaman.
#set enum(indent: 0.2cm)

= KESIMPULAN DAN SARAN

== Kesimpulan

Berdasarkan rumusan masalah pada Bab I, kesimpulan yang didapat setelah melaksanakan kerja
praktik di #data.instansi.nama adalah sebagai berikut.

+ *Situs publik.* Situs statis tanpa tahap _build_ dengan empat halaman utama dan halaman
  invoice, dilengkapi _photostrip_ kamera, galeri polaroid, pratinjau 3D, dan simulator
  aplikasi, serta cadangan statis agar tetap berfungsi tanpa basis data. Seluruh situs dicoba
  pada ponsel sungguhan sepanjang pengembangan.
+ *Pemesanan dan penagihan.* Harga dihitung di server, pemesanan ganda dicegah oleh kendala
  unik dan penguncian baris tanggal, dan setiap pesanan menerima invoice bernomor yang tidak
  berubah setelah terbit. Pada pengujian, pesanan kedua pada voucher berkuota satu ditolak,
  pemindahan ke tanggal penuh ditolak, dan dua pencatatan bersamaan menghasilkan nomor invoice
  berbeda.
+ *Panel admin.* Peran operator, admin, dan superadmin memungkinkan staf mengelola harga,
  kalender, pesanan, konten, dan akun tanpa pengembang, dengan hak ditegakkan oleh RLS.
+ *Model 3D.* Tiga unit _photobox_ dimodelkan di Blender dan diekspor ke GLB sebesar 1,26
  sampai 1,60 MB per unit sehingga dapat dimuat peramban tanpa kompresi tambahan.
+ *Keamanan dan penerapan.* RLS aktif pada seluruh tabel dan lima temuan keamanan dari tinjauan
  tiga lapis seluruhnya diperbaiki, sehingga kriteria K1 sampai K6 terpenuhi dengan sisa
  risiko yang tercatat. Penerapan diselesaikan setelah masa kerja praktik, sedangkan jenis
  penerapan akhir dan pengelolaan domain ditentukan dan ditangani Photo.Jo.

== Saran

Saran untuk pengembangan lebih lanjut adalah sebagai berikut.

+ *Pembayaran otomatis.* Gerbang pembayaran (Midtrans QRIS) yang telah dikaji dapat dibangun
  di atas fungsi `apply_payment` bila pesanan bertambah.
+ *Pengujian berkelanjutan.* Skrip _probe_ dan sesi manual perlu diganti rangkaian uji
  otomatis pada setiap migrasi, dilengkapi uji beban, uji kegunaan, dan peninjauan berkala atas
  sisa risiko.
+ *Penerapan dan kepemilikan.* Jenis penerapan akhir ditentukan manajemen (saat ini Vercel
  paket Hobby dan Supabase paket Free), dan repositori GitHub serta proyek hosting perlu
  dipindahkan dari akun pengembang ke Photo.Jo.
+ *Kode sisi klien.* Komponen bersama yang disalin pada setiap halaman dan `admin.html`
  sepanjang 14.384 baris layak dipisah menjadi modul bersama.
