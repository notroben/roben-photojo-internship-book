// ============================================================
// Diagram Bab II: struktur organisasi PT Jokeen Solusi Teknologi dan
// posisi Photo.Jo di dalamnya.
// ============================================================

#import "_lib.typ": *

// Simpul penghubung tak terlihat untuk garis batang bagan organisasi.
#let sambungan(pos, name) = node(
  pos, [], name: name, shape: shapes.rect, stroke: none, fill: none,
  inset: 0pt, width: 0.1pt, height: 0.1pt,
)

// Bagan organisasi menurut daftar jabatan yang dipublikasikan pada jokeen.id.
#let diagram-struktur-jokeen() = {
  let div(pos, teks, name) = node(
    pos, align(center, text(size: 7pt, teks)), name: name, width: 18.5mm, height: 11mm,
  )
  diagram(
    spacing: (2.5mm, 6mm),
    node-stroke: garis, node-fill: white, node-corner-radius: 2pt, node-inset: 3pt,
    node-shape: shapes.rect,

    node((2, 0), [*Founder / Owner*], name: <fo>, fill: teal-muda, width: 34mm),
    node((2, 1), [*CEO / Ketua*], name: <ceo>, width: 34mm),
    node((3.75, 1), [Wakil Ketua], name: <wk>, width: 24mm),
    edge(<fo>, <ceo>, "-"),
    edge(<ceo>, <wk>, "-"),

    // Batang utama dengan dua jabatan staf di sisinya
    sambungan((2, 2), <j1>),
    node((0.55, 2), [Sekretaris], name: <sek>, width: 24mm),
    node((3.45, 2), [Bendahara], name: <ben>, width: 24mm),
    edge(<ceo>, <j1>, "-"),
    edge(<j1>, <sek>, "-"),
    edge(<j1>, <ben>, "-"),

    // Garis batang menuju lima divisi
    sambungan((2, 3), <b3>),
    sambungan((0, 3), <b1>),
    sambungan((1, 3), <b2>),
    sambungan((3, 3), <b4>),
    sambungan((4, 3), <b5>),
    edge(<j1>, <b3>, "-"),
    edge(<b1>, <b2>, "-"),
    edge(<b2>, <b3>, "-"),
    edge(<b3>, <b4>, "-"),
    edge(<b4>, <b5>, "-"),

    div((0, 3.9), [Divisi\ Kreatif], <d1>),
    div((1, 3.9), [Divisi\ Produksi], <d2>),
    div((2, 3.9), [Divisi\ Marketing\ dan Media], <d3>),
    div((3, 3.9), [Divisi\ Operasional], <d4>),
    div((4, 3.9), [Divisi\ Humas dan\ Kerja Sama], <d5>),
    edge(<b1>, <d1>, "-"),
    edge(<b2>, <d2>, "-"),
    edge(<b3>, <d3>, "-"),
    edge(<b4>, <d4>, "-"),
    edge(<b5>, <d5>, "-"),
  )
}

// Posisi Photo.Jo sebagai salah satu merek produk PT Jokeen Solusi Teknologi.
#let diagram-posisi-photojo() = {
  let anak(pos, judul, ket, name) = node(
    pos, align(center)[*#judul*\ #text(size: 7pt, ket)], name: name, width: 44mm,
  )
  let kepala(pos, teks, name) = node(
    pos, align(center, teks), name: name, stroke: none, fill: none, inset: 0pt, width: 44mm,
  )
  diagram(
    spacing: (7mm, 4mm),
    node-stroke: garis, node-fill: white, node-corner-radius: 2.5pt, node-inset: 4pt,
    node-shape: shapes.rect,

    node((0.5, 0), [*PT Jokeen Solusi Teknologi*], name: <pt>, fill: abu2, width: 56mm),
    sambungan((0.5, 0.75), <s0>),
    sambungan((0, 0.75), <sa>),
    sambungan((1, 0.75), <sb>),
    edge(<pt>, <s0>, "-"),
    edge(<sa>, <s0>, "-"),
    edge(<s0>, <sb>, "-"),

    // Cabang jasa rekayasa teknik
    kepala((0, 1.55), [*Jokeen Indonesia*\ jasa rekayasa teknik], <jkh>),
    anak((0, 2.55), [Desain teknik], [produk mekanik dan mekatronika], <j1>),
    anak((0, 3.55), [Prototipe dan manufaktur], [3D printing, laser cutting, CNC], <j2>),
    anak((0, 4.55), [Mekatronika dan IoT], [sensor, kontrol, data _real-time_], <j3>),
    node(
      enclose: (<jkh>, <j1>, <j2>, <j3>), name: <jk>,
      stroke: putus, fill: abu, inset: 6pt, corner-radius: 3pt,
    ),

    // Cabang Photo.Jo
    kepala((1, 1.55), [*Photo.Jo*\ merek produk fotografi dan _photobox_], <pjh>),
    anak((1, 2.55), [Jasa _photobooth_], [sewa untuk acara], <p1>),
    anak((1, 3.55), [Unit _photobox_], [dijual kepada calon pemilik usaha], <p2>),
    anak((1, 4.55), [Aplikasi _photobooth_], [lisensi langganan bulanan], <p3>),
    anak((1, 5.55), [Studio foto], [Tuban, Lamongan, Banyuwangi], <p4>),
    node(
      enclose: (<pjh>, <p1>, <p2>, <p3>, <p4>), name: <pj>,
      stroke: 1.1pt + black, fill: teal-muda, inset: 6pt, corner-radius: 3pt,
    ),

    edge(<sa>, <jk>, "->"),
    edge(<sb>, <pj>, "->"),
  )
}
