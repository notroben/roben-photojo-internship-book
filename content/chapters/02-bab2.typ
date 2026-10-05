// ============================================================
// BAB II PROFIL PERUSAHAAN
// Profil PT Jokeen Solusi Teknologi bersumber dari jokeen.id dan ITS News;
// uraian Photo.Jo bersumber dari situs dan dokumen rancangan Photo.Jo.
// ============================================================

#import "../../template/lib.typ": *
#import "../diagram/_lib.typ": gambar-diagram
#import "../diagram/profil.typ": diagram-struktur-jokeen, diagram-posisi-photojo
#let data = yaml("../../data.yaml")

// Tabel pada bab ini: huruf 9,5 pt dan rata kiri; judul tabel menempel pada baris pertama.
#show figure.where(kind: table): it => {
  show figure.caption: set block(sticky: true)
  it
}
#set table.cell(breakable: false)
#show table: set text(size: 9.5pt)
#show table: set par(justify: false)
#set table(inset: 4pt)

= PROFIL PERUSAHAAN

Bab ini menguraikan profil PT Jokeen Solusi Teknologi sebagai tempat pelaksanaan kerja
praktik dan Photo.Jo sebagai produk yang menjadi objek pekerjaan. Karena pekerjaan kerja
praktik dilakukan pada produk, uraian tentang perusahaan dibuat ringkas dan pembahasan lebih
banyak diarahkan pada Photo.Jo.

== Profil #data.instansi.nama

PT Jokeen Solusi Teknologi beroperasi dengan nama Jokeen Indonesia atau Jokeen.id, yaitu
perusahaan rintisan (_startup_) di bidang rekayasa teknik yang menyediakan jasa desain teknik,
_3D printing_, _computer numerical control_ (CNC), dan pengembangan _Internet of Things_
(IoT) @jokeen-id.

=== Sejarah Berdiri

Jokeen.id dirintis sejak tahun 2020 oleh Puguh Pambudi dan Muhammad Husnir Rahman, dua
mahasiswa Departemen Teknik Mesin ITS angkatan 2018 @its-jokeen-2021. Latar belakangnya
adalah kesulitan industri kecil dalam mewujudkan ide di bidang IoT. Perusahaan ini juga
dimaksudkan sebagai jembatan antara klien yang ingin mewujudkan suatu produk dan mahasiswa
yang memiliki keterampilan teknis tetapi belum memiliki wadah untuk mengembangkannya
@its-jokeen-2021.

Pada tahap awal, perusahaan melayani desain produk mekanik dan pembuatan prototipe sederhana.
Seiring meningkatnya kepercayaan klien, layanan berkembang mencakup manufaktur presisi dengan
_3D printing_, _laser cutting_, dan _CNC machining_, kemudian sistem mekatronika dan IoT
@jokeen-sejarah. Pemberitaan ITS pada tahun 2021 mencatat bahwa Jokeen.id telah menyelesaikan lebih
dari 100 proyek. Perusahaan ini juga tercatat sebagai penyewa (_tenant_) Inkubator ITS,
penerima pendanaan Program Kompetisi Bisnis Mahasiswa Indonesia (KBMI) 2021, 25 besar
_Innovation Challenge & Business Summit_ (ICBS) 2021, dan 100 besar Startup4Industry 2021
yang diselenggarakan Kementerian Perindustrian @its-jokeen-2021. Saat ini perusahaan bekerja
sama dengan UMKM, institusi pendidikan, _startup_ teknologi, dan industri manufaktur
@jokeen-sejarah.

=== Bidang Usaha

Bidang usaha PT Jokeen Solusi Teknologi mencakup seluruh tahapan pengembangan produk, dari
konsep hingga produksi. Layanan yang ditawarkan adalah sebagai berikut @jokeen-produk:

- Jasa desain teknik untuk produk mekanik dan sistem mekatronika.
- Prototipe cepat dengan _3D printing_, _CNC machining_, dan _laser cutting_.
- Pengembangan produk mekatronika dan IoT yang siap uji dan siap produksi, termasuk integrasi
  _hardware_ dan _firmware_.
- Produksi massal komponen mekanik dan sistem mekatronika.
- Konsultasi teknis dan optimasi manufaktur.

Proyek yang dicantumkan pada situs perusahaan antara lain sistem pemantau lingkungan berbasis
IoT, prototipe robot otomasi industri ringan, modul mekanik modular untuk penelitian dan
pendidikan, serta komponen presisi _custom_ untuk mitra industri @jokeen-projek. Perusahaan
menyatakan keunggulannya pada layanan terpadu dari konsep desain hingga produksi massal oleh
tim berkeahlian multidisiplin @jokeen-id.

=== Visi dan Misi

Visi dan misi yang dicantumkan pada situs perusahaan adalah sebagai berikut @jokeen-id.

*Visi.* Menjadi _startup engineering_ terdepan di Indonesia yang mampu menghadirkan solusi
rekayasa produk berkualitas tinggi dan berkelanjutan.

*Misi.*

+ Mengembangkan layanan _engineering_ yang inovatif, efisien, dan terintegrasi.
+ Mendorong lahirnya produk berbasis teknologi yang mampu bersaing di tingkat nasional maupun
  global.
+ Menempatkan kualitas, profesionalisme, dan kepuasan klien sebagai prioritas utama, dengan
  pendekatan teknis yang matang, perencanaan yang terstruktur, dan pengujian yang menyeluruh.

=== Struktur Organisasi

Struktur organisasi yang dipublikasikan pada situs perusahaan ditunjukkan pada
@gbr-struktur-jokeen. _Founder_ atau pemilik bertanggung jawab atas arah dan visi utama,
sedangkan CEO atau ketua mengelola dan mengawasi seluruh kegiatan organisasi dengan dibantu
wakil ketua. Sekretaris mengelola administrasi, arsip, dan surat-menyurat, sedangkan bendahara
mengatur keuangan, pemasukan, dan pengeluaran. Kegiatan usaha dijalankan oleh lima divisi.
Divisi Kreatif mengelola desain, konten, dan ide kreatif. Divisi Produksi mengatur proses
produksi dan kualitas produk. Divisi Marketing dan Media menangani promosi, media sosial, dan
pemasaran. Divisi Operasional mengatur kegiatan harian dan distribusi. Divisi Humas dan Kerja
Sama menjalin hubungan dengan mitra dan pihak eksternal @jokeen-struktur.

#gambar-diagram(
  diagram-struktur-jokeen(),
  caption: [Struktur organisasi PT Jokeen Solusi Teknologi menurut situs perusahaan],
) <gbr-struktur-jokeen>

== Photo.Jo sebagai Produk PT Jokeen Solusi Teknologi

=== Gambaran Umum

Photo.Jo adalah merek di bawah PT Jokeen Solusi Teknologi yang bergerak di bidang fotografi
dan _photobox_. Hubungan keduanya terlihat pada dokumen usaha. Invoice Photo.Jo, baik yang
dibuat manual maupun oleh sistem, mencantumkan PT Jokeen Solusi Teknologi sebagai nama badan
usaha dan Photo.Jo sebagai nama dagang. Unit _photobox_ yang disewakan maupun dijual dirancang dan
dibuat oleh para _engineer_ Photo.Jo sendiri, baik secara internal maupun melalui pihak
ketiga. @gbr-posisi-photojo menunjukkan posisi Photo.Jo di antara usaha PT Jokeen Solusi
Teknologi, dan @gbr-logo menampilkan logo kedua merek.

#gambar-diagram(
  diagram-posisi-photojo(),
  caption: [Posisi Photo.Jo dan lini produknya di bawah PT Jokeen Solusi Teknologi],
) <gbr-posisi-photojo>

Identitas Photo.Jo dibangun di sekitar kalimat _"Save the Moment with Us!"_ dan pernyataan
bahwa foto bukan sekadar gambar, melainkan perasaan yang bisa dipegang. Logonya berupa
gelembung percakapan dengan tulisan putih, dan huruf _o_ pada akhir nama digambarkan sebagai
lensa kamera. Pada halaman beranda situsnya, Photo.Jo menyebut telah melayani lebih dari
1.000 acara dan 10 ribu sesi foto, dengan peringkat rata-rata 4,9 dan pengalaman lebih dari
empat tahun. Angka-angka ini adalah pernyataan perusahaan pada situsnya. Pelanggan
menghubungi Photo.Jo terutama melalui WhatsApp, dan merek ini juga aktif di Instagram dan
TikTok dengan akun #box(`@photo.jo_official`).

#figure(
  grid(
    columns: (auto, auto), column-gutter: 1.4cm, align: horizon + center,
    image("../../assets/figures/logo-jokeen.png", height: 2.3cm),
    image("../../assets/figures/logo-photojo.png", height: 1.9cm),
  ),
  kind: image,
  supplement: [Gambar],
  caption: [Logo PT Jokeen Solusi Teknologi (kiri) dan Photo.Jo (kanan)],
) <gbr-logo>

=== Lini Produk

Photo.Jo memiliki tiga lini produk yang masing-masing dilayani pada satu halaman situs,
ditambah studio foto yang dikelola sendiri. Ringkasannya ada pada @tbl-lini-produk. Photo.Jo
menyebut ketiganya sebagai satu ekosistem, mulai dari dokumentasi acara hingga unit mandiri
dan aplikasi yang dapat dijalankan pelanggan pada bisnisnya sendiri.

#allow-table-break[#figure(
  caption: [Lini produk Photo.Jo],
  table(
    columns: (2.3cm, 1fr, 2.8cm),
    align: (left, left, left),
    table.header([*Lini produk*], [*Uraian*], [*Harga yang dipublikasikan*]),
    [Jasa _photobooth_],
    [Sewa _photobooth_, _videobooth_ 360, _iPadbooth_, dan _photobox_ untuk pernikahan, ulang
      tahun, dan acara perusahaan. Paket dibagi menurut durasi (Classic, Moderate, Ultimate)
      dan didampingi _keeper_ profesional.],
    [Mulai Rp 1.800.000],

    [Unit _photobox_],
    [Unit _self-service_ siap pakai untuk mal, studio, kafe, hotel, dan lokasi ramai lainnya,
      dengan cetak foto kurang dari 60 detik. Tersedia Kiosk Slim, Velvet Booth, Cabin Booth,
      dan unit _custom_.],
    [Kiosk Slim mulai Rp 29.900.000; Velvet Booth dan Cabin Booth mulai Rp 49.900.000],

    [Aplikasi _photobooth_],
    [Lisensi aplikasi _photobooth_ untuk dipasang pada perangkat milik pelanggan, dengan
      pembayaran QRIS dan voucher, katalog _frame_ dan filter, cetak tambahan, serta panel
      admin. Tersedia tiga paket langganan: Basic, Pro, dan Enterprise.],
    [Rp 99.000, Rp 299.000, dan Rp 799.000 per bulan],

    [Studio foto],
    [Studio yang dikelola Photo.Jo di Tuban, Lamongan, dan Banyuwangi. Pengunjung datang,
      difoto di tempat, dan membawa pulang cetakan.],
    [Belum dipublikasikan],
  ),
) <tbl-lini-produk>]

Situs Photo.Jo menjadi etalase ketiga lini tersebut sekaligus tempat pelanggan memesan jasa
acara. Peran dan rancangan situs dibahas pada Bab IV.

=== Wilayah Layanan dan Studio

Layanan acara Photo.Jo tersedia di Surabaya, Gresik, Tuban, dan Lamongan. Acara di kota lain
dilayani melalui konsultasi lewat WhatsApp. Kantor di Surabaya tidak memiliki studio. Studio
foto berada di Tuban pada gedung tersendiri, di Lamongan pada lantai dua Lamongan Plaza, dan di
Banyuwangi pada lantai satu Sun East Mall Genteng, yang merupakan studio paling baru.

Pada awal pengembangan, pemilik menetapkan kapasitas harian dua acara di Surabaya serta satu
acara di Gresik dan di Tuban, sesuai jumlah kru dan perlengkapan yang dapat diberangkatkan
dalam sehari. Lamongan ditambahkan pada 21 September 2026 melalui panel admin tanpa perubahan
kode, yang menunjukkan bahwa kota layanan kini dapat diatur oleh staf sendiri.

=== Proses Usaha Sebelum Sistem Baru

Sebelum sistem baru, pemesanan jasa acara berjalan seluruhnya melalui percakapan WhatsApp.
Pelanggan menanyakan paket dan ketersediaan tanggal, staf memeriksa jadwal secara manual dan
menyebutkan harga, kemudian invoice disusun pada lembar kerja dan dikirim sebagai berkas.
Pembayaran dilakukan melalui transfer bank dan buktinya diterima staf melalui percakapan.
Tidak ada satu tempat yang merekam seluruh tahapan tersebut. Analisis permasalahan beserta
solusinya diuraikan pada Bab IV.

=== Pemangku Kepentingan dan Peran Penulis

Pengembangan situs melibatkan beberapa pihak. Pemilik Photo.Jo, Ayu Auliya Rahmah, menyampaikan kebutuhan bisnis,
memutuskan aturan usaha seperti kota layanan, kapasitas harian, dan aturan pembayaran, serta
meninjau hasil pada setiap putaran revisi. Manajemen ikut menentukan arah pengembangan,
misalnya keputusan menunda pembayaran otomatis. Staf Photo.Jo menjadi pengguna panel admin
dengan peran operator, admin, atau superadmin. Pembimbing lapangan membimbing pelaksanaan
kerja praktik.

Penulis berperan sebagai _Fullstack Engineer_ sekaligus satu-satunya pengembang. Penulis
bertanggung jawab atas seluruh lapisan sistem, yaitu perancangan UI/UX dan desain visual,
pengembangan sisi klien dengan HTML, CSS, dan JavaScript, pengembangan sisi server pada
Supabase (basis data PostgreSQL, kebijakan akses, fungsi, dan _Edge Function_), pemodelan 3D
unit _photobox_ pada Blender berdasarkan unit yang telah dirancang Photo.Jo, serta penerapan ke lingkungan produksi pada Vercel. Aset merek
seperti logo, foto unit, dan referensi tampilan aplikasi berasal dari Photo.Jo dan tidak dibuat
oleh penulis.

== Lokasi

PT Jokeen Solusi Teknologi berlokasi di #data.instansi.alamat, Kalisari, Kecamatan Mulyorejo,
Kota Surabaya. Jam layanan yang dicantumkan pada situs perusahaan adalah Senin sampai Sabtu
pukul 09.00 sampai 19.00 @jokeen-id.
