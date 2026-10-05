// ============================================================
// BAB IV ANALISIS DAN PERANCANGAN SISTEM
// Gambar dirakit dari berkas di content/diagram/ (paket fletcher).
// ============================================================

#import "../../template/lib.typ": *
#import "../diagram/_lib.typ": gambar-diagram
#import "../diagram/arsitektur.typ": diagram-arsitektur, diagram-topologi
#import "../diagram/usecase.typ": diagram-usecase-publik, diagram-usecase-staf
#import "../diagram/erd.typ": diagram-erd-katalog, diagram-erd-pemesanan
#import "../diagram/alur.typ": diagram-alur-pemesanan, diagram-status-pesanan, diagram-peta-situs, diagram-alur-3d

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

Pada bab ini dijelaskan tahapan analisis dan perancangan sistem yang dikerjakan selama
kerja praktik. Analisis mencakup definisi aplikasi, kondisi awal beserta permasalahannya,
kebutuhan sistem, serta aktor dan hak aksesnya. Perancangan mencakup arsitektur sistem,
basis data, keamanan, alur pemesanan dan penagihan, antarmuka, model 3D unit _photobox_,
dan rencana penerapan.

== Analisis Sistem

=== Definisi Umum Aplikasi

Photo.Jo Website adalah sistem berbasis web milik Photo.Jo, merek di bawah PT Jokeen Solusi
Teknologi, yang dikembangkan penulis selama kerja praktik. Photo.Jo memiliki tiga lini
produk: unit _photobox_ yang dijual kepada calon pemilik usaha, jasa _photobooth_ yang
disewa untuk acara seperti pernikahan, ulang tahun, dan acara perusahaan, serta aplikasi
_photobooth_ yang dilisensikan melalui langganan bulanan. Sistem ini berfungsi sebagai
etalase ketiga lini produk tersebut, sebagai tempat pelanggan memesan jasa, dan sebagai
alat kerja staf untuk mengelola usaha.

Sistem terdiri atas tiga bagian yang saling terhubung. Bagian pertama adalah situs publik
pada alamat #box(`www.photojo.id`) yang memuat empat halaman utama (Home, Service, Business,
dan Application), halaman invoice, dan halaman 404. Situs ini menghadirkan pengalaman
interaktif yang dapat dicoba langsung di peramban, yaitu pembuatan _photostrip_ dengan
kamera, galeri polaroid, pratinjau 3D unit _photobox_, dan simulator aplikasi
_photobooth_. Bagian kedua adalah sistem pemesanan dan penagihan yang memungkinkan
pelanggan memilih paket, lokasi, dan tanggal acara, membuat pesanan, lalu menerima
invoice bernomor tanpa menunggu balasan staf. Bagian ketiga adalah panel admin pada
#box(`dashboard.photojo.id`), yaitu halaman khusus staf untuk mengelola harga, promosi,
kalender, pesanan dan pembayaran, konten situs, calon pelanggan, dan akun pengguna.

Pengguna sistem terbagi menjadi dua kelompok. Pengunjung dan pelanggan mengakses situs
publik tanpa akun. Staf Photo.Jo mengakses panel admin dengan akun yang diundang oleh
superadmin dan memiliki salah satu dari tiga peran: operator, admin, atau superadmin.
Selain perangkat lunak, pekerjaan ini juga mencakup pemodelan tiga dimensi tiga unit
_photobox_ yang ditampilkan pada situs.

Seluruh bagian sistem dikerjakan penulis secara mandiri, mulai dari perancangan
antarmuka, pengembangan sisi klien dan sisi server, pemodelan 3D, hingga penerapan ke
lingkungan produksi. Kebutuhan dan keputusan bisnis ditetapkan bersama pemilik Photo.Jo
melalui putaran diskusi dan revisi selama pengerjaan.

=== Kondisi Awal dan Permasalahan

Sebelum kerja praktik, Photo.Jo telah memiliki situs lama pada alamat #box(`photojo.id/home`)
yang menjadi acuan merek, isi tulisan, dan identitas visual. Situs tersebut dirancang ulang
secara menyeluruh agar menyajikan ketiga lini produk pada halaman tersendiri, menghadirkan
pengalaman interaktif yang dapat dicoba sebelum membeli, dan mengarahkan pengunjung ke
kontak WhatsApp. Perancangan ulang ini baru menghasilkan situs informasi, sedangkan proses
usaha di baliknya masih dikerjakan secara manual. Penelusuran proses tersebut bersama
pemilik Photo.Jo, termasuk tinjauan terhadap contoh invoice yang selama ini dibuat,
menunjukkan permasalahan pada @tbl-masalah.

#allow-table-break[#figure(
  caption: [Permasalahan pada kondisi awal dan solusi yang dirancang],
  table(
    columns: (0.9cm, 1fr, 1fr),
    align: (center, left, left),
    table.header([*No*], [*Permasalahan*], [*Solusi pada sistem*]),
    [1.],
    [Harga dan paket tertulis langsung pada kode halaman. Mengubah harga atau memasang promo
      harus melalui pengembang dan penerapan ulang.],
    [Harga, paket, promosi, dan voucher disimpan di basis data dan diubah staf melalui panel
      admin; perubahan tampil di situs dalam hitungan detik.],
    [2.],
    [Ketersediaan tanggal hanya dapat diketahui dengan bertanya lewat WhatsApp, sehingga
      pemesanan ganda pada tanggal yang sama sulit dicegah.],
    [Kalender ketersediaan per lokasi dengan kapasitas harian ditampilkan pada jendela
      pemesanan; batas kapasitas dijaga oleh basis data.],
    [3.],
    [Invoice dibuat manual pada lembar kerja. Ditemukan satu nomor invoice yang dipakai pada
      dua pelanggan berbeda.],
    [Invoice dibuat otomatis oleh basis data dengan nomor berurutan yang unik dan disimpan
      sebagai salinan yang tidak berubah.],
    [4.],
    [Pembayaran dan sisa tagihan hanya tercatat dalam percakapan WhatsApp sehingga sulit
      ditelusuri.],
    [Pembayaran dicatat pada pesanan beserta bukti transfer; sisa tagihan, tenggat, dan daftar
      pesanan yang belum lunas tampil di panel.],
    [5.],
    [Calon pelanggan dari iklan Instagram dan TikTok tidak tercatat, dan asal kunjungannya
      tidak diketahui.],
    [Formulir kontak dengan persetujuan, penangkapan parameter UTM, dan daftar _leads_ pada
      panel admin.],
    [6.],
    [Foto galeri, ulasan, tanya jawab, dan pengumuman hanya dapat diganti oleh pengembang.],
    [Pengelolaan konten melalui panel admin dengan unggah gambar yang dikompresi otomatis.],
    [7.],
    [Tidak ada pembagian hak akses dan jejak perubahan bagi staf.],
    [Tiga peran pengguna, aturan akses di basis data, dan log aktivitas yang tidak dapat
      diubah.],
  ),
) <tbl-masalah>]

Dengan demikian, sasaran perancangan bergeser dari memperbarui tampilan menjadi mengubah
situs menjadi sebuah sistem. Halaman yang sebelumnya tetap menjadi sumber data yang dapat
diubah staf, dan percakapan yang sebelumnya hanya berlangsung di WhatsApp menjadi pesanan
yang tercatat. WhatsApp tetap dipertahankan sebagai kanal komunikasi utama dengan pelanggan;
sistem hanya mengurangi pertanyaan berulang dan menyediakan data yang rapi di baliknya.

=== Kebutuhan Fungsional

Kebutuhan fungsional disusun dari permasalahan pada @tbl-masalah, diskusi dengan pemilik
Photo.Jo dan pembimbing lapangan, serta tinjauan terhadap contoh invoice yang selama ini
dipakai. Kebutuhan dibagi menjadi kebutuhan situs publik (@tbl-kf-publik) dan kebutuhan
panel admin (@tbl-kf-admin).

#allow-table-break[#figure(
  caption: [Kebutuhan fungsional situs publik],
  table(
    columns: (1.3cm, 1fr, 2.3cm),
    align: (center, left, left),
    table.header([*Kode*], [*Kebutuhan*], [*Aktor*]),
    [KF-01], [Menampilkan informasi tiga lini produk: unit _photobox_, jasa _photobooth_, dan aplikasi _photobooth_.], [Pengunjung],
    [KF-02], [Menyediakan pembuatan _photostrip_ di peramban: memilih _frame_, mengambil tiga foto dengan kamera, dan mengunduh hasilnya.], [Pengunjung],
    [KF-03], [Menampilkan pratinjau 3D unit _photobox_ yang dapat diputar, diperbesar, dan diganti warna bodinya.], [Pengunjung],
    [KF-04], [Menyediakan simulasi alur aplikasi _photobooth_ beserta panel adminnya, dengan pengisian kontak sebelum panel dibuka.], [Pengunjung],
    [KF-05], [Menampilkan harga paket dan add-on terkini beserta promo yang sedang berjalan.], [Pengunjung],
    [KF-06], [Memilih paket dan add-on pada keranjang dengan aturan kelayakan, misalnya batas jumlah add-on.], [Pelanggan],
    [KF-07], [Menyediakan jendela pemesanan enam langkah: paket, lokasi, tanggal, pembayaran, kontak, dan selesai.], [Pelanggan],
    [KF-08], [Menampilkan ketersediaan tanggal per lokasi dan menawarkan daftar tunggu untuk tanggal yang penuh.], [Pelanggan],
    [KF-09], [Menerima kode voucher dan memeriksa keberlakuannya saat pesanan dibuat.], [Pelanggan],
    [KF-10], [Menerbitkan invoice bernomor saat pesanan dibuat dan menyediakannya melalui tautan pribadi.], [Pelanggan],
    [KF-11], [Menerima permintaan daftar harga unit _photobox_.], [Pengunjung],
    [KF-12], [Mengarahkan layanan tertentu, yaitu _photobox_ dan kota di luar jangkauan, ke konsultasi WhatsApp dengan pesan yang sudah terisi.], [Pengunjung],
  ),
) <tbl-kf-publik>]

#allow-table-break[#figure(
  caption: [Kebutuhan fungsional panel admin],
  table(
    columns: (1.3cm, 1fr, 2.3cm),
    align: (center, left, left),
    table.header([*Kode*], [*Kebutuhan*], [*Aktor*]),
    [KF-13], [Masuk dengan email dan kata sandi, mengganti kata sandi sendiri, dan menyelesaikan undangan akun.], [Semua staf],
    [KF-14], [Menampilkan ringkasan pesanan, pembayaran, ketersediaan, katalog, dan _leads_ pada dasbor sesuai peran.], [Semua staf],
    [KF-15], [Mengelola kalender: menutup tanggal, mencatat pemesanan dari luar situs, dan memindahkan jadwal pesanan.], [Semua staf],
    [KF-16], [Mengelola pesanan: melihat dan menyaring, membuat pesanan manual, memperpanjang masa berlaku, mengaktifkan ulang, dan membatalkan.], [Semua staf],
    [KF-17], [Mencatat pembayaran beserta bukti transfer, menerbitkan invoice berikutnya, dan mengirim pengingat lewat WhatsApp.], [Semua staf],
    [KF-18], [Membatalkan pembayaran yang salah catat, mengunci tanggal tanpa DP, dan menetapkan tenggat pelunasan khusus.], [Admin dan Superadmin],
    [KF-19], [Mengubah harga paket dan add-on serta add-on yang tersedia untuk tiap layanan.], [Admin dan Superadmin],
    [KF-20], [Mengelola promosi, voucher, dan pengumuman.], [Admin dan Superadmin],
    [KF-21], [Mengelola galeri, ulasan, tanya jawab, dan studio, dengan unggah gambar yang dikompresi otomatis.], [Admin dan Superadmin],
    [KF-22], [Mengelola _leads_: menandai sudah dihubungi dan mengekspor ke berkas CSV.], [Admin dan Superadmin],
    [KF-23], [Mencatat dan menampilkan log aktivitas perubahan data.], [Admin dan Superadmin],
    [KF-24], [Mengelola lokasi layanan beserta kapasitas hariannya.], [Superadmin],
    [KF-25], [Mengundang, menonaktifkan, dan mengubah peran pengguna.], [Superadmin],
  ),
) <tbl-kf-admin>]

=== Kebutuhan Nonfungsional

Kebutuhan nonfungsional pada @tbl-knf menetapkan mutu yang harus dipenuhi sistem. Beberapa
di antaranya menjadi keputusan perancangan yang menentukan arsitektur, terutama keandalan
saat layanan basis data tidak tersedia dan keamanan data pesanan.

#allow-table-break[#figure(
  caption: [Kebutuhan nonfungsional],
  table(
    columns: (1.3cm, 2.4cm, 1fr),
    align: (center, left, left),
    table.header([*Kode*], [*Aspek*], [*Kebutuhan*]),
    [KNF-01], [Keandalan], [Situs tetap berfungsi saat _backend_ tidak tersedia. Kegagalan fitur dinamis hanya boleh menurunkan fungsi, tidak mematikan halaman.],
    [KNF-02], [Keamanan data], [Hak akses ditentukan oleh basis data dengan prinsip tolak secara bawaan. Kunci rahasia tidak boleh berada di berkas yang dikirim ke peramban.],
    [KNF-03], [Integritas transaksi], [Harga selalu dihitung ulang di server. Kapasitas tanggal tidak boleh terlampaui walau dua pesanan masuk bersamaan. Nomor invoice unik.],
    [KNF-04], [Keterlacakan], [Setiap perubahan data penting mencatat pelaku, waktu, serta nilai sebelum dan sesudahnya, dan catatan itu tidak dapat diubah.],
    [KNF-05], [Kinerja], [Tanpa tahap _build_ dan _framework_. Gambar unggahan dikompresi ke format WebP. Model 3D berukuran di bawah 2 MB dan dimuat saat dibutuhkan.],
    [KNF-06], [Kegunaan], [Antarmuka berbahasa Indonesia, dapat dipakai pada layar ponsel sekitar 390 piksel, dan dapat dioperasikan dengan papan ketik pada dialog pemesanan.],
    [KNF-07], [Pemeliharaan], [Skema basis data dikelola sebagai migrasi berurutan di repositori sehingga pemulihan dilakukan dengan menjalankan ulang migrasi.],
    [KNF-08], [Biaya], [Biaya berulang tetap dan dapat diperkirakan, tidak bergantung pada jumlah operasi, yaitu sekitar Rp 410.000 hingga Rp 740.000 per bulan.],
    [KNF-09], [Penemuan dan berbagi tautan], [Setiap halaman memiliki judul, deskripsi, alamat kanonik, dan gambar pratinjau berukuran 1200 × 630 piksel untuk tautan yang dibagikan.],
  ),
) <tbl-knf>]

=== Aktor dan Hak Akses

Sistem memiliki satu aktor tanpa akun dan tiga aktor dengan akun. Tiga peran staf disusun
bertingkat: setiap peran memiliki seluruh kewenangan peran di bawahnya. Pemilik Photo.Jo
berperan sebagai superadmin sehingga dapat menambah dan menonaktifkan akun staf tanpa
melibatkan pengembang. @tbl-aktor merangkum keempat aktor.

#figure(
  caption: [Aktor sistem dan cakupan kewenangannya],
  table(
    columns: (2.5cm, 1fr),
    align: (left, left),
    table.header([*Aktor*], [*Cakupan kewenangan*]),
    [Pengunjung / pelanggan], [Mengakses situs publik tanpa akun. Hanya dapat membaca data yang memang dipublikasikan, membuat pesanan, menambahkan kontak, dan membuka invoice miliknya melalui tautan pribadi.],
    [Operator], [Mengerjakan kegiatan harian: melihat dasbor ringkas, mengelola kalender, mengelola pesanan, dan mencatat pembayaran.],
    [Admin], [Seluruh kewenangan operator, ditambah pengelolaan harga, promosi, voucher, pengumuman, konten, _leads_, pembatalan pembayaran, penguncian tanggal tanpa DP, dan pembacaan log aktivitas.],
    [Superadmin], [Seluruh kewenangan admin, ditambah pengelolaan lokasi, studio, dan akun pengguna. Selalu tersisa minimal satu superadmin aktif.],
  ),
) <tbl-aktor>

Hak akses pada panel admin per layar dirangkum dalam @tbl-hak-layar. Layar yang tidak dapat
diakses suatu peran disembunyikan dari menu, tetapi penghalang sebenarnya berada di basis
data, sebagaimana dijelaskan pada subbab perancangan keamanan.

#figure(
  caption: [Hak akses layar panel admin per peran],
  table(
    columns: (1fr, 2.2cm, 2.2cm, 2.4cm),
    align: (left, center, center, center),
    table.header([*Layar*], [*Operator*], [*Admin*], [*Superadmin*]),
    [Dashboard], [ringkas], [penuh], [penuh],
    [Calendar], [ubah], [ubah], [ubah],
    [Orders], [ubah#super[1]], [ubah], [ubah],
    [Leads], [–], [ubah], [ubah],
    [Pricing, Promotions, Vouchers, Announcements], [–], [ubah], [ubah],
    [Media, Reviews, FAQ], [–], [ubah], [ubah],
    [Activity Log], [–], [lihat], [lihat],
    [Locations], [–], [–], [ubah],
    [Users], [–], [–], [ubah],
  ),
) <tbl-hak-layar>

#text(size: 10pt)[#super[1] Operator tidak dapat membatalkan pembayaran, mengunci tanggal tanpa DP, atau menetapkan tenggat pelunasan khusus.]

=== Use Case

@gbr-usecase-publik menunjukkan use case situs publik. Pengunjung dapat menjelajahi
produk, mencoba pengalaman interaktif, dan memesan layanan. Dua use case bersifat
tambahan terhadap pemesanan: pemakaian kode voucher dan pendaftaran daftar tunggu yang
hanya muncul bila tanggal yang dipilih sudah penuh. Simulasi aplikasi _photobooth_
mengharuskan pengisian formulir kontak sebelum panel admin simulasi dibuka, sehingga
pengunjung yang menilai perangkat lunak tersebut tercatat sebagai calon pelanggan.

#gambar-diagram(diagram-usecase-publik(), caption: [Use case situs publik]) <gbr-usecase-publik>

@gbr-usecase-staf menunjukkan use case panel admin. Pewarisan antarperan digambarkan
dengan panah dari peran yang lebih tinggi ke peran di bawahnya. Pembatalan pembayaran dan
penguncian tanggal tanpa DP merupakan tambahan terhadap pengelolaan pesanan yang hanya
tersedia bagi admin ke atas.

#gambar-diagram(diagram-usecase-staf(), caption: [Use case panel admin]) <gbr-usecase-staf>

== Perancangan Sistem

=== Desain Sistem

Sistem dirancang dengan prinsip _static-first_. Halaman situs dikirim sebagai berkas statis
dari penyedia hosting, lalu JavaScript di peramban mengambil data dinamis langsung dari
layanan basis data terkelola. Tidak ada server aplikasi buatan sendiri yang harus dirawat.
Pekerjaan sisi server dilakukan oleh basis data, yaitu aturan akses, fungsi, dan pemicu
(_trigger_), serta satu _Edge Function_ untuk operasi yang membutuhkan kunci rahasia. Pilihan
ini sesuai dengan skala usaha Photo.Jo yang tidak memiliki tim operasional khusus.
@gbr-arsitektur menunjukkan arsitektur tersebut.

#gambar-diagram(diagram-arsitektur(), caption: [Arsitektur sistem Photo.Jo Website]) <gbr-arsitektur>

Peran tiap komponen pada @gbr-arsitektur adalah sebagai berikut.

- Peramban web menjalankan halaman HTML dan modul JavaScript tanpa _framework_ dan tanpa
  tahap _build_. Pustaka `supabase-js` dimuat dari CDN sebagai modul ES.
- Vercel menyajikan berkas statis dari dua nama domain, yaitu #box(`www.photojo.id`) untuk
  situs publik dan #box(`dashboard.photojo.id`) untuk panel admin. Vercel juga menetapkan
  header keamanan dan pengalihan berdasarkan nama host.
- PostgREST mengubah skema basis data menjadi API REST dan pemanggilan fungsi (_remote
  procedure call_, RPC), sehingga tidak ada kode penghubung yang harus ditulis.
- Auth mengelola akun staf, sesi, undangan, dan pengaturan ulang kata sandi.
- Storage menyimpan gambar dan video konten situs pada dua _bucket_ publik serta bukti
  transfer pada satu _bucket_ privat.
- Edge Function `manage-users` menjalankan operasi akun yang membutuhkan kunci
  `service_role`, sehingga tidak dapat dijalankan dari peramban.
- PostgreSQL menyimpan data dan menegakkan aturan, yaitu kebijakan akses, fungsi bisnis,
  pemicu, dan kendala data.
- Resend mengirim email undangan dan pengaturan ulang kata sandi melalui SMTP. WhatsApp
  digunakan melalui tautan `wa.me` yang pesan awalnya sudah terisi.

Prinsip _static-first_ dituangkan dalam aturan bahwa situs harus tetap berfungsi penuh
walaupun _backend_ tidak dapat dijangkau. Setiap fitur dinamis dirancang sebagai peningkatan
di atas dasar statis yang sudah berjalan. Perilaku tiap jenis data pada saat gangguan
dirangkum dalam @tbl-degradasi.

#allow-table-break[#figure(
  caption: [Perilaku halaman saat _backend_ tidak tersedia],
  table(
    columns: (2.6cm, 1fr, 1fr),
    align: (left, left, left),
    table.header([*Data*], [*Strategi*], [*Bila _backend_ tidak tersedia*]),
    [Harga, paket, dan add-on], [Ditulis pada HTML sebagai cadangan, lalu ditimpa hasil pengambilan data.], [Pengunjung melihat harga terakhir yang diterapkan; situs tampak normal.],
    [Ketersediaan tanggal], [Hanya dari pengambilan data, karena tidak ada cadangan yang masuk akal.], [Tampilan ketersediaan disembunyikan dan pelanggan diarahkan menanyakan ketersediaan lewat WhatsApp.],
    [Galeri dan portofolio], [Kumpulan foto cadangan pada HTML, ditimpa data.], [Foto terakhir yang diterapkan tetap tampil.],
    [Ulasan], [Tanpa cadangan, karena ulasan tiruan sama dengan klaim palsu.], [Tampil keterangan bahwa ulasan pelanggan segera hadir.],
    [Pengumuman], [Tanpa cadangan, karena pengumuman terikat waktu.], [Kapsul pengumuman tidak tampil.],
    [Keranjang dan pemesanan], [Membutuhkan _backend_ secara definisi.], [Jendela pemesanan tidak dibuka; panel keranjang memakai _checkout_ WhatsApp yang sudah ada.],
  ),
) <tbl-degradasi>]

Agar cadangan statis tidak tertinggal dari harga di basis data, skrip `sync-fallbacks.mjs`
menuliskan harga terbaru ke berkas HTML. Skrip ini memiliki mode `--check` yang berakhir
dengan status gagal bila terdapat selisih, sehingga penerapan dapat ditolak sebelum angka
yang usang sampai ke pengunjung.

Platform _backend_ yang dipilih adalah Supabase, bukan Firebase. Pertimbangannya sebagai
berikut.

- Model data. Pesanan beserta butirnya, paket milik layanan, dan add-on yang dibatasi per
  layanan adalah data relasional. Pada Firestore data tersebut harus didenormalisasi dan
  konsistensinya dijaga secara manual.
- Biaya. Supabase menetapkan biaya tetap bulanan, sehingga lonjakan kunjungan atau kesalahan
  pada kode tidak mengubah tagihan. Firebase diperkirakan sekitar Rp 330.000 per bulan lebih
  murah pada lalu lintas Photo.Jo, tetapi selisih itu dinilai lebih kecil daripada manfaat
  lainnya.
- Keamanan. Aturan akses ditulis sebagai kebijakan SQL yang dijalankan basis data sendiri,
  sehingga lebih mudah ditinjau daripada bahasa aturan yang terpisah.
- Biaya keluar. PostgreSQL standar dapat diekspor dan dijalankan di tempat lain bila suatu
  saat berpindah penyedia.

Komponen infrastruktur dan perangkat lunak yang membentuk sistem beserta spesifikasinya
disajikan pada @tbl-server dan @tbl-software.

#allow-table-break[#figure(
  caption: [Komponen infrastruktur dan spesifikasinya],
  table(
    columns: (0.9cm, 2.6cm, 1fr, 1fr),
    align: (center, left, left, left),
    table.header([*No*], [*Komponen*], [*Fungsi*], [*Spesifikasi*]),
    [1.], [Vercel], [Menyajikan berkas statis situs publik dan panel admin, menetapkan header keamanan, dan mengalihkan alamat menurut nama host.], [Paket Hobby pada masa uji. Produksi diterapkan dari _branch_ `main`. Sertifikat HTTPS otomatis. Aset gambar dan model 3D disimpan _cache_ satu hari.],
    [2.], [Supabase PostgreSQL], [Basis data relasional utama: 24 tabel, kebijakan akses, fungsi, dan pemicu.], [PostgreSQL 17.6. Paket Free selama pengembangan dan paket Pro untuk produksi, dengan kuota dasar 8 GB basis data dan pencadangan harian.],
    [3.], [Supabase PostgREST], [Membuka tabel, _view_, dan fungsi sebagai API REST.], [PostgREST v14.15. Peran dibaca dari token sesi pengguna.],
    [4.], [Supabase Auth], [Autentikasi staf dengan email dan kata sandi, undangan, dan pengaturan ulang kata sandi.], [GoTrue v2.195.0. Pendaftaran mandiri dimatikan.],
    [5.], [Supabase Storage], [Menyimpan gambar, video, dan bukti transfer.], [Storage API v1.69.0. Tiga _bucket_: `content` dan `content-video` (publik) serta `payment-proofs` (privat, maksimum 5 MB per berkas).],
    [6.], [Supabase Edge Functions], [Menjalankan fungsi `manage-users` yang membutuhkan kunci `service_role`.], [Runtime Deno dengan bahasa TypeScript. Rahasia fungsi disimpan pada pengaturan Supabase.],
    [7.], [Resend], [Mengirim email undangan dan pengaturan ulang kata sandi lewat SMTP.], [Domain pengirim terverifikasi. Kunci hanya berhak mengirim.],
    [8.], [Hostinger], [Mengelola DNS domain `photojo.id`.], [Catatan `www` dan `dashboard` diarahkan ke Vercel.],
    [9.], [GitHub], [Menyimpan kode dan memicu penerapan otomatis ke Vercel.], [Repositori privat. _Branch_ `main` untuk produksi dan _branch_ lain untuk pratinjau.],
  ),
) <tbl-server>]

#allow-table-break[#figure(
  caption: [Komponen perangkat lunak dan spesifikasinya],
  table(
    columns: (0.9cm, 2.6cm, 1fr, 1fr),
    align: (center, left, left, left),
    table.header([*No*], [*Komponen*], [*Fungsi*], [*Spesifikasi software*]),
    [1.], [HTML5, CSS3, JavaScript], [Antarmuka situs publik dan panel admin.], [Modul ES. Tanpa _framework_ dan tanpa tahap _build_. Satu berkas HTML untuk tiap halaman.],
    [2.], [supabase-js v2], [Klien basis data, autentikasi, dan penyimpanan di peramban.], [Dimuat dari CDN `esm.sh` sebagai modul ES.],
    [3.], [model-viewer 3.5.0], [Menampilkan model 3D berformat `.glb`.], [Komponen web dari Google, dimuat dari CDN hanya pada halaman Business.],
    [4.], [API peramban], [Kamera, kanvas, gestur, dan penyimpanan sesi.], [`getUserMedia`, Canvas 2D, Pointer Events, `IntersectionObserver`, `sessionStorage`, dan `localStorage`.],
    [5.], [Blender 4.0], [Pemodelan 3D unit _photobox_.], [Ekspor dengan Khronos glTF Blender I/O v4.0.44 ke format `.glb`.],
    [6.], [Supabase CLI dan Docker], [Menjalankan tumpukan Supabase lokal dan menerapkan migrasi.], [Skema disimpan pada `supabase/migrations`. Pengujian lokal dilakukan sebelum penerapan ke produksi.],
    [7.], [Node.js 22 dan Python 3], [Skrip bantu pengembangan.], [`sync-fallbacks.mjs`, `seed-demo.mjs`, dan `serve.py`.],
    [8.], [Git], [Kontrol versi kode dan skema.], [Riwayat perubahan pada repositori privat.],
    [9.], [Google Fonts], [Tipografi situs.], [Comfortaa untuk identitas merek dan Poppins untuk teks bacaan.],
    [10.], [Peramban sasaran], [Lingkungan tempat sisi klien berjalan.], [Chrome dan Edge 90 ke atas, Firefox 88 ke atas, Safari 14 ke atas, serta peramban ponsel yang setara.],
  ),
) <tbl-software>]

=== Perancangan Basis Data

Basis data dirancang relasional pada PostgreSQL dengan 24 tabel yang dikelompokkan menjadi
lima bagian pada @tbl-kelompok-tabel. Skema dibangun bertahap melalui 32 migrasi SQL
berurutan. Migrasi yang sudah diterapkan tidak pernah diubah; perubahan selalu berupa
migrasi baru, sehingga riwayat skema dapat ditelusuri dan dijalankan ulang pada proyek
yang bersih.

#figure(
  caption: [Kelompok tabel basis data],
  table(
    columns: (2.6cm, 1fr, 1fr),
    align: (left, left, left),
    table.header([*Kelompok*], [*Tabel*], [*Fungsi*]),
    [Katalog], [`services`, `packages`, `addons`, `service_addons`, `units`, `promotions`, `vouchers`], [Layanan, paket, add-on, unit _photobox_ (belum dihubungkan ke halaman), potongan harga berjangka waktu, dan kode voucher.],
    [Ketersediaan], [`locations`, `availability_slots`, `slot_claims`], [Kota layanan beserta kapasitas harian, status tiap tanggal, dan klaim yang menempati kapasitas.],
    [Pemesanan dan penagihan], [`orders`, `order_items`, `payments`, `invoices`, `company_profile`], [Pesanan, butir pesanan, pembayaran, invoice, dan data penjual yang dicetak pada invoice.],
    [Konten], [`media`, `reviews`, `faq_items`, `studios`, `announcements`], [Galeri, ulasan, tanya jawab, studio, dan kapsul pengumuman.],
    [Administrasi dan pelacakan], [`profiles`, `audit_log`, `leads`, `gate_events`], [Profil dan peran staf, log aktivitas, calon pelanggan, dan penghitung gerbang formulir.],
  ),
) <tbl-kelompok-tabel>

@gbr-erd-katalog menunjukkan relasi pada kelompok katalog dan ketersediaan. Satu layanan
memiliki banyak paket dan menawarkan banyak add-on melalui tabel penghubung
`service_addons`. Kota memiliki banyak baris tanggal pada `availability_slots`, dan tiap
tanggal dapat memiliki beberapa klaim. Tabel `promotions` dan `vouchers` tidak memiliki
kunci tamu; cakupan berlakunya ditulis sebagai JSON pada kolom `applies_to`, yaitu seluruh
layanan, daftar layanan, atau daftar paket.

#gambar-diagram(diagram-erd-katalog(), caption: [ERD katalog dan ketersediaan]) <gbr-erd-katalog>

@gbr-erd-pemesanan menunjukkan relasi pada kelompok pemesanan dan penagihan. Pesanan
merujuk ke lokasi, promosi, dan voucher secara opsional, karena pesanan manual dari luar
kota atau tanpa potongan tidak memilikinya. Satu pesanan dapat memiliki banyak pembayaran
dan banyak invoice. Tabel `company_profile` tidak dihubungkan dengan kunci tamu karena
isinya disalin ke setiap invoice pada saat terbit.

#gambar-diagram(diagram-erd-pemesanan(), caption: [ERD pemesanan dan penagihan]) <gbr-erd-pemesanan>

Beberapa keputusan perancangan basis data yang menentukan kebenaran sistem adalah sebagai
berikut.

+ Uang disimpan sebagai bilangan bulat dalam rupiah (`bigint`), bukan bilangan pecahan,
  untuk menghindari kesalahan pembulatan.
+ Harga disalin ke butir pesanan dan ke salinan invoice. Perubahan harga pada katalog tidak
  mengubah pesanan atau invoice yang sudah terbit.
+ Kapasitas tanggal dijaga oleh kendala `unique (location_id, date)` pada
  `availability_slots`, kolom `booked_count` yang dihitung pemicu dari `slot_claims`, dan
  pemicu yang mengunci baris tanggal sebelum menambah klaim. Dua pesanan yang memperebutkan
  tanggal terakhir diputuskan satu per satu, bukan keduanya berhasil.
+ Pemesanan dari luar situs, misalnya telepon atau kunjungan langsung, disimpan sebagai
  klaim bersumber `offline` tanpa pesanan. Dengan cara ini hanya ada satu penghitung
  kapasitas yang harus dijaga.
+ Kode pesanan berasal dari _sequence_ PostgreSQL, misalnya `PJ-2026-0142`, bukan dari
  jumlah baris, sehingga tidak pernah dipakai ulang.
+ Penghapusan bersifat lunak, yaitu dengan menonaktifkan atau menurunkan status terbit baris,
  agar riwayat pesanan dan log tidak kehilangan rujukan.
+ Log aktivitas diisi oleh pemicu generik pada tabel-tabel penting. Log menyimpan nilai
  sebelum dan sesudah dalam JSON serta nama dan email pelaku pada saat itu sebagai salinan,
  sehingga tetap benar walaupun akun kemudian diganti nama atau dinonaktifkan.
+ Nilai yang berbentuk pilihan tetap, seperti peran, status pesanan, status pembayaran, dan
  jenis potongan, memakai tipe `enum`.

=== Perancangan Keamanan

Perancangan keamanan berangkat dari satu asumsi: apa pun yang dikirim peramban tidak dapat
dipercaya. Kunci publik berada di berkas JavaScript dan dapat dibaca siapa pun, sehingga
kewenangannya harus ditentukan sepenuhnya oleh basis data. Jenis kunci dan penempatannya
dirangkum pada @tbl-kunci.

#figure(
  caption: [Jenis kunci dan penempatannya],
  table(
    columns: (3cm, 2.6cm, 1fr),
    align: (left, left, left),
    table.header([*Kunci*], [*Dipakai oleh*], [*Penempatan*]),
    [Kunci publik (_publishable_)], [Peramban pengunjung dan staf], [Tertulis pada `db.js`. Aman dipublikasikan karena kewenangannya dibatasi oleh kebijakan akses basis data.],
    [Token sesi staf (JWT)], [Peramban staf setelah masuk], [Dikelola `supabase-js` pada peramban staf, berumur singkat, dan diperbarui otomatis.],
    [Kunci `service_role`], [Edge Function `manage-users`], [Hanya pada rahasia fungsi di Supabase. Tidak ada di repositori, pengaturan Vercel, maupun berkas HTML.],
    [Kunci SMTP Resend], [Supabase Auth], [Disimpan pada pengaturan SMTP Supabase dan hanya berhak mengirim.],
  ),
) <tbl-kunci>

Perlindungan dirancang berlapis sebagai berikut.

+ _Row level security_ (RLS) diaktifkan dan dipaksakan (`force`) pada seluruh tabel dengan
  prinsip tolak secara bawaan: tabel tanpa kebijakan yang cocok tidak dapat diakses.
  @tbl-rls merangkum hak akses data per peran.
+ Data publik yang perlu disaring dibuka melalui _view_ yang hanya menampilkan kolom aman.
  `public_availability` hanya memberi status tanggal (tersedia, sebagian, atau penuh) tanpa
  jumlah pemesanan, `public_locations` memberi nama kota tanpa kapasitas, dan
  `staff_locations` memberi kapasitas hanya kepada staf.
+ Operasi bisnis berupa fungsi `SECURITY DEFINER` yang memeriksa peran di dalam badan fungsi.
  Pelanggan hanya dapat memanggil tiga fungsi yang dibuka secara eksplisit, yaitu
  `create_order`, `public_invoice`, dan `voucher_lookup`. Tabel pesanan, butir pesanan,
  pembayaran, dan invoice tidak memiliki kebijakan tulis untuk peran mana pun, sehingga
  semua perubahan melewati fungsi yang memeriksa aturan bisnis.
+ Pemicu pada tabel `profiles` mencegah pengguna mengubah peran atau status aksesnya
  sendiri, dan pemicu lain menolak perubahan yang menyisakan nol superadmin aktif.
+ Bukti transfer berada pada _bucket_ privat, dibaca melalui tautan bertanda tangan yang
  berlaku 60 detik, dan tidak pernah dicetak pada invoice yang dapat dibuka tanpa masuk.
+ Header HTTP `X-Frame-Options: DENY` dan `frame-ancestors 'none'` mencegah panel admin
  dibingkai oleh halaman lain. Header `nosniff`, `Referrer-Policy`, dan `Permissions-Policy`
  yang hanya mengizinkan kamera untuk demo _photostrip_ melengkapinya. Berkas
  `.vercelignore` mengecualikan dokumen, skema, dan skrip dari penerapan agar tidak dapat
  diunduh dari situs.
+ Panel admin berada pada subdomain tersendiri sehingga skrip aplikasi lama pada domain
  induk tidak berbagi asal (_origin_) dan tidak dapat membaca sesi staf.
+ Seluruh pembacaan data publik memakai klien yang tidak dapat menyimpan sesi. Halaman
  publik karenanya selalu melihat data seperti pengunjung biasa, walaupun staf sedang masuk
  pada peramban yang sama.

#allow-table-break[#figure(
  caption: [Hak akses data per peran],
  table(
    columns: (2.5cm, 1fr, 1.7cm, 1.7cm, 1.7cm),
    align: (left, left, left, left, left),
    table.header([*Data*], [*Pengunjung*], [*Operator*], [*Admin*], [*Super-admin*]),
    [Katalog (layanan, paket, add-on)], [baca yang aktif], [baca semua], [ubah], [ubah],
    [Promosi], [baca yang sedang berjalan], [–], [ubah], [ubah],
    [Voucher], [tidak ada akses langsung; hanya memeriksa satu kode], [–], [ubah], [ubah],
    [Lokasi], [nama kota melalui _view_], [kapasitas melalui _view_], [kapasitas melalui _view_], [ubah],
    [Ketersediaan dan klaim], [status tanggal melalui _view_], [ubah], [ubah], [ubah],
    [Pesanan, butir, pembayaran], [–], [baca], [baca], [baca],
    [Invoice], [satu pesanan melalui token pribadi], [baca], [baca], [baca],
    [_Leads_], [hanya menambah], [–], [baca dan tandai], [baca dan tandai],
    [Media, ulasan, FAQ, studio, pengumuman], [baca yang terbit], [–], [ubah], [ubah],
    [Profil staf], [–], [milik sendiri], [milik sendiri], [semua],
    [Log aktivitas], [–], [–], [baca], [baca],
    [Profil perusahaan], [–], [baca], [baca], [baca dan ubah],
  ),
) <tbl-rls>]

Perubahan pada pesanan, pembayaran, dan invoice oleh staf tidak terlihat pada @tbl-rls
karena tidak berupa akses tabel, melainkan pemanggilan fungsi bisnis yang memeriksa peran
dan aturan sebelum menulis. Cara kerja fungsi tersebut dijelaskan pada subbab berikutnya
dan implementasinya pada Bab 5.

=== Perancangan Alur Pemesanan

Alur pemesanan dan penagihan adalah bagian sistem yang paling banyak menanggung aturan
bisnis. Alur dirancang agar pelanggan dapat memesan tanpa menunggu balasan staf, sementara
penerimaan uang tetap dikonfirmasi oleh manusia melalui WhatsApp dan dicatat staf pada
sistem. Pembayaran otomatis dengan Midtrans QRIS telah dikaji dan dispesifikasikan, tetapi
sengaja ditunda atas keputusan pemilik dan manajemen. Sistem ini karenanya berfungsi
lengkap tanpa pembayaran otomatis, dan penambahan pembayaran otomatis di kemudian hari
tidak memerlukan perancangan ulang.

Jendela pemesanan tampil sebagai dialog di atas halaman Service setelah pelanggan memilih
paket. Dialog dapat diperkecil menjadi tombol melayang agar pelanggan tetap dapat
menjelajah, dan kemajuannya disimpan pada `sessionStorage` sehingga tidak hilang saat
berpindah langkah atau memuat ulang halaman. Memilih opsi hanya memilih; hanya tombol
_Lanjut_ yang memindahkan langkah, dan tombol itu tetap redup sampai langkah terpenuhi.
Enam langkahnya adalah sebagai berikut.

+ Paket dan add-on. Pelanggan meninjau dan dapat mengubah pilihannya. Add-on yang tidak
  diizinkan oleh paket terpilih ditampilkan redup disertai alasannya, misalnya khusus
  paket Ultimate.
+ Lokasi. Pelanggan memilih salah satu kota yang dilayani atau mengetik kota lain. Kota di
  luar jangkauan keluar dari alur menuju konsultasi WhatsApp. Alamat tempat acara dan jam
  mulai bersifat opsional.
+ Tanggal. Kalender bulanan diwarnai menurut lokasi terpilih: putih untuk tanggal
  tersedia, kuning untuk tanggal yang terisi sebagian (berlabel _Hampir penuh_ dan hanya
  mungkin di kota berkapasitas dua), dan merah untuk tanggal penuh atau ditutup yang tidak
  dapat dipilih.
  Mengetuk tanggal merah menawarkan daftar tunggu.
+ Pembayaran. Pelanggan memilih bayar penuh atau membayar DP. Aturan pembayaran
  ditampilkan sebelum pelanggan berkomitmen.
+ Kontak. Nama dan nomor WhatsApp wajib diisi, sedangkan alamat penagihan opsional bagi
  pelanggan korporat yang dipesankan dari satu kantor dan ditagih ke kantor lain. Nomor
  divalidasi bentuknya, tidak sekadar panjangnya.
+ Selesai. Server membuat pesanan. Jendela menampilkan kode pesanan dengan tombol salin
  dan tautan invoice pertama.

Alur ini digambarkan pada @gbr-alur-pemesanan. Dua jalur keluar menuju WhatsApp dibuat
dengan pesan awal yang berbeda sehingga staf menerima konteks yang tepat: paket _photobox_
dan kota di luar jangkauan.

#gambar-diagram(diagram-alur-pemesanan(), caption: [Alur pemesanan oleh pelanggan]) <gbr-alur-pemesanan>

Di sisi server, fungsi `create_order` hanya menerima pilihan pelanggan, yaitu layanan,
paket, add-on, lokasi, tanggal, pilihan pembayaran, nama, dan nomor WhatsApp, lalu
menghitung seluruh harga dari basis data. Harga yang tampil pada jendela hanyalah
pratinjau. Bila angka itu berbeda dengan hitungan server, hitungan server yang berlaku.
Rancangan ini menutup kemungkinan pelanggan mengubah harga melalui alat pengembang
peramban, yang akan menjadi celah serius begitu total pesanan dapat berubah menjadi
invoice. Pemeriksaan yang sama berlaku untuk kapasitas, lokasi, dan mode pemesanan:
permintaan yang menyebut tanggal penuh, kota yang tidak dilayani, atau paket yang hanya
boleh dipesan lewat WhatsApp ditolak server walaupun peramban yang dimodifikasi mengirimnya.

=== Aturan Pembayaran dan Penguncian Tanggal

Aturan pembayaran ditetapkan pemilik Photo.Jo dan dirangkum pada @tbl-aturan-bayar. Aturan
ini dituliskan sebelum pelanggan memesan agar syarat bahwa pembayaran tidak dapat
dikembalikan dibaca sebelum uang dikirim, bukan ditemukan kemudian pada invoice.

#figure(
  caption: [Aturan pembayaran dan penguncian tanggal],
  table(
    columns: (0.9cm, 1fr, 1fr),
    align: (center, left, left),
    table.header([*No*], [*Aturan*], [*Penerapan pada sistem*]),
    [1.], [DP boleh berapa pun, mulai dari Rp 500.000.], [Nilai minimum disimpan sebagai fungsi `dp_minimum()` sehingga hanya ada satu sumber nilai.],
    [2.], [Sisa tagihan dilunasi paling lambat H-3 sebelum acara.], [Acara yang kurang dari tiga hari lagi hanya dapat dibayar lunas.],
    [3.], [Perubahan jadwal atau pesanan paling lambat H-3.], [Dilayani staf melalui WhatsApp dan dikerjakan pada panel oleh fungsi pemindah jadwal.],
    [4.], [Pembayaran yang sudah diterima tidak dapat dikembalikan.], [Dinyatakan pada langkah pembayaran dan pada invoice.],
    [5.], [Tanggal terkunci ketika pembayaran tercatat mencapai minimum DP.], [Pesanan yang belum dibayar tidak menahan tanggal. Siapa yang pembayarannya dicatat lebih dulu mendapatkan tanggal itu.],
    [6.], [Pesanan yang belum dibayar berlaku 48 jam.], [Staf dapat memperpanjang tanpa batas atau mengaktifkan kembali pesanan yang sudah kedaluwarsa.],
  ),
) <tbl-aturan-bayar>

Pesanan yang belum dibayar sengaja tidak menahan tanggal. Dua pelanggan dapat memesan tanggal
terakhir yang sama, dan pelanggan yang pembayarannya dicatat lebih dulu memperoleh tanggal
itu. Pencatatan pembayaran pelanggan lainnya ditolak server dengan pesan agar staf
menawarkan tanggal lain, sehingga tidak ada uang yang diterima untuk tanggal yang tidak
dapat dilayani. Kebijakan ini mencegah pelanggan yang lambat menutup tanggal bagi pelanggan
yang siap membayar. Risikonya dikurangi pada empat tempat, yaitu penjelasan pada langkah
selesai bahwa tanggal belum terkunci, penanda tanggal penuh pada pesanan di panel,
daftar pesanan yang menunggu tanggal pada kalender, dan penolakan pembayaran oleh server.

Pelanggan korporat sering melunasi beberapa minggu setelah invoice terbit, bahkan setelah
acara. Kebutuhan ini dilayani dengan penguncian tanggal tanpa DP oleh admin dengan alasan
yang wajib dicatat, tenggat pelunasan khusus untuk satu pesanan, dan pesanan yang tidak
kedaluwarsa selama dikunci.

=== Status Pesanan

Siklus hidup pesanan digambarkan pada @gbr-status-pesanan. Pesanan lahir pada status
_Menunggu Bayar_. Pesanan yang melewati 48 jam tanpa pembayaran menjadi _Kedaluwarsa_,
tetapi karena tidak menahan tanggal tidak ada yang perlu dilepas. Staf dapat mengaktifkan
kembali pesanan tersebut tanpa membuat pesanan baru sehingga kode pesanan, riwayat invoice,
dan harga yang sudah dikunci tetap sama. Pembatalan dapat dilakukan staf dari keadaan
mana pun dan melepas tanggal yang ditahan pesanan itu.

#gambar-diagram(diagram-status-pesanan(), caption: [Status pesanan]) <gbr-status-pesanan>

=== Pencatatan Pembayaran dan Penerbitan Invoice

Uang diterima dan dikonfirmasi oleh manusia di luar sistem, yaitu melalui transfer bank atau
kode QRIS yang dikirim staf, lalu dicatat pada panel. Pencatatan dirancang sebagai satu
tindakan yang dikerjakan seluruhnya oleh basis data dalam satu transaksi, dengan langkah
sebagai berikut.

+ Staf menekan tindakan _Catat Bayar_ pada pesanan, lalu mengisi jumlah, metode, tanggal
  uang diterima, dan bukti transfer. Bukti wajib untuk transfer dan QRIS, sedangkan pembayaran
  tunai boleh tanpa bukti.
+ Server mengunci baris pesanan, memeriksa bahwa jumlah tidak melebihi sisa tagihan dan
  bahwa tanggal pembayaran tidak berada di masa depan.
+ Bila pesanan menahan tanggal dan belum memiliki klaim, server mengunci baris tanggal. Bila
  tanggal ditutup atau sudah dikunci pesanan lain, pembayaran ditolak dan tidak ada yang
  tercatat.
+ Bila total pembayaran mencapai minimum DP, server membuat klaim terkonfirmasi sehingga
  tanggal terkunci.
+ Server menyimpan pembayaran, memperbarui status dan sisa tagihan, lalu menerbitkan
  invoice berikutnya.

Penomoran invoice mengikuti kode pesanan. Kode `PJ-2026-0142` ditulis dengan garis miring
pada invoice sebagai `PJ/2026/0142`, ditambah akhiran dua digit. Nomor berakhiran `/01`
adalah tagihan pembuka yang terbit bersama pesanan. Setiap pembayaran yang dicatat
menerbitkan nomor berikutnya yang memuat jumlah yang sudah dibayar dan sisa tagihan, dan
invoice yang menutup tagihan bertanda LUNAS. @tbl-contoh-invoice memberi contoh pada
pesanan senilai Rp 4.000.000 yang dibayar dalam tiga kali.

#figure(
  caption: [Contoh penomoran invoice pada satu pesanan senilai Rp 4.000.000],
  table(
    columns: (3.4cm, 1fr, 2.3cm, 2.3cm),
    align: (left, left, right, right),
    table.header([*Nomor invoice*], [*Terbit saat*], [*Sudah dibayar*], [*Sisa tagihan*]),
    [PJ/2026/0142/01], [Pesanan dibuat], [Rp 0], [Rp 4.000.000],
    [PJ/2026/0142/02], [DP dicatat], [Rp 1.000.000], [Rp 3.000.000],
    [PJ/2026/0142/03], [Pembayaran kedua], [Rp 2.500.000], [Rp 1.500.000],
    [PJ/2026/0142/04], [Pelunasan], [Rp 4.000.000], [LUNAS],
  ),
) <tbl-contoh-invoice>

Beberapa aturan menjaga agar invoice dapat dipercaya sebagai dokumen.

- Invoice yang sudah terbit tidak pernah disunting. Isinya disimpan sebagai salinan beku,
  sehingga mengubah rekening perusahaan atau nama penagihan hanya memengaruhi invoice
  berikutnya. Perubahan nama penagihan atau tenggat khusus menerbitkan nomor baru dan
  menandai nomor lama sebagai BATAL.
- Pembayaran yang salah catat dibatalkan, bukan dihapus, oleh admin dengan alasan tertulis.
  Invoice yang terbit dari pembayaran itu ditandai BATAL dan sebuah invoice koreksi
  diterbitkan. Bila sisa pembayaran turun di bawah minimum DP, tanggal dilepas.
- Nomor tidak pernah dipakai ulang. Celah pada urutan dapat terjadi dan dapat diterima;
  yang dijamin adalah keunikan nomor, bukan urutan tanpa celah.
- Invoice dibuka melalui tautan pribadi `invoice.html?t=<token>` dengan token acak 122 bit
  yang tidak dapat ditebak. Halaman yang sama dipakai staf dan pelanggan, dengan tombol
  untuk menyimpannya sebagai PDF.

=== Perancangan Antarmuka

Antarmuka dirancang mengikuti identitas merek Photo.Jo yang bersih, ceria, dan berfokus pada
foto, seluruhnya dalam bahasa Indonesia. Struktur situs terdiri atas dua nama domain seperti
pada @gbr-peta-situs. Situs publik bersifat berhalaman jamak, bukan aplikasi satu halaman,
sehingga setiap lini produk memiliki alamat sendiri yang dapat dibagikan dan diindeks mesin
pencari.

#gambar-diagram(diagram-peta-situs(), caption: [Peta situs]) <gbr-peta-situs>

*Sistem desain.* Sistem desain ditetapkan sebagai token CSS yang sama pada seluruh halaman, termasuk panel
admin, agar tampilan konsisten. @tbl-warna merangkum palet warna dan @tbl-tipografi
merangkum tipografi.

#figure(
  caption: [Palet warna],
  table(
    columns: (1.1cm, 2.2cm, 1fr),
    align: (center, left, left),
    table.header([*Warna*], [*Kode*], [*Penggunaan*]),
    [#box(width: 7mm, height: 4mm, fill: rgb("#1d1d1f"), stroke: 0.4pt)], [`#1d1d1f`], [Teks utama dan latar gelap],
    [#box(width: 7mm, height: 4mm, fill: rgb("#f5f5f7"), stroke: 0.4pt)], [`#f5f5f7`], [Latar bagian terang],
    [#box(width: 7mm, height: 4mm, fill: rgb("#636366"), stroke: 0.4pt)], [`#636366`], [Teks sekunder dan keterangan],
    [#box(width: 7mm, height: 4mm, fill: rgb("#424245"), stroke: 0.4pt)], [`#424245`], [Teks isi pada latar terang],
    [#box(width: 7mm, height: 4mm, fill: rgb("#2d7d6f"), stroke: 0.4pt)], [`#2d7d6f`], [Aksen utama, tautan, dan lencana],
    [#box(width: 7mm, height: 4mm, fill: rgb("#5cd4c4"), stroke: 0.4pt)], [`#5cd4c4`], [Sorotan pada latar gelap],
    [#box(width: 7mm, height: 4mm, fill: rgb("#ccfbf1"), stroke: 0.4pt)], [`#ccfbf1`], [Latar _chip_, tanda centang, dan lencana],
    [#box(width: 7mm, height: 4mm, fill: rgb("#be123c"), stroke: 0.4pt)], [`#be123c`], [Peringatan dan kesalahan],
    [#box(width: 7mm, height: 4mm, fill: rgb("#f59e0b"), stroke: 0.4pt)], [`#f59e0b`], [Bintang penilaian],
  ),
) <tbl-warna>

#figure(
  caption: [Tipografi dan geometri komponen],
  table(
    columns: (2.6cm, 1fr),
    align: (left, left),
    table.header([*Unsur*], [*Ketentuan*]),
    [Huruf merek], [Comfortaa (bobot 300 sampai 700) untuk logo, judul, navigasi, tombol, dan lencana.],
    [Huruf bacaan], [Poppins (bobot 300 sampai 600) untuk paragraf, deskripsi, kartu, ulasan, dan tanya jawab, dengan ukuran 15 sampai 16 piksel dan tinggi baris 1,7 sampai 1,8.],
    [Bentuk], [Kartu berjari-jari 24 piksel, tombol berbentuk pil, dan lebar isi maksimum 1100 piksel.],
    [Jarak bagian], [100 piksel vertikal dan 40 piksel horizontal pada layar lebar, 80 dan 20 piksel pada ponsel.],
    [Latar hero], [Latar gelap dengan cahaya teal yang mengikuti kursor pada perangkat penunjuk halus, sama pada Home, Business, dan Application.],
  ),
) <tbl-tipografi>

*Pola interaksi dan aksesibilitas.* Beberapa pola interaksi dirancang sebagai aturan yang berlaku di seluruh situs.

- Dua titik patah responsif, yaitu 1023 dan 767 piksel. Pada ponsel navigasi menjadi menu
  layar penuh dan tata letak kolom ganda menjadi satu kolom.
- Elemen muncul bertahap saat digulir menggunakan `IntersectionObserver`. Gerak dan
  animasi dikurangi bagi pengguna yang meminta pengurangan gerak pada sistem operasinya.
- Ikon berupa SVG sebaris dan teks tombol tidak memakai emoji, agar tampilan sama di
  semua perangkat.
- Setiap halaman dimulai dengan tautan lompat ke konten. Dialog pemesanan menahan fokus
  papan ketik, menutup latar di belakangnya dari pembaca layar, dan menanyakan sebelum
  menutup bila Escape ditekan.
- Seluruh kontrol formulir berukuran huruf minimal 16 piksel pada layar sentuh agar peramban
  iOS tidak memperbesar halaman saat kolom difokuskan.

*Rancangan panel admin.* Panel admin memakai token warna dan huruf yang sama sehingga terasa sebagai bagian dari
Photo.Jo, dengan bilah samping gelap dan area konten terang. Menu dikelompokkan menurut
tujuan layar: pekerjaan harian di atas dan pengaturan yang jarang disentuh di bawah, seperti
pada @tbl-menu. Layar yang tidak boleh diakses suatu peran disembunyikan dari menu, bukan
sekadar dinonaktifkan.

#figure(
  caption: [Pengelompokan menu panel admin],
  table(
    columns: (2.6cm, 1fr, 2.6cm),
    align: (left, left, left),
    table.header([*Kelompok*], [*Layar*], [*Dapat dilihat oleh*]),
    [(tanpa judul)], [Dashboard], [Semua staf],
    [Operations], [Calendar, Orders, Leads], [Calendar dan Orders: semua staf; Leads: admin ke atas],
    [Pricing & Promos], [Pricing, Promotions, Vouchers, Announcements], [Admin ke atas],
    [Website], [Media, Reviews, FAQ], [Admin ke atas],
    [Settings], [Locations, Users], [Superadmin],
    [History], [Activity Log], [Admin ke atas],
  ),
) <tbl-menu>

Beberapa prinsip berlaku pada seluruh layar panel.

- Daftar yang dapat bertambah tanpa batas dibagi per 10 baris. Daftar yang besar diurutkan
  dan di-halaman-kan oleh server, sedangkan daftar kecil diurutkan di memori.
- Perubahan harga ditampung dahulu dan disimpan sekaligus. Perubahan lebih dari 25 persen
  meminta konfirmasi satu kali untuk seluruh perubahan, agar salah ketik tidak langsung
  tayang di situs.
- Urutan daftar yang menentukan tampilan situs, seperti galeri, ulasan, tanya jawab, dan
  pengumuman, diatur dengan seret dan lepas, dengan alternatif papan ketik.
- Tindakan yang merusak meminta konfirmasi, dan penghapusan lebih mengutamakan penonaktifan.
- Panel dapat dipakai pada layar sekitar 390 piksel, karena operator dapat menandai tanggal
  atau mengonfirmasi pembayaran dari ponsel pada hari acara.

=== Perancangan Model 3D

Calon pembeli unit _photobox_ ingin memeriksa bentuk unit sebelum menghubungi penjual. Untuk
itu tiga unit dimodelkan secara tiga dimensi dan ditampilkan interaktif pada halaman
Business. Ketiganya dirangkum pada @tbl-unit. Unit keempat, _Custom Unit_, tidak
dimodelkan karena bentuknya mengikuti permintaan pembeli, dan halaman menampilkan keterangan
yang sesuai.

#figure(
  caption: [Unit _photobox_ yang dimodelkan],
  table(
    columns: (2.3cm, 3cm, 1fr),
    align: (left, left, left),
    table.header([*Unit*], [*Lebar × panjang × tinggi*], [*Karakteristik*]),
    [Kiosk Slim], [450 × 450 × 1500 mm], [Kios ramping dengan monitor, lensa kamera, pencetak, dan rak. Bodi dan pintu satu warna yang dapat diganti.],
    [Velvet Booth], [1400 × 1800 × 2240 mm], [Bilik tertutup dengan dua pintu, rel dan tirai, tiga lampu, dua kipas, pencetak, dan kotak lampu berlogo.],
    [Cabin Booth], [940 × 1600 × 2100 mm], [Bilik tertutup dengan satu pintu berengsel, rel dan tirai, dua panel cermin, monitor, kamera, lampu, dan rak penyimpanan aksesori.],
  ),
) <tbl-unit>

Perancangan model mengikuti beberapa batasan yang diturunkan dari cara model ditampilkan.

- Format keluaran adalah `.glb`, sehingga satu berkas memuat bentuk dan tekstur dan dapat
  langsung dimuat oleh _model-viewer_.
- Jumlah poligon dijaga rendah, sekitar 1.100 sampai 2.000 segitiga per unit, dengan ukuran
  berkas 1,3 sampai 1,7 MB. Pada angka ini tidak diperlukan kompresi Draco.
- Material bodi diberi nama `BoxBody` agar situs dapat mengganti warnanya saat pengunjung
  memilih. Semua material bernama itu diubah sekaligus, karena satu unit dapat memiliki dua
  material seperti itu, yaitu bodi dan pintu.
- Layar monitor, lensa kamera, kipas, tirai, cermin, dan stiker memakai tekstur gambar
  agar rincian terbaca tanpa menambah jumlah poligon.

Tahapan pemodelan sampai tampil di peramban digambarkan pada @gbr-alur-3d.

#gambar-diagram(diagram-alur-3d(), caption: [Jalur pemodelan 3D unit _photobox_]) <gbr-alur-3d>

=== Rancangan Penerapan

Sistem dirancang berjalan pada tiga lingkungan seperti pada @tbl-lingkungan. Klien memilih
lingkungan secara otomatis dari nama host halaman, sehingga tidak ada langkah mengganti
kunci sebelum penerapan yang dapat terlupa.

#figure(
  caption: [Lingkungan pengembangan dan produksi],
  table(
    columns: (2.2cm, 1fr, 1fr, 2.2cm),
    align: (left, left, left, left),
    table.header([*Lingkungan*], [*Klien*], [*Backend*], [*Biaya*]),
    [Lokal], [Server statis lokal `serve.py`.], [Tumpukan Supabase lokal pada Docker.], [Rp 0],
    [Uji dan pratinjau], [Pratinjau Vercel untuk setiap _branch_.], [Proyek Supabase terkelola paket Free.], [Rp 0],
    [Produksi], [Vercel pada nama domain `www` dan `dashboard`.], [Proyek Supabase terkelola paket Pro.], [Lihat @tbl-biaya],
  ),
) <tbl-lingkungan>

Domain `photojo.id` sebelumnya sudah dipakai aplikasi _photobooth_ lama yang masih melayani
halaman foto tamu dan antarmuka pemrograman bagi unit yang memakainya. Penerapan tidak
boleh mengganggu sistem tersebut. Karena itu situs baru ditempatkan pada subdomain `www`,
sedangkan domain induk tetap melayani aplikasi lama dan hanya mengalihkan jalur milik situs
baru ke `www`. Panel admin ditempatkan pada subdomain tersendiri, `dashboard`, agar skrip
aplikasi lama tidak berbagi asal dengan sesi staf. Pengelolaan DNS dipusatkan pada Hostinger.
@gbr-topologi menggambarkan susunan tersebut.

#gambar-diagram(diagram-topologi(), caption: [Topologi domain dan jalur penerapan]) <gbr-topologi>

Biaya berulang sistem dirancang tetap dan dapat diperkirakan, seperti pada @tbl-biaya. Angka
dikonversi dengan kurs sekitar Rp 16.500 per dolar Amerika Serikat dan bersifat perkiraan
perancangan.

#figure(
  caption: [Perkiraan biaya berulang produksi per bulan],
  table(
    columns: (2.4cm, 3.2cm, 1fr),
    align: (left, left, left),
    table.header([*Komponen*], [*Perkiraan biaya*], [*Catatan*]),
    [Vercel], [Rp 0 atau sekitar Rp 330.000], [Paket Hobby berlisensi nonkomersial. Pemilihan paket produksi dibahas bersama pemilik setelah peluncuran.],
    [Supabase Pro], [Sekitar Rp 410.000], [Basis data, autentikasi, penyimpanan, fungsi, dan pencadangan harian, tanpa jeda otomatis.],
    [Domain], [Rp 0], [Sudah dimiliki dan dikelola Photo.Jo jauh sebelum pengembangan situs, sehingga bukan biaya tambahan.],
    [Total tambahan], [Rp 410.000 sampai Rp 740.000], [Bergantung pada pilihan paket Vercel.],
  ),
) <tbl-biaya>

Perancangan pada bab ini diwujudkan menjadi sistem yang berjalan pada bab berikutnya.
