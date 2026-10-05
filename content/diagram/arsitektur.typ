// ============================================================
// Diagram arsitektur sistem dan topologi domain.
// ============================================================

#import "_lib.typ": *

#let grup = (stroke: putus, fill: abu, inset: 7pt, corner-radius: 3pt)

// Arsitektur tingkat tinggi: peramban memuat berkas statis dari Vercel,
// lalu berbicara langsung dengan Supabase.
#let diagram-arsitektur() = diagram(
  spacing: (7mm, 6mm),
  node-stroke: garis, node-fill: white, node-corner-radius: 2.5pt, node-inset: 4pt,
  node-shape: shapes.rect,

  node((0.5, 0), [*Peramban web* (klien)\ HTML + modul JavaScript\ tanpa _framework_], name: <br>, fill: teal-muda),
  node((-0.55, 0), [CDN: esm.sh,\ unpkg, Google\ Fonts], name: <cdn>, fill: abu),
  node((1.55, 0), [WhatsApp\ (`wa.me`)], name: <wa>, fill: abu),
  edge(<cdn>, <br>, "<-"),
  edge(<br>, <wa>, "->"),

  // Vercel
  node((0, 2.3), [*www.photojo.id*\ Home, Service, Business,\ Application, Invoice, 404], name: <pub>),
  node((0, 3.3), [*dashboard.photojo.id*\ admin.html (panel admin)], name: <adm>),
  node((0, 4.3), [Aset statis: modul JS,\ model 3D (.glb), frame], name: <aset>),
  node((0, 1.5), [*Vercel* (hosting statis)\ dimuat sebagai halaman dan aset], stroke: none, fill: none, inset: 0pt, name: <tv>),
  node(enclose: (<tv>, <pub>, <adm>, <aset>), name: <vercel>, ..grup),

  // Supabase
  node((1, 2.35), [PostgREST\ (REST dan RPC)], name: <rest>),
  node((1, 3.05), [Auth (GoTrue)], name: <auth>),
  node((1, 3.75), [Storage (3 bucket)], name: <stor>),
  node((1, 4.45), [Edge Function\ `manage-users`], name: <edge>),
  node((1, 5.35), [*PostgreSQL 17*\ 24 tabel, RLS, fungsi, pemicu], name: <pg>, fill: teal-muda),
  node((1, 1.5), [*Supabase* (backend terkelola)\ dipanggil lewat API], stroke: none, fill: none, inset: 0pt, name: <ts>),
  node(enclose: (<ts>, <rest>, <auth>, <stor>, <edge>, <pg>), name: <sb>, ..grup),

  edge(<br>, <vercel>, "->"),
  edge(<br>, <sb>, "->"),

  node((1, 6.5), [Resend (SMTP)\ email undangan dan reset], name: <rs>, fill: abu),
  edge(<sb>, <rs>, "->"),
)

// Topologi domain dan jalur penerapan.
#let diagram-topologi() = diagram(
  spacing: (6mm, 8mm),
  node-stroke: garis, node-fill: white, node-corner-radius: 2.5pt, node-inset: 4pt,
  node-shape: shapes.rect,

  node((1, 0), [*photojo.id*\ DNS dikelola di Hostinger], name: <dns>, fill: teal-muda),
  node((0, 1), [`photojo.id`\ (apex)], name: <apex>),
  node((1, 1), [`www.photojo.id`], name: <www>),
  node((2, 1), [`dashboard.photojo.id`], name: <dash>),
  edge(<dns>, <apex>, "->"),
  edge(<dns>, <www>, "->"),
  edge(<dns>, <dash>, "->"),

  node((0, 2.3), [Aplikasi photobooth\ lama (tidak diubah)], name: <lama>, fill: abu),
  node((1.5, 2.3), [*Vercel*\ satu proyek, dua nama domain], name: <vercel>),
  edge(<apex>, <lama>, "->"),
  edge(<www>, <vercel>, "->"),
  edge(<dash>, <vercel>, "->"),

  node((1.5, 3.7), [*GitHub* (repositori privat)\ _branch_ `main` → produksi\ _branch_ lain → pratinjau], name: <git>, fill: abu),
  edge(<git>, <vercel>, "->", label: [terapkan otomatis], label-side: right),
)
