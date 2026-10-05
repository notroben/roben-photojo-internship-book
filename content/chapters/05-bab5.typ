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
// Listing pendek selalu utuh; hanya listing panjang (kode-panjang) yang boleh terpotong.
#let kode-panjang(body) = {
  show figure.where(kind: "kode"): set block(breakable: true)
  body
}

= IMPLEMENTASI SISTEM

Bab ini membahas implementasi sistem yang dikerjakan selama kerja praktik. Potongan kode
diambil dari repositori proyek dan diringkas agar sesuai dengan halaman laporan. Komentar
pada potongan kode diterjemahkan ke dalam bahasa Indonesia, sedangkan nama berkas, fungsi,
kolom, dan pesan galat dipertahankan. Bagian yang dihilangkan ditandai dengan elipsis.

== Lingkungan dan Tahapan Implementasi

=== Lingkungan Pengembangan

Perangkat yang dipakai telah dirangkum pada @tbl-software. Pengembangan dilakukan secara
lokal: halaman disajikan oleh server statis `serve.py` yang mengirim header `no-store`,
sedangkan basis data, autentikasi, penyimpanan, dan fungsi dijalankan oleh tumpukan
Supabase lokal pada Docker. Server statis bawaan Python tidak mengirim header _cache_
sehingga peramban dapat memakai modul JavaScript yang usang. Gejalanya berupa galat
`does not provide an export named` terhadap berkas yang jelas memuat ekspor tersebut,
dan masalah itu tidak muncul pada Vercel yang selalu memvalidasi ulang berkas statis.

Basis data lokal diisi data demo oleh skrip `seed-demo.mjs`, yang membuat 69 pesanan
dalam berbagai keadaan, lengkap dengan pembayaran, bukti transfer, voucher, pengumuman,
_leads_, dan akun staf. Skrip ini memasukkan data melalui pintu yang sama dengan
penggunaan nyata, yaitu `create_order()` dan `record_manual_payment()`, sehingga
penomoran, invoice, klaim kapasitas, dan log aktivitas terbentuk seperti pada kondisi
sebenarnya. Skrip hanya berjalan terhadap tumpukan lokal: alamat API-nya diarahkan ke
`127.0.0.1` dan basis datanya dijangkau lewat kontainer Docker lokal, sehingga tidak ada
permintaannya yang dapat mencapai proyek produksi. Data yang dibuatnya dapat dikenali
(nomor telepon yang bukan nomor nyata, kode `demo-*`, dan akun `@demo.photojo.test`)
sehingga dapat dihapus tanpa menyentuh data lain.

=== Tahapan Implementasi

Implementasi dikerjakan bertahap dan mengikuti fase yang ditetapkan pada dokumen
perancangan. Setiap fase berakhir pada titik evaluasi yang menentukan apakah pekerjaan
dilanjutkan, sehingga setiap fase menghasilkan sesuatu yang dapat dipakai sendiri.
@tbl-tahap merangkum tahapan beserta periodenya menurut riwayat repositori.

#allow-table-break[#figure(
  caption: [Tahapan implementasi menurut riwayat repositori],
  table(
    columns: (0.8cm, 3cm, 2.8cm, 1fr),
    align: (center, left, left, left),
    table.header([*No*], [*Tahap*], [*Periode (2026)*], [*Hasil*]),
    [1.], [Situs publik], [13 sampai 30 Juli], [Halaman Home, Business, Application, dan Service; pengalaman interaktif _photostrip_, galeri polaroid, dan simulator; sistem desain.],
    [2.], [Pemodelan 3D], [Juli sampai 11 Agustus], [Tiga model unit _photobox_ dalam format `.glb`: Kiosk Slim diperbarui 4 Agustus, Velvet Booth 6 Agustus, dan Cabin Booth 10 Agustus.],
    [3.], [Fase 0: fondasi], [13 Agustus], [Skema awal, kebijakan RLS, autentikasi staf, fungsi `manage-users`, dan kerangka panel admin.],
    [4.], [Fase 1: calon pelanggan], [13 Agustus], [Gerbang formulir kontak pada simulator, penghitung `gate_events`, layar Leads dan Dashboard.],
    [5.], [Fase 2: harga dan ketersediaan], [Sampai 19 Agustus], [Katalog dinamis, promosi, lokasi dengan kapasitas, kalender ketersediaan, dan cadangan statis.],
    [6.], [Fase 3: konten dinamis], [20 sampai 27 Agustus], [Penyimpanan gambar, kompresi, pengelolaan media dan ulasan, serta tampilan publik yang membaca data.],
    [7.], [Fase 4: pemesanan dan penagihan], [2 sampai 30 September], [Jendela pemesanan, `create_order`, layar Orders, pembayaran manual, invoice, voucher, FAQ dan studio dinamis, pengumuman, kalender baru, dan pemindahan jadwal.],
    [8.], [Penguatan dan peluncuran], [17 September sampai 5 Oktober], [Tinjauan keamanan lanjutan, header HTTP, pelacakan UTM, gambar berbagi, serta persiapan penerapan pada nama domain bersama Photo.Jo.],
  ),
) <tbl-tahap>]

== Implementasi Basis Data

=== Migrasi Skema

Skema dikelola sebagai 32 berkas migrasi SQL pada folder `supabase/migrations`, bernomor
berurutan dan diterapkan dengan Supabase CLI, baik ke tumpukan lokal maupun ke proyek
terkelola. @tbl-migrasi mengelompokkan migrasi menurut isinya. Migrasi bersifat tambahan:
bagian yang perlu berubah tidak disunting pada berkas lama, melainkan ditulis ulang utuh
pada migrasi baru. Fungsi `create_order`, misalnya, didefinisikan pada migrasi 12 dan ditulis
ulang pada tujuh migrasi berikutnya seiring bertambahnya aturan bisnis.

#figure(
  caption: [Kelompok migrasi basis data],
  table(
    columns: (1.9cm, 1fr),
    align: (left, left),
    table.header([*Migrasi*], [*Isi*]),
    [00 sampai 03], [Skema awal (profil, katalog, ketersediaan, pemesanan, konten), kebijakan RLS, penghitung gerbang formulir, dan data awal katalog.],
    [04 sampai 10], [Audit add-on layanan, lencana promo, pemesanan luar situs, hak akses _view_, media konten, sorotan layanan, dan batas panjang teks.],
    [11 sampai 15], [Tabel pesanan fase 4, fungsi `create_order`, tanggal yang memblokir, nama aktor yang unik, dan penghapusan undangan.],
    [16 sampai 24], [Rincian invoice, aturan pembayaran, _lead_ khusus WhatsApp, invoice dengan masa berlaku dan bukti pembayaran, tanggal bayar, alamat penagihan, pencabutan hak `EXECUTE` publik, dan kolom isian _lead_.],
    [25 sampai 31], [FAQ dan studio sebagai data, voucher, pengumuman dan urutan daftar, sumber diskon, paket kustom dan jam acara, serta pemindahan jadwal.],
  ),
) <tbl-migrasi>

Migrasi yang mengubah hak akses atau fungsi penting diakhiri blok pemeriksaan yang
mengeluarkan galat bila keadaan skema tidak sesuai harapan, misalnya bila suatu fungsi masih
dapat dipanggil peran yang tidak semestinya. Dengan cara ini penerapan yang keliru berhenti
pada migrasinya sendiri dan tidak diam-diam menghasilkan sistem yang longgar.

=== Pemicu Penjaga Kapasitas

Kapasitas tanggal adalah aturan yang paling mahal bila dilanggar, karena uang dapat
diterima untuk tanggal yang tidak dapat dilayani. Aturan ini karenanya dijaga oleh basis
data dan bukan oleh panel atau situs. @kode-kapasitas menunjukkan pemicu yang berjalan
sebelum sebuah klaim ditambahkan. Baris tanggal dikunci dengan `FOR UPDATE` sebelum klaim
dihitung. Tanpa kunci itu, dua penyisipan yang berjalan bersamaan sama-sama membaca
jumlah klaim sebelum penyisipan, sama-sama menemukan ruang, dan sama-sama berhasil.

#kode-panjang[#kode-sumber(caption: [Pemicu penjaga kapasitas tanggal (diringkas)], ```sql
create or replace function enforce_slot_capacity()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cap  int;
  v_used int;
begin
  -- Klaim yang dilepas tidak menempati kapasitas.
  if new.status not in ('held', 'confirmed') then
    return new;
  end if;

  -- Baris tanggal dikunci sebelum klaim dihitung.
  select coalesce(s.capacity_override, l.daily_capacity)
    into v_cap
  from availability_slots s
  join locations l on l.id = s.location_id
  where s.id = new.slot_id
  for update of s;

  select count(*) into v_used
  from slot_claims c
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

create trigger slot_claims_enforce_capacity
  before insert or update on slot_claims
  for each row execute function enforce_slot_capacity();
```) <kode-kapasitas>]

Fungsi pada @kode-kapasitas dideklarasikan `SECURITY DEFINER`, dan itu bukan hiasan. Fungsi
pemicu berjalan dengan hak pemanggil sehingga kebijakan RLS ikut berlaku pada semua yang
dibacanya, padahal fungsi ini menggabungkan tabel `locations` yang tidak dapat dibaca
operator. Bagi operator hasil gabungan itu kosong, kapasitas bernilai kosong, dan setiap
pencatatan pemesanan luar situs oleh operator gagal. Kesalahan ini tidak tampak sebagai
lubang keamanan karena gagal secara tertutup; sistem hanya tidak bekerja bagi peran yang
justru bertugas mengerjakan layar itu. Kesalahan ini ditemukan dengan menguji sebagai
operator, bukan sebagai superadmin tempat layar itu pertama kali ditulis. Aturan yang
dipetik: pemicu yang membaca tabel yang tidak dapat dilihat pemanggilnya harus berstatus
_definer_, atau ia tidak menegakkan apa pun bagi pengguna yang dituju.

=== Log Aktivitas dan Pelindung Akun

Log aktivitas diisi oleh satu fungsi pemicu generik yang dipasang pada tabel-tabel penting.
Seperti terlihat pada @kode-audit, nilai sebelum dan sesudah disimpan dalam JSON, dan email
pelaku disalin pada saat kejadian, bukan digabungkan ketika log dibaca. Tabel `audit_log`
tidak memiliki kebijakan tulis untuk peran mana pun, sehingga satu-satunya penulisnya adalah
pemicu ini dan catatan tidak dapat disunting atau dihapus.

#kode-sumber(caption: [Pemicu log aktivitas generik (diringkas)], ```sql
create or replace function write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id    uuid := auth.uid();
  v_actor_email text;
begin
  -- Email pelaku disalin saat itu juga,
  -- bukan digabung ketika log dibaca.
  if v_actor_id is not null then
    select p.email into v_actor_email
    from profiles p where p.user_id = v_actor_id;
  end if;

  if (tg_op = 'UPDATE') then
    insert into audit_log(
      actor_user_id, actor_email, action,
      table_name, record_id, before, after)
    values (
      v_actor_id, v_actor_email, 'update',
      tg_table_name, new.id,
      to_jsonb(old), to_jsonb(new));
    return new;
  end if;
  -- ... cabang INSERT dan DELETE serupa
end;
$$;
```) <kode-audit>

Dua pemicu lain pada tabel `profiles` melindungi pengelolaan akun. RLS bekerja per baris,
bukan per kolom, sehingga kebijakan yang mengizinkan pengguna memperbarui profilnya sendiri
agar dapat menyelesaikan undangan akan sekaligus mengizinkannya menetapkan dirinya sebagai
superadmin. Pemicu `guard_profile_self_update` menolak perubahan peran, status akses, email,
dan pengundang pada baris sendiri, dan hanya mengizinkan satu perubahan status, yaitu dari
`invited` menjadi `active`. @kode-superadmin memperlihatkan pemicu kedua yang menolak
perubahan apa pun yang menyisakan nol superadmin aktif, dari jalur mana pun perubahan itu
datang.

#kode-sumber(caption: [Pemicu penjaga superadmin terakhir (diringkas)], ```sql
create or replace function guard_last_superadmin()
returns trigger
language plpgsql
as $$
begin
  if (old.role = 'superadmin' and old.is_active
      and old.status = 'active')
     and (new.role <> 'superadmin' or not new.is_active
          or new.status <> 'active')
     and active_superadmin_count() <= 1
  then
    raise exception
      'Cannot remove or demote the last '
      'active superadmin.';
  end if;
  return new;
end;
$$;
```) <kode-superadmin>

== Implementasi Keamanan

=== Row Level Security

RLS diaktifkan dan dipaksakan pada setiap tabel. Perintah `FORCE` diperlukan karena beberapa
tabel dimiliki peran `postgres` yang menjalankan migrasi, dan pemilik tabel melewati RLS biasa.
Kebijakan menentukan hak akses dengan bantuan fungsi `current_user_role()` yang membaca peran
dari profil aktif pemanggil. Fungsi itu berstatus `SECURITY DEFINER` agar dapat membaca tabel
`profiles` tanpa berulang melalui kebijakan tabel itu sendiri. @kode-rls menunjukkan pola yang
dipakai, dengan tabel `packages` sebagai contoh.

#kode-sumber(caption: [Pola RLS: aktifkan, peran pemanggil, dan kebijakan (disederhanakan)], ```sql
-- Aktifkan dan paksa RLS (pemilik tabel ikut tunduk).
alter table packages enable row level security;
alter table packages force row level security;

-- Peran pemanggil, dibaca dari profil yang aktif.
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

Pengujian di tumpukan lokal menunjukkan bahwa RLS mempersempit hak `GRANT` dan tidak
menggantikannya. Migrasi yang dijalankan lewat CLI berjalan sebagai `postgres`, yang
memiliki hak bawaan jauh lebih sempit daripada peran yang dipakai dasbor Supabase. Tanpa
`GRANT` dasar, setiap kebijakan tidak terjangkau: kueri gagal pada hak dasar dengan galat
_permission denied_ sebelum RLS sempat menyaring satu baris pun. Migrasi 1 karenanya
memberikan hak dasar secara luas, dan kebijakanlah yang sepenuhnya menentukan akses
sebenarnya.

=== View dan Fungsi Publik

Pengunjung perlu melihat status tanggal, tetapi tidak perlu dan tidak boleh mengetahui
berapa banyak pesanan yang masuk. Kalender publik karenanya dibaca dari _view_
`public_availability` pada @kode-view, yang menghitung label status di server dan tidak
mengirim jumlah pemesanan, kapasitas, catatan, maupun baris klaim ke peramban. _View_ dibuat
dengan `security_invoker = false` sehingga berjalan dengan hak pemiliknya dan tidak
tersandung RLS pada tabel dasarnya.

#kode-sumber(caption: [View status tanggal untuk kalender publik], ```sql
create or replace view public_availability
with (security_invoker = false) as
select
  s.location_id,
  l.slug as location_slug,
  s.date,
  case
    when s.is_blocked then 'full'
    when s.booked_count >= coalesce(
           s.capacity_override, l.daily_capacity)
         then 'full'
    when s.booked_count > 0 then 'half'
    else 'available'
  end as state
from availability_slots s
join locations l on l.id = s.location_id
where l.is_active;

grant select on public_availability
  to anon, authenticated;
```) <kode-view>

Fungsi yang dipanggil pelanggan dibatasi dengan hak `EXECUTE`. Tinjauan keamanan pada 17
September 2026 menemukan celah yang tidak tampak dari membaca kebijakan: Postgres memberikan
`EXECUTE` kepada `PUBLIC` ketika sebuah fungsi dibuat, dan mencabutnya dari `anon` tidak
menyentuh pemberian itu karena `anon` mewarisinya melalui `PUBLIC`. Pada tiga fungsi,
pencabutan dari `anon` saja ternyata tidak efektif. Fungsi `next_order_code()` tidak memiliki
pemeriksaan sendiri dan memanggil `nextval()`; dua panggilan anonim memajukan urutan kode
pesanan dari 202 ke 204, sehingga orang asing dapat menentukan nomor pesanan berikutnya dan
mengetahui jumlah pesanan tahun itu. Migrasi 23 mencabut hak dari `PUBLIC`, menegaskan
kembali hak bagi pengguna terautentikasi, dan menambahkan pemeriksaan yang gagal bila
`anon` masih dapat memanggilnya, seperti pada @kode-revoke.

#kode-sumber(caption: [Pencabutan hak EXECUTE publik beserta pemeriksaannya (diringkas)], ```sql
-- EXECUTE diberikan ke PUBLIC saat fungsi dibuat;
-- mencabutnya dari anon saja tidak cukup.
revoke execute on function next_order_code()
  from public, anon, authenticated;

revoke execute on function set_order_cancelled(uuid)
  from public, anon;
grant execute on function set_order_cancelled(uuid)
  to authenticated;

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

Hasil akhirnya, fungsi yang dibuka secara eksplisit bagi pengunjung hanya `create_order`,
`public_invoice`, dan `voucher_lookup`. Beberapa fungsi pembaca yang tidak mengubah data,
seperti `dp_minimum()` dan `balance_due_days()`, tetap dapat dipanggil karena hak bawaan
`PUBLIC`. Hal ini dicatat dan diterima, sebab jendela pemesanan memakainya untuk menampilkan
pratinjau aturan pembayaran dan tidak satu pun membuka isi baris.

=== Edge Function manage-users

Pengelolaan akun mencakup operasi yang tidak dapat dilakukan peran biasa mana pun, yaitu
membuat dan menghapus baris pada skema `auth.users`. Operasi itu membutuhkan kunci
`service_role`, yang tidak boleh berada di peramban, sehingga dikerjakan oleh Edge Function
`manage-users` pada Supabase. Fungsi ini menerima tujuh tindakan: `invite`, `reset`,
`remove`, `reactivate`, `delete_invite`, `rename`, dan `role_change`.

Pemeriksaan pertama berlaku untuk semua tindakan: pemanggil harus superadmin aktif.
Seperti terlihat pada @kode-manage-users, profil pemanggil dibaca melalui klien yang terikat
pada token milik pemanggil sendiri, sehingga hanya baris profilnya sendiri yang dapat
dikembalikan. Pemeriksaan ini tidak dapat dipalsukan dengan mengirim `user_id` lain pada
badan permintaan.

#kode-sumber(caption: [Gerbang superadmin pada Edge Function manage-users (diringkas)], ```ts
const callerId = ctx.userClaims?.id;

// Profil dibaca dengan klien milik pemanggil (terikat
// JWT-nya), jadi hanya profilnya sendiri yang kembali.
const { data: callerProfile, error: callerErr } =
  await ctx.supabase
    .from("profiles")
    .select("id, role, status, is_active")
    .eq("user_id", callerId)
    .single();

if (callerErr || !callerProfile) {
  return json({
    ok: false,
    error: "No profile found for the calling account",
  }, 403);
}
if (callerProfile.role !== "superadmin" ||
    callerProfile.status !== "active" ||
    !callerProfile.is_active) {
  return json({
    ok: false,
    error: "Superadmin access required",
  }, 403);
}

switch (body.action) {
  case "invite":
    return await handleInvite(
      ctx, callerProfile.id, body);
  case "reset":
    return await handleReset(ctx, body);
  case "remove":
    return await handleRemove(ctx, body);
  case "role_change":
    return await handleRoleChange(ctx, body);
  // ... reactivate, delete_invite, rename
}
```) <kode-manage-users>

Klien dengan hak `service_role` hanya dipakai pada dua tempat, yaitu `inviteUserByEmail` dan
`deleteUser`. Semua penulisan lain melalui klien milik pemanggil. Alasannya dua. Pertama,
`auth.uid()` di dalam penulisan menjadi identitas pemanggil sehingga pemicu log aktivitas
mencatat siapa yang bertindak; penulisan dengan `service_role` tidak membawa identitas dan
akan tercatat sebagai tindakan sistem. Kedua, kebijakan RLS pada `profiles` menjadi
pemeriksaan kedua yang berdiri sendiri di atas pemeriksaan peran pada kode fungsi.
Penjagaan superadmin terakhir sengaja tidak ditulis ulang di dalam fungsi; ia berada pada
pemicu basis data (@kode-superadmin) sehingga tidak dapat dilewati oleh jalur kode mana pun,
termasuk fungsi ini.

#kode-sumber(caption: [Tindakan undangan pada manage-users (diringkas)], ```ts
// Satu-satunya operasi yang butuh service_role:
// membuat baris auth.users lewat Admin API.
const { data: invited, error: inviteErr } =
  await ctx.supabaseAdmin.auth.admin.inviteUserByEmail(
    email, { redirectTo: adminUrl() });

// Kembali ke klien pemanggil agar auth.uid()
// tercatat pada log aktivitas.
const { error: profileErr } = await ctx.supabase
  .from("profiles").insert({
    user_id: invited.user.id,
    email,
    full_name: fullName,
    role,
    status: "invited",
    is_active: true,
    invited_by: callerProfileId,
    invited_at: new Date().toISOString(),
  });
```) <kode-invite>

Alur undangan berjalan sebagai berikut. Superadmin mengisi email, nama, dan peran pada layar
Users. Fungsi membuat akun dan mengirim email berisi tautan, lalu mencatat profil dengan
status `invited`. Penerima membuka tautan yang mendarat pada `admin.html` dalam keadaan
_atur kata sandi_ dan tidak pernah menampilkan panel; saat kata sandi disimpan, penerima
sendiri yang mengubah status profilnya menjadi `active`. Pengiriman email memakai Resend
melalui SMTP yang diatur pada Supabase, karena pengirim bawaan Supabase dibatasi lajunya dan
hanya ditujukan bagi pengujian.

=== Header HTTP dan Berkas yang Tidak Diterapkan

Tinjauan keamanan yang sama menemukan celah pada penerapan, bukan pada basis data. Vercel
menyajikan setiap berkas repositori pada alamatnya sendiri, ditautkan atau tidak. Pada
penerapan percobaan, dokumen perancangan, tinjauan RLS, konfigurasi Supabase, dan setiap
berkas migrasi dapat diunduh. Tidak ada kunci yang bocor, dan RLS tetap berdiri di antara
pembaca dan data, tetapi tebakan tentang nama fungsi, bentuk argumen, dan peran yang
memegang tiap tindakan menjadi tidak perlu. Berkas `.vercelignore` kini mengecualikan
`*.md`, `supabase/`, `scripts/`, `references/`, dan `test-pages/`.

Header respons ditetapkan pada `vercel.json` seperti pada @kode-vercel. Selain header
keamanan, berkas ini menyalakan `cleanUrls` karena tag kanonik halaman menyebut alamat tanpa
ekstensi, serta memuat dua aturan berdasarkan nama host: pada `www`, alamat `/admin`
dialihkan ke subdomain panel, sedangkan pada subdomain panel, akar situs membuka
`admin.html`. Aturan berdasarkan host ini hanya dapat diuji setelah kedua domain terpasang
pada penerapan, tidak secara lokal.

#kode-sumber(caption: [Konfigurasi Vercel: pengalihan host dan header keamanan (diringkas)], ```json
{
  "cleanUrls": true,
  "redirects": [{
    "source": "/admin",
    "has": [{ "type": "host",
              "value": "www.photojo.id" }],
    "destination": "https://dashboard.photojo.id/",
    "permanent": false
  }],
  "rewrites": [{
    "source": "/",
    "has": [{ "type": "host",
              "value": "dashboard.photojo.id" }],
    "destination": "/admin.html"
  }],
  "headers": [{
    "source": "/(.*)",
    "headers": [
      { "key": "X-Frame-Options", "value": "DENY" },
      { "key": "Content-Security-Policy",
        "value": "frame-ancestors 'none'" },
      { "key": "X-Content-Type-Options",
        "value": "nosniff" },
      { "key": "Referrer-Policy",
        "value": "strict-origin-when-cross-origin" },
      { "key": "Permissions-Policy",
        "value": "camera=(self), microphone=(), ..." }
    ]
  }]
}
```) <kode-vercel>

Header `frame-ancestors 'none'` menjadi yang terpenting: panel admin yang dapat dibingkai
oleh halaman lain adalah cara sesi staf yang sedang masuk dapat diklik melalui lapisan
transparan. Izin kamera hanya diberikan kepada halaman sendiri karena demo _photostrip_ memanggil
`getUserMedia`; mikrofon, geolokasi, pembayaran, dan USB ditutup.

== Implementasi Logika Bisnis di Server

=== Pembuatan Pesanan

Fungsi `create_order(p jsonb)` adalah satu-satunya jalan pembuatan pesanan, baik dari situs
maupun dari panel staf. Fungsi ini berstatus `SECURITY DEFINER` dan dapat dipanggil
pengunjung tanpa akun. Seluruh parameter diterima sebagai satu objek JSON. Parameter
`source` menentukan mode, yaitu `web` bagi pelanggan dan `manual` bagi staf, dan yang
berbeda di antara keduanya hanya izin, bukan logika. Pesanan manual membuka beberapa
kelonggaran khusus staf: paket yang hanya boleh dipesan lewat WhatsApp, kota di luar
jangkauan, butir bebas, potongan manual, tanggal yang sudah lewat, dan nama penagihan
perusahaan. Dengan satu jalur, harga, kapasitas, dan validasi tidak punya salinan kedua
yang dapat menyimpang.

@kode-create-order-1 menunjukkan bagian awal fungsi. Harga dibaca dari katalog dan tidak
dari permintaan, sehingga yang dikirim peramban hanyalah kode paket. Nomor WhatsApp
dinormalisasi sehingga `0812…`, `+62 812…`, dan `812…` menjadi satu bentuk, lalu
divalidasi bentuknya. Panjang saja bukan validasi, sebab `123123123123` terdiri atas dua
belas angka. Yang menolak angka sembarang adalah awalan operator seluler, yaitu angka 8
setelah kode negara. Nomor telepon rumah sengaja ditolak karena nomor yang dikumpulkan
adalah nomor yang akan dihubungi staf lewat WhatsApp, bukan untuk ditelepon.

#kode-panjang[#kode-sumber(caption: [Bagian awal create_order: mode, harga, dan nomor WhatsApp (diringkas)], ```sql
create or replace function create_order(p jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_staff    boolean := is_staff();
  v_manual   boolean;
  v_subtotal bigint := 0;
  -- ... variabel lain
begin
  v_manual := coalesce((p ->> 'source') = 'manual', false);
  if v_manual and not v_staff then
    raise exception
      'Hanya staf yang bisa membuat pesanan manual.'
      using errcode = 'insufficient_privilege';
  end if;

  -- Harga dibaca dari katalog, bukan dari permintaan.
  select * into v_package from packages
   where service_id = v_service.id
     and code = (p ->> 'package_code') and is_active;

  -- Paket khusus WhatsApp ditolak bila dipesan dari situs.
  if not v_manual
     and v_package.booking_mode <> 'automated' then
    raise exception
      'Paket ini hanya bisa dipesan lewat WhatsApp.'
      using errcode = 'insufficient_privilege';
  end if;
  v_subtotal := v_package.price;

  -- 0812..., +62 812..., dan 812... menjadi 62812...
  v_wa := regexp_replace(v_contact, '[^0-9]', '', 'g');
  if left(v_wa, 1) = '0' then
    v_wa := '62' || substring(v_wa from 2);
  elsif left(v_wa, 2) <> '62' then
    v_wa := '62' || v_wa;
  end if;
  -- Awalan operator 8 yang menolak angka sembarang.
  if v_wa !~ '^628[1-9][0-9]{6,11}$' then
    raise exception 'Nomor WhatsApp tidak valid.'
      using errcode = 'check_violation';
  end if;
```) <kode-create-order-1>]

Add-on divalidasi satu per satu: harus terdaftar untuk layanan itu pada `service_addons`,
memerlukan paket tertinggi bila bertanda `requires_top_tier`, dan jumlahnya dibatasi
fungsi `addon_line_cap` yang mengambil batas tetap atau batas yang diturunkan dari durasi
paket. Tanggal dinilai pada zona waktu WIB (`Asia/Jakarta`), bukan UTC milik basis data.
Antara tengah malam dan pukul 07.00 WIB tanggal UTC masih hari kemarin, yang akan
menggeser aturan hari sebelum acara sebanyak satu hari.

Bagian berikutnya pada @kode-create-order-2 menangani potongan harga dan pembatasan laju.
Tepat satu dari tiga sumber potongan berlaku: nilai manual dari staf, kode voucher, atau
promosi otomatis `best_promotion()`. Voucher sengaja tidak dibandingkan dengan promosi untuk
dipilih yang lebih besar, sebab pelanggan yang diberi kode tertentu seharusnya mendapat
persis apa yang dijanjikan kode itu. Kuota voucher dipakai dalam transaksi yang sama dengan
pembuatan pesanan. Klausa `WHERE` pada `UPDATE` adalah penjaga atomik: bila pesanan lain
sudah mengambil pemakaian terakhir di antara pemeriksaan pelanggan dan saat ini, `UPDATE`
tidak mengenai baris dan seluruh pesanan ditolak, bukan dua pelanggan yang berbagi satu
pemakaian. Bila langkah berikutnya gagal, transaksi digulung balik dan pemakaian voucher
tidak terpakai.

Pembatasan laju diletakkan pada fungsi ini karena fungsi dapat dipanggil langsung oleh siapa
pun yang memegang kunci publik tanpa melewati peramban: satu nomor WhatsApp paling banyak
memiliki lima pesanan yang belum dibayar dalam satu jam, dengan staf dikecualikan.

#kode-panjang[#kode-sumber(caption: [Bagian create_order: voucher yang atomik dan pembatasan laju (diringkas)], ```sql
  -- Voucher dicek, lalu kuotanya dipakai pada transaksi
  -- yang sama dengan pembuatan pesanan.
  select voucher_id, discount, error
    into v_voucher_id, v_discount, v_voucher_err
  from voucher_lookup(p ->> 'voucher_code', v_service.slug,
                      v_package.code, v_subtotal);
  if v_voucher_err is not null then
    raise exception '%', v_voucher_err
      using errcode = 'check_violation';
  end if;

  -- Penjaga atomik: bila kuota baru saja habis oleh pesanan
  -- lain, UPDATE tidak mengenai baris dan pesanan ditolak.
  update vouchers
     set times_redeemed = times_redeemed + 1
   where id = v_voucher_id
     and (max_redemptions is null
          or times_redeemed < max_redemptions);
  if not found then
    raise exception
      'Kuota kode voucher ini baru saja habis.'
      using errcode = 'check_violation';
  end if;

  -- ...

  -- Pembatasan laju: paling banyak 5 pesanan belum dibayar
  -- per jam untuk satu nomor WhatsApp (staf dikecualikan).
  if not v_staff then
    select count(*) into v_pending
    from orders
    where status in ('draft', 'sent', 'awaiting_payment')
      and created_at > now() - interval '1 hour'
      and customer_whatsapp = v_wa;
    if v_pending >= 5 then
      raise exception
        'Terlalu banyak pesanan dari kontak ini.'
        using errcode = 'check_violation';
    end if;
  end if;
```) <kode-create-order-2>]

Pesanan yang dibuat berstatus `awaiting_payment`, berlaku 48 jam, dan memiliki tenggat
pelunasan H-3. Baris butir pesanan dibaca ulang dari tabel katalog pada saat disalin, bukan
dari masukan. Fungsi diakhiri dengan menerbitkan invoice `/01` dan mengembalikan satu
objek berisi id, kode, token invoice, nomor invoice, dan total.

=== Pencatatan Pembayaran dan Penguncian Tanggal

Pencatatan pembayaran dibagi menjadi dua fungsi. `apply_payment` bersifat internal, dan
hak `EXECUTE` atasnya dicabut dari semua peran. `record_manual_payment` adalah pintu bagi
staf: ia memanggil `apply_payment` lalu `issue_invoice` dan mengembalikan status pesanan,
sisa tagihan, keadaan tanggal, dan nomor invoice yang baru. Pembagian ini membuat aturan
pembayaran hanya ada pada satu tempat dan dapat dipakai pula oleh `create_order` ketika staf
membuat pesanan yang sudah menerima uang.

Bagian terpenting `apply_payment` ditunjukkan pada @kode-apply-payment. Baris pesanan
dikunci terlebih dahulu, dan jumlah yang melebihi sisa tagihan ditolak karena tidak ada
pengembalian dan uang berlebih hanya dapat berarti salah ketik. Baris tanggal dibuat bila
belum ada, lalu dikunci sebelum dibaca sehingga dua pembayaran yang berebut tanggal terakhir
diputuskan satu per satu. Bila tanggal ditutup atau sudah penuh oleh pesanan lain, pembayaran
ditolak dan tidak ada yang tercatat. Klaim terkonfirmasi baru dibuat ketika total pembayaran
mencapai minimum DP, dan itulah saat tanggal terkunci.

#kode-panjang[#kode-sumber(caption: [Penguncian tanggal pada apply_payment (diringkas)], ```sql
  select * into v_order from orders
   where id = p_order_id for update;

  -- Uang berlebih hanya dapat dikembalikan, padahal tidak
  -- ada pengembalian: jumlah berlebih dianggap salah ketik.
  if p_amount > v_order.total - v_settled then
    raise exception 'Jumlah melebihi sisa tagihan (%).',
      format_rupiah(greatest(v_order.total - v_settled, 0))
      using errcode = 'check_violation';
  end if;

  if v_order.blocks_date and v_order.location_id is not null
     and not exists (
       select 1 from slot_claims
        where order_id = p_order_id
          and status in ('held', 'confirmed')) then
    insert into availability_slots (location_id, date)
    values (v_order.location_id, v_order.event_date)
    on conflict (location_id, date) do nothing;

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

    if v_blocked then
      raise exception
        'Tanggal acara pesanan ini sudah ditutup. ...';
    end if;
    if v_booked >= v_capacity then
      raise exception
        'Tanggal ... dikunci pesanan lain ...';
    end if;

    if v_settled + p_amount >=
       least(dp_minimum(), v_order.total) then
      insert into slot_claims
        (slot_id, order_id, status, expires_at)
      values (v_slot_id, p_order_id, 'confirmed', null)
      on conflict (slot_id, order_id) do update
        set status = 'confirmed', expires_at = null;
    end if;
  end if;
```) <kode-apply-payment>]

Pembatalan pembayaran yang salah catat dikerjakan fungsi `void_payment`. Fungsi ini hanya
dapat dijalankan admin ke atas dengan alasan sedikitnya tiga karakter, mengunci pesanan
lalu pembayaran dengan urutan yang sama seperti `apply_payment` agar tidak terjadi kebuntuan
(_deadlock_), menandai pembayaran sebagai dibatalkan, menghitung ulang status dan sisa
tagihan, melepas klaim tanggal bila sisa pembayaran turun di bawah minimum DP dan pesanan
tidak sedang dikunci tanpa DP, menandai BATAL setiap invoice yang terbit sesudah pembayaran
itu, lalu menerbitkan invoice koreksi.

=== Invoice

Penerbitan invoice dipusatkan pada fungsi `issue_invoice` seperti pada @kode-issue-invoice.
Baris pesanan dikunci sehingga nomor urut dihitung dengan aman: dua staf yang mencatat
pembayaran pada pesanan yang sama pada saat yang sama mendapat nomor yang berbeda, dan
kendala unik `(order_id, seq)` menjadi lapisan pengaman terakhir. Ini diuji pada tahap
tinjauan keamanan. Isi invoice tidak dihitung ulang ketika dibuka; fungsi `invoice_snapshot`
menyusunnya satu kali menjadi satu objek JSON yang memuat data penjual dari
`company_profile`, nama tagihan, rincian pesanan, butir, pembayaran, jumlah terbayar, sisa
tagihan, dan syarat pembayaran, lalu disimpan pada kolom `snapshot`.

#kode-sumber(caption: [Penerbitan invoice bernomor (diringkas)], ```sql
-- PJ-2026-0142 + 1 -> PJ/2026/0142/01
create or replace function invoice_number(
  p_code text, p_seq int)
returns text language sql immutable as $$
  select replace(p_code, '-', '/') || '/'
      || lpad(p_seq::text,
              greatest(2, length(p_seq::text)), '0')
$$;

create or replace function issue_invoice(
  p_order_id uuid, p_kind text,
  p_payment_id uuid default null
) returns text
language plpgsql security definer set search_path = public
as $$
declare v_code text; v_seq int; v_number text;
begin
  -- Baris pesanan dikunci: dua pencatatan bersamaan tidak
  -- dapat mengambil nomor yang sama.
  select code into v_code from orders
   where id = p_order_id for update;

  select coalesce(max(seq), 0) + 1 into v_seq
    from invoices where order_id = p_order_id;
  v_number := invoice_number(v_code, v_seq);

  insert into invoices (order_id, seq, number, kind,
                        payment_id, snapshot, issued_by)
  values (p_order_id, v_seq, v_number, p_kind, p_payment_id,
          invoice_snapshot(p_order_id)
            || jsonb_build_object(
                 'number', v_number,
                 'seq', v_seq, 'kind', p_kind),
          current_profile_id());
  return v_number;
end;
$$;
```) <kode-issue-invoice>

Pelanggan tidak memiliki sesi, sehingga halaman invoice menjangkau pesanannya melalui token
acak 122 bit pada `orders.public_token`. Pada rancangan awal fungsi ini direncanakan sebagai
Edge Function karena `company_profile` tidak dapat dibaca pengunjung. Hal itu ternyata tidak
perlu: yang dikembalikan adalah salinan beku yang dialamatkan ke satu pesanan, sehingga
tidak memerlukan kunci yang tidak boleh dimiliki peramban dan tidak ada yang perlu
diterapkan terpisah. @kode-public-invoice menunjukkan fungsi `public_invoice` yang
menggantikannya. Fungsi ini tidak dapat diperluas oleh argumennya, dan token yang salah
mengembalikan nilai kosong. Alasan pembatalan invoice, yang bersifat internal staf, tidak
ikut dikembalikan.

#kode-sumber(caption: [Fungsi publik pembaca invoice berdasarkan token], ```sql
create or replace function public_invoice(p_token uuid)
returns jsonb language sql stable
security definer set search_path = public
as $$
  select jsonb_build_object(
    'code', o.code, 'status', o.status,
    'expires_at', o.expires_at,
    'invoices', coalesce((
      select jsonb_agg(jsonb_build_object(
               'seq', i.seq, 'number', i.number,
               'issued_at', i.created_at,
               'voided', i.voided_at is not null,
               'snapshot', i.snapshot) order by i.seq)
        from invoices i where i.order_id = o.id
    ), '[]'::jsonb))
  from orders o
  where o.public_token = p_token
$$;

grant execute on function public_invoice(uuid)
  to anon, authenticated;
```) <kode-public-invoice>

=== Promosi, Voucher, dan Pengurutan Daftar

Dua fungsi lain melengkapi mesin harga. `best_promotion()` memilih promosi yang aktif,
berada dalam jendela waktunya, dan cakupannya cocok, lalu mengurutkan menurut besar potongan
dan mengambil yang terbesar. Dengan cara ini pelanggan membayar paling sedikit dan hasilnya
tidak bergantung pada urutan baris atau jenis potongan. Fungsi `voucher_lookup()` bersifat
`STABLE` dan `SECURITY DEFINER`: ia membaca satu kode tanpa pernah mengembalikan barisnya,
dan hanya menjawab apakah kode itu berlaku, berapa potongannya, atau pesan galat berbahasa
Indonesia seperti kode tidak ditemukan, belum berlaku, kedaluwarsa, atau kuota habis. Tabel
`vouchers` tidak memiliki kebijakan baca untuk pengunjung agar seluruh daftar kode tidak dapat
diunduh. Rumus potongan juga ada di sisi klien, pada `discountedPrice()` dan `bestPromoFor()`
di `db.js`, dan dipakai bersama oleh pratinjau harga di panel admin dan oleh halaman publik
agar pratinjau yang dilihat admin sama persis dengan yang dilihat pelanggan.

Urutan daftar yang menentukan tampilan situs, yaitu galeri, ulasan, tanya jawab, pengumuman,
lokasi, dan studio, disimpan melalui satu fungsi, `reorder_rows`, seperti pada
@kode-reorder. Fungsi ini sengaja berstatus `SECURITY INVOKER` sehingga RLS tetap berlaku,
hanya menerima nama tabel dari daftar yang diizinkan, dan mengunci baris lebih dulu. Di
bawah RLS, penguncian hanya menjangkau baris yang boleh dilihat dan diubah pemanggil, sehingga
jumlah baris yang terkunci harus sama dengan daftar yang dikirim. Daftar yang sudah berubah
sejak dibuka di peramban, atau memuat baris yang tidak boleh disentuh, menghentikan seluruh
pemanggilan alih-alih menomori ulang sebagian daftar tanpa pemberitahuan. Hanya baris yang
posisinya benar-benar berpindah yang ditulis sehingga satu seretan tidak menulis seluruh
daftar ke log aktivitas.

#kode-sumber(caption: [Penyimpanan urutan daftar dengan reorder_rows (diringkas)], ```sql
create or replace function reorder_rows(
  p_table text, p_ids uuid[])
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  if p_table is null or p_table not in
     ('announcements', 'faq_items', 'locations',
      'media', 'reviews', 'studios') then
    raise exception
      'Daftar "%" tidak bisa diurutkan.', p_table
      using errcode = 'invalid_parameter_value';
  end if;

  -- Baris dikunci dulu. Di bawah RLS hanya baris yang boleh
  -- dilihat dan diubah pemanggil yang terkunci, jadi
  -- jumlahnya harus sama dengan daftar yang dikirim.
  execute format(
    'select count(*) from (select 1 from %I
       where id = any($1) for update) s', p_table)
    into v_locked using p_ids;
  -- ... galat bila v_locked <> cardinality(p_ids)

  -- Hanya baris yang benar-benar berpindah yang ditulis.
  execute format(
    'update %I t set sort_order = o.ord::int
       from unnest($1) with ordinality as o(id, ord)
      where t.id = o.id
        and t.sort_order is distinct from o.ord::int',
    p_table)
    using p_ids;
end;
$$;
```) <kode-reorder>

== Implementasi Situs Publik

=== Struktur Halaman dan Sistem Desain

Setiap halaman publik adalah satu berkas HTML mandiri dengan CSS pada blok `<style>` dan
JavaScript pada blok `<script>` di akhir berkas. Hanya sedikit modul yang dipakai bersama:
`db.js` untuk akses data, `order-window.js` untuk jendela pemesanan, `announce.js` untuk
kapsul pengumuman, `holidays.js`, dan `scrollbar.js`. Pilihan ini meniadakan tahap _build_,
dengan konsekuensi yang disadari: token desain dan komponen bersama seperti navigasi, kaki
halaman, dan tombol ditulis ulang pada setiap halaman, sehingga perubahan bersama harus
disalin satu per satu. @tbl-ukuran memberi gambaran ukuran pekerjaan.

#figure(
  caption: [Ukuran berkas utama (jumlah baris)],
  table(
    columns: (1fr, 2cm, 1fr),
    align: (left, right, left),
    table.header([*Berkas*], [*Baris*], [*Peran*]),
    [`admin.html`], [14.384], [Panel admin],
    [`application.html`], [5.494], [Halaman Application dan simulator],
    [`service.html`], [5.242], [Halaman Service dan keranjang],
    [`index.html`], [5.165], [Halaman Home],
    [`business.html`], [2.949], [Halaman Business dan pratinjau 3D],
    [`assets/js/db.js`], [2.460], [Klien Supabase dan fungsi data],
    [`assets/js/order-window.js`], [1.378], [Jendela pemesanan],
    [`supabase/functions/manage-users`], [442], [Edge Function akun staf],
    [`assets/js/announce.js`], [411], [Kapsul pengumuman],
    [`invoice.html` dan `invoice.js`], [667], [Halaman invoice],
    [`scripts/*`], [1.202], [Skrip data demo, sinkron cadangan, server lokal],
    [`supabase/migrations/*.sql`], [32 berkas], [Skema, kebijakan, dan fungsi],
  ),
) <tbl-ukuran>

Sistem desain yang dijabarkan pada Bab 4 diwujudkan sebagai variabel CSS (_custom
properties_) pada pemilih `:root` yang nilainya identik pada kelima halaman. @gbr-home-hero
menunjukkan hasilnya pada bagian hero halaman Home: latar gelap dengan cahaya teal, judul
berhuruf Comfortaa, navigasi berbentuk pil, dan dua tombol ajakan.

#gambar("../assets/figures/home-hero.png", caption: [Bagian hero halaman Home], width: 100%) <gbr-home-hero>

=== Data Dinamis dengan Cadangan Statis

Halaman Service membaca katalog melalui `getPublicCatalogue()` pada @kode-katalog. Fungsi ini
mengambil layanan beserta paketnya, add-on, dan tautan layanan dengan add-on dalam satu
`Promise.all`, lalu menyusunnya dalam bentuk yang sama dengan konstanta yang sebelumnya
tertulis pada halaman, sehingga penggantian cadangan statis dengan data hidup berupa
pertukaran data dan bukan penulisan ulang logika halaman. Hasilnya disimpan pada
`sessionStorage` agar berpindah halaman tidak mengambil ulang. Bila pengambilan gagal,
konstanta cadangan yang sudah tertulis pada HTML tetap dipakai dan pengunjung tidak melihat
perbedaan.

#kode-sumber(caption: [Pembacaan katalog publik dengan _cache_ sesi (diringkas)], ```js
const CATALOGUE_KEY = 'pj.catalogue.v1';

export async function getPublicCatalogue(
    { cache = true } = {}) {
  if (cache) {
    try {
      const hit = sessionStorage.getItem(CATALOGUE_KEY);
      if (hit) return JSON.parse(hit);
    } catch { /* mode privat/data rusak: ambil ulang */ }
  }

  const [services, addons, links] = await Promise.all([
    publicDb.from('services')
      .select(`slug, packages ( code, label, duration_label,
                 duration_hours, price, is_top_tier,
                 booking_mode, sort_order )`)
      .order('sort_order'),
    publicDb.from('addons')
      .select('id, code, label, price, unit, max_qty, '
            + 'cap_by_duration')
      .order('sort_order'),
    publicDb.from('service_addons')
      .select('service_id, addon_id, is_enabled'),
  ]);
  for (const r of [services, addons, links]) {
    if (r.error) throw r.error;
  }
  // ... disusun menjadi { tiers, addons, addonsByService }
}
```) <kode-katalog>

Cadangan statis dijaga agar tidak tertinggal oleh skrip `sync-fallbacks.mjs`. Skrip ini
mengambil katalog dari proyek, lalu menulis ulang bukan hanya konstanta JavaScript tetapi
juga harga yang tercetak pada markup, karena itulah yang dibaca mesin pencari. Mode
`--check` pada @kode-sinkron membandingkan hasil tanpa menulis dan keluar dengan status
gagal bila ada selisih, sehingga angka usang tidak ikut diterapkan. Cadangan yang
tertinggal setahun gagal secara meyakinkan, dan itu lebih buruk daripada tidak punya
cadangan.

#kode-sumber(caption: [Mode pemeriksaan pada sync-fallbacks.mjs (diringkas)], ```js
const changed = normalise(html) !== normalise(before);

if (CHECK_ONLY) {
  if (changed) {
    console.error(
      `✗ service.html fallback is STALE against the ` +
      `${ENV} catalogue.`);
    console.error('  Run: node scripts/sync-fallbacks.mjs');
    process.exit(1);
  }
  console.log(`✓ Fallback matches the ${ENV} catalogue.`);
  process.exit(0);
}
```) <kode-sinkron>

=== Pengalaman Photostrip

Bagian _Coba Sesi Photobooth Langsung di Browser_ pada halaman Home memungkinkan pengunjung
membuat _photostrip_ dengan kamera perangkatnya, seperti pada @gbr-home-photobox. Alur
dirancang sebagai mesin keadaan dengan tiga layar: pemilihan _frame_, sesi foto, dan layar
akhir. Pengunjung memilih satu dari enam _frame_ (putih, hitam, teal, krem, biru, dan
merah), lalu kamera dibuka dengan `getUserMedia` pada resolusi ideal 640 × 480, kamera depan,
dan tanpa audio. Setiap foto didahului hitung mundur lima detik dan dapat diulang. Setelah tiga
foto, kamera dimatikan dan hasil dapat diunduh. Pada perangkat iOS yang tidak mengizinkan
unduhan melalui tautan, hasil ditampilkan dalam dialog dengan petunjuk tekan lama untuk
menyimpan.

#gambar("../assets/figures/home-photobox.png", caption: [Pemilihan _frame_ pada pengalaman _photostrip_ interaktif], width: 100%) <gbr-home-photobox>

Foto dikerjakan seluruhnya di peramban dan tidak diunggah ke server; keterangan ini
dituliskan pada kartu agar pengunjung tahu. @kode-photostrip menunjukkan dua langkah
intinya. Pada pengambilan, bingkai video dipotong tengah agar sesuai rasio kotak foto
(480 × 400) dan dicerminkan sehingga hasilnya sama dengan yang dilihat pada pratinjau. Pada
penyusunan, ketiga foto digambar pada kanvas 500 × 1500 piksel, lalu _frame_ yang berupa
PNG dengan jendela transparan digambar paling akhir di atasnya.

#kode-panjang[#kode-sumber(caption: [Pemotongan bingkai kamera dan penyusunan _photostrip_ (diringkas)], ```js
const PB_SLOT_W = 480, PB_SLOT_H = 400, PB_SLOT_X = 10;
const PB_SLOTS_Y = [20, 440, 860];

function pbGetCroppedCameraURL() {
  const ctx = helperCanvas.getContext('2d');
  helperCanvas.width = PB_SLOT_W;
  helperCanvas.height = PB_SLOT_H;

  // Potong tengah video agar sesuai rasio kotak foto.
  const vW = pbVideoEl.videoWidth;
  const vH = pbVideoEl.videoHeight;
  const targetRatio = PB_SLOT_W / PB_SLOT_H;
  let sX = 0, sY = 0, sW = vW, sH = vH;
  if (vW / vH > targetRatio) {
    sW = vH * targetRatio; sX = (vW - sW) / 2;
  } else {
    sH = vW / targetRatio; sY = (vH - sH) / 2;
  }

  ctx.save();
  ctx.translate(PB_SLOT_W, 0);   // dicerminkan agar sama
  ctx.scale(-1, 1);              // dengan pratinjau
  ctx.drawImage(pbVideoEl, sX, sY, sW, sH,
                0, 0, PB_SLOT_W, PB_SLOT_H);
  ctx.restore();
  return helperCanvas.toDataURL('image/png');
}

async function pbCompileAndFinish() {
  pbOutputCanvas.width = 500;
  pbOutputCanvas.height = 1500;
  for (let i = 0; i < PB_PHOTO_COUNT; i++) {
    const photoImg = await pbLoadImageElement(
      pbCapturedPhotoURLs[i]);
    ctx.drawImage(photoImg, PB_SLOT_X, PB_SLOTS_Y[i],
                  PB_SLOT_W, PB_SLOT_H);
  }
  // Frame digambar terakhir, di atas foto.
  ctx.drawImage(frameImg, 0, 0, 500, 1500);
}
```) <kode-photostrip>]

=== Galeri Polaroid

Bagian galeri menampilkan foto sebagai polaroid yang dapat diseret di atas meja. Kartu
dilempar masuk dari kiri dan kanan saat bagian ini terlihat, mendarat dengan putaran acak,
dan dapat diseret dengan kelembaman. Satu pendengar `pointerdown` dipasang pada meja dan
memakai delegasi peristiwa, sehingga tetap bekerja walaupun kartu dibangun ulang saat
jendela diubah ukurannya. Kecepatan lepas dihitung dari lima sampel posisi terakhir dan
dirata-ratakan agar lonjakan sesaat tidak membuat kartu melesat. Setelah dilepas, kartu
meluncur melalui `requestAnimationFrame` dengan gesekan yang meluruhkan kecepatan dan
memantul pada tepi bagian seperti pada @kode-momentum.

Pada perangkat dengan penunjuk kasar (layar sentuh), tata letak tebaran digantikan grid tiga
kolom, seretan dinonaktifkan agar halaman dapat digulir dengan bebas, dan mengetuk kartu
memperbesarnya. Pemeriksaan jenis penunjuk dibuat sebagai fungsi yang dipanggil setiap
kali, bukan konstanta yang disimpan saat halaman dimuat. Bila disimpan, mengganti mode sentuh
pada alat pengembang akan membuat gaya dan skrip tidak sinkron dan kartu tidak terlihat sama
sekali. Foto galeri berasal dari tabel `media` (paling banyak 15 foto terbit). Slot yang
belum terisi memakai latar teal agar galeri yang masih sedikit tetap tampak disengaja.
@gbr-galeri menunjukkan tampilan galeri pada layar lebar. Foto-foto yang ditampilkan dipilih
dari daftar foto yang telah disetujui orang-orang di dalamnya dan boleh dipakai Photo.Jo
sebagai materi merek.

#gambar("../assets/figures/galeri-polaroid.png", caption: [Galeri polaroid pada halaman Home], width: 85%) <gbr-galeri>

#kode-sumber(caption: [Kelembaman dan pantulan kartu polaroid (diringkas)], ```js
const FRICTION = 0.88, MIN_VEL = 0.25;

function applyMomentum(card, velX, velY, velRot) {
  if (!card._bounds) return;
  const { minL, maxL, minT, maxT } = card._bounds;
  let curLeft = parseFloat(card.style.left);
  let curTop = parseFloat(card.style.top);

  curLeft += velX; curTop += velY; card._rot += velRot;

  // Memantul pada tepi, kehilangan 65% kecepatan.
  if (curLeft < minL) { curLeft = minL; velX *= -0.35; }
  if (curLeft > maxL) { curLeft = maxL; velX *= -0.35; }
  if (curTop < minT) { curTop = minT; velY *= -0.35; }
  if (curTop > maxT) { curTop = maxT; velY *= -0.35; }

  card.style.left = curLeft + 'px';
  card.style.top = curTop + 'px';
  card.style.transform = `rotate(${card._rot}deg)`;

  velX *= FRICTION; velY *= FRICTION; velRot *= FRICTION;
  if (Math.abs(velX) > MIN_VEL || Math.abs(velY) > MIN_VEL
      || Math.abs(velRot) > 0.04)
    card._momentumAnimId = requestAnimationFrame(
      () => applyMomentum(card, velX, velY, velRot));
  else
    card._momentumAnimId = null;
}
```) <kode-momentum>

=== Pratinjau 3D Unit

Halaman Business menampilkan model 3D tiga unit _photobox_ seperti pada @gbr-business-3d.
Pratinjau memakai komponen web `<model-viewer>` yang memuat berkas `.glb` langsung dan
menyediakan putar, perbesar, sentuhan, pengelolaan resolusi layar, dan penggantian warna
material tanpa perlu menulis kode Three.js sendiri. Satu elemen `<model-viewer>` dipakai
bersama oleh semua unit, dan atribut `src` serta `alt` diganti menurut unit yang dipilih
melalui peta `UNIT_MODELS`. Menambah unit baru cukup dengan menambahkan satu entri pada peta
itu. Komponen dimuat dari CDN hanya pada halaman ini, dan model dimuat secara malas
(`loading="lazy"`) karena letaknya jauh di bawah lipatan layar dan berukuran sekitar 1,6 MB.
Pengunjung yang tidak pernah menggulir sejauh itu tidak membayarnya.

#gambar("../assets/figures/business-3d.png", caption: [Pratinjau 3D unit Velvet Booth pada halaman Business], width: 100%) <gbr-business-3d>

@kode-model-viewer-html dan @kode-model-viewer-js memperlihatkan elemen serta logika
penggantian warna. Warna `baseColorFactor`
pada glTF bersifat linear, sedangkan palet yang ditampilkan berupa kode heksadesimal sRGB,
sehingga nilainya dikonversi lebih dahulu. Seluruh material bernama `BoxBody` pada unit yang
sedang termuat diubah sekaligus. Saat model selesai dimuat, yang diterapkan adalah warna
bawaan milik unit itu sendiri sehingga berganti unit tidak membawa warna unit sebelumnya.

#kode-sumber(caption: [Elemen model-viewer dan penggantian warna bodi (diringkas)], ```html
<model-viewer id="pb-model" src="./assets/models/unit2.glb"
  alt="Model 3D Photobox Velvet Booth Photo.Jo"
  data-unit="walkin1" camera-controls disable-pan
  interaction-prompt="none" loading="lazy"
  environment-image="neutral" shadow-intensity="0.9"
  exposure="1.05" camera-orbit="-25deg 78deg auto"
  min-camera-orbit="auto 25deg auto"
  max-camera-orbit="auto 100deg auto">
  <div class="pb-poster" slot="poster">...</div>
</model-viewer>
```) <kode-model-viewer-html>

#kode-sumber(caption: [Konversi warna dan peta unit pada business.html (diringkas)], ```js
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
  if (!viewer.model) return;
  const rgba = hexToLinear(hex);
  viewer.model.materials
    .filter(m => m.name === 'BoxBody')
    .forEach(m => m.pbrMetallicRoughness
                    .setBaseColorFactor(rgba));
}

const UNIT_MODELS = {
  kiosk:   { src: './assets/models/unit1.glb', alt: '...' },
  walkin1: { src: './assets/models/unit2.glb', alt: '...' },
  walkin2: { src: './assets/models/unit3.glb', alt: '...' },
};
```) <kode-model-viewer-js>

=== Simulator Aplikasi dan Gerbang Kontak

Halaman Application berisi simulasi aplikasi _photobooth_ yang dapat dicoba pengunjung tanpa
memasang apa pun, seperti pada @gbr-app-simulator. Simulasi dibangun ulang penuh dengan HTML,
CSS, dan JavaScript, bukan berupa tangkapan layar yang diberi tombol. Pendekatan tangkapan
layar sempat direncanakan lebih dulu tetapi memerlukan koordinat piksel tebakan untuk menutupi
penghitung waktu yang tertanam pada gambar, dan hanya setepat mata menebaknya. Pada
pembangunan ulang, setiap elemen adalah DOM sungguhan yang diposisikan dengan benar.
Tangkapan layar aplikasi asli dipakai hanya sebagai acuan desain dan tidak dikirim sebagai
aset.

#gambar("../assets/figures/app-simulator.png", caption: [Layar pemilihan frame pada simulator aplikasi _photobooth_], width: 100%) <gbr-app-simulator>

Alur simulasi berupa mesin keadaan: selamat datang, petunjuk, pembayaran (QRIS atau
voucher), pilih _frame_, sesi foto, tinjau, pilih filter, cetak, dan selesai, ditambah
cabang panel admin dan skenario printer gagal. Setiap keadaan memiliki fungsi templat yang
mengembalikan elemen layar utuh, dan elemen itu menggantikan layar sebelumnya pada setiap
`render()`. Karena simpul diganti, pendengar peristiwa tidak dipasang pada tombol,
melainkan sekali pada cangkang layar yang tetap, dengan membaca atribut `data-action` dan
`data-value`. Seluruh ukuran di dalam layar memakai satuan `em` dengan `1em` setara sekitar
1% lebar layar simulasi, sehingga simulasi mengecil secara proporsional. Kamera sengaja tidak
dipakai pada simulator; fitur kamera hanya ada pada pengalaman _photostrip_ di halaman Home.

Panel admin pada simulator adalah demo perangkat lunak itu sendiri, sehingga pengunjung yang
membukanya sedang menilai perangkat lunak secara komersial. Karena itu, sebelum panel dibuka
ditampilkan formulir kecil berisi nama, nomor WhatsApp, dan pernyataan persetujuan. Beberapa
keputusan rancangan gerbang ini patut dicatat.

- Gerbang dirender sebagai modal tingkat halaman dengan gaya Photo.Jo, di luar bingkai
  kiosk. Isi bingkai adalah tiruan produk lain, dan permintaan persetujuan yang terlihat
  seperti bagian dari aplikasi tiruan bukanlah permintaan persetujuan. Gerbang muncul
  sebelum layar kata sandi tiruan agar keduanya tidak dapat tertukar.
- Penanda "sudah mengisi" disimpan pada `localStorage`, sedangkan penanda "sudah
  ditampilkan" pada `sessionStorage`. Dengan `sessionStorage` saja, pengunjung yang kembali
  keesokan harinya diminta lagi, yang menambah baris ganda pada daftar yang harus
  ditindaklanjuti staf.
- Gerbang gagal terbuka (_fail open_). Bila Supabase tidak terjangkau, impor CDN gagal, atau
  penulisan melebihi tenggat delapan detik, pengunjung diberi tahu bahwa penyimpanan gagal
  dan tetap diberi akses ke demo. Gerbang ini melindungi demo, bukan rahasia, sehingga
  gangguan layanan tidak boleh mengunci pengunjung dari halaman pemasaran.
- Modul `db.js` baru dimuat ketika tombol panel admin pertama kali ditekan, sehingga
  pengunjung yang tidak pernah membukanya tidak membayar apa pun untuk fitur ini.

@kode-lead menunjukkan fungsi penulisan _lead_ dan penghitung gerbang. Hanya tindakan
menambah baris yang dapat dilakukan pengunjung pada seluruh basis data, ditambah dua
penghitung `gate_events` yang tidak memuat identitas apa pun. Parameter UTM yang disimpan
pada `sessionStorage` sejak halaman dibuka digabungkan ke kolom `context` agar asal kunjungan
terjawab tanpa pelacak, kuki, atau skrip pihak ketiga.

#kode-sumber(caption: [Penulisan _lead_ dan penghitung gerbang (diringkas)], ```js
export async function submitLead(
    { name, contact, contactKind, source, context = {} }) {
  // utm_* dari sessionStorage, digabung agar setiap lead
  // membawa asal kunjungannya.
  const campaign = campaignContext();

  const { error } = await publicDb.from('leads').insert({
    name: String(name).trim(),
    contact: normalizeContact(contact, contactKind),
    contact_kind: contactKind,
    source,
    context: campaign ? { ...context, campaign } : context,
    consent_at: new Date().toISOString(),
  });
  if (error) throw error;
}

// Penghitung tidak boleh menunda atau merusak halaman:
// galat diabaikan, bukan ditampilkan.
export function recordGateEvent(gate, kind) {
  return publicDb.from('gate_events').insert({ gate, kind })
    .then(() => true, () => false);
}
```) <kode-lead>

=== Halaman Service dan Jendela Pemesanan

Halaman Service menampilkan empat layanan dalam tab: Photobooth Event, Videobooth 360,
iPadbooth Event, dan Photobox Event. Memilih paket mengisi keranjang yang meluncur dari
kanan, seperti pada @gbr-service-keranjang. Hanya satu paket yang dapat dipilih pada satu
waktu, dan berganti layanan mengosongkan add-on karena layanan baru mungkin tidak
menerimanya. Add-on dikendalikan oleh aturan yang berlaku sama pada panel, jendela, dan
server: Projector dibatasi satu unit, _Tambah durasi_ hanya untuk paket tertinggi, dan
add-on per jam dibatasi oleh durasi paket. Tidak satu add-on pun dapat dipilih sebelum paket
masuk keranjang. Pada layanan Photobox, tombol pada keranjang berubah menjadi konsultasi
WhatsApp dan jendela pemesanan tidak dibuka.

#gambar("../assets/figures/service-keranjang.png", caption: [Halaman Service dengan keranjang terbuka setelah paket dipilih], width: 100%) <gbr-service-keranjang>

Jendela pemesanan diimplementasikan sebagai modul tersendiri, `order-window.js`, karena terlalu
besar untuk disisipkan pada halaman dan merupakan satu-satunya bagian yang benar-benar dapat
dipakai ulang. Modul mengekspor `openOrderWindow(selection)` dan menyimpan keadaan (langkah,
pilihan, dan hasil) pada `sessionStorage` setiap berpindah langkah. @gbr-jendela-pemesanan
menunjukkan empat langkah pertama pada tampilan ponsel. Tampilan ini bukan desktop yang
diperkecil: pada lebar di bawah 640 piksel tombol langkah disusun menjadi grid tiga kolom,
baris add-on menjadi dua kolom, dan tombol pada kaki dialog ditumpuk.

#gambar("../assets/figures/jendela-pemesanan.png", caption: [Empat langkah pertama jendela pemesanan pada tampilan ponsel: paket, lokasi, tanggal, dan pembayaran], width: 100%) <gbr-jendela-pemesanan>

Modul ini tidak pernah menentukan harga. Seluruh angka pada layar hanyalah pratinjau yang
dihitung dari katalog yang sudah dimuat halaman, dan bila berbeda dengan hasil server, yang
berlaku adalah server. @kode-order-submit menunjukkan satu-satunya penulisan ke server pada
seluruh jendela, yaitu pemanggilan `createOrder` pada langkah kelima. Pesan galat dari server
diperiksa: bila memuat kata penuh atau ditutup, artinya tanggal hilang di antara langkah
ketiga dan keenam, dan pelanggan langsung dikembalikan ke kalender yang segar, bukan ke jalan
buntu. Hanya kode voucher yang baru saja dikonfirmasi yang dikirim, dan server memeriksanya
ulang.

#kode-sumber(caption: [Pembuatan pesanan dari jendela pemesanan (diringkas)], ```js
try {
  const res = await createOrder({
    voucher_code: (state.voucher_code &&
      state.voucher_code === voucherInputCode())
      ? state.voucher_code : null,
    service_slug: state.svc,
    package_code: state.tier,
    addons: (state.addons || [])
      .map((a) => ({ code: a.code, qty: a.qty })),
    location_slug: state.location_slug,
    event_date: state.event_date,
    payment_choice: state.payment_choice,
    customer_name: state.name,
    contact_kind: 'whatsapp',
    contact_value: state.contact_value,
  });
  state.result = res;
  save();
  go(6);
} catch (err) {
  // Tanggal hilang di antara langkah 3 dan 6: kembali ke
  // kalender yang segar, bukan ke jalan buntu.
  const msg = String(err.message || '');
  if (/penuh|ditutup/i.test(msg)) {
    cal.cache = {};
    state.event_date = null;
    save();
    flash(msg + ' Silakan pilih tanggal lain.');
    go(3);
  } else {
    flash(msg || 'Gagal membuat pesanan.');
  }
}
```) <kode-order-submit>

Dialog juga dirancang agar dapat dipakai dengan papan ketik dan pembaca layar. Semua jalur
yang menampilkan atau menyembunyikan jendela melewati satu fungsi, `holdPage()`, sehingga
tidak ada jalur yang dapat meninggalkan keadaan yang salah. Pada @kode-fokus, latar belakang
dijadikan `inert` agar keluar dari urutan tab dan dari pohon aksesibilitas dengan satu
atribut, dan hanya yang dinyalakan oleh jendela yang dimatikan kembali. Fokus dipindahkan
ke dialog itu sendiri dan bukan ke kolom pertama, karena memfokuskan kolom akan memunculkan
papan ketik ponsel di atas jendela yang belum sempat dibaca. Tab tidak dapat meninggalkan
dialog, dan Escape menanyakan dahulu sebelum menutup. Sebelum perbaikan ini, pengguna papan
ketik membuka jendela dan mendarat di 14 perhentian tab pada halaman di belakang yang tidak
dapat mereka lihat.

#kode-sumber(caption: [Penguncian latar belakang dan jebakan fokus pada dialog (diringkas)], ```js
// Latar belakang tidak boleh dapat dijangkau papan ketik
// atau dibaca pembaca layar saat dialog terbuka.
function setBackgroundInert(on) {
  if (!('inert' in HTMLElement.prototype)) return;
  for (const node of Array.from(document.body.children)) {
    if (node === root || node.id === 'ow-pill') continue;
    if (on) {
      if (!node.inert) {
        node.inert = true;
        node.dataset.owInert = '1';
      }
    } else if (node.dataset.owInert) {
      node.inert = false;
      delete node.dataset.owInert;
    }
  }
}

function onKeydown(e) {
  if (!root || root.hidden) return;
  if (e.key === 'Escape') { /* askClose() */ return; }
  if (e.key !== 'Tab') return;
  const items = focusables();
  const first = items[0], last = items[items.length - 1];
  const at = document.activeElement;
  if (!items.includes(at) ||
      (e.shiftKey && at === first) ||
      (!e.shiftKey && at === last)) {
    e.preventDefault();
    (e.shiftKey ? last : first).focus();
  }
}
```) <kode-fokus>

=== Halaman Invoice

Halaman `invoice.html` menampilkan invoice dengan gaya siap cetak. Halaman dibuka melalui
`?t=<token>` dan tidak memerlukan masuk. Skrip `invoice.js` memanggil `public_invoice` dan
menampilkan invoice valid terbaru sebagai dokumen utama, sedangkan nomor-nomor sebelumnya
tercantum di bawahnya. Pelanggan yang menyimpan tautan setelah membayar DP melihat posisinya
saat ini dan bukan tagihan yang sudah dilunasi. Parameter tambahan `&n=<urut>` memilih satu
invoice tertentu. Bila yang dibuka bukan yang terbaru, spanduk berwarna menyebutkan nomor itu
dan menautkan kembali ke tagihan terkini sehingga nomor lama dari penanda yang usang tidak
dikira tagihan hari ini. Status pesanan yang hidup, misalnya dibatalkan atau kedaluwarsa,
ditampilkan sebagai spanduk di atas dokumen yang tidak berubah. Nama berkas simpanan PDF
diambil dari `document.title`, sehingga judul halaman memakai nomor dengan tanda hubung,
karena garis miring bukan nama berkas yang sah. Tampilan halaman invoice ditunjukkan pada
@gbr-invoice.

#gambar("../assets/figures/invoice-contoh.png", caption: [Halaman invoice yang dibuka pelanggan melalui tautan pribadi], width: 100%) <gbr-invoice>

=== Fitur Pendukung

Beberapa fitur kecil melengkapi situs publik.

- Kapsul pengumuman melayang di bagian bawah halaman dan berputar tiap lima detik bila ada
  lebih dari satu. Modul `announce.js` dipakai bersama oleh keempat halaman publik dan oleh
  pratinjau pada panel admin, sehingga kapsul yang dipratinjau staf dibangun oleh kode yang
  persis sama dengan yang dijalankan peramban pengunjung. Hanya pengumuman yang lolos
  `announcement_is_live()` yang terbaca publik: terbit, berada dalam jendela tanggalnya,
  dan promosi atau voucher yang diikutinya masih aktif.
- Setiap halaman memuat judul di bawah 60 karakter, deskripsi di bawah 160 karakter, alamat
  kanonik, data terstruktur `Organization` dengan `areaServed` untuk kota yang dilayani,
  dan gambar pratinjau 1200 × 630 piksel berformat PNG, karena beberapa pemindai tautan,
  termasuk WhatsApp, tidak menampilkan WebP. Berkas `robots.txt` dan `sitemap.xml` memuat
  keempat halaman publik, sedangkan panel admin dan invoice ditutup dari indeks.
- Halaman 404 sengaja minimal: satu hero tanpa navigasi dan tanpa kaki halaman, dengan satu
  tombol kembali ke beranda sebagai satu-satunya jalan keluar.
- Mode Tompel adalah kejutan kecil berupa penghormatan kepada kucing pemilik: lima klik
  cepat pada logo, selama hero masih terlihat, mengganti kursor dengan enam gambar dan
  memasang foto kucing sebagai latar hero pada seluruh halaman publik. Pemicunya urutan
  klik, bukan peluang acak, sebab penemuan hanya bermakna bila disebabkan pengunjung dan
  dapat diulang dalam pengujian.

== Implementasi Panel Admin

=== Kerangka dan Pembatasan Peran

Panel admin adalah satu berkas HTML, `admin.html`, yang ditulis tanpa _framework_ dengan
layar-layar sebagai bagian yang ditampilkan atau disembunyikan. Saat dibuka, fungsi `boot()`
menentukan salah satu dari lima keadaan: memuat, masuk, atur kata sandi, akses ditolak,
atau aplikasi. Tautan undangan dan tautan pemulihan hanya menampilkan layar atur kata
sandi dan tidak pernah menampilkan panel. Akun yang dinonaktifkan atau yang undangannya
belum diselesaikan ditolak oleh `accessDenialReason()` dengan pesan yang menyebut
alasannya.

Pembatasan peran pada antarmuka dikerjakan oleh `enterApp()` pada @kode-enter-app. Elemen
yang bertanda `data-role-gate` disembunyikan, bukan dinonaktifkan, menurut peran
pengguna. Ini kenyamanan, bukan penghalang: penghalang sebenarnya adalah RLS di basis
data. Pembedaan itu penting pada dasbor, karena RLS menyaring dan tidak menolak. Pembacaan
oleh peran yang tidak berhak mengembalikan nol baris, sehingga ubin yang ditampilkan kepada
peran yang salah akan melaporkan angka nol dengan yakin, bukan galat. Setiap kelompok pada
dasbor karenanya dibatasi sesuai layar yang diwakilinya.

#kode-sumber(caption: [Pembatasan tampilan menurut peran pada panel admin (diringkas)], ```js
async function enterApp() {
  me = await getMyProfile();

  const denial = accessDenialReason(me);
  if (denial) {
    $('denied-reason').textContent = denial;
    show('screen-denied');
    return;
  }

  // Layar yang tak terjangkau suatu peran DISEMBUNYIKAN,
  // bukan sekadar dinonaktifkan. RLS batas yang sebenarnya;
  // kode ini hanya menentukan apa yang digambar.
  document.querySelectorAll('[data-role-gate]')
    .forEach((el) => {
      const gate = el.dataset.roleGate;
      let allowed;
      if (gate === 'superadmin')
        allowed = isSuperadmin(me);
      else if (gate === 'operator-only')
        allowed = !isAdminOrAbove(me);
      else allowed = isAdminOrAbove(me);
      el.hidden = !allowed;
    });

  show('app');
  goto('dashboard');
}
```) <kode-enter-app>

=== Layar Panel Admin

@tbl-layar merangkum layar-layar panel beserta cara kerjanya dan hubungannya dengan server.
Seluruh antarmuka berbahasa Indonesia, kecuali judul menu yang sengaja berbahasa Inggris dan
identik dengan label bilah samping agar tidak ada ketidakkonsistenan antara tombol yang
ditekan dan judul halaman yang muncul.

#allow-table-break[#figure(
  caption: [Layar panel admin dan hubungannya dengan server],
  table(
    columns: (2.8cm, 1fr),
    align: (left, left),
    table.header([*Layar*], [*Cara kerja dan server*]),
    [Dashboard], [Ringkasan pesanan bulan ini menurut sumber (situs atau manual), pesanan yang menunggu pembayaran dan pelunasan, uang diterima menurut tanggal terima, promosi dan voucher yang berjalan, _leads_ tujuh hari terakhir, tanggal terisi dan tertutup, serta sepuluh aktivitas terakhir. \ _Server:_ Kueri hitung pada tabel terkait; `expire_stale_orders()` dijalankan sebelum menghitung.],
    [Calendar], [Tampilan bulan, minggu, dan agenda atas seluruh lokasi sekaligus. Pesanan tampil sebagai kotak berwarna menurut status pembayaran. Tenggat pembayaran, promosi, voucher, pengumuman, dan libur nasional ikut digambar. Menyeret pesanan ke hari lain memindahkannya. \ _Server:_ `availability_slots`, `slot_claims`, `reschedule_order()`.],
    [Orders], [Daftar dengan penyaring status, lokasi, sumber, dan periode, diurutkan dan dihalamani oleh server. Dialog detail memuat pembayaran, bukti, dan invoice. Tindakan: Catat Bayar, Pesanan Baru, pengingat WhatsApp, dan ekspor CSV. \ _Server:_ `create_order`, `record_manual_payment`, `void_payment`, dan `set_order_*`.],
    [Leads], [Daftar dengan penyaring sumber dan tanggal, tautan `wa.me` satu ketukan, penanda sudah dihubungi, dan ekspor CSV yang mencakup seluruh hasil penyaringan, bukan hanya halaman di layar. \ _Server:_ `leads` dan `gate_events`.],
    [Pricing], [Perubahan harga ditampung dan disimpan sekaligus, dengan konfirmasi untuk perubahan lebih dari 25 persen. Matriks layanan dan add-on mengatur add-on yang tersedia. \ _Server:_ `packages`, `addons`, `service_addons`.],
    [Promotions dan Vouchers], [Daftar dengan status berjalan, terjadwal, berakhir, dan nonaktif (voucher ditambah kuota habis). Pratinjau memakai fungsi harga yang sama dengan situs. Kuota voucher tidak dapat diturunkan di bawah jumlah yang sudah dipakai. \ _Server:_ `promotions` dan `vouchers`.],
    [Announcements], [Setiap pengumuman tampil sebagai kapsul dengan warnanya sendiri, dengan pratinjau ukuran layar lebar dan ponsel, jendela tanggal, dan opsi mengikuti promosi atau voucher. \ _Server:_ `announcements` dan `announcement_is_live()`.],
    [Media, Reviews, FAQ], [Unggah dengan pemotong gambar, status terbit, dan urutan dengan seret dan lepas. Pratinjau FAQ dirender oleh fungsi tampilan yang sama dengan situs. \ _Server:_ Storage `content` dan `reorder_rows()`.],
    [Locations], [Kota layanan dengan kapasitas harian dan studio kunjungan langsung dengan foto, alamat, dan tautan peta. Slug dibekukan setelah dibuat, dan menurunkan kapasitas menyebut tanggal yang sudah terpesan melebihi angka baru. \ _Server:_ `locations` dan `studios`.],
    [Users], [Undang, atur ulang kata sandi, nonaktifkan, aktifkan, hapus undangan, ganti nama, dan ubah peran. \ _Server:_ Edge Function `manage-users`.],
    [Activity Log], [Catatan perubahan terbaru lebih dulu, sepuluh baris per halaman, diurutkan oleh server. \ _Server:_ `audit_log`.],
  ),
) <tbl-layar>]

=== Unggah dan Kompresi Media

Gambar yang diunggah staf harus ringan agar halaman publik tidak melambat tanpa disadari.
Batas ini dijaga dua lapis. Lapis pertama berada di peramban: gambar dipotong menurut rasio
koleksi, diperkecil, dan dikodekan ulang sebelum satu bita pun melintasi jaringan. Lapis
kedua ditegakkan _bucket_, yaitu batas 5 MB dan daftar jenis berkas yang diizinkan, karena
siapa pun dapat memanggil API Storage secara langsung tanpa melewati peramban. Ketentuan tiap
koleksi dirangkum pada @tbl-koleksi.

#figure(
  caption: [Ketentuan koleksi media],
  table(
    columns: (2.9cm, 2.5cm, 1.8cm, 1fr),
    align: (left, left, left, left),
    table.header([*Koleksi*], [*Rasio*], [*Sisi maks.*], [*Batas*]),
    [Galeri polaroid Home], [1 : 1], [800 px], [20 berkas, 15 terbit],
    [Sorotan layanan], [4 : 3], [1200 px], [12 berkas per layanan; satu video maks. 15 detik dan 8 MB per layanan],
    [Portofolio layanan], [4 : 3 atau 3 : 4], [1000 px], [30 berkas],
    [Foto studio], [4 : 3], [1200 px], [Satu per studio],
  ),
) <tbl-koleksi>

@kode-kompres menunjukkan fungsi pemrosesan. Fungsi ini memotong, bukan menolak. Menolak
gambar berbeda rasio benar secara prinsip tetapi tidak dapat dipakai, sebab foto ponsel
berukuran 4 : 3 atau 3 : 4 sehingga setiap unggahan langsung ke koleksi 1 : 1 akan gagal.
Pemotongan tengah serupa dengan `object-fit: cover` yang akan dilakukan halaman, hanya
dikerjakan sekali pada saat unggah sehingga hasilnya langsung terlihat pada gambar mini.
Gambar hanya diperkecil dan tidak pernah diperbesar, karena memperbesar menambah bita tanpa
menambah rincian.

#kode-sumber(caption: [Pemotongan dan kompresi gambar unggahan ke WebP (diringkas)], ```js
export async function compressImage(
    file, collection, crop = null) {
  const spec = cropSpec(collection);
  const master = spec?.master ?? 1200;
  const bitmap = await createImageBitmap(file);
  const sw = bitmap.width, sh = bitmap.height;

  // ... tentukan persegi potong (cx, cy, cw, ch) menurut
  // rasio koleksi: pilihan pemotong, atau potong tengah.

  // Hanya diperkecil, tidak pernah diperbesar.
  const scale = Math.min(1, master / Math.max(cw, ch));
  const w = Math.round(cw * scale);
  const h = Math.round(ch * scale);

  const canvas = document.createElement('canvas');
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext('2d');
  ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(bitmap, cx, cy, cw, ch, 0, 0, w, h);

  const blob = await new Promise((resolve) =>
    canvas.toBlob(resolve, 'image/webp', 0.82));
  if (!blob) throw new Error('Gagal memproses gambar.');
  return { blob, width: w, height: h };
}
```) <kode-kompres>

=== Pesanan, Pembayaran, dan Kalender

Layar Orders adalah tempat sebagian besar pekerjaan harian dilakukan. Dialog detail pesanan
memuat butir dan total, status serta tenggat, daftar pembayaran beserta bukti dan nomor
invoice yang diterbitkannya, serta tindakan yang diizinkan bagi peran pengguna. Dialog
_Catat Bayar_ menawarkan tombol jumlah satu ketukan untuk sisa tagihan dan DP minimum.
Bukti berupa gambar dikompresi menjadi WebP dengan sisi terpanjang 1600 piksel sebelum
diunggah ke _bucket_ privat, sedangkan PDF dari mobile banking diunggah apa adanya. Bukti
dilihat kembali melalui tautan bertanda tangan yang berlaku 60 detik. Urutan kerjanya:
berkas diunggah lebih dulu, pembayaran dicatat kedua, dan bila pencatatan gagal berkas
dihapus lagi, sebab berkas yatim pada _bucket_ privat adalah kuota yang tidak terlihat
siapa pun.

Layar Calendar dibangun mengikuti pola Google Calendar karena itulah bentuk yang sudah
dikenal staf. Pesanan ditekan untuk dibuka pada layar Orders dan, setelah ditutup, kembali
ke kalender. Pemindahan jadwal dengan seretan hanya untuk penunjuk mouse atau pena, karena
pada layar sentuh seretan adalah cara halaman digulir. Detail pesanan karenanya menyediakan
formulir yang sama. Tombol _Tambah ke Google Calendar_ sengaja berupa tautan yang membuka
halaman acara baru Google dengan tanggal, jam, tempat, dan tautan kembali ke pesanan, bukan
umpan berlangganan. Umpan akan menaruh nama pelanggan dan alamat acara pada sebuah URL di
luar proteksi masuk panel. @gbr-admin-dashboard menampilkan dasbor panel, @gbr-admin-calendar
layar Calendar, dan @gbr-admin-pesanan dialog pembuatan pesanan oleh staf.

#gambar("../assets/figures/admin-dashboard.png", caption: [Dasbor panel admin (data contoh)], width: 100%) <gbr-admin-dashboard>

#gambar("../assets/figures/admin-calendar.png", caption: [Layar Calendar pada tampilan bulan (data contoh)], width: 100%) <gbr-admin-calendar>

#gambar("../assets/figures/admin-pesanan.png", caption: [Dialog pembuatan pesanan oleh staf pada layar Orders], width: 100%) <gbr-admin-pesanan>

== Implementasi Pemodelan 3D

Ketiga unit dimodelkan di Blender 4.0 berdasarkan foto dan ukuran unit sebenarnya, lalu
diekspor ke format `.glb` dengan pengekspor Khronos glTF Blender I/O v4.0.44, sebagaimana
tercatat pada metadata setiap berkas. Berkas sumber `.blend` disimpan terpisah dari aset
situs, bersama gambar tekstur untuk layar monitor, lensa kamera, kipas, tirai, cermin, dan
stiker. Hanya berkas `.glb` yang dikirim ke pengunjung.

Kiosk Slim dimodelkan ulang pada 4 Agustus 2026 mengikuti referensi terbaru dari pemilik:
tepi depan miring (_chamfer_), potongan tampilan samping, serta kamera, layar, dan slot cetak pada
posisi baru. Jumlah segitiganya naik sekitar empat kali dibanding versi pertama yang hanya
298 segitiga, dan masih tergolong ringan. Velvet Booth ditambahkan pada 6 Agustus dan
Cabin Booth pada 10 Agustus. Kedua bilik tertutup itu jauh lebih rumit daripada kios yang
berupa kotak sederhana. Spesifikasi hasil ekspor, yang dibaca langsung dari JSON glTF setiap
berkas, disajikan pada @tbl-model.

#figure(
  caption: [Spesifikasi model 3D hasil ekspor],
  table(
    columns: (3.2cm, 1.7cm, 1.5cm, 1.3cm, 1.3cm, 1.3cm, 1.3cm),
    align: (left, right, right, right, right, right, right),
    table.header([*Unit*], [*Ukuran*], [*Segitiga*], [*Titik*], [*Objek*], [*Material*], [*Tekstur*]),
    [Kiosk Slim (`unit1.glb`)], [1,26 MB], [1.110], [1.598], [8], [5], [3],
    [Velvet Booth (`unit2.glb`)], [1,60 MB], [1.646], [2.623], [17], [15], [7],
    [Cabin Booth (`unit3.glb`)], [1,42 MB], [1.990], [3.052], [15], [9], [4],
  ),
) <tbl-model>

Penamaan material menjadi bagian dari kontrak antara model dan situs. Kiosk Slim dan Cabin
Booth masing-masing memiliki dua material bernama `BoxBody` (bodi dan pintu), sedangkan Velvet
Booth hanya satu. Kode pengganti warna pada @kode-model-viewer-js menyaring semua material
dengan nama itu sehingga tidak perlu percabangan per unit. @gbr-unit-3d menunjukkan ketiga
model sebagaimana tampil pada halaman Business.

#gambar("../assets/figures/unit-3d-tiga.png", caption: [Model 3D unit _photobox_ pada pratinjau: (a) Velvet Booth, (b) Cabin Booth, dan (c) Kiosk Slim], width: 100%) <gbr-unit-3d>

== Implementasi Penerapan

=== Penerapan Aplikasi dan Basis Data

Penerapan dilakukan dengan langkah-langkah berikut. Langkah terakhir kini berada di tangan
Photo.Jo.

+ Kode disimpan pada repositori GitHub privat yang terhubung ke Vercel. _Branch_ `main`
  diterapkan ke produksi dan setiap _branch_ lain menghasilkan pratinjau. Pekerjaan
  persiapan peluncuran dikerjakan pada _branch_ tersendiri dan baru digabung ke `main` saat
  nama domain siap, karena `main` langsung menjadi produksi.
+ Migrasi diterapkan ke proyek Supabase terkelola dengan `supabase db push`, lalu daftar
  migrasi lokal dibandingkan dengan yang jauh agar kedua sisi sinkron.
+ Pengaturan Auth disesuaikan: alamat situs diarahkan ke `www.photojo.id`, alamat panel
  ditambahkan sebagai alamat pengalihan yang diizinkan, pendaftaran mandiri dimatikan, dan
  SMTP Resend dipasang. Pendaftaran mandiri ternyata masih menyala ketika diperiksa pada 30
  September dan bertentangan dengan rancangan, sehingga dimatikan dan diverifikasi.
+ Rahasia Edge Function `ADMIN_URL` diarahkan ke panel pada subdomain `dashboard`, lalu
  fungsi diterapkan.
+ Data uji dibersihkan. Pesanan, _leads_, pembayaran, dan baris katalog contoh dihapus dengan
  terlebih dahulu menjalankan klausa `where` sebagai `select` untuk melihat apa yang akan
  terhapus. Urutan kode pesanan tidak diputar ulang karena sebuah _sequence_ tidak pernah
  mundur, dan celah nomor yang tertinggal dianggap wajar. Cadangan statis disinkronkan dengan
  `sync-fallbacks.mjs`.
+ DNS dikelola pada Hostinger, dan pengaturan catatannya ditangani oleh pihak Photo.Jo
  bersama penulis. Rancangannya mengarahkan catatan `www` dan `dashboard` ke Vercel,
  sedangkan catatan domain induk tidak diubah sehingga aplikasi lama tetap berjalan. Panel
  admin sudah dapat diakses pada `dashboard.photojo.id`. Peralihan situs publik ke
  `www.photojo.id` dan pengelolaan domain selanjutnya kini ditangani oleh Photo.Jo.

Keadaan sebelum peluncuran diperiksa dengan daftar pada @tbl-periksa.

#figure(
  caption: [Daftar periksa penerapan],
  table(
    columns: (1fr, 2.4cm),
    align: (left, left),
    table.header([*Butir pemeriksaan*], [*Keadaan*]),
    [Tinjauan RLS tiga lapis ditandatangani], [Selesai],
    [Pendaftaran mandiri pada Auth dimatikan dan diverifikasi], [Selesai],
    [Harga cadangan statis sama dengan katalog], [Selesai, diverifikasi],
    [Data uji pada proyek terkelola dibersihkan], [Selesai],
    [Subdomain panel terpasang, sertifikat terbit, HTTP dialihkan ke HTTPS], [Selesai],
    [Alamat situs dan pengalihan pada Auth diatur, `ADMIN_URL` diatur], [Selesai],
    [Fungsi `manage-users` diterapkan dan versinya mutakhir], [Selesai],
    [Email undangan staf terkirim melalui SMTP Resend], [Selesai, diuji],
    [Peralihan `www.photojo.id` ke Vercel dan pengelolaan domain], [Ditangani Photo.Jo],
  ),
) <tbl-periksa>

=== Pengelolaan Rahasia dan Kepemilikan

Seluruh rahasia berada di luar repositori. Setiap nilai rahasia pada berkas konfigurasi
berupa rujukan `env(...)`, dan berkas `.env` dikecualikan dari kontrol versi. Kunci
`service_role` hanya ada pada pengaturan rahasia fungsi di Supabase, dan kunci pengiriman
email hanya berhak mengirim. Organisasi Supabase dibuat di bawah akun milik Photo.Jo dengan
pengembang sebagai anggota, bukan sebaliknya. Penempatan ini adalah bagian perancangan
keamanan: hierarki peran pada panel yang memungkinkan pemilik mengatur akses tanpa
pengembang akan sia-sia bila akun infrastruktur di bawahnya adalah akun pribadi pengembang.
Serah terima kelak cukup dengan mencabut keanggotaan pengembang, tanpa memindahkan
organisasi. Repositori GitHub dan proyek Vercel saat ini berada pada akun pengembang dan
direncanakan dipindahkan ke kepemilikan Photo.Jo.

Implementasi yang telah dibahas pada bab ini kemudian diuji, dan hasil pengujian dibahas
pada bab berikutnya.
