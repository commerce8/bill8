# Changelog - bill8

## v0.1.0 - initial implementation

- **Vertical design authored**: root `README.md` (overview), `DESIGN.md`
  (vertical DDD), `BUSINESS.md` (BRD), and `backlog.md` (story list) for
  the bill8 vertical. Eight services (merchants, payments, checkout,
  billing, ledger, webhooks, risk, reporting), eight contract crates, the
  SDK facade, and four apps designed against the Sentin8 platform
  patterns (schema-per-service, DBX outbox, Shield policy, FORCE-RLS,
  cert-bound DCR M2M, RFW admin UI).
- **Implementation pass**: all 17 Rust crates implemented and green -
  `cargo build --workspace` exits 0 with 0 warnings in bill8 crates;
  81 tests passing (contracts round-trips, the fail-closed risk engine,
  the HMAC delivery engine, and the cent-exact proration engine with
  leap-year/month-clamp cycle math). Settlement-channel core: a
  `ChannelAdapter` contract + runtime registry + fail-closed routing
  (charges route through selectable channels; money moves only through
  the ledger's public API). Money-path invariants enforced end-to-end:
  append-only charges, row-locked bounded refunds, idempotency on every
  money mutation, same-transaction outbox discipline.

## v0.1.1 - second implementation pass

- **Payments completion**: tokenization (`/v1/tokens` + single-use
  consume), test-mode simulation instruments (decline/timeout/SCA
  amount suffixes), SCA challenge hold + single-use handback (the
  channel-verified completion only), the publishable method catalog,
  split-at-charge (the three-leg batch: payer → connected → platform
  fee, netting exactly to the charge), payment/setup intents with the
  guarded confirmation state machine, and dispute resolution with the
  lost-dispute clawback.
- **Event-driven wiring**: env-init consumers live (per-tenant
  simulation-channel + ledger-account seeding on `service:updated`);
  review resolution is payload-complete (the risk service carries the
  charge reference - no cross-schema reads anywhere); billing consumes
  `charge:succeeded` to settle invoices; webhooks materialize events
  per family and fan out signed deliveries.
- **Billing completion**: invoice runs (due subscriptions → lines →
  finalize → charge through the payments API), the dunning ladder
  (attempts + configs; exhaustion voids the invoice and cancels the
  subscription), coupons, credits, credit notes, tax rates,
  pause/resume, and the no-write previews (upcoming invoice +
  proration quote).
- **Ledger**: payout schedules + the Cron tick; the split posting is
  the explicit three-leg net-zero batch.
- **Reporting**: report schedules (per type/period) + the idempotent
  Cron proxy-back tick - one run per period, two fires in one window
  are a no-op.
- **Wire conventions (WS-4)**: `bill8-wire-contracts` - the
  uniform error envelope, cursor pagination, header conventions;
  re-exported as `bill8::wire`.
- **Apps**: all four Flutter apps (merchant, checkout, portal, admin
  RFW host) analyze clean, build for web, and pass their widget tests
  through the shared platform SDK.
- **E2E**: the Playwright scaffold + core money-flow spec (UI + BFF
  proxy only; CLI-driven global setup, zero SQL).
- **Verification**: `cargo build --workspace` green with 0 warnings in
  bill8 crates; 90 Rust tests + 8 Flutter tests green.
