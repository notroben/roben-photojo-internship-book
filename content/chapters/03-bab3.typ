// ============================================================
// BAB III TINJAUAN PUSTAKA
// Setiap sumber diperiksa langsung pada halaman rujukannya (lihat daftar-pustaka.bib).
// ============================================================

#import "../../template/lib.typ": *

= TINJAUAN PUSTAKA

Bab ini merangkum dasar teori teknologi yang dipakai pada sistem, yaitu situs web statis,
PostgreSQL dengan _Row Level Security_, Supabase, Vercel, format glTF, serta keamanan dan
aksesibilitas web.

== Situs Web Statis dan Teknologi Peramban

Situs web statis dikirim ke peramban sebagai berkas HTML, CSS, dan JavaScript yang sudah jadi,
tanpa server aplikasi yang merakit halaman pada setiap permintaan. Interaksi dan pengambilan
data dikerjakan JavaScript di peramban. Modul ES (`import` dan `export`) memungkinkan program
JavaScript dipecah menjadi berkas terpisah yang dimuat langsung oleh peramban modern dengan
atribut `type="module"` @mdn-modules. Beberapa API peramban dipakai pada proyek ini, misalnya
`getUserMedia()` yang meminta izin pengguna untuk memakai kamera dan hanya tersedia pada
konteks aman seperti HTTPS @mdn-getusermedia. Pendekatan ini meniadakan server yang harus
dirawat dan menjadi dasar prinsip _static-first_ pada Bab IV.

== PostgreSQL dan Row Level Security

PostgreSQL adalah sistem basis data relasional yang mendukung kebijakan keamanan baris
(_row security policies_). Kebijakan membatasi baris yang dapat dikembalikan atau diubah suatu
perintah bagi tiap pengguna, di samping sistem hak akses SQL standar. Bila RLS diaktifkan pada
tabel tanpa kebijakan, berlaku kebijakan tolak-bawaan sehingga tidak ada baris yang terlihat
atau dapat diubah. Superuser, peran dengan atribut `BYPASSRLS`, dan pemilik tabel melewati RLS,
kecuali tabel diberi `FORCE ROW LEVEL SECURITY`. Klausa `USING` menentukan baris yang terlihat
atau dapat diubah, sedangkan `WITH CHECK` menentukan baris yang boleh ditulis @pg-rls.

Fungsi PostgreSQL berstatus `SECURITY INVOKER` (bawaan, berjalan dengan hak pemanggil) atau
`SECURITY DEFINER` (berjalan dengan hak pemilik fungsi). Saat fungsi dibuat, hak `EXECUTE`
diberikan kepada `PUBLIC` secara bawaan sehingga perlu dicabut dan diberikan secara selektif
@pg-function. Penguncian baris dengan `SELECT ... FOR UPDATE` mencegah baris dikunci, diubah,
atau dihapus transaksi lain sampai transaksi berakhir @pg-locking. Ketiga mekanisme ini dipakai
pada Bab IV dan V untuk aturan akses, fungsi bisnis, dan penjagaan kapasitas tanggal.

== Supabase

Supabase menyediakan basis data PostgreSQL terkelola beserta komponen di sekitarnya. PostgREST
adalah server web mandiri yang mengubah basis data PostgreSQL langsung menjadi API REST
@postgrest. Supabase memetakan permintaan tanpa login ke peran `anon` dan pengguna yang login
ke peran `authenticated`. Dokumentasinya menegaskan bahwa tabel pada skema yang terbuka tanpa
RLS dapat dibaca dan ditulis peran mana pun yang memiliki hak, dan bahwa hak (_grant_)
menentukan apakah suatu peran boleh menjalankan operasi sedangkan kebijakan menentukan baris
yang terkena @supabase-rls. Supabase Auth adalah sistem autentikasi berbasis JWT yang
menyimpan data pengguna pada skema khusus dan terintegrasi dengan RLS @supabase-auth, sedangkan
_Edge Functions_ adalah fungsi TypeScript sisi server yang berjalan pada _runtime_ kompatibel
Deno @supabase-functions.

== Vercel

Vercel adalah platform hosting. Sebuah _deployment_ adalah hasil build proyek yang berhasil dan
memiliki URL unik, dengan tiga lingkungan bawaan, yaitu _Local_, _Preview_, dan _Production_.
Pada repositori Git yang terhubung, setiap _commit_ memicu _deployment_ baru secara otomatis
@vercel-deploy. Perilaku proyek dapat diatur melalui `vercel.json`, antara lain properti
`headers`, `redirects`, `rewrites`, dan `cleanUrls` @vercel-config. Pada proyek ini fitur tersebut
dipakai untuk pratinjau tiap _branch_, pengalihan menurut nama host, dan header keamanan.

== glTF dan Pemodelan 3D

glTF adalah format penyampaian aset 3D yang tidak terikat API grafis dan dirancang untuk
transmisi dan pemuatan konten 3D secara efisien. Format GLB mengemas aset glTF dalam satu
kontainer biner yang berisi bagian JSON untuk deskripsi adegan dan bagian biner untuk
geometri, animasi, dan tekstur @gltf-spec. Blender mengekspor ke glTF 2.0 melalui add-on bawaan
dalam bentuk `.glb` satu berkas atau `.gltf` dengan berkas terpisah @blender-gltf.
`<model-viewer>` adalah komponen web untuk menampilkan model 3D interaktif pada web dan AR
@model-viewer. Ketiganya membentuk jalur dari pemodelan hingga tampil di peramban pada
Bab IV dan V.

== Keamanan dan Aksesibilitas Web

OWASP Top 10:2021 menempatkan _Broken Access Control_ sebagai risiko pertama. Kontrol akses
memastikan pengguna tidak bertindak di luar izinnya, dan pencegahan utamanya adalah menolak
secara bawaan kecuali untuk sumber daya publik @owasp-a01. Direktif CSP `frame-ancestors`
menentukan induk mana yang boleh membenamkan halaman pada `<iframe>`, dan nilai `'none'`
setara dengan `X-Frame-Options: deny` @mdn-frame-ancestors, sehingga dipakai agar panel admin
tidak dapat dibingkai halaman lain. WCAG 2.2 memuat kriteria seperti 2.1.2 _No Keyboard Trap_
dan 2.4.1 _Bypass Blocks_, yaitu mekanisme untuk melompati blok konten yang berulang
@wcag22, yang diwujudkan pada tautan lompat ke konten dan dialog pemesanan yang menahan fokus
tetapi tetap dapat ditutup dengan papan ketik.
