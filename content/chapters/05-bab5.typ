// ============================================================
// BAB V IMPLEMENTASI SISTEM
// Potongan kode diambil dari repositori proyek, diringkas, dan komentarnya
// diterjemahkan. Tangkapan layar panel admin dan invoice memakai data contoh.
// ============================================================

#import "../../template/lib.typ": *

// Tabel: 9,5 pt, rata kiri; hanya tabel panjang yang boleh terpotong antarhalaman.
#show figure.where(kind: table): it => {
  show figure.caption: set block(sticky: true)
  it
}
#set table.cell(breakable: false)
#show table: set text(size: 9.5pt)
#show table: set par(justify: false)
#set table(inset: 4pt)

// Kode: huruf kecil agar muat pada halaman A5.
#show raw.where(block: true): set text(size: 7.2pt)
#show raw.where(block: false): set text(size: 0.88em)
// Listing mengambang (placement: auto) agar teks berikutnya mengisi halaman dan tidak
// tersisa ruang kosong besar; ia tidak terpotong dan mendarat di atas atau bawah halaman.
#let kode-sumber(caption: "", body) = figure(
  kind: "kode", supplement: [Kode Sumber], caption: caption, placement: auto,
  block(
    fill: luma(248), stroke: 0.5pt + luma(200), radius: 3pt,
    inset: (x: 12pt, y: 10pt), width: 100%, align(left, body),
  ),
)

// Tangkapan layar mengambang agar tidak meninggalkan ruang kosong pada halaman.
#let gb(path, caption: "", width: 100%) = figure(
  image(path, width: width),
  caption: caption, supplement: [Gambar], placement: auto,
)

= IMPLEMENTASI SISTEM

Bab ini membahas implementasi sistem yang dikerjakan selama kerja praktik. Potongan kode
diambil dari repositori proyek dan diringkas, dengan komentar diterjemahkan ke bahasa
Indonesia dan bagian yang dihilangkan ditandai elipsis.

== Lingkungan dan Tahapan Implementasi

Perangkat yang dipakai telah dirangkum pada @tbl-software. Pengembangan dilakukan secara
lokal: halaman disajikan server statis `serve.py` dan basis data, autentikasi, penyimpanan,
serta fungsi dijalankan tumpukan Supabase lokal pada Docker. Basis data lokal diisi 69 pesanan
demo oleh skrip `seed-demo.mjs` melalui pintu yang sama dengan penggunaan nyata, yaitu
`create_order()` dan `record_manual_payment()`, sehingga penomoran, invoice, dan klaim
kapasitas terbentuk seperti kondisi sebenarnya. Implementasi dikerjakan bertahap mengikuti fase
pada dokumen perancangan, dimulai dari situs publik (13 sampai 30 Juli), model 3D (sampai 11
Agustus), lalu sisi server dalam lima fase dan penguatan keamanan sampai 30 September,
sedangkan penerapan diselesaikan setelah masa kerja praktik berakhir.

== Implementasi Basis Data

Skema dikelola sebagai 32 berkas migrasi SQL pada `supabase/migrations`, diterapkan dengan
Supabase CLI ke tumpukan lokal maupun proyek terkelola. Migrasi bersifat tambahan: bagian yang
perlu berubah ditulis ulang utuh pada migrasi baru, dan `create_order`, misalnya, ditulis ulang
pada tujuh migrasi sesudah migrasi 12. Migrasi yang mengubah hak akses diakhiri blok
pemeriksaan yang mengeluarkan galat bila keadaan skema tidak sesuai harapan.

Kapasitas tanggal adalah aturan yang paling mahal bila dilanggar, karena uang dapat diterima
untuk tanggal yang tidak dapat dilayani, sehingga dijaga oleh basis data. @kode-kapasitas
menunjukkan pemicu yang berjalan sebelum klaim ditambahkan. Baris tanggal dikunci dengan
`FOR UPDATE` sebelum klaim dihitung; tanpa kunci itu, dua penyisipan bersamaan sama-sama
membaca jumlah klaim lama, sama-sama menemukan ruang, dan sama-sama berhasil.

#kode-sumber(caption: [Pemicu penjaga kapasitas tanggal (diringkas)], ```sql
create or replace function enforce_slot_capacity()
returns trigger language plpgsql
security definer set search_path = public
as $$
declare v_cap int; v_used int;
begin
  if new.status not in ('held', 'confirmed') then
    return new;   -- klaim yang dilepas tidak menempati
  end if;

  -- Baris tanggal dikunci sebelum klaim dihitung.
  select coalesce(s.capacity_override, l.daily_capacity)
    into v_cap
  from availability_slots s
  join locations l on l.id = s.location_id
  where s.id = new.slot_id
  for update of s;

  select count(*) into v_used from slot_claims c
  where c.slot_id = new.slot_id
    and c.status in ('held', 'confirmed')
    and c.id is distinct from new.id;

  if v_used >= v_cap then
    raise exception
      'Tanggal ini sudah penuh (kapasitas %).', v_cap
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;
```) <kode-kapasitas>

Fungsi ini dideklarasikan `SECURITY DEFINER` dengan alasan nyata: pemicu berjalan dengan hak
pemanggil, padahal ia menggabungkan tabel `locations` yang tidak dapat dibaca operator, sehingga
bagi operator kapasitas menjadi kosong dan setiap pencatatan pemesanan luar situs gagal.
Kesalahan ini baru ditemukan dengan menguji sebagai operator, bukan sebagai superadmin tempat
layar itu ditulis. Log aktivitas diisi satu pemicu generik `write_audit_log()` yang menyalin
email pelaku saat kejadian, dan tabel `audit_log` tidak memiliki kebijakan tulis sehingga
catatan tidak dapat disunting. Pemicu `guard_profile_self_update` dan `guard_last_superadmin`
mencegah pengguna menaikkan perannya sendiri dan menyisakan nol superadmin aktif.

== Implementasi Keamanan

RLS diaktifkan dan dipaksakan pada setiap tabel; `FORCE` diperlukan karena pemilik tabel, yaitu
peran `postgres` yang menjalankan migrasi, melewati RLS biasa. Kebijakan memakai fungsi
`current_user_role()` yang berstatus `SECURITY DEFINER` agar tidak berulang melalui kebijakan
`profiles` sendiri (@kode-rls). Pengujian lokal menunjukkan bahwa RLS mempersempit hak `GRANT`
dan tidak menggantikannya, sehingga migrasi 1 memberikan hak dasar secara luas dan kebijakanlah
yang menentukan akses sebenarnya.

#kode-sumber(caption: [Pola RLS: aktifkan, peran pemanggil, dan kebijakan (disederhanakan)], ```sql
alter table packages enable row level security;
alter table packages force row level security;

create or replace function current_user_role()
returns user_role
language sql stable security definer
set search_path = public
as $$
  select p.role from profiles p
  where p.user_id = auth.uid()
    and p.is_active and p.status = 'active'
  limit 1;
$$;

-- Katalog: publik membaca baris aktif, admin menulis.
create policy "public read active" on packages
  for select to anon, authenticated using (is_active);
create policy "admin write" on packages
  for all to authenticated
  using (is_admin_or_above())
  with check (is_admin_or_above());
```) <kode-rls>

Kalender publik dibaca dari _view_ `public_availability` yang menghitung label status di server
(`full`, `half`, atau `available`) dan tidak mengirim jumlah pemesanan, kapasitas, atau baris
klaim ke peramban. Tinjauan keamanan pada 17 September 2026 menemukan celah yang tidak tampak
dari membaca kebijakan: Postgres memberikan `EXECUTE` kepada `PUBLIC` saat fungsi dibuat,
sehingga mencabutnya dari `anon` saja tidak efektif. Fungsi `next_order_code()` ternyata dapat
dipanggil anonim, dan dua panggilan memajukan urutan kode pesanan dari 202 ke 204 sehingga
orang asing dapat mengetahui jumlah pesanan tahun itu. Migrasi 23 mencabut hak dari `PUBLIC`
dan menambahkan pemeriksaan yang gagal bila `anon` masih dapat memanggilnya (@kode-revoke).
Hasil akhirnya, hanya `create_order`, `public_invoice`, dan `voucher_lookup` yang dibuka
eksplisit bagi pengunjung.

#kode-sumber(caption: [Pencabutan hak EXECUTE publik beserta pemeriksaannya (diringkas)], ```sql
-- EXECUTE diberikan ke PUBLIC saat fungsi dibuat;
-- mencabutnya dari anon saja tidak cukup.
revoke execute on function next_order_code()
  from public, anon, authenticated;

-- Pemeriksaan akhir: gagal bila masih terbuka.
do $guard$
begin
  if has_function_privilege(
       'anon', 'next_order_code()', 'execute') then
    raise exception
      'next_order_code is still reachable by anon';
  end if;
end $guard$;
```) <kode-revoke>

Operasi akun seperti membuat dan menghapus baris `auth.users` membutuhkan kunci `service_role`
yang tidak boleh berada di peramban, sehingga dikerjakan Edge Function `manage-users` dengan
tujuh tindakan (`invite`, `reset`, `remove`, `reactivate`, `delete_invite`, `rename`, dan
`role_change`). Pemeriksaan pertamanya berlaku untuk semua tindakan: pemanggil harus superadmin
aktif, dengan profil dibaca melalui klien yang terikat pada token pemanggil sendiri sehingga
tidak dapat dipalsukan dengan mengirim `user_id` lain. Klien `service_role` hanya dipakai pada
`inviteUserByEmail` dan `deleteUser`, sedangkan penulisan lain memakai klien pemanggil agar
`auth.uid()` tercatat pada log aktivitas.

Tinjauan yang sama menemukan celah pada penerapan: Vercel menyajikan setiap berkas repositori
pada alamatnya sendiri, sehingga pada penerapan percobaan dokumen perancangan dan berkas
migrasi dapat diunduh. Berkas `.vercelignore` kini mengecualikan `*.md`, `supabase/`,
`scripts/`, `references/`, dan `test-pages/`. Header respons pada `vercel.json` mencakup
`X-Frame-Options: DENY` dan `frame-ancestors 'none'` agar panel tidak dapat dibingkai halaman
lain, serta `Permissions-Policy` yang hanya mengizinkan kamera bagi halaman sendiri.

== Implementasi Logika Bisnis di Server

#kode-sumber(caption: [Bagian inti create_order: harga, nomor WhatsApp, dan voucher (diringkas)], ```sql
create or replace function create_order(p jsonb)
returns jsonb language plpgsql
security definer set search_path = public
as $$
begin
  -- Harga dibaca dari katalog, bukan dari permintaan.
  select * into v_package from packages
   where service_id = v_service.id
     and code = (p ->> 'package_code') and is_active;
  v_subtotal := v_package.price;

  -- 0812..., +62 812..., dan 812... menjadi 62812...
  v_wa := regexp_replace(v_contact, '[^0-9]', '', 'g');
  if left(v_wa, 1) = '0' then
    v_wa := '62' || substring(v_wa from 2);
  end if;
  if v_wa !~ '^628[1-9][0-9]{6,11}$' then
    raise exception 'Nomor WhatsApp tidak valid.'
      using errcode = 'check_violation';
  end if;

  -- Penjaga atomik: bila kuota baru saja habis, UPDATE
  -- tidak mengenai baris dan pesanan ditolak.
  update vouchers set times_redeemed = times_redeemed + 1
   where id = v_voucher_id
     and (max_redemptions is null
          or times_redeemed < max_redemptions);
  if not found then
    raise exception
      'Kuota kode voucher ini baru saja habis.'
      using errcode = 'check_violation';
  end if;
  -- ... batas laju, invoice /01, dan hasil
```) <kode-create-order>

Fungsi `create_order(p jsonb)` adalah satu-satunya jalan pembuatan pesanan, baik dari situs
maupun panel staf, dan dapat dipanggil pengunjung tanpa akun. Parameter `source` menentukan
mode, dan yang berbeda antara pelanggan (`web`) dan staf (`manual`) hanya izin, bukan logika,
sehingga harga, kapasitas, dan validasi tidak punya salinan kedua yang dapat menyimpang.
@kode-create-order menunjukkan bagian intinya. Harga dibaca dari katalog dan bukan dari
permintaan, dan nomor WhatsApp dinormalisasi lalu divalidasi dengan awalan operator seluler
karena panjang saja bukan validasi. Kuota voucher dipakai dalam transaksi yang sama: klausa
`WHERE` pada `UPDATE` adalah penjaga atomik, sehingga bila pesanan lain sudah mengambil
pemakaian terakhir, seluruh pesanan ditolak. Pembatasan laju diletakkan pada fungsi ini karena
fungsi dapat dipanggil langsung oleh pemegang kunci publik tanpa melewati peramban.


Tanggal dinilai pada zona waktu WIB, bukan UTC milik basis data, karena antara tengah malam
dan pukul 07.00 WIB tanggal UTC masih hari kemarin. Pesanan yang dibuat berstatus
`awaiting_payment`, berlaku 48 jam, dan langsung menerbitkan invoice `/01`.

#kode-sumber(caption: [Penguncian tanggal pada apply_payment (diringkas)], ```sql
  select * into v_order from orders
   where id = p_order_id for update;

  if p_amount > v_order.total - v_settled then
    raise exception 'Jumlah melebihi sisa tagihan (%).',
      format_rupiah(greatest(v_order.total - v_settled, 0))
      using errcode = 'check_violation';
  end if;

  -- Dikunci sebelum dibaca: dua pembayaran yang berebut
  -- tanggal terakhir diputuskan satu per satu.
  select s.id, s.is_blocked, s.booked_count,
         coalesce(s.capacity_override, l.daily_capacity)
    into v_slot_id, v_blocked, v_booked, v_capacity
    from availability_slots s
    join locations l on l.id = s.location_id
   where s.location_id = v_order.location_id
     and s.date = v_order.event_date
   for update of s;
  -- ... galat bila tanggal ditutup atau sudah penuh

  if v_settled + p_amount >=
     least(dp_minimum(), v_order.total) then
    insert into slot_claims
      (slot_id, order_id, status, expires_at)
    values (v_slot_id, p_order_id, 'confirmed', null)
    on conflict (slot_id, order_id) do update
      set status = 'confirmed', expires_at = null;
  end if;
```) <kode-apply-payment>

Pencatatan pembayaran dibagi dua: `apply_payment` bersifat internal dan `EXECUTE`-nya dicabut
dari semua peran, sedangkan `record_manual_payment` adalah pintu bagi staf yang memanggil
`apply_payment` lalu `issue_invoice`. @kode-apply-payment menunjukkan bagian terpentingnya.
Baris pesanan dikunci lebih dulu, jumlah yang melebihi sisa tagihan ditolak karena tidak ada
pengembalian, dan baris tanggal dikunci sebelum dibaca sehingga dua pembayaran yang berebut
tanggal terakhir diputuskan satu per satu. Klaim terkonfirmasi baru dibuat ketika total
pembayaran mencapai minimum DP.


Pembatalan pembayaran dikerjakan `void_payment`, hanya oleh admin ke atas dengan alasan
tertulis. Fungsi ini mengunci pesanan lalu pembayaran dengan urutan yang sama agar tidak terjadi
kebuntuan, melepas klaim tanggal bila sisa pembayaran di bawah minimum DP, menandai BATAL
invoice yang terbit sesudahnya, lalu menerbitkan invoice koreksi.

Penerbitan invoice dipusatkan pada `issue_invoice`, yang mengunci baris pesanan sehingga nomor
urut dihitung dengan aman, dengan kendala unik `(order_id, seq)` sebagai pengaman terakhir.
Isi invoice disusun satu kali oleh `invoice_snapshot` menjadi objek JSON berisi data penjual,
butir, pembayaran, dan syarat pembayaran, lalu disimpan pada kolom `snapshot` sehingga tidak
dihitung ulang saat dibuka. Pelanggan tidak memiliki sesi, sehingga halaman invoice menjangkau
pesanannya melalui token acak 122 bit lewat fungsi `public_invoice(p_token uuid)`. Rancangan
awal merencanakan Edge Function untuk ini, tetapi fungsi `SECURITY DEFINER` yang hanya
mengembalikan salinan beku untuk satu pesanan ternyata cukup dan tidak memerlukan kunci yang
tidak boleh dimiliki peramban.

Fungsi `best_promotion()` memilih promosi yang cocok dengan potongan terbesar, sedangkan
`voucher_lookup()` membaca satu kode tanpa mengembalikan barisnya, dan tabel `vouchers` tidak
memiliki kebijakan baca bagi pengunjung agar daftar kode tidak dapat diunduh. Urutan daftar
yang menentukan tampilan situs disimpan melalui `reorder_rows`, yang sengaja berstatus
`SECURITY INVOKER` agar RLS tetap berlaku, hanya menerima nama tabel dari daftar yang
diizinkan, dan hanya menulis baris yang benar-benar berpindah.

== Implementasi Situs Publik

Setiap halaman publik adalah satu berkas HTML mandiri dengan CSS dan JavaScript di dalamnya,
dengan modul bersama `db.js`, `order-window.js`, `announce.js`, `holidays.js`, dan
`scrollbar.js`. Pilihan tanpa tahap _build_ ini punya konsekuensi yang disadari: token desain
dan komponen bersama ditulis ulang pada setiap halaman sehingga perubahan bersama harus disalin
satu per satu. Berkas terbesarnya adalah `admin.html` (14.384 baris), disusul `application.html`,
`service.html`, dan `index.html` yang masing-masing sekitar 5.000 baris, sedangkan `db.js`
berisi 2.460 baris. Sistem desain pada Bab 4 diwujudkan sebagai variabel CSS pada `:root` yang
identik pada kelima halaman.

Halaman Service membaca katalog melalui `getPublicCatalogue()`, yang mengambil layanan, add-on,
dan tautannya dalam satu `Promise.all` dan menyusunnya dalam bentuk yang sama dengan konstanta
yang sebelumnya tertulis pada halaman. Penggantian cadangan statis dengan data hidup karenanya
berupa pertukaran data, bukan penulisan ulang logika, dan bila pengambilan gagal konstanta
cadangan tetap dipakai. Skrip `sync-fallbacks.mjs` menulis ulang konstanta dan harga yang
tercetak pada markup, dan mode `--check` keluar dengan status gagal bila ada selisih.

Bagian _Coba Sesi Photobooth Langsung di Browser_ pada halaman Home memungkinkan pengunjung
membuat _photostrip_ dengan kamera perangkatnya (@gbr-home-photobox). Alurnya berupa mesin
keadaan tiga layar: pemilihan _frame_ dari enam pilihan, sesi foto dengan hitung mundur lima
detik, dan layar akhir untuk mengunduh hasil. Foto dikerjakan seluruhnya di peramban dan tidak
diunggah ke server. @kode-photostrip menunjukkan intinya: bingkai video dipotong tengah sesuai
rasio kotak foto (480 × 400) dan dicerminkan agar sama dengan pratinjau, lalu tiga foto
digambar pada kanvas 500 × 1500 piksel dengan _frame_ PNG berjendela transparan di atasnya.

#gb("../../assets/figures/home-photobox.png", caption: [Pemilihan _frame_ pada pengalaman _photostrip_ interaktif], width: 75%) <gbr-home-photobox>

#kode-sumber(caption: [Penyusunan _photostrip_ pada kanvas (diringkas)], ```js
const PB_SLOT_W = 480, PB_SLOT_H = 400, PB_SLOT_X = 10;
const PB_SLOTS_Y = [20, 440, 860];

// Setiap bingkai dipotong tengah dan dicerminkan.
ctx.translate(PB_SLOT_W, 0);
ctx.scale(-1, 1);
ctx.drawImage(pbVideoEl, sX, sY, sW, sH,
              0, 0, PB_SLOT_W, PB_SLOT_H);

async function pbCompileAndFinish() {
  pbOutputCanvas.width = 500;
  pbOutputCanvas.height = 1500;
  for (let i = 0; i < PB_PHOTO_COUNT; i++)
    ctx.drawImage(await pbLoadImageElement(
      pbCapturedPhotoURLs[i]),
      PB_SLOT_X, PB_SLOTS_Y[i], PB_SLOT_W, PB_SLOT_H);
  // Frame digambar terakhir, di atas foto.
  ctx.drawImage(frameImg, 0, 0, 500, 1500);
}
```) <kode-photostrip>

Galeri polaroid menampilkan foto yang dapat diseret di atas meja dengan kelembaman: satu
pendengar `pointerdown` dengan delegasi peristiwa, kecepatan lepas dirata-ratakan dari lima
sampel posisi, lalu kartu meluncur melalui `requestAnimationFrame` dengan gesekan dan memantul
pada tepi. Pada layar sentuh, tata letak tebaran diganti grid tiga kolom agar halaman dapat
digulir. Fotonya berasal dari tabel `media` (paling banyak 15 foto terbit) dan dipilih dari foto
yang telah disetujui orang-orang di dalamnya serta boleh dipakai Photo.Jo sebagai materi merek
(@gbr-galeri).

#gb("../../assets/figures/galeri-polaroid.png", caption: [Galeri polaroid pada halaman Home], width: 60%) <gbr-galeri>

Halaman Business menampilkan model 3D tiga unit melalui komponen `<model-viewer>` yang memuat
`.glb` langsung (@gbr-business-3d). Satu elemen dipakai bersama semua unit, dengan atribut
`src` dan `alt` diganti menurut peta `UNIT_MODELS`, dan model dimuat malas karena berukuran
sekitar 1,6 MB dan letaknya jauh di bawah lipatan layar. Warna `baseColorFactor` pada glTF
bersifat linear sedangkan palet berupa heksadesimal sRGB, sehingga nilainya dikonversi lebih
dahulu (@kode-model-viewer), lalu seluruh material bernama `BoxBody` diubah sekaligus.

#gb("../../assets/figures/business-3d.png", caption: [Pratinjau 3D unit Velvet Booth pada halaman Business], width: 75%) <gbr-business-3d>

#kode-sumber(caption: [Konversi warna dan penggantian warna bodi (diringkas)], ```js
// sRGB hex -> rgba linear (baseColorFactor glTF linear)
function hexToLinear(hex) {
  const n = parseInt(hex.slice(1), 16);
  const toLin = (c) => { c /= 255;
    return c <= 0.04045 ? c / 12.92
      : Math.pow((c + 0.055) / 1.055, 2.4); };
  return [toLin((n >> 16) & 255), toLin((n >> 8) & 255),
          toLin(n & 255), 1];
}

// Ubah semua material "BoxBody" pada unit yang termuat.
function applyColor(hex) {
  const rgba = hexToLinear(hex);
  viewer.model.materials
    .filter(m => m.name === 'BoxBody')
    .forEach(m => m.pbrMetallicRoughness
                    .setBaseColorFactor(rgba));
}
```) <kode-model-viewer>

Halaman Application berisi simulasi aplikasi _photobooth_ yang dibangun ulang penuh dengan
HTML, CSS, dan JavaScript, bukan tangkapan layar yang diberi tombol (@gbr-app-simulator).
Alurnya berupa mesin keadaan dengan fungsi templat per keadaan, dan pendengar peristiwa
dipasang sekali pada cangkang layar dengan membaca atribut `data-action`. Panel admin pada
simulator adalah demo perangkat lunak itu sendiri, sehingga sebelum dibuka ditampilkan formulir
nama, nomor WhatsApp, dan persetujuan sebagai modal di luar bingkai kiosk agar tidak tampak
sebagai bagian dari aplikasi tiruan. Gerbang ini bersifat _fail open_: bila Supabase tidak
terjangkau atau penulisan melebihi delapan detik, pengunjung tetap diberi akses karena gerbang
melindungi demo, bukan rahasia. Pengunjung hanya dapat menambah baris pada `leads` ditambah dua
penghitung `gate_events` tanpa identitas, dan parameter UTM digabungkan ke kolom `context`
tanpa pelacak, kuki, atau skrip pihak ketiga.

#gb("../../assets/figures/app-simulator.png", caption: [Layar pemilihan frame pada simulator aplikasi _photobooth_], width: 75%) <gbr-app-simulator>

Halaman Service menampilkan empat layanan dalam tab dengan keranjang yang meluncur dari kanan,
dan add-on dikendalikan aturan yang sama pada panel, jendela, dan server. Jendela pemesanan
diimplementasikan sebagai modul `order-window.js` yang menyimpan keadaannya pada
`sessionStorage` setiap berpindah langkah, dan @gbr-jendela-pemesanan menunjukkan empat langkah
pertamanya pada tampilan ponsel. Modul ini tidak pernah menentukan harga: angka pada layar
hanyalah pratinjau, dan satu-satunya penulisan ke server adalah pemanggilan `createOrder`.
Bila galat menyebut tanggal penuh atau ditutup, pelanggan dikembalikan ke kalender yang segar,
bukan ke jalan buntu. Semua jalur yang menampilkan atau menyembunyikan jendela melewati satu
fungsi, `holdPage()`, yang menjadikan latar belakang `inert`, memindahkan fokus ke dialog, dan
menjaga Tab tetap di dalamnya, karena sebelum perbaikan ini pengguna papan ketik mendarat di 14
perhentian tab pada halaman di belakang yang tidak dapat mereka lihat.

#gb("../../assets/figures/jendela-pemesanan.png", caption: [Empat langkah pertama jendela pemesanan pada tampilan ponsel: paket, lokasi, tanggal, dan pembayaran], width: 80%) <gbr-jendela-pemesanan>

Halaman `invoice.html` menampilkan invoice bergaya siap cetak (@gbr-invoice) melalui
`?t=<token>` tanpa masuk. Skrip `invoice.js` menampilkan invoice valid terbaru sebagai dokumen
utama dengan nomor sebelumnya di bawahnya, sehingga pelanggan yang menyimpan tautan setelah
membayar DP melihat posisinya saat ini, dan status pesanan seperti dibatalkan atau kedaluwarsa
tampil sebagai spanduk di atas dokumen yang tidak berubah. Fitur kecil lain meliputi kapsul
pengumuman, data terstruktur dan gambar berbagi 1200 × 630 piksel pada setiap halaman, halaman
404 minimal, dan mode Tompel berupa kejutan penghormatan kepada kucing penulis.

#gb("../../assets/figures/invoice-contoh.png", caption: [Halaman invoice yang dibuka pelanggan melalui tautan pribadi], width: 80%) <gbr-invoice>

== Implementasi Panel Admin

Panel admin adalah satu berkas HTML, `admin.html`, tanpa _framework_, dengan layar-layar
sebagai bagian yang ditampilkan atau disembunyikan. Saat dibuka, `boot()` menentukan salah
satu dari lima keadaan: memuat, masuk, atur kata sandi, akses ditolak, atau aplikasi.
Pembatasan peran pada antarmuka dikerjakan `enterApp()`: elemen bertanda `data-role-gate`
disembunyikan menurut peran. Ini kenyamanan, bukan penghalang, karena penghalang sebenarnya
adalah RLS. Pembedaan ini penting pada dasbor sebab RLS menyaring dan tidak menolak, sehingga
ubin yang ditampilkan kepada peran yang salah akan melaporkan angka nol dengan yakin, bukan
galat, dan setiap kelompok dasbor karenanya dibatasi sesuai layar yang diwakilinya.

@tbl-layar merangkum layar panel beserta hubungannya dengan server, dan @gbr-panel-admin
menampilkan tiga di antaranya. Seluruh antarmuka berbahasa Indonesia, kecuali judul menu yang
sengaja berbahasa Inggris dan identik dengan label bilah samping.

#figure(
  grid(
    columns: (1fr, 1fr), column-gutter: 4mm, row-gutter: 3mm,
    grid.cell(colspan: 2, align(center, stack(dir: ttb, spacing: 3pt,
      image("../../assets/figures/admin-dashboard.png", width: 88%),
      text(size: 8.5pt)[(a) Dasbor]))),
    stack(dir: ttb, spacing: 3pt,
      image("../../assets/figures/admin-calendar.png", width: 100%),
      align(center, text(size: 8.5pt)[(b) Calendar])),
    stack(dir: ttb, spacing: 3pt,
      image("../../assets/figures/admin-pesanan.png", width: 100%),
      align(center, text(size: 8.5pt)[(c) Dialog Pesanan Baru])),
  ),
  kind: image, supplement: [Gambar], placement: auto,
  caption: [Panel admin dengan data contoh: (a) dasbor, (b) layar Calendar, dan (c) dialog pembuatan pesanan],
) <gbr-panel-admin>

#allow-table-break[#figure(
  caption: [Layar panel admin dan hubungannya dengan server],
  table(
    columns: (2.8cm, 1fr),
    align: (left, left),
    table.header([*Layar*], [*Cara kerja dan server*]),
    [Dashboard, Calendar], [Ringkasan pesanan, pembayaran, dan _leads_; kalender bulan, minggu, dan agenda seluruh lokasi dengan pesanan yang dapat diseret ke hari lain. \ _Server:_ `slot_claims`, `reschedule_order()`.],
    [Orders], [Daftar berpenyaring dengan dialog detail, Catat Bayar, Pesanan Baru, pengingat WhatsApp, dan ekspor CSV. \ _Server:_ `create_order`, `record_manual_payment`, `void_payment`.],
    [Leads, Pricing, Promotions, Vouchers], [_Leads_ dengan tautan `wa.me`; perubahan harga disimpan sekaligus dengan konfirmasi bila lebih dari 25 persen. \ _Server:_ `leads`, `packages`, `promotions`, `vouchers`.],
    [Announcements, Media, Reviews, FAQ], [Pengumuman berkapsul dengan pratinjau; unggah dengan pemotong gambar, status terbit, dan urutan seret dan lepas. \ _Server:_ Storage `content`, `reorder_rows()`.],
    [Locations, Users, Activity Log], [Kota dan kapasitas, studio, akun staf, dan catatan perubahan. \ _Server:_ `locations`, `manage-users`, `audit_log`.],
  ),
) <tbl-layar>]

Gambar yang diunggah staf dijaga ringan dalam dua lapis: di peramban gambar dipotong menurut
rasio koleksi (misalnya 1 : 1 untuk galeri polaroid, sisi maksimum 800 piksel), diperkecil,
dan dikodekan ulang ke WebP sebelum melintasi jaringan, sedangkan di _bucket_ batas 5 MB dan
daftar jenis berkas ditegakkan karena siapa pun dapat memanggil API Storage langsung. Fungsi
`compressImage` memotong, bukan menolak, sebab foto ponsel berukuran 4 : 3 atau 3 : 4 dan
penolakan akan menggagalkan unggahan ke koleksi 1 : 1. Bukti transfer dikompresi dengan cara
yang sama, diunggah ke _bucket_ privat lebih dulu, dan dihapus lagi bila pencatatan pembayaran
gagal agar tidak ada berkas yatim.

Layar Calendar mengikuti pola Google Calendar karena sudah dikenal staf. Pemindahan jadwal
dengan seretan hanya untuk penunjuk mouse atau pena karena pada layar sentuh seretan adalah
cara menggulir. Tombol _Tambah ke Google Calendar_ berupa tautan ke halaman acara baru Google,
bukan umpan berlangganan, karena umpan akan menaruh nama pelanggan dan alamat acara pada URL di
luar proteksi masuk panel.

== Implementasi Pemodelan 3D

Ketiga unit dimodelkan di Blender 4.0 berdasarkan foto dan ukuran unit sebenarnya, lalu
diekspor ke `.glb` dengan Khronos glTF Blender I/O v4.0.44. Berkas sumber `.blend` dan tekstur
disimpan terpisah dari aset situs, dan hanya `.glb` yang dikirim ke pengunjung. Kiosk Slim
dimodelkan ulang pada 4 Agustus 2026 mengikuti referensi terbaru dari pemilik, lalu Velvet
Booth (6 Agustus) dan Cabin Booth (10 Agustus) yang berupa bilik tertutup dan jauh lebih rumit. Spesifikasi hasil ekspor, yang dibaca
langsung dari JSON glTF, disajikan pada @tbl-model; berkasnya `unit1.glb` (Kiosk Slim),
`unit2.glb` (Velvet Booth), dan `unit3.glb` (Cabin Booth). Penamaan material menjadi bagian dari
kontrak antara model dan situs: Kiosk Slim dan Cabin Booth masing-masing memiliki dua material
`BoxBody` (bodi dan pintu), Velvet Booth satu, dan kode pengganti warna menyaring semuanya tanpa
percabangan per unit (@gbr-unit-3d).

#[
  #show table: set text(size: 9pt)
  #figure(
    caption: [Spesifikasi model 3D hasil ekspor],
    table(
      columns: (1fr, auto, auto, auto, auto, auto, auto),
      align: (left, right, right, right, right, right, right),
      inset: (x: 3pt, y: 4pt),
      table.header([*Unit*], [*Ukuran*], [*Segitiga*], [*Titik*], [*Objek*], [*Material*], [*Tekstur*]),
      [Kiosk Slim], [1,26 MB], [1.110], [1.598], [8], [5], [3],
      [Velvet Booth], [1,60 MB], [1.646], [2.623], [17], [15], [7],
      [Cabin Booth], [1,42 MB], [1.990], [3.052], [15], [9], [4],
    ),
  ) <tbl-model>
]

#gb("../../assets/figures/unit-3d-tiga.png", caption: [Model 3D unit _photobox_ pada pratinjau: (a) Velvet Booth, (b) Cabin Booth, dan (c) Kiosk Slim], width: 82%) <gbr-unit-3d>

== Implementasi Penerapan

Penerapan diselesaikan setelah masa kerja praktik berakhir dengan langkah berikut, dan langkah
terakhirnya kini berada di tangan Photo.Jo. Saat laporan ini ditulis situs memakai Vercel paket
Hobby dan Supabase paket Free, dan jenis penerapan akhir ditentukan manajemen Photo.Jo.

+ Kode disimpan pada repositori GitHub privat yang terhubung ke Vercel. _Branch_ `main`
  diterapkan ke produksi dan _branch_ lain menghasilkan pratinjau.
+ Migrasi diterapkan ke proyek Supabase terkelola dengan `supabase db push`, lalu daftar
  migrasi lokal dibandingkan dengan yang jauh agar sinkron.
+ Pengaturan Auth disesuaikan: alamat situs dan panel, SMTP Resend, dan pendaftaran mandiri
  dimatikan setelah ternyata masih menyala saat diperiksa pada 30 September.
+ Rahasia `ADMIN_URL` diarahkan ke subdomain `dashboard`, data uji dibersihkan, dan cadangan
  statis disinkronkan.
+ DNS dikelola pada Hostinger oleh Photo.Jo bersama penulis. Panel admin sudah aktif pada
  `dashboard.photojo.id`, sedangkan `www.photojo.id` dan domain kini ditangani Photo.Jo.

Keadaan sebelum peluncuran diperiksa dengan daftar pada @tbl-periksa. Seluruh rahasia berada
di luar repositori, kunci `service_role` hanya ada pada rahasia fungsi di Supabase, dan
organisasi Supabase dibuat di bawah akun milik Photo.Jo dengan pengembang sebagai anggota,
bukan sebaliknya. Repositori GitHub dan proyek Vercel saat ini berada pada akun pengembang dan
direncanakan dipindahkan ke Photo.Jo.

#figure(
  caption: [Daftar periksa penerapan],
  table(
    columns: (1fr, 3cm),
    align: (left, left),
    table.header([*Butir pemeriksaan*], [*Keadaan*]),
    [Tinjauan RLS tiga lapis dan pendaftaran mandiri Auth dimatikan], [Selesai, diuji],
    [Harga cadangan statis sama dengan katalog], [Selesai],
    [Subdomain panel, HTTPS, dan `manage-users` aktif], [Selesai],
    [Email undangan staf terkirim melalui SMTP Resend], [Selesai, diuji],
    [Peralihan `www.photojo.id` dan domain], [Ditangani Photo.Jo],
  ),
) <tbl-periksa>
