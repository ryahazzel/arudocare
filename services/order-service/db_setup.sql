-- Jalankan di psql atau pgAdmin sebagai user postgres
-- Pastikan database arudo_order sudah dibuat dulu:
--   CREATE DATABASE arudo_order;

CREATE TABLE IF NOT EXISTS orders (
    id             SERIAL PRIMARY KEY,
    user_id        INTEGER NOT NULL,
    product_id     INTEGER NOT NULL,
    merchant_id    INTEGER NOT NULL,
    product_name   VARCHAR(255) NOT NULL,
    merchant_name  VARCHAR(255) NOT NULL,
    quantity       INTEGER NOT NULL DEFAULT 1,
    total_price    NUMERIC(12, 2) NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'pending',
    qr_code        TEXT NOT NULL UNIQUE,
    created_at     TIMESTAMP DEFAULT NOW(),
    completed_at   TIMESTAMP
);
