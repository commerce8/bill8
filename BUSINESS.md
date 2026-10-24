# bill8 - Business Requirements & Functionality

> Secure Post-Quantum-Safe Billing & Payment Platform That Heals and Scales Itself.

> Audience: product owners, business analysts, and anyone evaluating what
> the bill8 vertical **does for the business**. For architecture read
> `README.md`; for wire-level detail read `DESIGN.md`.

## 1. Business Purpose

bill8 is the **billing layer of the Sentin8 platform** - a complete
payments and billing product that lets any merchant accept money, manage
recurring revenue, onboard sellers, and pay out funds, all with a
provable, replayable audit trail. It delivers:

- **Frictionless acceptance** - merchants accept one-off and recurring
  payments through hosted checkout pages and payment links, with no
  card-handling code of their own.
- **Rail freedom** - merchants select the settlement channels that fit
  their business: the platform's own finance rails, external acquirer
  and payment platforms, or direct bank connections. Channels are
  selectable per merchant, routable by cost, method, and geography, and
  new channels onboard without re-engineering the product.
- **Recurring revenue** - subscriptions, metered usage, invoices,
  proration, coupons, and credits are first-class, so SaaS and usage-based
  businesses bill correctly without building a billing engine.
- **Marketplace money movement** - connected accounts onboard through a
  guided flow, and funds split between platform and seller with explicit
  fees, held balances, and payouts.
- **Provable money integrity** - every cent moved is a double-entry
  balance transaction; refunds and disputes are compensating records, so
  the books can never silently drift.
- **Reliable integrations** - signed webhooks deliver every lifecycle
  event with retry, fraud rules block bad actors before money moves, and
  external integrators get API keys, client-side tokenization,
  deterministic test mode, and published specs.

## 2. Business Scope (What the Vertical Provides)

| # | Capability area | What the business gets |
|---|---|---|
| 1 | Connected accounts | Onboarding, persons, identity verification, external accounts, login links, account links |
| 2 | Payments | Customers, payment methods, intents, charges, refunds, disputes, setup intents, tokens |
| 3 | Hosted checkout | Sessions, payment links, hosted payment pages |
| 4 | Recurring billing | Products, prices, subscriptions, invoices, usage records, coupons, credits, proration |
| 5 | Money engine | Balances, balance transactions, payouts, transfers, fee model |
| 6 | Webhooks | Event materialization, endpoint management, signed delivery |
| 7 | Fraud prevention | Rules, velocity checks, sanctions screening, review queue |
| 8 | Reporting | Report runs, report types, scheduled reports |
| 9 | Settlement channels | Selectable rails - platform finance, external acquirer/payment platforms, bank rails - with routing and reconciliation |
| 10 | Integration access | Merchant API keys, client-side tokenization, deterministic test mode, published specs and SDKs |

**What the vertical does NOT own (business boundary):**

| Out of scope | Owned by |
|---|---|
| Customer identity, sign-in, sessions | Sentin8:Auth |
| Event transport, durability, delivery (Bus-side) | Sentin8:Bus |
| Workflow orchestration (subscription retries, invoice runs) | Sentin8:Flow |
| Scheduling / timing of scheduled work (invoice runs, reports) | Sentin8:Cron |
| Tenant-authored executable hooks | Sentin8:Func |
| Object storage (report files, invoice PDFs) | Sentin8:Storage |
| Analytics dashboards / KPI computation | Sentin8:Stat |
| API proxying to client apps | Sentin8:BFF |

## 3. Business Capabilities

Each service's `BUSINESS.md` details its capabilities. At the vertical
level the headline capabilities are:

| Capability | Business rule |
|---|---|
| Accept a one-off payment | A charge routes through a selected channel and moves money through the ledger; it is recorded immutably; a refund reverses it with a compensating transaction |
| Choose rails | A merchant selects and routes settlement channels; new channels onboard without product changes |
| Integrate from their own code | A merchant issues API keys, collects payment details client-side with a publishable key, and builds against deterministic test mode before going live |
| Create a subscription | A customer subscribes to a price; invoices are generated per billing cycle with proration on plan change |
| Meter usage | Usage records feed billable metrics that appear on the next invoice |
| Onboard a seller | A connected account is created with identity verification and a payout balance |
| Pay out funds | A payout moves available balance to an external account, recorded as a balance transaction |
| Deliver events | Every lifecycle change emits a signed webhook with retry until acknowledged |
| Block fraud | A risk rule screens a charge before money moves and can route it to review |

## 4. Business Events (Outbound)

The vertical's complete event surface (families):

| Family | Service | Emitted when |
|---|---|---|
| `merchants` | merchants | account/person/verification/external-account lifecycle changes |
| `payments` | payments | charge/refund/dispute/payment-method/intent lifecycle changes |
| `checkout` | checkout | session/link lifecycle changes |
| `billing` | billing | product/price/subscription/invoice/usage/coupon/credit lifecycle changes |
| `ledger` | ledger | balance/payout/transfer/balance-transaction changes |
| `webhooks` | webhooks | endpoint lifecycle + delivery outcome |
| `risk` | risk | rule/review/screening lifecycle changes |
| `reporting` | reporting | report run lifecycle changes |

## 5. Business Rules & Invariants

1. Money is only ever moved through the ledger service.
2. Charges and balance transactions are append-only - never mutated.
3. Refunds and disputes are compensating records referencing their origin.
4. Every money movement nets to zero (double-entry).
5. Every lifecycle change emits an event (outbox-first, same transaction).
6. Every webhook delivery is signed and retried until acknowledged.
7. Terminal states never regress.
8. Every tenant's data is isolated at the row level.

## 6. Target-User Roles & Use Cases

| Persona | Uses | Does |
|---|---|---|
| Merchant / business owner | merchant app, checkout | Accept payments, manage subscriptions, view reports, onboard sellers |
| Seller / connected account | portal app | View earnings, manage payout details |
| Customer / buyer | checkout app, portal | Pay via hosted pages, view invoices |
| Platform operator | admin app | Manage platform config, review fraud, oversee accounts |

## 7. KPIs / Success Criteria

| KPI | Measure |
|---|---|
| Charge success rate | Ratio of succeeded to attempted charges |
| Charge latency | p50/p95 time from request to terminal state |
| Refund integrity | Zero double-refunds; refund ≤ charge amount always |
| Webhook delivery | Signed delivery success rate; retry backoff respected |
| Fraud catch rate | Blocked/reviewed vs. attempted, with low false-positive |
| Invoice accuracy | Proration and usage metering reconcile to the cent |
| Idempotency | A retried request never double-moves money |

## 8. Dependencies & Reliance on Other Services

| Reliance | On |
|---|---|
| Identity and token issuance | Sentin8:Auth |
| Event transport and durability | Sentin8:Bus |
| Multi-step orchestration | Sentin8:Flow |
| Scheduled work | Sentin8:Cron |
| Tenant-authored hooks | Sentin8:Func |
| Object storage | Sentin8:Storage |
| Analytics | Sentin8:Stat |
| Proxying to apps | Sentin8:BFF |

## 9. Acceptance Criteria

1. A merchant can accept a one-off payment end-to-end with money recorded
   in the ledger and a webhook delivered.
2. A merchant can create a subscription that generates invoices with
   correct proration and metered usage.
3. A seller can onboard, receive split funds, and be paid out.
4. A refund fully reverses a charge and cannot be double-executed.
5. A fraud rule can block or review a charge before money moves.
6. A retried request is idempotent and never double-moves money.
7. Every tenant's data is isolated; cross-tenant access is rejected.
8. All flows are exercisable through the UI and BFF proxy only.

## 10. Open Business Questions

- Deferred to each service's `BUSINESS.md` §10 and the root `backlog.md`.
  No phased rollouts.

---

**Architecture & Design:** bill8 and its underlying concepts were designed by [Hamid Jahanzad](https://www.linkedin.com/in/hamidjahanzad/).
