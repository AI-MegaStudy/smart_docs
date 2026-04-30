# Material 3 Selection Payload Migration Checklist

> Scope: `prototype_user_web_m3/` customer web mockup pages.
> Goal: replace free text / loose display states with DB and FastAPI payload-oriented selection UI.

## Ground Rules

- [x] Use apple products only.
- [x] Product selection is based on `products.product_id + package_unit_kg`.
- [x] Harvest slot selection is based on `harvest_slots.slot_id`.
- [x] Reservation quantity is calculated from `package_count * package_unit_kg`.
- [x] Checkout starts from `customer_profiles.default_*`, then allows memo selection and optional edit.
- [x] Return request is centered on `reason_code`, `request_amount`, and evidence image selection.

## Page Tasks

- [x] `local-basket.html`
  - [x] Show basket lines as selected `product_id`, `slot_id`, `package_unit_kg`, `package_count`, `reserved_kg`.
  - [x] Remove any direct kg input implication.
  - [x] Add FastAPI preview for reservation preview/create payload.

- [x] `reservation-confirm.html`
  - [x] Show final server validation fields per reservation item.
  - [x] Show `reserved_until` / lock behavior before moving to checkout.
  - [x] Add FastAPI preview for `POST /reservations`.

- [x] `checkout.html`
  - [x] Replace recipient/name/address direct-first inputs with default delivery profile selection.
  - [x] Add delivery memo selection and optional edit state.
  - [x] Add FastAPI preview for `POST /orders/from-reservation`.

- [x] `return-request.html`
  - [x] Select an order line item and reason code.
  - [x] Make request amount a selected/calculated amount, not an arbitrary free input.
  - [x] Make evidence images explicit selected attachments.
  - [x] Add FastAPI preview for `POST /returns`.

## Verification

- [x] Search for non-apple product leakage in updated pages.
- [x] Search for direct kg entry / free amount wording in updated pages.
- [x] Open pages locally or run a static sanity check.
