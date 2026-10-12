// ============================================================
// BAB I PENDAHULUAN
// ============================================================

#import "../../template/lib.typ": *
#let data = yaml("../../data.yaml")

// Tabel pada bab ini: huruf 9 pt dan rata kiri; judul tabel menempel pada baris pertama.
#show figure.where(kind: table): it => {
  show figure.caption: set block(sticky: true)
  it
}
#set table.cell(breakable: false)
#show table: set text(size: 9pt)
#show table: set par(justify: false)

= PENDAHULUAN

== Latar Belakang

Perkembangan teknologi informasi mengubah cara masyarakat mencari dan memesan jasa. Survei
APJII mencatat bahwa penetrasi internet di Indonesia pada tahun 2024 mencapai 79,5%
@apjii-2024. Bagi usaha jasa, termasuk dokumentasi foto dan _photobooth_, situs web menjadi
salah satu tempat pertama calon pelanggan menilai harga, hasil, dan ketersediaan tanggal.

Photo.Jo adalah merek di bawah PT Jokeen Solusi Teknologi di bidang fotografi dan _photobox_
dengan tiga lini produk: jasa _photobooth_ untuk acara, unit _photobox_ yang dijual kepada
calon pemilik usaha, dan aplikasi _photobooth_ yang dilisensikan (profil lengkap pada Bab II).
Namun informasi harga, ketersediaan tanggal, pemesanan, dan penagihan hampir seluruhnya
ditangani staf secara manual melalui WhatsApp. Pelanggan tidak dapat melihat ketersediaan
tanggal sebelum bertanya, pemesanan ganda sulit dicegah, dan invoice disusun satu per satu pada
lembar kerja. Dari delapan contoh invoice yang ditinjau penulis, satu nomor dipakai pada dua
pelanggan berbeda dan format nomornya tidak seragam. Selain itu, setiap perubahan harga,
promosi, atau foto galeri harus dikerjakan pengembang melalui perubahan kode.

Untuk menjawab kebutuhan tersebut, Photo.Jo menetapkan _Fokus Pengembangan 01: Website Baru
Photo.Jo_, yaitu membangun situs dari konsep dan desain yang sepenuhnya baru dengan fitur
pemesanan unit untuk acara, galeri dan etalase unit, informasi lokasi dan harga, serta penampil
3D interaktif untuk setiap varian unit. Rencananya berlangsung tiga bulan: riset dan desain,
halaman inti dan penampil 3D, lalu pemesanan, pengujian, dan penerapan.

Pekerjaan tersebut menjadi bahan kerja praktik penulis, yang bertugas sebagai _Fullstack
Engineer_ dan mengerjakannya seorang diri, dari perancangan antarmuka, pengembangan sisi klien
dan server, pemodelan 3D, hingga penerapan. Seiring diskusi dengan pemilik, cakupan tumbuh
dari situs informasi menjadi sistem yang juga menangani pemesanan, penagihan, dan pengelolaan
konten melalui panel admin. Masalah ini perlu diselesaikan karena pertanyaan yang dijawab
manual menyita waktu staf, pemesanan ganda merugikan pelanggan dan usaha, dan perubahan harga
yang menunggu pengembang memperlambat usaha.

== Tujuan

Tujuan kerja praktik ini adalah menyelesaikan kewajiban mata kuliah Kerja Praktik
(#data.kode-mk) sebesar #data.sks sks dan menghasilkan sistem web Photo.Jo yang dapat dipakai
pelanggan dan staf. Secara khusus:

+ Membangun situs publik Photo.Jo yang informatif dan interaktif.
+ Membangun sistem pemesanan dan penagihan dengan harga dihitung di server dan invoice
  bernomor.
+ Membangun panel admin berbasis peran agar staf mengelola harga, kalender, pesanan, dan
  konten tanpa pengembang.
+ Memodelkan tiga unit _photobox_ secara 3D untuk situs.
+ Menjaga keamanan data dan menerapkan sistem ke produksi.

== Manfaat

Kerja praktik ini diharapkan bermanfaat bagi tiga pihak berikut.

+ *Bagi mahasiswa.* Pengalaman menjalankan siklus pengembangan yang utuh pada kebutuhan nyata,
  dari menggali kebutuhan pemilik hingga penerapan dan revisi, yang mempertemukan ilmu
  perkuliahan dengan batasan usaha yang sebenarnya.
+ *Bagi Photo.Jo dan PT Jokeen Solusi Teknologi.* Pelanggan dapat melihat harga, memilih
  tanggal, dan menerima invoice tanpa menunggu staf. Staf memperoleh data pesanan yang rapi,
  dapat mengubah harga dan konten tanpa pengembang, dan terhindar dari pemesanan ganda.
+ *Bagi masyarakat.* Calon pelanggan memperoleh harga dan ketersediaan yang transparan setiap
  saat, serta dapat mencoba pembuatan _photostrip_ yang diproses di peramban tanpa mengunggah
  foto.

== Rumusan Masalah

Rumusan masalah dari kerja praktik ini adalah sebagai berikut:

+ Bagaimana membangun situs publik Photo.Jo yang informatif, interaktif, dan nyaman dipakai
  pada ponsel?
+ Bagaimana merancang sistem pemesanan dan penagihan yang menghitung harga di server,
  mencegah pemesanan ganda, dan menerbitkan invoice bernomor yang dapat ditelusuri?
+ Bagaimana merancang panel admin berbasis peran agar staf dapat mengelola harga, kalender,
  pesanan, dan konten tanpa pengembang?
+ Bagaimana memodelkan unit _photobox_ secara 3D dan menampilkannya di peramban dengan berkas
  yang ringan?
+ Bagaimana menjaga keamanan data dan menerapkan sistem ke lingkungan produksi?

Pekerjaan dibatasi sebagai berikut:

- Pembayaran dicatat manual oleh staf; gerbang pembayaran otomatis (Midtrans, QRIS) dirancang
  tetapi tidak dibangun atas keputusan pemilik dan manajemen.
- Pemesanan otomatis hanya untuk jasa acara di kota yang dilayani; layanan _Photobox_,
  pembelian unit, langganan aplikasi, dan kota lain melalui konsultasi WhatsApp.
- Simulator aplikasi hanya memperagakan alur di peramban, dan unit _custom_ belum dimodelkan.

== Lokasi dan Waktu Kerja Praktik

Kerja Praktik dilaksanakan di #data.instansi.nama, berlokasi di #data.instansi.alamat.
Pelaksanaan dimulai pada tanggal #data.periode.mulai hingga #data.periode.selesai, yaitu
sekitar empat belas pekan, dengan bimbingan #data.pembimbing-lapangan.nama (pembimbing
lapangan) dan #data.pembimbing-departemen.nama (pembimbing departemen). Kegiatan terbagi
menjadi sembilan tahap kerja (@tbl-lini-masa) yang disusun dari riwayat repositori Git dan
dokumen rancangan teknis.

#let kegiatan = (
  ([Riset dan desain antarmuka], (0, 2)),
  ([Situs publik (empat halaman)], (3, 5)),
  ([Pemodelan 3D tiga unit], (6, 7)),
  ([Perancangan pemesanan dan panel], (5, 7)),
  ([Basis data dan panel (Fase 0-1)], (7, 8)),
  ([Harga, kalender, konten (Fase 2-3)], (8, 9)),
  ([Pemesanan dan invoice (Fase 4)], (10, 14)),
  ([Tinjauan keamanan dan pengujian], (7, 14)),
  ([Persiapan penerapan], (12, 14)),
)
#let n-pekan = 15

#figure(
  caption: [Lini masa pelaksanaan kerja praktik (pekan ke-1 dimulai 22 Juni 2026)],
  table(
    columns: (0.7cm, 1fr) + n-pekan * (0.33cm,),
    align: (center, left) + n-pekan * (center,),
    inset: (x: 2pt, y: 3pt),
    fill: (x, y) => {
      if y == 0 { luma(225) }
      else if x >= 2 {
        let (_, (a, b)) = kegiatan.at(y - 1)
        if a <= x - 2 and x - 2 <= b { rgb("#2d7d6f").lighten(35%) } else { none }
      } else { none }
    },
    table.header(
      [*No*], [*Kegiatan*],
      ..range(1, n-pekan + 1).map(i => text(size: 7pt)[*#i*]),
    ),
    ..kegiatan.enumerate().map(((i, (judul, _))) => (
      [#(i + 1).], judul, ..n-pekan * ([],),
    )).flatten(),
  ),
) <tbl-lini-masa>

== Metodologi Kerja Praktik

Metodologi dalam pembuatan laporan kerja praktik meliputi:

=== Perumusan Masalah

Masalah dirumuskan dari dokumen _Fokus Pengembangan 01: Website Baru Photo.Jo_, situs lama
pada #box(`photojo.id/home`) sebagai acuan merek, diskusi dengan pemilik dan pembimbing
lapangan, serta tinjauan delapan contoh invoice yang selama ini dibuat.

=== Studi Literatur

Studi literatur dilakukan pada teknologi yang dipakai, yaitu situs statis dengan HTML, CSS,
dan JavaScript; PostgreSQL dengan _Row Level Security_; platform Supabase; Vercel; format glTF
dengan `<model-viewer>` dan Blender; serta keamanan dan aksesibilitas web, terutama dari
dokumentasi resmi masing-masing (Bab III).

=== Analisis dan Perancangan Sistem

Kebutuhan disusun dari diskusi dengan pemilik, lalu dirancang arsitektur _static-first_,
basis data beserta kebijakan akses, alur pemesanan dan penagihan, antarmuka, dan model 3D.
Rancangan dicatat pada dua dokumen teknis beserta log keputusannya (Bab IV).

=== Implementasi Sistem

Situs publik dikerjakan lebih dulu, disusul model 3D dan sisi server pada Supabase dalam lima
fase (Fase 0 sampai 4). Perubahan basis data ditulis sebagai migrasi, seluruh kode disimpan
pada Git, dan hasilnya ditinjau pemilik melalui putaran revisi (Bab V).

=== Pengujian dan Evaluasi

Aturan akses basis data ditinjau dalam tiga lapis: sumber kebijakan, pemeriksaan akses anonim
pada proyek sebenarnya, dan uji peran dengan data contoh lokal. Alur pemesanan dan tampilan
diuji dengan data contoh pada peramban desktop, sedangkan seluruh situs dicoba langsung pada
ponsel sungguhan (iPhone 15 dan Galaxy A32) sepanjang pengembangan (Bab VI).

=== Kesimpulan dan Saran

Kesimpulan ditarik dengan membandingkan hasil dengan tujuan dan rumusan masalah, sedangkan
saran disusun dari batasan pekerjaan dan temuan selama pengerjaan (Bab VII).

== Sistematika Laporan

Laporan ini disusun dalam tujuh bab sebagai berikut.

- *Bab I Pendahuluan.* Latar belakang, tujuan, manfaat, rumusan masalah, lokasi dan waktu,
  metodologi, dan sistematika laporan.
- *Bab II Profil Perusahaan.* Profil PT Jokeen Solusi Teknologi, Photo.Jo sebagai produknya,
  dan lokasi kerja praktik.
- *Bab III Tinjauan Pustaka.* Dasar teori teknologi yang dipakai: situs statis, PostgreSQL
  dengan RLS, Supabase, Vercel, glTF, serta keamanan dan aksesibilitas web.
- *Bab IV Analisis dan Perancangan Sistem.* Analisis kebutuhan serta perancangan arsitektur,
  basis data, keamanan, alur, antarmuka, model 3D, dan penerapan.
- *Bab V Implementasi Sistem.* Pelaksanaan perancangan pada basis data, keamanan, logika
  bisnis, situs publik, panel admin, model 3D, dan penerapan.
- *Bab VI Pengujian dan Evaluasi.* Tujuan, kriteria, skenario, dan hasil pengujian beserta
  temuannya.
- *Bab VII Kesimpulan dan Saran.* Jawaban atas rumusan masalah dan saran pengembangan lanjutan.
