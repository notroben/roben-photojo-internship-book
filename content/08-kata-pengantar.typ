// ============================================================
// WAJIB EDIT — Kata pengantar. Ganti isi ucapan terima kasih.
// ============================================================

#import "../template/lib.typ": *

#let kata-pengantar(data) = {
  headz[KATA PENGANTAR]
  v(0.8cm)
  set par(justify: true, first-line-indent: 1.25cm)

  [
    Puji syukur penulis panjatkan kepada Tuhan Yang Maha Esa atas karunia-Nya sehingga
    penulis dapat menyelesaikan Laporan Kerja Praktik yang berjudul:
    "#data.judul".

    Penulis menyadari masih banyak kekurangan pada laporan ini dan berharap laporan ini
    bermanfaat bagi pembaca.

    Penulis ingin menyampaikan rasa terima kasih kepada:
  ]

  set par(first-line-indent: 0pt)
  enum(
    [Bapak #data.pembimbing-departemen.nama selaku dosen pembimbing departemen.],
    [Bapak #data.pembimbing-lapangan.nama selaku pembimbing lapangan selama
      kerja praktik berlangsung.],
    [Ayu Auliya Rahmah selaku pemilik Photo.Jo atas kesempatan dan peninjauan hasil.],
  )

  v(0.8cm)
  align(right)[#data.institusi.kota, #data.tanggal-laporan]
  v(1.6cm)
  align(right)[#data.mahasiswa.nama]
}
