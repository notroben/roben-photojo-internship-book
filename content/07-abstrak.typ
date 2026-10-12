// ============================================================
// WAJIB EDIT — Abstrak laporan (sekitar 150–250 kata) + kata kunci.
// ============================================================

#import "../template/lib.typ": *

// ISI ABSTRAK — EDIT DI SINI
// Ringkas: latar belakang, tujuan, metode, hasil, kesimpulan.
#let isi-abstrak = [
  Photo.Jo adalah merek di bawah PT Jokeen Solusi Teknologi di bidang fotografi dan _photobox_
  yang informasi harga, ketersediaan tanggal, pemesanan, dan penagihannya hampir seluruhnya
  ditangani staf secara manual melalui WhatsApp. Kerja praktik ini bertujuan membangun situs
  web Photo.Jo yang informatif, interaktif, dan dapat dipakai pada ponsel, dilengkapi sistem
  pemesanan dan penagihan yang menghitung harga di server, panel admin berbasis peran, serta
  model 3D tiga unit _photobox_. Situs dibangun sebagai halaman statis dengan Supabase
  (PostgreSQL) sebagai basis data, autentikasi, dan penyimpanan; hak akses ditegakkan oleh
  _Row Level Security_ dan aturan bisnis dijalankan oleh fungsi pada basis data, sedangkan
  model 3D dibuat di Blender. Pengujian tiga lapis menemukan lima temuan keamanan dan tiga
  temuan fungsional yang seluruhnya diperbaiki sehingga keenam kriteria pengujian terpenuhi.
  Hasilnya, pelanggan dapat melihat harga, memilih tanggal, dan menerima invoice bernomor
  tanpa menunggu staf, dan staf dapat mengelola harga dan konten tanpa pengembang.
]

// KATA KUNCI — EDIT DI SINI (3–5 kata, boleh pakai _miring_)
#let kata-kunci = ([Photo.Jo], [situs web], [Supabase], [Row Level Security], [model 3D])

// ============================================================
// Tata letak — tidak perlu diedit
// ============================================================

#let halaman-abstrak(data) = {
  // Penanda untuk DAFTAR ISI — tidak tampil di halaman
  {
    show heading: none
    heading(level: 1, outlined: true, numbering: none)[ABSTRAK]
  }

  set par(first-line-indent: 0pt, justify: false)

  align(center, text(size: 12pt, weight: "bold")[#data.judul])
  v(0.7cm)

  entry-fields(
    (
      ([Nama Mahasiswa], [#data.mahasiswa.nama]),
      ([NRP], [#data.mahasiswa.nrp]),
      ([Departemen], [#data.institusi.departemen]),
      ([Pembimbing Departemen], [#data.pembimbing-departemen.nama]),
      ([Pembimbing Lapangan], [#data.pembimbing-lapangan.nama]),
    ),
    col-widths: (4cm, 0.3cm, 1fr),
  )

  v(0.8cm)
  align(center, text(size: 12pt, weight: "bold")[ABSTRAK])
  v(0.5cm)

  set par(justify: true, first-line-indent: 1.25cm)
  isi-abstrak

  v(0.6cm)
  set par(first-line-indent: 0pt, justify: false)
  text(weight: "bold", style: "italic")[Kata Kunci: #kata-kunci.join(", ")]
}
