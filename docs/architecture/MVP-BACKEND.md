# BonAcheter — MVP backend & sync (Supabase-oriented)

This document maps the product plan (shared list, budget, Québec context) to a concrete next step after the **local-only iOS prototype**.

## Goals

| Concern | MVP app today | Target |
|--------|----------------|--------|
| Auth | Email stored on device (demo) | **Supabase Auth** (Sign in with Apple + email magic link) |
| Household | `householdInviteCode` (local key) | Row in `households` + **validated invite codes** (short code → `household_id` UUID) |
| Shared list | `LocalOnlyListSyncService` (no-op) | **Supabase Realtime** on `list_items` filtered by `household_id` |
| Conflicts | N/A | **Last-write-wins** per row or per-field merge (document choice) |
| Barcode | Open Food Facts (client-side HTTP) | Keep client-side; optionally cache product metadata in `products` table keyed by EAN |

## Suggested schema (PostgreSQL)

- **`profiles`**: `id` (uuid, = auth user), `display_name`, `locale`, `created_at`
- **`households`**: `id`, `name`, `invite_code` (unique, short), `created_at`
- **`household_members`**: `household_id`, `user_id`, `role` (`owner` | `editor` | `viewer`), `joined_at`
- **`lists`**: `id`, `household_id`, `name`, `region_label` (text for Montérégie/CMM/city MVP)
- **`list_items`**: `id`, `list_id`, `name`, `quantity`, `unit`, `is_taxable`, `barcode`, `updated_at`, `updated_by`
- **`purchases`**, **`purchase_lines`**: mirror `AppState` purchase flow; `total`, `store_name`, `purchased_at`
- **`price_history`** (optional server mirror): for cross-device history and future “below average” alerts

Row Level Security (RLS): members of `household_id` can `select/insert/update` rows for that household only.

## Realtime

- Channel per household: `household:{id}:list_items`
- On insert/update/delete, clients refresh or patch local `ListItem` models.
- iOS: Supabase Swift client + `RealtimeChannel` subscriptions; replace `LocalOnlyListSyncService` with `SupabaseListSyncService` conforming to `ListSyncServicing`.

## Open Food Facts

- Continue calling **HTTPS** `world.openfoodfacts.org` from the app (respect [OFF User-Agent policy](https://openfoodfacts.github.io/openfoodfacts-server/api/)).
- Optional: edge function to proxy/cache if rate limits or privacy policy require it.

## Migration path in code

1. Implement `SupabaseListSyncService` (same protocol as `ListSyncServicing`).
2. Inject service in `AppState` (e.g. `#if DEBUG` local vs release Supabase).
3. On login, resolve `household_id` from invite + user; subscribe to Realtime.
4. Replace `currentUserEmail` stub with Supabase session user id.

## Security & privacy

- No receipt images in MVP schema until OCR pipeline is defined; store object paths in private bucket with signed URLs.
- Community price sharing (future) should use **aggregates** only, not raw receipts.
