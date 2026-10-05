// ============================================================
// Diagram use case: situs publik dan panel admin.
// ============================================================

#import "_lib.typ": *

// Situs publik: satu aktor (pengunjung yang menjadi pelanggan).
#let diagram-usecase-publik() = {
  let L = 43mm
  diagram(
    spacing: (11mm, 3mm), edge-stroke: garis, node-shape: shapes.rect,
    node((0, 4), aktor[Pengunjung /\ Pelanggan], name: <p>, stroke: none, inset: 0pt),

    uc((1, 0), [Melihat informasi produk dan layanan], name: <u1>, lebar: L),
    uc((1, 1), [Mencoba photostrip interaktif], name: <u2>, lebar: L),
    uc((1, 2), [Melihat pratinjau 3D unit photobox], name: <u3>, lebar: L),
    uc((1, 3), [Mencoba simulasi aplikasi photobooth], name: <u4>, lebar: L),
    uc((1, 4), [Melihat harga, promo, dan ketersediaan], name: <u5>, lebar: L),
    uc((1, 5), [Memesan layanan], name: <u6>, lebar: L),
    uc((1, 6), [Mengunduh invoice], name: <u7>, lebar: L),
    uc((1, 7), [Meminta daftar harga unit], name: <u8>, lebar: L),
    uc((1, 8), [Berkonsultasi lewat WhatsApp], name: <u9>, lebar: L),

    uc((2, 3), [Mengisi formulir kontak], name: <s4>, lebar: 29mm),
    uc((2, 4.75), [Memakai kode voucher], name: <s6b>, lebar: 29mm),
    uc((2, 5.75), [Mendaftar daftar tunggu], name: <s6c>, lebar: 29mm),
    node((1.5, -0.95), [*Situs Photo.Jo*], stroke: none, inset: 0pt, name: <jud>),
    node(enclose: (<jud>, <u1>, <u9>, <s4>, <s6c>), stroke: garis, inset: 5pt, corner-radius: 2pt),

    edge(<p>, <u1>, "-"), edge(<p>, <u2>, "-"), edge(<p>, <u3>, "-"), edge(<p>, <u4>, "-"),
    edge(<p>, <u5>, "-"), edge(<p>, <u6>, "-"), edge(<p>, <u7>, "-"), edge(<p>, <u8>, "-"),
    edge(<p>, <u9>, "-"),
    edge(<u4>, <s4>, "-->", label: stereotipe[«include»], label-side: left),
    edge(<s6b>, <u6>, "-->", label: stereotipe[«extend»], label-side: right),
    edge(<s6c>, <u6>, "-->", label: stereotipe[«extend»], label-side: right),
  )
}

// Panel admin: tiga peran yang saling mewarisi.
#let diagram-usecase-staf() = {
  let L = 44mm
  diagram(
    spacing: (13mm, 2.6mm), edge-stroke: garis, node-shape: shapes.rect,
    node((0, 1.5), aktor[Operator], name: <op>, stroke: none, inset: 0pt),
    node((0, 6), aktor[Admin], name: <ad>, stroke: none, inset: 0pt),
    node((0, 10.5), aktor[Superadmin], name: <su>, stroke: none, inset: 0pt),

    uc((1, 0), [Masuk dan mengganti kata sandi], name: <a1>, lebar: L),
    uc((1, 1), [Melihat dasbor], name: <a2>, lebar: L),
    uc((1, 2), [Mengelola kalender ketersediaan], name: <a3>, lebar: L),
    uc((1, 3), [Mengelola pesanan dan pembayaran], name: <a4>, lebar: L),
    uc((1, 4), [Mengelola harga dan paket], name: <b1>, lebar: L),
    uc((1, 5), [Mengelola promo, voucher, pengumuman], name: <b2>, lebar: L),
    uc((1, 6), [Mengelola galeri, ulasan, dan FAQ], name: <b3>, lebar: L),
    uc((1, 7), [Mengelola leads], name: <b4>, lebar: L),
    uc((1, 8), [Melihat log aktivitas], name: <b5>, lebar: L),
    uc((1, 9), [Mengelola lokasi dan studio], name: <c1>, lebar: L),
    uc((1, 10), [Mengelola pengguna], name: <c2>, lebar: L),

    uc((2, 3.15), [Membatalkan pembayaran], name: <x1>, lebar: 27mm, tinggi: 9mm),
    uc((2, 4.5), [Mengunci tanggal tanpa DP], name: <x2>, lebar: 27mm, tinggi: 9mm),

    node((1.5, -0.95), [*Panel admin (dashboard.photojo.id)*], stroke: none, inset: 0pt, name: <jud>),
    node(enclose: (<jud>, <a1>, <c2>, <x2>), stroke: garis, inset: 5pt, corner-radius: 2pt),

    edge(<op>, <a1>, "-"), edge(<op>, <a2>, "-"), edge(<op>, <a3>, "-"), edge(<op>, <a4>, "-"),
    edge(<ad>, <b1>, "-"), edge(<ad>, <b2>, "-"), edge(<ad>, <b3>, "-"), edge(<ad>, <b4>, "-"),
    edge(<ad>, <b5>, "-"),
    edge(<su>, <c1>, "-"), edge(<su>, <c2>, "-"),
    edge(<ad>, <op>, "-|>", label: stereotipe[mewarisi], label-side: left),
    edge(<su>, <ad>, "-|>", label: stereotipe[mewarisi], label-side: left),
    edge(<x1>, <a4>, "-->", label: stereotipe[«extend»], label-side: right, label-pos: 0.45),
    edge(<x2>, <a4>, "-->", label: stereotipe[«extend»], label-side: left, label-pos: 0.45),
  )
}
