// ============================================================
// BAB II PROFIL PERUSAHAAN
// Profil PT Jokeen Solusi Teknologi bersumber dari jokeen.id dan ITS News;
// uraian Photo.Jo bersumber dari situs dan dokumen rancangan Photo.Jo.
// ============================================================

#import "../../template/lib.typ": *
#import "../diagram/_lib.typ": gambar-diagram
#import "../diagram/profil.typ": diagram-posisi-photojo
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

Bab ini menguraikan profil PT Jokeen Solusi Teknologi dan Photo.Jo sebagai produk yang
menjadi objek pekerjaan. Uraian perusahaan dibuat ringkas dan pembahasan lebih banyak
diarahkan pada Photo.Jo.

== Profil #data.instansi.nama

PT Jokeen Solusi Teknologi beroperasi dengan nama Jokeen Indonesia atau Jokeen.id, yaitu
perusahaan rintisan (_startup_) di bidang rekayasa teknik dengan layanan desain teknik,
_3D printing_, _computer numerical control_ (CNC), dan pengembangan _Internet of Things_
(IoT) @jokeen-id.

=== Sejarah dan Bidang Usaha

Jokeen.id dirintis sejak 2020 oleh Puguh Pambudi dan Muhammad Husnir Rahman, dua mahasiswa
Teknik Mesin ITS angkatan 2018, untuk membantu industri kecil mewujudkan ide di bidang IoT
@its-jokeen-2021. Layanannya berkembang dari desain produk mekanik dan prototipe sederhana
menjadi manufaktur presisi, mekatronika, dan IoT @jokeen-sejarah, dengan produksi massal dan
konsultasi teknis @jokeen-produk. Pada tahun 2021 perusahaan telah menyelesaikan lebih dari
100 proyek dan tercatat sebagai penyewa Inkubator ITS @its-jokeen-2021.

=== Visi dan Misi

*Visi.* Menjadi _startup engineering_ terdepan di Indonesia yang mampu menghadirkan solusi
rekayasa produk berkualitas tinggi dan berkelanjutan @jokeen-id.

*Misi.*

+ Mengembangkan layanan _engineering_ yang inovatif, efisien, dan terintegrasi.
+ Mendorong lahirnya produk berbasis teknologi yang mampu bersaing secara nasional dan global.
+ Mengutamakan kualitas, profesionalisme, dan kepuasan klien.

== Photo.Jo sebagai Produk PT Jokeen Solusi Teknologi

=== Gambaran Umum

Photo.Jo adalah merek di bawah PT Jokeen Solusi Teknologi di bidang fotografi dan _photobox_.
Invoice Photo.Jo mencantumkan PT Jokeen Solusi Teknologi sebagai badan usaha dan Photo.Jo
sebagai nama dagang. Unit _photobox_ yang disewakan maupun dijual dirancang dan dibuat oleh
para _engineer_ Photo.Jo, secara internal maupun melalui pihak ketiga. Posisi dan logo
Photo.Jo ditunjukkan pada @gbr-posisi-photojo dan @gbr-logo. Pada halaman berandanya,
Photo.Jo menyebut telah melayani lebih dari 1.000 acara dengan peringkat rata-rata 4,9.

#gambar-diagram(
  diagram-posisi-photojo(),
  caption: [Posisi Photo.Jo dan lini produknya di bawah PT Jokeen Solusi Teknologi],
) <gbr-posisi-photojo>

#figure(
  grid(
    columns: (auto, auto), column-gutter: 1.4cm, align: horizon + center,
    image("../../assets/figures/logo-jokeen.png", height: 1.9cm),
    image("../../assets/figures/logo-photojo.png", height: 1.6cm),
  ),
  kind: image,
  supplement: [Gambar],
  placement: auto,
  caption: [Logo PT Jokeen Solusi Teknologi (kiri) dan Photo.Jo (kanan)],
) <gbr-logo>

=== Pemangku Kepentingan dan Peran Penulis

Pemilik Photo.Jo, Ayu Auliya Rahmah, menyampaikan kebutuhan bisnis dan meninjau hasil pada
setiap putaran revisi, dengan dukungan manajemen. Staf menjadi pengguna panel admin. Penulis
berperan sebagai _Fullstack Engineer_ sekaligus satu-satunya pengembang, yang mengerjakan
perancangan UI/UX, sisi klien dan server, pemodelan 3D unit, serta penerapan. Logo, foto unit,
dan referensi tampilan aplikasi berasal dari Photo.Jo.

=== Lini Produk

Photo.Jo memiliki tiga lini produk dan studio foto yang dikelola sendiri (@tbl-lini-produk).

#figure(
  caption: [Lini produk Photo.Jo],
  table(
    columns: (2.3cm, 1fr, 2.8cm),
    align: (left, left, left),
    table.header([*Lini produk*], [*Uraian*], [*Harga yang dipublikasikan*]),
    [Jasa _photobooth_],
    [Sewa _photobooth_, _videobooth_ 360, _iPadbooth_, dan _photobox_ untuk acara di
      Surabaya, Gresik, Tuban, dan Lamongan.],
    [Mulai Rp 1.800.000],

    [Unit _photobox_],
    [Unit _self-service_ untuk mal, studio, kafe, dan hotel: Kiosk Slim, Velvet Booth, Cabin
      Booth, dan unit _custom_.],
    [Mulai Rp 29.900.000 (Kiosk Slim) dan Rp 49.900.000 (booth tertutup)],

    [Aplikasi _photobooth_],
    [Lisensi aplikasi dengan pembayaran QRIS dan voucher, katalog _frame_ dan filter, serta
      panel admin.],
    [Rp 99.000 sampai Rp 799.000 per bulan],

    [Studio foto],
    [Studio di Tuban, Lamongan, dan Banyuwangi tempat pengunjung difoto dan membawa pulang
      cetakan.],
    [Berbeda di tiap studio, mulai dari sekitar Rp 25.000],
  ),
) <tbl-lini-produk>

== Lokasi

PT Jokeen Solusi Teknologi berlokasi di #data.instansi.alamat, Kalisari, Kecamatan Mulyorejo,
Kota Surabaya. Jam layanan yang dicantumkan pada situs perusahaan adalah Senin sampai Sabtu
pukul 09.00 sampai 19.00 @jokeen-id.
