// ============================================================
// Pustaka bantu diagram — dipakai oleh semua berkas di folder ini.
// Diagram digambar dengan paket fletcher (diunduh otomatis oleh Typst
// pada kompilasi pertama). Teks diagram mengikuti huruf dokumen.
// ============================================================

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz:0.3.4"
#import fletcher.shapes

// Ukuran huruf di dalam diagram; diagram otomatis diperkecil bila melebihi lebar kolom.
#let ukuran = 8pt
#let garis = 0.6pt + black
#let garis-tipis = 0.4pt + black
#let abu = luma(244)
#let abu2 = luma(225)
#let teal = rgb("#2d7d6f")
#let teal-muda = rgb("#e3f3ef")
#let putus = (dash: "dashed", paint: black, thickness: 0.6pt)

// Kecilkan diagram agar muat dalam lebar kolom (tidak pernah membesarkan).
#let muat(body) = layout(size => {
  let m = measure(body)
  let k = if m.width > size.width { size.width / m.width * 100% } else { 100% }
  align(center, scale(k, reflow: true, body))
})

// Pembungkus gambar: ikut Daftar Gambar dan penomoran per bab milik template.
#let gambar-diagram(body, caption: "") = figure(
  muat({
    // Template memakai teks rata kiri-kanan; di dalam diagram itu merusak spasi kata.
    set par(justify: false, leading: 0.55em, spacing: 0pt)
    set text(size: ukuran)
    show raw: set text(size: 0.85em)
    body
  }),
  kind: image,
  supplement: [Gambar],
  caption: caption,
)

// ---- Elemen ERD --------------------------------------------------------
// Atribut ditulis "PK id", "FK service_id", "PK,FK order_id" atau "nama".
#let entitas(nama, lebar: 31mm, ..atribut) = {
  let baris = atribut.pos().map(a => {
    let bagian = a.split(" ")
    if bagian.at(0) in ("PK", "FK", "PK,FK") {
      (text(size: 6pt, weight: "bold")[#bagian.at(0)], bagian.slice(1).join(" "))
    } else { ([], a) }
  }).flatten()
  box(stroke: garis, fill: white, radius: 1.5pt, width: lebar, clip: true, {
    set block(spacing: 0pt)
    block(fill: abu2, width: 100%, inset: (x: 3pt, y: 2.5pt), align(center, strong(nama)))
    line(length: 100%, stroke: garis-tipis)
    block(inset: (x: 3pt, y: 2.5pt), grid(
      columns: (auto, 1fr), column-gutter: 3pt, row-gutter: 1.8pt, align: left, ..baris,
    ))
  })
}
// shape: rect wajib. Dengan shape otomatis, fletcher memilih lingkaran untuk
// kotak yang hampir persegi dan garis relasi terpotong di tempat yang salah.
#let ent(pos, nama, ..atribut, name: none, lebar: 31mm) = node(
  pos, entitas(nama, lebar: lebar, ..atribut),
  name: name, stroke: none, fill: none, inset: 0pt, shape: shapes.rect,
)

// ---- Elemen use case ---------------------------------------------------
// Aktor: figur batang dengan nama di bawahnya.
#let aktor(nama) = stack(dir: ttb, spacing: 2pt,
  cetz.canvas(length: 1mm, {
    import cetz.draw: *
    circle((0, 7.5), radius: 1.6, stroke: garis, fill: white)
    line((0, 5.9), (0, 2.2), stroke: garis)
    line((-2.6, 4.6), (2.6, 4.6), stroke: garis)
    line((0, 2.2), (-2.2, -1), stroke: garis)
    line((0, 2.2), (2.2, -1), stroke: garis)
  }),
  align(center, text(size: 7.5pt, weight: "bold", nama)))

// Use case berbentuk oval (pil), ukuran seragam.
#let uc(pos, teks, name: none, lebar: 50mm, tinggi: 7mm) = node(
  pos, teks, name: name, shape: shapes.pill, width: lebar, height: tinggi,
  stroke: garis, fill: white, inset: 2pt,
)
#let stereotipe(t) = text(size: 6.5pt, style: "italic")[#t]

// ---- Elemen diagram alur -----------------------------------------------
#let proses(pos, teks, name: none, lebar: 50mm, ..a) = node(
  pos, teks, name: name, shape: shapes.rect, width: lebar,
  stroke: garis, fill: white, corner-radius: 2pt, inset: 4pt, ..a,
)
#let ujung(pos, teks, name: none) = node(
  pos, teks, name: name, shape: shapes.pill, stroke: garis, fill: abu, inset: 4pt,
)
#let cabang(pos, teks, name: none, lebar: 36mm) = node(
  pos, teks, name: name, shape: shapes.rect, width: lebar,
  stroke: putus, fill: abu, corner-radius: 2pt, inset: 3.5pt,
)
