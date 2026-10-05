// ============================================================
// Diagram relasi entitas (notasi crow's foot).
//   1!  tepat satu            1?  nol atau satu
//   n!  satu atau banyak      n?  nol atau banyak
// Hanya kolom penting yang ditampilkan; skema lengkap ada di migrasi.
// ============================================================

#import "_lib.typ": *

// Katalog layanan dan ketersediaan tanggal.
#let diagram-erd-katalog() = diagram(
  spacing: (5mm, 9mm), edge-stroke: garis,
  ent((0, 0), "services", "PK id", "slug", "name", "is_active", name: <svc>),
  ent((1, 0), "service_addons", "PK,FK service_id", "PK,FK addon_id", "requires_top_tier", "is_enabled", name: <sa>),
  ent((2, 0), "addons", "PK id", "code", "price", "max_qty", "cap_by_duration", name: <add>),

  ent((0, 1), "packages", "PK id", "FK service_id", "code", "price", "duration_hours", "booking_mode", name: <pkg>),
  ent((1, 1), "promotions", "PK id", "code", "kind", "value", "applies_to", "starts_at", "ends_at", name: <pro>),
  ent((2, 1), "vouchers", "PK id", "code", "kind", "value", "max_redemptions", "times_redeemed", name: <vou>),

  ent((0, 2), "locations", "PK id", "slug", "name", "daily_capacity", "is_active", name: <loc>),
  ent((1, 2), "availability_slots", "PK id", "FK location_id", "date", "booked_count", "capacity_override", "is_blocked", name: <slot>),
  ent((2, 2), "slot_claims", "PK id", "FK slot_id", "FK order_id", "status", "source", name: <claim>),

  edge(<svc>, <sa>, marks: ("1!", "n?")),
  edge(<add>, <sa>, marks: ("1!", "n?")),
  edge(<svc>, <pkg>, marks: ("1!", "n?")),
  edge(<loc>, <slot>, marks: ("1!", "n?")),
  edge(<slot>, <claim>, marks: ("1!", "n?")),
)

// Pemesanan, pembayaran, dan penagihan.
#let diagram-erd-pemesanan() = diagram(
  spacing: (4mm, 7mm), edge-stroke: garis,
  ent((0, 0), "promotions", "PK id", "code", "kind", "value", name: <pro>),
  ent((1, 0), "vouchers", "PK id", "code", "max_redemptions", "times_redeemed", name: <vou>, lebar: 34mm),
  ent((2, 0), "locations", "PK id", "slug", "daily_capacity", name: <loc>),

  ent((1, 1), "orders", "PK id", "code", "customer_name", "customer_whatsapp", "event_date", "FK location_id", "FK promotion_id", "FK voucher_id", "status", "total", "expires_at", "public_token", name: <ord>, lebar: 34mm),

  ent((0, 2), "order_items", "PK id", "FK order_id", "kind", "label", "qty", "unit_price", "line_total", name: <item>),
  ent((1, 2), "payments", "PK id", "FK order_id", "method", "amount", "status", "paid_on", "proof_path", name: <pay>, lebar: 34mm),
  ent((2, 2), "slot_claims", "PK id", "FK slot_id", "FK order_id", "status", "source", name: <claim>),

  ent((0, 3), "company_profile", "PK id", "legal_name", "bank_name", "signatory_name", "payment_terms_note", name: <cp>),
  ent((1, 3), "invoices", "PK id", "FK order_id", "FK payment_id", "seq", "number", "kind", "snapshot", name: <inv>, lebar: 34mm),

  edge(<pro>, <ord>, marks: ("1?", "n?")),
  edge(<vou>, <ord>, marks: ("1?", "n?")),
  edge(<loc>, <ord>, marks: ("1?", "n?")),
  edge(<ord>, <item>, marks: ("1!", "n!")),
  edge(<ord>, <pay>, marks: ("1!", "n?")),
  edge(<ord>, <claim>, marks: ("1?", "n?")),
  edge(<pay>, <inv>, marks: ("1?", "n?")),
  edge(<cp>, <inv>, "--"),
)
