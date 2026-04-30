-- Harvest Slot v3.1 final 19 tables
-- MySQL 8.x / InnoDB
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customer_profiles;
DROP TABLE IF EXISTS owner_profiles;
DROP TABLE IF EXISTS email_verifications;
DROP TABLE IF EXISTS farms;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS ml_predictions;
DROP TABLE IF EXISTS harvest_slots;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS reservation_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS procurements;
DROP TABLE IF EXISTS procurement_items;
DROP TABLE IF EXISTS quality_inspections;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS return_requests;
DROP TABLE IF EXISTS refunds;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE accounts (
  account_id BIGINT AUTO_INCREMENT NOT NULL,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (account_id),
  UNIQUE KEY uk_accounts_email (email),
  CHECK (role IN ('CUSTOMER','OWNER')),
  CHECK (status IN ('ACTIVE','LOCKED','WITHDRAWN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE customer_profiles (
  customer_id BIGINT AUTO_INCREMENT NOT NULL,
  account_id BIGINT NOT NULL,
  customer_name VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(30) NOT NULL,
  default_receiver_name VARCHAR(100) NULL,
  default_receiver_phone VARCHAR(30) NULL,
  default_shipping_address VARCHAR(500) NULL,
  marketing_agree BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id),
  UNIQUE KEY uk_customer_profiles_account_id (account_id),
  CONSTRAINT fk_customer_profiles_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE owner_profiles (
  owner_id BIGINT AUTO_INCREMENT NOT NULL,
  account_id BIGINT NOT NULL,
  owner_name VARCHAR(100) NOT NULL,
  owner_phone VARCHAR(30) NOT NULL,
  business_number VARCHAR(50) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (owner_id),
  UNIQUE KEY uk_owner_profiles_account_id (account_id),
  CONSTRAINT fk_owner_profiles_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE email_verifications (
  email_verification_id BIGINT AUTO_INCREMENT NOT NULL,
  account_id BIGINT NOT NULL,
  email VARCHAR(255) NOT NULL,
  purpose VARCHAR(30) NOT NULL,
  verification_code VARCHAR(20) NOT NULL,
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  expires_at DATETIME NOT NULL,
  verified_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (email_verification_id),
  KEY idx_email_verifications_account_id (account_id),
  CONSTRAINT fk_email_verifications_account_id FOREIGN KEY (account_id) REFERENCES accounts(account_id),
  CHECK (purpose IN ('SIGNUP','RESET_PASSWORD'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE farms (
  farm_id BIGINT AUTO_INCREMENT NOT NULL,
  owner_id BIGINT NOT NULL,
  farm_name VARCHAR(150) NOT NULL,
  farm_region VARCHAR(100) NOT NULL,
  farm_address VARCHAR(500) NOT NULL,
  farm_image_url VARCHAR(1000) NULL,
  farm_description TEXT NULL,
  delivery_policy TEXT NULL,
  return_policy TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (farm_id),
  KEY idx_farms_owner_id (owner_id),
  CONSTRAINT fk_farms_owner_id FOREIGN KEY (owner_id) REFERENCES owner_profiles(owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
  product_id BIGINT AUTO_INCREMENT NOT NULL,
  farm_id BIGINT NOT NULL,
  product_name VARCHAR(200) NOT NULL,
  fruit_type VARCHAR(50) NOT NULL,
  variety VARCHAR(100) NOT NULL,
  package_unit_kg DECIMAL(6,2) NOT NULL,
  base_price INT NOT NULL,
  product_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  image_url VARCHAR(1000) NULL,
  product_description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (product_id),
  KEY idx_products_farm_id (farm_id),
  CONSTRAINT fk_products_farm_id FOREIGN KEY (farm_id) REFERENCES farms(farm_id),
  CHECK (product_status IN ('ACTIVE','HIDDEN','SOLD_OUT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ml_predictions (
  prediction_id BIGINT AUTO_INCREMENT NOT NULL,
  farm_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  created_by_owner_id BIGINT NOT NULL,
  input_feature_json JSON NOT NULL,
  open_api_snapshot_json JSON NULL,
  predicted_harvest_start DATE NOT NULL,
  predicted_harvest_end DATE NOT NULL,
  estimated_yield_kg DECIMAL(10,2) NOT NULL,
  suggested_reservable_min_kg DECIMAL(10,2) NOT NULL,
  suggested_reservable_max_kg DECIMAL(10,2) NOT NULL,
  recommended_price INT NOT NULL,
  confidence DECIMAL(5,4) NOT NULL,
  safety_factor DECIMAL(5,4) NOT NULL,
  warning_message VARCHAR(500) NOT NULL,
  model_version VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (prediction_id),
  KEY idx_ml_predictions_farm_id (farm_id),
  KEY idx_ml_predictions_product_id (product_id),
  KEY idx_ml_predictions_created_by_owner_id (created_by_owner_id),
  CONSTRAINT fk_ml_predictions_farm_id FOREIGN KEY (farm_id) REFERENCES farms(farm_id),
  CONSTRAINT fk_ml_predictions_product_id FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_ml_predictions_created_by_owner_id FOREIGN KEY (created_by_owner_id) REFERENCES owner_profiles(owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE harvest_slots (
  slot_id BIGINT AUTO_INCREMENT NOT NULL,
  farm_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  prediction_id BIGINT NULL,
  confirmed_harvest_start DATE NOT NULL,
  confirmed_harvest_end DATE NOT NULL,
  confirmed_reservable_kg DECIMAL(10,2) NOT NULL,
  reserved_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
  sold_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
  confirmed_price INT NOT NULL,
  customer_notice VARCHAR(500) NOT NULL,
  slot_status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  owner_confirmed_at DATETIME NULL,
  opened_at DATETIME NULL,
  closed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (slot_id),
  KEY idx_harvest_slots_farm_id (farm_id),
  KEY idx_harvest_slots_product_id (product_id),
  KEY idx_harvest_slots_prediction_id (prediction_id),
  CONSTRAINT fk_harvest_slots_farm_id FOREIGN KEY (farm_id) REFERENCES farms(farm_id),
  CONSTRAINT fk_harvest_slots_product_id FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_harvest_slots_prediction_id FOREIGN KEY (prediction_id) REFERENCES ml_predictions(prediction_id),
  CHECK (slot_status IN ('DRAFT','OPEN','CLOSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reservations (
  reservation_id BIGINT AUTO_INCREMENT NOT NULL,
  customer_id BIGINT NOT NULL,
  reservation_no VARCHAR(50) NOT NULL,
  reservation_status VARCHAR(30) NOT NULL DEFAULT 'RESERVED',
  reserved_until DATETIME NOT NULL,
  total_reserved_kg DECIMAL(10,2) NOT NULL,
  total_amount INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (reservation_id),
  UNIQUE KEY uk_reservations_reservation_no (reservation_no),
  KEY idx_reservations_customer_id (customer_id),
  CONSTRAINT fk_reservations_customer_id FOREIGN KEY (customer_id) REFERENCES customer_profiles(customer_id),
  CHECK (reservation_status IN ('RESERVED','ORDERED','EXPIRED','CANCELED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reservation_items (
  reservation_item_id BIGINT AUTO_INCREMENT NOT NULL,
  reservation_id BIGINT NOT NULL,
  slot_id BIGINT NOT NULL,
  package_count INT NOT NULL,
  reserved_kg DECIMAL(10,2) NOT NULL,
  unit_price_snapshot INT NOT NULL,
  subtotal_amount INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (reservation_item_id),
  KEY idx_reservation_items_reservation_id (reservation_id),
  KEY idx_reservation_items_slot_id (slot_id),
  CONSTRAINT fk_reservation_items_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id),
  CONSTRAINT fk_reservation_items_slot_id FOREIGN KEY (slot_id) REFERENCES harvest_slots(slot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  order_id BIGINT AUTO_INCREMENT NOT NULL,
  reservation_id BIGINT NOT NULL,
  order_no VARCHAR(50) NOT NULL,
  order_status VARCHAR(30) NOT NULL DEFAULT 'PAYMENT_PENDING',
  total_amount INT NOT NULL,
  receiver_name VARCHAR(100) NOT NULL,
  receiver_phone VARCHAR(30) NOT NULL,
  shipping_address VARCHAR(500) NOT NULL,
  delivery_memo VARCHAR(500) NULL,
  ordered_at DATETIME NOT NULL,
  paid_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id),
  UNIQUE KEY uk_orders_reservation_id (reservation_id),
  UNIQUE KEY uk_orders_order_no (order_no),
  CONSTRAINT fk_orders_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id),
  CHECK (order_status IN ('PAYMENT_PENDING','PAID','PROCUREMENT_REQUESTED','PROCUREMENT_APPROVED','PROCUREMENT_PARTIAL_APPROVED','PROCUREMENT_REJECTED','SHIPPED','DELIVERED','RETURN_REQUESTED','REFUNDED','CANCELED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
  order_item_id BIGINT AUTO_INCREMENT NOT NULL,
  order_id BIGINT NOT NULL,
  reservation_item_id BIGINT NOT NULL,
  package_count INT NOT NULL,
  ordered_kg DECIMAL(10,2) NOT NULL,
  unit_price INT NOT NULL,
  subtotal_amount INT NOT NULL,
  order_item_status VARCHAR(30) NOT NULL DEFAULT 'ORDERED',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (order_item_id),
  UNIQUE KEY uk_order_items_reservation_item_id (reservation_item_id),
  KEY idx_order_items_order_id (order_id),
  CONSTRAINT fk_order_items_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_order_items_reservation_item_id FOREIGN KEY (reservation_item_id) REFERENCES reservation_items(reservation_item_id),
  CHECK (order_item_status IN ('ORDERED','PROCUREMENT_REQUESTED','APPROVED','PARTIAL_APPROVED','REJECTED','QUALITY_CHECKED','SHIPPED','DELIVERED','RETURN_REQUESTED','REFUNDED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payments (
  payment_id BIGINT AUTO_INCREMENT NOT NULL,
  order_id BIGINT NOT NULL,
  payment_provider VARCHAR(30) NOT NULL DEFAULT 'MOCK',
  payment_method VARCHAR(30) NOT NULL DEFAULT 'MOCK_CARD',
  payment_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
  requested_amount INT NOT NULL,
  approved_amount INT NOT NULL DEFAULT 0,
  mock_transaction_key VARCHAR(200) NULL,
  idempotency_key VARCHAR(200) NOT NULL,
  requested_at DATETIME NOT NULL,
  approved_at DATETIME NULL,
  failed_at DATETIME NULL,
  failure_reason VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (payment_id),
  UNIQUE KEY uk_payments_idempotency_key (idempotency_key),
  KEY idx_payments_order_id (order_id),
  CONSTRAINT fk_payments_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CHECK (payment_method IN ('MOCK_CARD')),
  CHECK (payment_status IN ('REQUESTED','APPROVED','FAILED','CANCELED','REFUNDED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE procurements (
  procurement_id BIGINT AUTO_INCREMENT NOT NULL,
  order_id BIGINT NOT NULL,
  farm_id BIGINT NOT NULL,
  owner_id BIGINT NOT NULL,
  procurement_no VARCHAR(50) NOT NULL,
  procurement_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
  requested_at DATETIME NOT NULL,
  response_deadline_at DATETIME NULL,
  decided_at DATETIME NULL,
  rejected_reason VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (procurement_id),
  UNIQUE KEY uk_procurements_order_id (order_id),
  UNIQUE KEY uk_procurements_procurement_no (procurement_no),
  KEY idx_procurements_farm_id (farm_id),
  KEY idx_procurements_owner_id (owner_id),
  CONSTRAINT fk_procurements_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_procurements_farm_id FOREIGN KEY (farm_id) REFERENCES farms(farm_id),
  CONSTRAINT fk_procurements_owner_id FOREIGN KEY (owner_id) REFERENCES owner_profiles(owner_id),
  CHECK (procurement_status IN ('REQUESTED','APPROVED','PARTIAL_APPROVED','REJECTED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE procurement_items (
  procurement_item_id BIGINT AUTO_INCREMENT NOT NULL,
  procurement_id BIGINT NOT NULL,
  order_item_id BIGINT NOT NULL,
  requested_package_count INT NOT NULL,
  requested_kg DECIMAL(10,2) NOT NULL,
  approved_package_count INT NOT NULL DEFAULT 0,
  approved_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
  approval_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
  owner_memo VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (procurement_item_id),
  UNIQUE KEY uk_procurement_items_order_item_id (order_item_id),
  KEY idx_procurement_items_procurement_id (procurement_id),
  CONSTRAINT fk_procurement_items_procurement_id FOREIGN KEY (procurement_id) REFERENCES procurements(procurement_id),
  CONSTRAINT fk_procurement_items_order_item_id FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
  CHECK (approval_status IN ('REQUESTED','APPROVED','PARTIAL_APPROVED','REJECTED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE quality_inspections (
  quality_inspection_id BIGINT AUTO_INCREMENT NOT NULL,
  procurement_item_id BIGINT NOT NULL,
  owner_id BIGINT NOT NULL,
  image_url VARCHAR(1000) NOT NULL,
  model_grade VARCHAR(20) NOT NULL,
  freshness_score DECIMAL(5,2) NOT NULL,
  color_score DECIMAL(5,2) NOT NULL,
  roundness_score DECIMAL(5,2) NOT NULL,
  bruise_probability DECIMAL(5,4) NOT NULL,
  model_decision VARCHAR(20) NOT NULL,
  owner_confirmed_grade VARCHAR(20) NULL,
  owner_decision VARCHAR(20) NULL,
  model_version VARCHAR(50) NOT NULL,
  inspected_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (quality_inspection_id),
  KEY idx_quality_inspections_procurement_item_id (procurement_item_id),
  KEY idx_quality_inspections_owner_id (owner_id),
  CONSTRAINT fk_quality_inspections_procurement_item_id FOREIGN KEY (procurement_item_id) REFERENCES procurement_items(procurement_item_id),
  CONSTRAINT fk_quality_inspections_owner_id FOREIGN KEY (owner_id) REFERENCES owner_profiles(owner_id),
  CHECK (model_grade IN ('A','B','C')),
  CHECK (model_decision IN ('PASS','REVIEW','HOLD')),
  CHECK (owner_confirmed_grade IS NULL OR owner_confirmed_grade IN ('A','B','C')),
  CHECK (owner_decision IS NULL OR owner_decision IN ('PASS','HOLD'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shipments (
  shipment_id BIGINT AUTO_INCREMENT NOT NULL,
  order_id BIGINT NOT NULL,
  carrier_name VARCHAR(100) NOT NULL,
  tracking_no VARCHAR(100) NOT NULL,
  shipped_package_count INT NOT NULL,
  shipped_kg DECIMAL(10,2) NOT NULL,
  shipment_status VARCHAR(30) NOT NULL DEFAULT 'READY',
  shipped_at DATETIME NULL,
  delivered_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (shipment_id),
  UNIQUE KEY uk_shipments_order_id (order_id),
  CONSTRAINT fk_shipments_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CHECK (shipment_status IN ('READY','SHIPPED','DELIVERED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE return_requests (
  return_request_id BIGINT AUTO_INCREMENT NOT NULL,
  order_id BIGINT NOT NULL,
  return_no VARCHAR(50) NOT NULL,
  return_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
  reason_code VARCHAR(100) NOT NULL,
  reason_detail VARCHAR(1000) NULL,
  evidence_image_url VARCHAR(1000) NULL,
  requested_amount INT NOT NULL,
  approved_amount INT NOT NULL DEFAULT 0,
  decision_reason VARCHAR(500) NULL,
  requested_at DATETIME NOT NULL,
  decided_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (return_request_id),
  UNIQUE KEY uk_return_requests_order_id (order_id),
  UNIQUE KEY uk_return_requests_return_no (return_no),
  CONSTRAINT fk_return_requests_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CHECK (return_status IN ('REQUESTED','APPROVED','REJECTED','REFUNDED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE refunds (
  refund_id BIGINT AUTO_INCREMENT NOT NULL,
  return_request_id BIGINT NOT NULL,
  payment_id BIGINT NOT NULL,
  refund_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
  requested_amount INT NOT NULL,
  refunded_amount INT NOT NULL DEFAULT 0,
  requested_at DATETIME NOT NULL,
  completed_at DATETIME NULL,
  failure_reason VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (refund_id),
  UNIQUE KEY uk_refunds_return_request_id (return_request_id),
  UNIQUE KEY uk_refunds_payment_id (payment_id),
  CONSTRAINT fk_refunds_return_request_id FOREIGN KEY (return_request_id) REFERENCES return_requests(return_request_id),
  CONSTRAINT fk_refunds_payment_id FOREIGN KEY (payment_id) REFERENCES payments(payment_id),
  CHECK (refund_status IN ('REQUESTED','COMPLETED','FAILED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
