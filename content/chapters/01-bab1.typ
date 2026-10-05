// ============================================================
// BAB I PENDAHULUAN
// Diagram metodologi dirakit dari content/diagram/metodologi.typ.
// ============================================================

#import "../../template/lib.typ": *
#import "../diagram/_lib.typ": gambar-diagram
#import "../diagram/metodologi.typ": diagram-metodologi
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
Asosiasi Penyelenggara Jasa Internet Indonesia (APJII) mencatat bahwa penetrasi internet di
Indonesia pada tahun 2024 mencapai 79,5% @apjii-2024. Bagi usaha yang menjual jasa, termasuk
jasa dokumentasi foto dan _photobooth_, situs web menjadi salah satu tempat pertama calon
pelanggan menilai sebuah usaha. Mereka ingin mengetahui apa yang ditawarkan, berapa harganya,
seperti apa hasilnya, dan apakah tanggal acara mereka masih tersedia.

Photo.Jo adalah merek di bawah PT Jokeen Solusi Teknologi yang bergerak di bidang fotografi
dan _photobox_. Photo.Jo memiliki tiga lini produk, yaitu jasa _photobooth_ yang disewa untuk
acara, unit _photobox_ yang dijual kepada calon pemilik usaha, dan aplikasi _photobooth_ yang
dilisensikan. Layanan acara tersedia di Surabaya, Gresik, Tuban, dan Lamongan, dan Photo.Jo
juga mengelola studio foto di Tuban, Lamongan, dan Banyuwangi. Pada halaman beranda situsnya,
Photo.Jo menyebut telah melayani lebih dari seribu acara. Gambaran lengkap tentang perusahaan
dan produknya dibahas pada Bab II.

Pertumbuhan usaha tersebut belum diimbangi sistem yang mendukung. Informasi harga,
ketersediaan tanggal, pemesanan, dan penagihan hampir seluruhnya ditangani staf secara manual
melalui WhatsApp. Pelanggan tidak dapat mengetahui apakah suatu tanggal masih tersedia sebelum
bertanya, sehingga staf menjawab pertanyaan yang sama berulang kali dan pemesanan ganda pada
tanggal yang sama sulit dicegah. Invoice disusun satu per satu pada lembar kerja. Dari delapan
contoh invoice yang ditinjau penulis, ditemukan satu nomor invoice yang dipakai pada dua
pelanggan berbeda dan format nomor yang tidak seragam. Pembayaran dan sisa tagihan pun hanya tercatat dalam percakapan sehingga
sulit ditelusuri. Selain itu, situs yang ada hanya berfungsi sebagai media informasi. Setiap
perubahan harga, promosi, atau foto galeri harus dikerjakan pengembang melalui perubahan kode
dan penerapan ulang.

Untuk menjawab kebutuhan tersebut, Photo.Jo menetapkan _Fokus Pengembangan 01: Website Baru
Photo.Jo_. Dokumen itu meminta situs dibangun ulang dari konsep dan desain yang sepenuhnya
baru, bukan melanjutkan situs lama, dengan tampilan yang menarik, mencerminkan merek Photo.Jo,
dan berfungsi mendukung pertumbuhan usaha. Fitur yang diminta meliputi pemesanan unit untuk
acara langsung dari situs, galeri hasil foto dan etalase unit, informasi lokasi dan daftar
harga, serta penampil 3D interaktif untuk setiap varian unit _photobox_. Rencana kerjanya
berlangsung tiga bulan. Bulan pertama untuk riset, konsep, dan desain, bulan kedua untuk
halaman inti dan penampil 3D, dan bulan ketiga untuk pemesanan, pengujian, dan penerapan.

Pekerjaan inilah yang menjadi bahan kerja praktik penulis. Penulis bertugas sebagai
_Fullstack Engineer_ dan mengerjakannya seorang diri, mulai dari perancangan antarmuka,
pengembangan sisi klien dan sisi server, pemodelan 3D unit _photobox_, hingga penerapan ke
lingkungan produksi. Seiring berjalannya pengerjaan dan diskusi dengan pemilik, cakupan tumbuh
dari situs informasi menjadi sistem yang juga menangani pemesanan, penagihan, dan pengelolaan
konten melalui panel admin. Masalah ini perlu diselesaikan karena setiap pertanyaan yang
dijawab manual menyita waktu staf, setiap pemesanan ganda merugikan pelanggan dan usaha, dan
setiap perubahan harga yang menunggu pengembang memperlambat usaha yang kebutuhannya terus
berubah.

== Tujuan

Tujuan kerja praktik ini adalah menyelesaikan kewajiban mata kuliah Kerja Praktik
(#data.kode-mk) sebesar #data.sks sks dan menghasilkan sistem web Photo.Jo yang dapat
digunakan oleh pelanggan dan staf. Secara khusus, tujuan tersebut adalah sebagai berikut:

+ Membangun situs publik Photo.Jo yang menyajikan tiga lini produk secara informatif dan
  interaktif.
+ Membangun sistem pemesanan dan penagihan yang menghitung harga di sisi server, menjaga
  kapasitas tanggal, dan menerbitkan invoice bernomor.
+ Membangun panel admin berbasis peran agar staf dapat mengelola harga, promosi, kalender,
  pesanan, pembayaran, dan konten tanpa bantuan pengembang.
+ Memodelkan tiga unit _photobox_ secara tiga dimensi dan menampilkannya pada situs.
+ Menjaga keamanan data pelanggan dan staf, serta menerapkan sistem ke lingkungan produksi.

== Manfaat

Kerja praktik ini diharapkan memberi manfaat bagi tiga pihak berikut.

+ *Bagi mahasiswa.* Penulis memperoleh pengalaman menjalankan siklus pengembangan secara utuh
  pada kebutuhan nyata, mulai dari menggali kebutuhan pemilik, merancang basis data dan
  keamanan, membangun antarmuka dan logika bisnis, hingga menerapkan sistem dan menerima
  putaran revisi. Pengalaman ini mempertemukan ilmu perkuliahan dengan batasan usaha yang
  sebenarnya, seperti biaya, waktu, dan perangkat yang dipakai staf.
+ *Bagi Photo.Jo dan PT Jokeen Solusi Teknologi.* Pelanggan dapat melihat harga, mencoba
  layanan, memilih tanggal, dan menerima invoice tanpa menunggu balasan staf. Staf memperoleh
  data pesanan, pembayaran, dan calon pelanggan yang tercatat rapi, dapat mengubah harga dan
  konten tanpa pengembang, serta terhindar dari pemesanan ganda dan nomor invoice kembar.
  Situs baru juga memperkuat citra merek.
+ *Bagi masyarakat.* Calon pelanggan memperoleh informasi harga dan ketersediaan yang
  transparan setiap saat, dapat memeriksa invoice melalui tautan pribadi, dan dapat mencoba
  pembuatan _photostrip_ yang diproses sepenuhnya di peramban tanpa mengunggah foto ke server.

== Rumusan Masalah

Rumusan masalah dari kerja praktik ini adalah sebagai berikut:

+ Bagaimana merancang dan membangun situs publik Photo.Jo yang menyajikan tiga lini produk
  secara informatif dan interaktif serta nyaman dipakai pada ponsel?
+ Bagaimana merancang sistem pemesanan dan penagihan yang menghitung harga di sisi server,
  menjaga kapasitas tanggal agar tidak terjadi pemesanan ganda, dan menerbitkan invoice
  bernomor yang dapat ditelusuri?
+ Bagaimana merancang panel admin dengan pembagian peran dan jejak perubahan sehingga staf
  dapat mengelola harga, kalender, pesanan, dan konten tanpa bantuan pengembang?
+ Bagaimana memodelkan unit _photobox_ secara tiga dimensi dan menampilkannya pada peramban
  dengan ukuran berkas yang ringan?
+ Bagaimana menjaga keamanan data pelanggan dan staf, serta menerapkan sistem pada lingkungan
  produksi?

Pekerjaan dibatasi pada hal-hal berikut:

- Pembayaran oleh pelanggan dicatat manual oleh staf. Gerbang pembayaran otomatis (Midtrans
  dengan QRIS) telah dirancang tetapi tidak dibangun atas keputusan pemilik dan manajemen.
- Pemesanan otomatis hanya tersedia untuk jasa acara di kota yang dilayani. Layanan
  _Photobox_, pembelian unit, langganan aplikasi, dan kota lain dilayani melalui konsultasi
  WhatsApp.
- Simulator aplikasi _photobooth_ hanya memperagakan alur aplikasi di peramban. Aplikasi
  _photobooth_ yang dipakai unit tidak dikembangkan dalam kerja praktik ini.
- Pemodelan 3D mencakup tiga unit, yaitu Kiosk Slim, Velvet Booth, dan Cabin Booth. Unit
  _custom_ belum memiliki model.

== Lokasi dan Waktu Kerja Praktik

Kerja Praktik dilaksanakan di #data.instansi.nama, berlokasi di
#data.instansi.alamat.

Pelaksanaan dimulai pada tanggal #data.periode.mulai hingga #data.periode.selesai, yaitu
sekitar empat belas pekan. Selama pelaksanaan, penulis dibimbing oleh
#data.pembimbing-lapangan.nama sebagai pembimbing lapangan dan #data.pembimbing-departemen.nama
sebagai pembimbing departemen. Kegiatan penulis terbagi menjadi sebelas tahap kerja yang
ditunjukkan pada @tbl-lini-masa. Urutan dan lamanya disusun dari riwayat pengerjaan pada
repositori Git dan dokumen rancangan teknis.

#let kegiatan = (
  ([Riset, konsep, dan perancangan antarmuka], (0, 2)),
  ([Situs publik: Home, _photostrip_, dan galeri polaroid], (3, 4)),
  ([Halaman Photobox, Application, dan Service], (4, 5)),
  ([Pemodelan 3D tiga unit _photobox_], (6, 7)),
  ([Perancangan sistem pemesanan dan panel admin], (5, 7)),
  ([Basis data, autentikasi, dan panel admin (Fase 0 dan 1)], (7, 8)),
  ([Harga, promosi, dan kalender ketersediaan (Fase 2)], (8, 8)),
  ([Media dan ulasan (Fase 3)], (9, 9)),
  ([Jendela pemesanan, pembayaran, invoice, dan voucher (Fase 4)], (10, 14)),
  ([Peninjauan keamanan dan pengujian], (7, 14)),
  ([Persiapan penerapan ke produksi], (12, 14)),
)
#let n-pekan = 15

#figure(
  caption: [Lini masa pelaksanaan kerja praktik (pekan ke-1 dimulai 22 Juni 2026)],
  table(
    columns: (0.7cm, 1fr) + n-pekan * (0.36cm,),
    align: (center, left) + n-pekan * (center,),
    inset: (x: 2pt, y: 3.5pt),
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

Metodologi dalam pembuatan laporan kerja praktik meliputi enam tahap yang ditunjukkan pada
@gbr-metodologi. Pengerjaan berjalan per fase, sehingga temuan pengujian dan revisi dari
pemilik kembali ke tahap analisis dan perancangan.

#gambar-diagram(diagram-metodologi(), caption: [Tahapan metodologi kerja praktik]) <gbr-metodologi>

=== Perumusan Masalah

Perumusan masalah dimulai dari dokumen _Fokus Pengembangan 01: Website Baru Photo.Jo_ yang
memuat arah dan fitur situs baru. Penulis kemudian mempelajari situs lama pada
#box(`photojo.id/home`) sebagai acuan merek, isi tulisan, dan identitas visual, serta
berdiskusi dengan pemilik Photo.Jo dan pembimbing lapangan. Proses usaha yang berjalan
ditelusuri bersama pemilik, termasuk melalui tinjauan terhadap delapan contoh invoice yang
selama ini dibuat. Hasilnya adalah daftar permasalahan pada Bab IV dan batasan pekerjaan pada
subbab Rumusan Masalah.

=== Studi Literatur

Studi literatur dilakukan pada teknologi yang dipakai untuk menyelesaikan masalah, yaitu
HTML, CSS, dan JavaScript tanpa _framework_ dan tanpa tahap _build_ untuk situs statis;
PostgreSQL beserta _Row Level Security_ (RLS); platform Supabase yang mencakup PostgREST,
GoTrue untuk autentikasi, _Storage_, dan _Edge Function_; hosting Vercel; antarmuka peramban
seperti kamera, kanvas, dan _Pointer Events_; format glTF dengan pustaka `<model-viewer>` dan
perangkat lunak Blender untuk pemodelan 3D; serta keamanan dan aksesibilitas web. Sumber
utamanya adalah dokumentasi resmi masing-masing teknologi, dan dasar teorinya dirangkum pada
Bab III.

=== Analisis dan Perancangan Sistem

Analisis kebutuhan disusun dari dokumen kebutuhan perusahaan, diskusi dengan pemilik, dan
permasalahan proses usaha, lalu dituangkan sebagai kebutuhan fungsional dan nonfungsional,
aktor, dan _use case_. Perancangan mencakup arsitektur _static-first_ dengan Supabase sebagai
_backend_ terkelola, rancangan basis data beserta kebijakan akses, alur pemesanan dan
penagihan, antarmuka, model 3D, dan rencana penerapan. Rancangan dicatat pada dua dokumen
rancangan teknis, yaitu untuk situs publik dan untuk panel admin, yang memuat log keputusan
beserta tanggal dan pihak yang memutuskan. Hasilnya dibahas pada Bab IV.

=== Implementasi Sistem

Implementasi dilakukan secara bertahap. Situs publik dikerjakan lebih dahulu dengan HTML,
CSS, dan JavaScript murni, disusul pemodelan tiga unit _photobox_ pada Blender. Sisi server
kemudian dibangun pada Supabase dalam lima fase, yaitu skema basis data dan autentikasi
(Fase 0), pencatatan calon pelanggan (Fase 1), harga, promosi, dan kalender (Fase 2), media dan
ulasan (Fase 3), serta pemesanan, pembayaran, dan invoice (Fase 4). Setiap perubahan basis
data ditulis sebagai berkas migrasi yang diakhiri pemeriksaan regresi, dan seluruh kode
disimpan pada repositori Git. Hasil pengerjaan ditinjau pemilik melalui putaran revisi pada
situs uji di Vercel. Hasilnya dibahas pada Bab V.

=== Pengujian dan Evaluasi

Pengujian berfokus pada keamanan dan kebenaran logika bisnis. Aturan akses basis data ditinjau
dalam tiga lapis, yaitu tinjauan sumber kebijakan, pemeriksaan permukaan akses anonim pada
proyek Supabase yang sebenarnya, dan pengujian perilaku setiap peran pada tumpukan Supabase
lokal dengan data contoh. Alur pemesanan, pembayaran, dan penerbitan invoice diuji dengan data
contoh yang dibangkitkan skrip, sedangkan tampilan diperiksa pada peramban desktop dan ponsel.
Evaluasi dilakukan bersama pemilik melalui putaran revisi. Hasilnya dibahas pada Bab VI.

=== Kesimpulan dan Saran

Kesimpulan ditarik dengan membandingkan hasil pengerjaan dan pengujian dengan tujuan serta
rumusan masalah. Saran disusun dari batasan pekerjaan dan temuan selama pengerjaan, misalnya
otomatisasi pembayaran yang telah dirancang tetapi belum dibangun. Hasilnya dibahas pada
Bab VII.

== Sistematika Laporan

=== Bab I Pendahuluan

Bab ini berisi latar belakang, tujuan, manfaat, rumusan masalah, lokasi dan waktu kerja
praktik, metodologi, serta sistematika laporan.

=== Bab II Profil Perusahaan

Bab ini berisi profil PT Jokeen Solusi Teknologi, uraian tentang Photo.Jo sebagai produk yang
menjadi objek pekerjaan, serta lokasi pelaksanaan kerja praktik.

=== Bab III Tinjauan Pustaka

Bab ini berisi dasar teori dari teknologi yang digunakan dalam menyelesaikan proyek kerja
praktik, yaitu arsitektur situs statis, basis data PostgreSQL dengan _Row Level Security_,
platform Supabase, hosting Vercel, format glTF dan pemodelan 3D, serta keamanan dan
aksesibilitas web.

=== Bab IV Analisis dan Perancangan Sistem

Bab ini berisi analisis kebutuhan dan perancangan sistem, meliputi permasalahan, kebutuhan
fungsional dan nonfungsional, arsitektur, basis data, keamanan, alur pemesanan dan penagihan,
antarmuka, model 3D, dan rencana penerapan.

=== Bab V Implementasi Sistem

Bab ini berisi uraian tahap-tahap implementasi sistem, yaitu basis data, keamanan, logika bisnis
pada basis data, situs publik, panel admin, pemodelan 3D, dan penerapan ke lingkungan produksi.

=== Bab VI Pengujian dan Evaluasi

Bab ini berisi hasil pengujian dan evaluasi dari sistem yang telah dikembangkan.

=== Bab VII Kesimpulan dan Saran

Bab ini berisi kesimpulan dan saran yang didapat dari proses pelaksanaan kerja praktik.
