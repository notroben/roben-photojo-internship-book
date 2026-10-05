// ============================================================
// Diagram alur: pemesanan, status pesanan, peta situs, jalur model 3D.
// ============================================================

#import "_lib.typ": *

// Alur pemesanan oleh pelanggan (jendela pemesanan 6 langkah).
#let diagram-alur-pemesanan() = diagram(
  spacing: (8mm, 5.5mm), edge-stroke: garis, node-shape: shapes.rect,
  ujung((0, 0), [Mulai], name: <mulai>),
  proses((0, 1), [*Langkah 1.* Pilih paket dan add-on], name: <l1>),
  proses((0, 2), [*Langkah 2.* Pilih kota (lokasi acara)], name: <l2>),
  proses((0, 3), [*Langkah 3.* Pilih tanggal pada kalender\ lokasi tersebut], name: <l3>),
  proses((0, 4), [*Langkah 4.* Pilih pembayaran:\ lunas atau DP minimal Rp 500.000], name: <l4>),
  proses((0, 5), [*Langkah 5.* Isi nama dan nomor WhatsApp], name: <l5>),
  proses((0, 6), [*create_order()* di server: validasi ulang, hitung harga, simpan pesanan, terbitkan invoice /01], name: <srv>, fill: teal-muda),
  proses((0, 7), [*Langkah 6.* Tampilkan kode pesanan\ dan tautan invoice], name: <l6>),
  ujung((0, 8), [Selesai], name: <akhir>),

  cabang((1, 1), [Paket Photobox: arahkan ke konsultasi via WhatsApp], name: <c1>),
  cabang((1, 2), [Kota di luar jangkauan: arahkan ke konsultasi via WhatsApp], name: <c2>),
  cabang((1, 3), [Tanggal penuh: tawarkan daftar tunggu (disimpan sebagai lead)], name: <c3>),
  cabang((1, 6), [Ditolak: tampilkan pesan; bila tanggal penuh, kembali ke Langkah 3], name: <c6>),

  edge(<mulai>, <l1>, "->"), edge(<l1>, <l2>, "->"), edge(<l2>, <l3>, "->"), edge(<l3>, <l4>, "->"),
  edge(<l4>, <l5>, "->"), edge(<l5>, <srv>, "->"), edge(<srv>, <l6>, "->"), edge(<l6>, <akhir>, "->"),
  edge(<l1>, <c1>, "-->"), edge(<l2>, <c2>, "-->"), edge(<l3>, <c3>, "-->"), edge(<srv>, <c6>, "-->"),
)

// Diagram status pesanan (state machine).
#let diagram-status-pesanan() = {
  let st(t) = text(size: 7pt, style: "italic")[#t]
  let keadaan(pos, teks, name: none, ..a) = node(pos, teks, name: name, shape: shapes.pill, stroke: garis, fill: white, inset: 5pt, ..a)
  diagram(
    spacing: (15mm, 17mm), edge-stroke: garis, node-shape: shapes.rect,
    node((0, -0.65), [], name: <awal>, shape: shapes.circle, fill: black, width: 3mm, height: 3mm, stroke: none),
    keadaan((0, 0), [Menunggu Bayar\ (`awaiting_payment`)], name: <mb>),
    keadaan((1.2, 0), [DP Diterima\ (`partially_paid`)], name: <dp>),
    keadaan((2.4, 0), [Lunas\ (`paid`)], name: <lunas>, fill: teal-muda),
    keadaan((0, 1.6), [Kedaluwarsa\ (`expired`)], name: <exp>),
    keadaan((1.6, 1.6), [Dibatalkan\ (`cancelled`)], name: <batal>, fill: abu),

    edge(<awal>, <mb>, "->", label: st[`create_order()`], label-side: right),
    edge(<mb>, <dp>, "->", label: st[bayar sebagian], label-side: right),
    edge(<dp>, <lunas>, "->", label: st[pelunasan], label-side: right),
    edge(<mb>, <lunas>, "->", bend: 38deg, label: st[dibayar penuh], label-side: left),
    edge(<mb>, <exp>, "<->", label: st[↓ 48 jam tanpa pembayaran\ ↑ diaktifkan lagi oleh staf], label-side: left),
    edge(<mb>, <batal>, "->"),
    edge(<dp>, <batal>, "->"),
    edge(<lunas>, <batal>, "->", label: st[dibatalkan staf\ (dari keadaan mana pun)], label-side: right, label-pos: 0.5),
  )
}

// Peta situs: dua nama domain beserta halamannya.
#let diagram-peta-situs() = {
  let halaman(nama, berkas) = box(stroke: garis, fill: white, radius: 2pt, width: 100%, inset: (x: 4pt, y: 3pt))[#strong(nama) #h(1fr) #text(size: 7pt, berkas)]
  let kolom(judul, ..isi) = box(stroke: putus, fill: abu, radius: 3pt, inset: 6pt, width: 100%, {
    align(center, strong(judul))
    v(3pt)
    stack(dir: ttb, spacing: 3pt, ..isi.pos())
  })
  grid(columns: (1fr, 1fr), column-gutter: 6mm,
    kolom([www.photojo.id (situs publik)],
      halaman([Home], [index.html]),
      halaman([Service], [service.html]),
      halaman([Business (Photobox)], [business.html]),
      halaman([Application], [application.html]),
      halaman([Invoice], [invoice.html?t=…]),
      halaman([Halaman 404], [404.html])),
    kolom([dashboard.photojo.id (panel)],
      halaman([Masuk / atur kata sandi], []),
      halaman([Dashboard], []),
      halaman([Calendar], []),
      halaman([Orders], []),
      halaman([Leads], []),
      halaman([Pricing · Promotions · Vouchers], []),
      halaman([Announcements], []),
      halaman([Media · Reviews · FAQ], []),
      halaman([Locations · Users], []),
      halaman([Activity Log · Account], []),
    ),
  )
}

// Jalur pemodelan 3D: dari foto unit sampai tampil di peramban.
#let diagram-alur-3d() = {
  let langkah(pos, judul, isi, name: none, fill: white) = node(
    pos, [#strong(judul) #h(0.8em) #text(size: 7.5pt, isi)], name: name, shape: shapes.rect,
    width: 80mm, stroke: garis, fill: fill, corner-radius: 2pt, inset: 4.5pt,
  )
  diagram(
    spacing: (6mm, 4mm), edge-stroke: garis, node-shape: shapes.rect,
    langkah((0, 0), "1. Referensi", "foto dan ukuran unit sebenarnya", name: <a>),
    langkah((0, 1), "2. Pemodelan", "bentuk dasar dan detail di Blender 4.0 (.blend)", name: <b>),
    langkah((0, 2), "3. Material", "penamaan material (BoxBody) dan tekstur", name: <c>),
    langkah((0, 3), "4. Ekspor", "glTF Binary (.glb) dengan tekstur tertanam", name: <d>),
    langkah((0, 4), "5. Tayang", "dimuat oleh model-viewer di peramban", name: <e>, fill: teal-muda),
    edge(<a>, <b>, "->"), edge(<b>, <c>, "->"), edge(<c>, <d>, "->"), edge(<d>, <e>, "->"),
  )
}
