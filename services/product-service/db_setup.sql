-- Jalankan di psql atau pgAdmin sebagai user postgres
-- Pastikan database sudah dibuat dulu:
--   CREATE DATABASE arudo_product;

CREATE TABLE IF NOT EXISTS categories (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

INSERT INTO categories (name) VALUES
    ('Makanan Siap Saji'),
    ('Bakery'),
    ('Sayuran'),
    ('Belanja')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS products (
    id                SERIAL PRIMARY KEY,
    name              VARCHAR(255)    NOT NULL,
    description       TEXT,
    original_price    NUMERIC(12, 2)  NOT NULL,
    discount_price    NUMERIC(12, 2)  NOT NULL,
    stock             INTEGER         NOT NULL DEFAULT 0,
    category_id       INTEGER         REFERENCES categories(id),
    merchant_id       INTEGER         NOT NULL,
    merchant_name     VARCHAR(255)    NOT NULL,
    image_url         TEXT,
    pickup_time_start TIME,
    pickup_time_end   TIME,
    distance_km       NUMERIC(5, 2)   DEFAULT 0,
    is_active         BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP       DEFAULT NOW()
);

-- For existing databases, run this to add the column:
ALTER TABLE products ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;
