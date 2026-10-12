// ============================================================
// BAB IV ANALISIS DAN PERANCANGAN SISTEM
// Gambar dirakit dari berkas di content/diagram/ (paket fletcher).
// ============================================================

#import "../../template/lib.typ": *
#import "../diagram/_lib.typ": gambar-diagram
#import "../diagram/arsitektur.typ": diagram-arsitektur
#import "../diagram/usecase.typ": diagram-usecase-publik
#import "../diagram/erd.typ": diagram-erd-katalog, diagram-erd-pemesanan
#import "../diagram/alur.typ": diagram-alur-pemesanan, diagram-status-pesanan

// Tabel pada bab ini: huruf 9,5 pt dan rata kiri. Hanya tabel panjang yang boleh
// terpotong antarhalaman (dibungkus allow-table-break); tabel pendek selalu utuh.
// Judul tabel selalu menempel pada baris pertama, dan satu baris tidak terpotong antarhalaman.
#show figure.where(kind: table): it => {
  show figure.caption: set block(sticky: true)
  it
}
#set table.cell(breakable: false)
#show table: set text(size: 9.5pt)
#show table: set par(justify: false)
#set table(inset: 4pt)
#show raw.where(block: false): set text(size: 0.88em)

= ANALISIS DAN PERANCANGAN SISTEM

Pada bab ini dijelaskan analisis dan perancangan sistem yang dikerjakan selama kerja
praktik, mulai dari definisi aplikasi, permasalahan, kebutuhan, dan aktor, hingga arsitektur,
basis data, keamanan, alur pemesanan dan penagihan, antarmuka, model 3D, dan penerapan.

== Analisis Sistem

=== Definisi Umum Aplikasi

Photo.Jo Website adalah sistem berbasis web milik Photo.Jo, merek di bawah PT Jokeen Solusi
Teknologi, yang dikembangkan penulis selama kerja praktik. Sistem ini berfungsi sebagai
etalase tiga lini produk Photo.Jo, tempat pelanggan memesan jasa, dan alat kerja staf.

Sistem terdiri atas tiga bagian. Situs publik pada #box(`www.photojo.id`) memuat empat
halaman utama (Home, Service, Business, dan Application), halaman invoice, dan halaman 404,
dengan pengalaman interaktif berupa _photostrip_ kamera, galeri polaroid, pratinjau 3D unit,
dan simulator aplikasi. Sistem pemesanan dan penagihan memungkinkan pelanggan memilih paket,
lokasi, dan tanggal, lalu menerima invoice bernomor tanpa menunggu staf. Panel admin pada
#box(`dashboard.photojo.id`) dipakai staf dengan peran operator, admin, atau superadmin untuk
mengelola harga, kalender, pesanan, pembayaran, konten, dan akun. Seluruh bagian, termasuk
pemodelan 3D tiga unit, dikerjakan penulis secara mandiri dengan kebutuhan bisnis ditetapkan
bersama pemilik Photo.Jo.

=== Kondisi Awal dan Permasalahan

Sebelum kerja praktik, Photo.Jo telah memiliki situs lama pada #box(`photojo.id/home`) yang
menjadi acuan merek, tetapi proses usaha di baliknya masih manual. Penelusuran bersama
pemilik, termasuk tinjauan contoh invoice, menunjukkan permasalahan pada @tbl-masalah.

#figure(
  caption: [Permasalahan pada kondisi awal dan solusi yang dirancang],
  table(
    columns: (0.9cm, 1fr, 1fr),
    align: (center, left, left),
    table.header([*No*], [*Permasalahan*], [*Solusi pada sistem*]),
    [1.], [Harga tertulis pada kode halaman; perubahan harus melalui pengembang.],
    [Harga, paket, promosi, dan voucher disimpan di basis data dan diubah staf melalui panel.],
    [2.], [Ketersediaan tanggal hanya diketahui lewat WhatsApp, sehingga pemesanan ganda sulit dicegah.],
    [Kalender per lokasi dengan kapasitas harian yang dijaga basis data.],
    [3.], [Invoice dibuat manual; satu nomor dipakai pada dua pelanggan.],
    [Invoice otomatis dengan nomor unik dan salinan yang tidak berubah.],
    [4.], [Pembayaran dan sisa tagihan hanya tercatat dalam percakapan.],
    [Pembayaran dicatat pada pesanan beserta bukti; sisa tagihan tampil di panel.],
    [5.], [Konten, ulasan, pengumuman, dan asal calon pelanggan tidak dapat dikelola atau dilacak staf.],
    [Pengelolaan konten melalui panel, formulir kontak dengan UTM, dan daftar _leads_.],
    [6.], [Tidak ada pembagian hak akses dan jejak perubahan bagi staf.],
    [Tiga peran pengguna, aturan akses di basis data, dan log aktivitas.],
  ),
) <tbl-masalah>

Sasaran perancangan karenanya bergeser dari memperbarui tampilan menjadi mengubah situs
menjadi sistem, dengan WhatsApp tetap sebagai kanal utama dengan pelanggan.

=== Kebutuhan Fungsional

Kebutuhan fungsional pada @tbl-kf disusun dari permasalahan di atas serta diskusi dengan
pemilik dan pembimbing lapangan.

#allow-table-break[#figure(
  caption: [Kebutuhan fungsional],
  table(
    columns: (1.3cm, 1fr, 2.1cm),
    align: (center, left, left),
    table.header([*Kode*], [*Kebutuhan*], [*Aktor*]),
    [KF-01], [Menampilkan tiga lini produk, harga paket dan add-on terkini, dan promo.], [Pengunjung],
    [KF-02], [Menyediakan pengalaman interaktif: _photostrip_ dengan kamera, pratinjau 3D unit, dan simulasi aplikasi dengan pengisian kontak.], [Pengunjung],
    [KF-03], [Menyediakan keranjang dan jendela pemesanan enam langkah dengan ketersediaan tanggal, daftar tunggu, dan voucher.], [Pelanggan],
    [KF-04], [Menerbitkan invoice bernomor yang dibuka melalui tautan pribadi.], [Pelanggan],
    [KF-05], [Mengarahkan layanan _photobox_, permintaan daftar harga, dan kota di luar jangkauan ke WhatsApp.], [Pengunjung],
    [KF-06], [Masuk, mengganti kata sandi, dan melihat dasbor ringkasan menurut peran.], [Semua staf],
    [KF-07], [Mengelola kalender dan pesanan: menutup tanggal, mencatat booking luar situs, memindahkan jadwal, membuat, memperpanjang, dan membatalkan pesanan.], [Semua staf],
    [KF-08], [Mencatat pembayaran beserta bukti, menerbitkan invoice berikutnya, dan mengirim pengingat WhatsApp.], [Semua staf],
    [KF-09], [Membatalkan pembayaran salah catat, mengunci tanggal tanpa DP, dan menetapkan tenggat khusus.], [Admin ke atas],
    [KF-10], [Mengelola harga, promosi, voucher, pengumuman, dan konten (galeri, ulasan, FAQ, studio).], [Admin ke atas],
    [KF-11], [Mengelola _leads_ dan membaca log aktivitas.], [Admin ke atas],
    [KF-12], [Mengelola lokasi beserta kapasitas dan akun pengguna.], [Superadmin],
  ),
) <tbl-kf>]

=== Kebutuhan Nonfungsional

@tbl-knf menetapkan mutu yang harus dipenuhi sistem.

#figure(
  caption: [Kebutuhan nonfungsional],
  table(
    columns: (1.3cm, 2.4cm, 1fr),
    align: (center, left, left),
    table.header([*Kode*], [*Aspek*], [*Kebutuhan*]),
    [KNF-01], [Keandalan], [Situs tetap berfungsi saat _backend_ tidak tersedia.],
    [KNF-02], [Keamanan data], [Hak akses ditentukan basis data dengan prinsip tolak bawaan, dan kunci rahasia tidak berada di berkas yang dikirim ke peramban.],
    [KNF-03], [Integritas transaksi], [Harga dihitung ulang di server, kapasitas tanggal tidak terlampaui, dan nomor invoice unik.],
    [KNF-04], [Keterlacakan], [Perubahan data penting tercatat beserta pelaku serta nilai sebelum dan sesudah.],
    [KNF-05], [Kinerja dan kegunaan], [Tanpa tahap _build_, model 3D di bawah 2 MB, dan antarmuka berbahasa Indonesia yang dapat dipakai pada layar ponsel.],
    [KNF-06], [Biaya], [Biaya berulang produksi tetap dan dapat diperkirakan, sekitar Rp 410.000 hingga Rp 740.000 per bulan bila memakai paket berbayar.],
  ),
) <tbl-knf>

=== Aktor dan Hak Akses

Sistem memiliki satu aktor tanpa akun dan tiga aktor staf yang disusun bertingkat: setiap peran
memiliki seluruh kewenangan peran di bawahnya (@tbl-aktor). Pemilik Photo.Jo berperan sebagai
superadmin sehingga dapat mengelola akun staf tanpa pengembang.

#figure(
  caption: [Aktor sistem dan cakupan kewenangannya],
  table(
    columns: (2.5cm, 1fr),
    align: (left, left),
    table.header([*Aktor*], [*Cakupan kewenangan*]),
    [Pengunjung / pelanggan], [Mengakses situs publik tanpa akun, membuat pesanan, dan membuka invoice miliknya melalui tautan pribadi.],
    [Operator], [Dasbor ringkas, kalender, pesanan, dan pencatatan pembayaran.],
    [Admin], [Kewenangan operator ditambah harga, promosi, voucher, konten, _leads_, pembatalan pembayaran, penguncian tanggal tanpa DP, dan log aktivitas.],
    [Superadmin], [Kewenangan admin ditambah lokasi, studio, dan akun pengguna.],
  ),
) <tbl-aktor>

=== Use Case

@gbr-usecase-publik menunjukkan use case situs publik. Pemakaian voucher dan daftar tunggu
bersifat tambahan terhadap pemesanan, dan simulasi aplikasi mengharuskan pengisian kontak
sehingga pengunjung tercatat sebagai calon pelanggan. Use case panel admin mengikuti hak akses
pada @tbl-aktor.

#gambar-diagram(diagram-usecase-publik(), caption: [Use case situs publik], placement: none) <gbr-usecase-publik>

== Perancangan Sistem

=== Desain Sistem

Sistem dirancang dengan prinsip _static-first_. Halaman dikirim sebagai berkas statis dari
penyedia hosting, lalu JavaScript di peramban mengambil data dinamis langsung dari layanan
basis data terkelola, sehingga tidak ada server aplikasi buatan sendiri yang harus dirawat.
Pekerjaan sisi server dilakukan basis data melalui aturan akses, fungsi, dan pemicu
(_trigger_), serta satu _Edge Function_ untuk operasi yang membutuhkan kunci rahasia
(@gbr-arsitektur).

#gambar-diagram(diagram-arsitektur(), caption: [Arsitektur sistem Photo.Jo Website]) <gbr-arsitektur>

Situs harus tetap berfungsi walaupun _backend_ tidak dapat dijangkau. Harga, paket, dan galeri
memiliki cadangan statis pada HTML yang ditimpa hasil pengambilan data, dan skrip
`sync-fallbacks.mjs` menolak penerapan bila cadangan berbeda dari basis data. Ketersediaan,
ulasan, dan pengumuman sengaja tanpa cadangan karena data tiruan menyesatkan, sehingga
tampilannya disembunyikan dan pelanggan diarahkan ke WhatsApp.

Komponen sistem tercantum pada @tbl-software.

#allow-table-break[#figure(
  caption: [Komponen sistem dan spesifikasinya],
  table(
    columns: (0.9cm, 2.6cm, 1fr, 1fr),
    align: (center, left, left, left),
    table.header([*No*], [*Komponen*], [*Fungsi*], [*Spesifikasi*]),
    [1.], [Vercel], [Menyajikan berkas statis dan menetapkan header keamanan.], [Paket Hobby saat ini; _branch_ `main` untuk produksi; HTTPS otomatis.],
    [2.], [Supabase], [PostgreSQL (24 tabel, kebijakan akses, fungsi), PostgREST, Auth, Storage, dan Edge Function `manage-users`.], [PostgreSQL 17.6, PostgREST v14.15, GoTrue v2.195.0, Storage v1.69.0, runtime Deno; paket Free saat ini dan Pro dirancang untuk produksi.],
    [3.], [Resend dan Hostinger], [Email undangan lewat SMTP dan pengelolaan DNS `photojo.id`.], [Domain pengirim terverifikasi; `www` dan `dashboard` diarahkan ke Vercel.],
    [4.], [HTML5, CSS3, JavaScript, supabase-js v2], [Antarmuka dan klien Supabase di peramban.], [Modul ES tanpa _framework_ dan tanpa tahap _build_; `supabase-js` dari CDN `esm.sh`.],
    [5.], [model-viewer 3.5.0 dan Blender 4.0], [Menampilkan dan membuat model 3D unit _photobox_.], [Ekspor Khronos glTF Blender I/O v4.0.44 ke `.glb`.],
    [6.], [Supabase CLI, Docker, Node.js, Python, Git, GitHub], [Tumpukan lokal, migrasi, skrip bantu, dan kontrol versi.], [Skema pada `supabase/migrations`; repositori privat dengan `main` untuk produksi.],
  ),
) <tbl-software>]

Supabase dipilih daripada Firebase karena data pesanan bersifat relasional, biayanya tetap
bulanan, aturan akses ditulis sebagai kebijakan SQL yang mudah ditinjau, dan PostgreSQL standar
dapat dipindahkan ke penyedia lain. Firebase diperkirakan sekitar Rp 330.000 per bulan lebih
murah, tetapi selisih itu dinilai lebih kecil daripada manfaat tersebut.

=== Perancangan Basis Data

Basis data dirancang relasional pada PostgreSQL dengan 24 tabel dalam lima kelompok
(@tbl-kelompok-tabel), dibangun bertahap melalui 32 migrasi SQL berurutan yang tidak pernah
diubah setelah diterapkan.

#figure(
  caption: [Kelompok tabel basis data],
  table(
    columns: (2.6cm, 1fr, 1fr),
    align: (left, left, left),
    table.header([*Kelompok*], [*Tabel*], [*Fungsi*]),
    [Katalog], [`services`, `packages`, `addons`, `service_addons`, `units`, `promotions`, `vouchers`], [Layanan, paket, add-on, unit, potongan harga, dan voucher.],
    [Ketersediaan], [`locations`, `availability_slots`, `slot_claims`], [Kota dan kapasitas harian, status tanggal, dan klaim kapasitas.],
    [Pemesanan dan penagihan], [`orders`, `order_items`, `payments`, `invoices`, `company_profile`], [Pesanan, butir, pembayaran, invoice, dan data penjual.],
    [Konten], [`media`, `reviews`, `faq_items`, `studios`, `announcements`], [Galeri, ulasan, tanya jawab, studio, dan pengumuman.],
    [Administrasi], [`profiles`, `audit_log`, `leads`, `gate_events`], [Peran staf, log aktivitas, calon pelanggan, dan penghitung formulir.],
  ),
) <tbl-kelompok-tabel>

@gbr-erd-katalog menunjukkan relasi katalog dan ketersediaan, dan @gbr-erd-pemesanan relasi
pemesanan dan penagihan. Satu pesanan dapat memiliki banyak pembayaran dan invoice, dan
`company_profile` tidak dihubungkan dengan kunci tamu karena isinya disalin ke setiap invoice
saat terbit.

#gambar-diagram(diagram-erd-katalog(), caption: [ERD katalog dan ketersediaan]) <gbr-erd-katalog>

#gambar-diagram(diagram-erd-pemesanan(), caption: [ERD pemesanan dan penagihan]) <gbr-erd-pemesanan>

Keputusan perancangan yang menentukan kebenaran sistem adalah sebagai berikut.

+ Uang disimpan sebagai bilangan bulat rupiah (`bigint`), dan harga disalin ke butir pesanan
  serta invoice sehingga perubahan katalog tidak mengubah dokumen yang sudah terbit.
+ Kapasitas tanggal dijaga oleh kendala `unique (location_id, date)` dan pemicu yang mengunci
  baris tanggal sebelum menambah klaim, sehingga dua pesanan yang memperebutkan tanggal
  terakhir diputuskan satu per satu. Pemesanan luar situs disimpan sebagai klaim `offline`
  agar hanya ada satu penghitung kapasitas.
+ Kode pesanan berasal dari _sequence_ (misalnya `PJ-2026-0142`), penghapusan bersifat lunak,
  dan log aktivitas diisi pemicu generik dengan nilai sebelum dan sesudah serta nama pelaku
  saat itu sebagai salinan.

=== Perancangan Keamanan

Perancangan keamanan berangkat dari asumsi bahwa apa pun yang dikirim peramban tidak dapat
dipercaya. Kunci publik tertulis pada berkas JavaScript dan dapat dibaca siapa pun, sehingga
kewenangan ditentukan sepenuhnya oleh basis data, sedangkan kunci `service_role` hanya ada pada
rahasia Edge Function. Perlindungan dirancang berlapis.

+ _Row level security_ (RLS) diaktifkan dan dipaksakan (`force`) pada seluruh tabel dengan
  prinsip tolak secara bawaan. Pengunjung hanya membaca data yang terbit, menambah _leads_, dan
  memanggil fungsi yang dibuka eksplisit, sedangkan staf diatur menurut peran.
+ Data publik yang perlu disaring dibuka melalui _view_, misalnya `public_availability` yang
  hanya memberi status tanggal tanpa jumlah pemesanan.
+ Operasi bisnis berupa fungsi `SECURITY DEFINER` yang memeriksa peran di dalamnya. Pelanggan
  hanya dapat memanggil `create_order`, `public_invoice`, dan `voucher_lookup`, dan tabel
  pesanan, pembayaran, serta invoice tidak memiliki kebijakan tulis untuk peran mana pun.
+ Pemicu mencegah pengguna mengubah perannya sendiri dan menolak perubahan yang menyisakan
  nol superadmin aktif.
+ Bukti transfer berada pada _bucket_ privat dan dibaca melalui tautan bertanda tangan 60
  detik. Header HTTP mencegah panel dibingkai halaman lain, dan panel berada pada subdomain
  tersendiri agar skrip aplikasi lama tidak dapat membaca sesi staf.

=== Perancangan Alur Pemesanan

Alur pemesanan dirancang agar pelanggan dapat memesan tanpa menunggu staf, sementara
penerimaan uang tetap dikonfirmasi manusia melalui WhatsApp dan dicatat staf. Pembayaran
otomatis dengan Midtrans QRIS telah dikaji tetapi ditunda atas keputusan pemilik dan
manajemen. Jendela pemesanan tampil sebagai dialog di atas halaman Service dengan enam
langkah (@gbr-alur-pemesanan).

#gambar-diagram(diagram-alur-pemesanan(), caption: [Alur pemesanan oleh pelanggan]) <gbr-alur-pemesanan>

+ Paket dan add-on, dengan add-on yang tidak diizinkan paket ditampilkan redup.
+ Lokasi; kota di luar jangkauan keluar menuju konsultasi WhatsApp.
+ Tanggal pada kalender berwarna (putih tersedia, kuning _Hampir penuh_, merah penuh atau
  ditutup), dengan daftar tunggu untuk tanggal merah.
+ Pembayaran, bayar penuh atau DP, dengan aturan ditampilkan lebih dulu.
+ Kontak berupa nama dan nomor WhatsApp, dengan alamat penagihan opsional.
+ Selesai: server membuat pesanan, lalu jendela menampilkan kode pesanan dan tautan invoice.

Fungsi `create_order` hanya menerima pilihan
pelanggan lalu menghitung seluruh harga dari basis data, sehingga harga pada jendela hanyalah
pratinjau. Server juga menolak tanggal penuh, kota yang tidak dilayani, dan paket yang hanya
boleh dipesan lewat WhatsApp walaupun peramban yang dimodifikasi mengirimnya.

=== Aturan Pembayaran dan Status Pesanan

Aturan pembayaran ditetapkan pemilik Photo.Jo dan dituliskan sebelum pelanggan memesan
(@tbl-aturan-bayar).

#figure(
  caption: [Aturan pembayaran dan penguncian tanggal],
  table(
    columns: (0.9cm, 1fr, 1fr),
    align: (center, left, left),
    table.header([*No*], [*Aturan*], [*Penerapan pada sistem*]),
    [1.], [DP boleh berapa pun, mulai Rp 500.000.], [Minimum pada fungsi `dp_minimum()`.],
    [2.], [Sisa tagihan lunas paling lambat H-3.], [Acara kurang dari tiga hari lagi hanya dapat dibayar lunas.],
    [3.], [Pembayaran yang diterima tidak dapat dikembalikan.], [Dinyatakan pada langkah pembayaran dan invoice.],
    [4.], [Tanggal terkunci saat pembayaran tercatat mencapai minimum DP.], [Pesanan yang belum dibayar tidak menahan tanggal.],
    [5.], [Pesanan belum dibayar berlaku 48 jam.], [Staf dapat memperpanjang atau mengaktifkan kembali.],
  ),
) <tbl-aturan-bayar>

Pesanan yang belum dibayar sengaja tidak menahan tanggal. Dua pelanggan dapat memesan tanggal
terakhir yang sama, dan yang pembayarannya dicatat lebih dulu memperoleh tanggal itu,
sedangkan pencatatan lainnya ditolak server agar tidak ada uang diterima untuk tanggal yang
tidak dapat dilayani. Pelanggan korporat yang melunasi berminggu-minggu kemudian dilayani
melalui penguncian tanggal tanpa DP oleh admin dengan alasan tercatat.

Siklus hidup pesanan digambarkan pada @gbr-status-pesanan. Pesanan lahir _Menunggu Bayar_ dan
menjadi _Kedaluwarsa_ setelah 48 jam tanpa pembayaran. Staf dapat mengaktifkannya kembali
tanpa membuat pesanan baru sehingga kode dan harga tetap sama, dan dapat membatalkan pesanan
dari keadaan mana pun.

#gambar-diagram(diagram-status-pesanan(), caption: [Status pesanan]) <gbr-status-pesanan>

=== Pencatatan Pembayaran dan Penerbitan Invoice

Uang diterima dan dikonfirmasi manusia di luar sistem, lalu dicatat pada panel melalui
tindakan _Catat Bayar_ yang dikerjakan basis data dalam satu transaksi. Server mengunci baris
pesanan, memeriksa bahwa jumlah tidak melebihi sisa tagihan, mengunci baris tanggal, dan
menolak pembayaran bila tanggal ditutup atau sudah dikunci pesanan lain. Bila total pembayaran
mencapai minimum DP, server membuat klaim terkonfirmasi sehingga tanggal terkunci, menyimpan
pembayaran, dan menerbitkan invoice berikutnya.

Nomor invoice mengikuti kode pesanan: `PJ-2026-0142` menjadi `PJ/2026/0142` ditambah akhiran
dua digit. Akhiran `/01` adalah tagihan pembuka, setiap pembayaran menerbitkan nomor
berikutnya, dan invoice yang menutup tagihan bertanda LUNAS. Invoice yang terbit tidak pernah
disunting karena isinya disimpan sebagai salinan beku. Pembayaran yang salah catat dibatalkan
oleh admin dengan alasan tertulis, bukan dihapus: invoicenya ditandai BATAL dan invoice koreksi
diterbitkan. Invoice dibuka melalui tautan pribadi `invoice.html?t=<token>` dengan token acak
122 bit dan dapat disimpan sebagai PDF.

=== Perancangan Antarmuka

Antarmuka mengikuti identitas merek Photo.Jo yang bersih, ceria, dan berfokus pada foto,
seluruhnya berbahasa Indonesia. Situs publik bersifat berhalaman jamak sehingga setiap lini
produk memiliki alamat sendiri yang dapat dibagikan dan diindeks mesin pencari. Token CSS yang
sama dipakai pada seluruh halaman, termasuk panel admin (@tbl-desain).

#figure(
  caption: [Sistem desain],
  table(
    columns: (2.3cm, 1fr),
    align: (left, left),
    table.header([*Unsur*], [*Ketentuan*]),
    [Warna], [Teks utama `#1d1d1f`, latar terang `#f5f5f7`, teks sekunder `#636366`, aksen teal `#2d7d6f`, sorotan `#5cd4c4`, peringatan `#be123c`.],
    [Huruf], [Comfortaa untuk logo, judul, navigasi, dan tombol; Poppins untuk teks bacaan.],
    [Bentuk], [Kartu berjari-jari 24 piksel, tombol berbentuk pil, dan lebar isi maksimum 1100 piksel.],
  ),
) <tbl-desain>

Pola interaksi berlaku di seluruh situs: dua titik patah responsif (1023 dan 767 piksel),
animasi yang dikurangi bagi pengguna yang meminta pengurangan gerak, tautan lompat ke konten,
dialog pemesanan yang menahan fokus papan ketik, dan kontrol formulir berukuran huruf minimal
16 piksel pada layar sentuh. Panel admin memakai token yang sama dengan bilah samping gelap,
menu yang dikelompokkan menurut tujuan, layar yang tidak boleh diakses suatu peran
disembunyikan, perubahan harga disimpan sekaligus dengan konfirmasi bila berubah lebih dari 25
persen, dan dapat dipakai pada layar ponsel karena operator mengonfirmasi pembayaran pada hari
acara.

=== Perancangan Model 3D

Calon pembeli ingin memeriksa bentuk unit sebelum menghubungi penjual, sehingga tiga unit
dimodelkan tiga dimensi dan ditampilkan interaktif pada halaman Business (@tbl-unit). Unit
keempat, _Custom Unit_, tidak dimodelkan karena bentuknya mengikuti permintaan pembeli.

#figure(
  caption: [Unit _photobox_ yang dimodelkan],
  table(
    columns: (2.3cm, 3cm, 1fr),
    align: (left, left, left),
    table.header([*Unit*], [*Lebar × panjang × tinggi*], [*Karakteristik*]),
    [Kiosk Slim], [450 × 450 × 1500 mm], [Kios ramping dengan monitor, kamera, pencetak, dan rak.],
    [Velvet Booth], [1400 × 1800 × 2240 mm], [Bilik tertutup dengan dua pintu, tirai, tiga lampu, dua kipas, dan pencetak.],
    [Cabin Booth], [940 × 1600 × 2100 mm], [Bilik tertutup dengan satu pintu, tirai, dua panel cermin, monitor, dan rak aksesori.],
  ),
) <tbl-unit>

Model dikeluarkan sebagai satu berkas `.glb` berisi bentuk dan tekstur, dengan poligon dijaga
rendah (sekitar 1.100 sampai 2.000 segitiga dan 1,3 sampai 1,7 MB per unit) sehingga tidak
memerlukan kompresi Draco. Material bodi diberi nama `BoxBody` agar situs dapat mengganti
warnanya, sedangkan rincian seperti layar, lensa, dan tirai memakai tekstur gambar.

=== Rancangan Penerapan

Sistem dirancang berjalan pada tiga lingkungan (@tbl-lingkungan), dan klien memilih
lingkungan otomatis dari nama host halaman. Domain `photojo.id` sebelumnya dipakai aplikasi
_photobooth_ lama yang tidak boleh terganggu, sehingga situs baru ditempatkan pada subdomain
`www`, domain induk tetap melayani aplikasi lama, dan panel admin berada pada subdomain
`dashboard`. DNS dipusatkan pada Hostinger. Biaya berulang produksi dirancang tetap dan dapat
diperkirakan (@tbl-biaya, kurs sekitar Rp 16.500 per dolar Amerika Serikat). Saat laporan ini
ditulis situs masih memakai paket Hobby dan Free, dan jenis penerapan akhir ditentukan
manajemen Photo.Jo.

#figure(
  caption: [Lingkungan pengembangan dan produksi],
  table(
    columns: (2.2cm, 1fr, 1fr, 2.2cm),
    align: (left, left, left, left),
    table.header([*Lingkungan*], [*Klien*], [*Backend*], [*Biaya*]),
    [Lokal], [Server statis lokal `serve.py`.], [Tumpukan Supabase lokal pada Docker.], [Rp 0],
    [Uji dan pratinjau], [Pratinjau Vercel untuk setiap _branch_.], [Proyek Supabase paket Free.], [Rp 0],
    [Produksi (rancangan)], [Vercel pada nama domain `www` dan `dashboard`.], [Proyek Supabase paket Pro.], [Lihat @tbl-biaya],
  ),
) <tbl-lingkungan>

#figure(
  caption: [Perkiraan biaya berulang produksi per bulan],
  table(
    columns: (2.4cm, 3.2cm, 1fr),
    align: (left, left, left),
    table.header([*Komponen*], [*Perkiraan biaya*], [*Catatan*]),
    [Vercel], [Rp 0 atau sekitar Rp 330.000], [Paket Hobby berlisensi nonkomersial; jenis penerapan produksi ditentukan manajemen.],
    [Supabase Pro], [Sekitar Rp 410.000], [Basis data, autentikasi, penyimpanan, fungsi, dan pencadangan harian.],
    [Domain], [Rp 0], [Sudah dimiliki dan dikelola Photo.Jo sebelum pengembangan situs.],
    [Total tambahan], [Rp 410.000 sampai Rp 740.000], [Bergantung pada paket Vercel; saat ini Rp 0 (Hobby dan Free).],
  ),
) <tbl-biaya>
