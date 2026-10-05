// ============================================================
// Diagram Bab I: tahapan metodologi kerja praktik.
// ============================================================

#import "_lib.typ": *

#let diagram-metodologi() = {
  let tahap(y, judul, ket, name) = node(
    (0, y), align(center)[*#judul*\ #text(size: 7pt, ket)], name: name, width: 64mm,
  )
  diagram(
    spacing: (9mm, 5mm),
    node-stroke: garis, node-fill: white, node-corner-radius: 2.5pt, node-inset: 4pt,
    node-shape: shapes.rect,

    tahap(0, [Perumusan masalah], [dokumen kebutuhan perusahaan, diskusi dengan pemilik, pengamatan proses usaha], <m1>),
    tahap(1, [Studi literatur], [teknologi web, basis data, keamanan, dan model 3D], <m2>),
    tahap(2, [Analisis dan perancangan sistem], [kebutuhan, arsitektur, basis data, antarmuka], <m3>),
    tahap(3, [Implementasi sistem], [situs publik, basis data, panel admin, model 3D], <m4>),
    tahap(4, [Pengujian dan evaluasi], [peninjauan keamanan, uji peran, uji pada peramban], <m5>),
    tahap(5, [Kesimpulan dan saran], [simpulan terhadap tujuan dan rumusan masalah], <m6>),

    edge(<m1>, <m2>, "->"),
    edge(<m2>, <m3>, "->"),
    edge(<m3>, <m4>, "->"),
    edge(<m4>, <m5>, "->"),
    edge(<m5>, <m6>, "->"),

    // Pengerjaan berjalan per fase: temuan pengujian dan revisi pemilik kembali ke perancangan.
    edge(
      <m5>, (1, 4), (1, 2), <m3>, "->", stroke: putus,
      label: rotate(-90deg, reflow: true, text(size: 7pt)[iterasi per fase]),
      label-fill: true, label-pos: 0.5,
    ),
  )
}
