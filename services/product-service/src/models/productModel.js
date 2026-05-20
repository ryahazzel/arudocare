const pool = require('../config/db');

const Product = {
    findAll: async () => {
        const query = `
            SELECT p.id, p.name, p.description,
                   p.original_price::float AS original_price,
                   p.discount_price::float AS discount_price,
                   p.stock, p.merchant_id, p.merchant_name, p.image_url,
                   p.pickup_time_start, p.pickup_time_end,
                   p.distance_km::float AS distance_km,
                   p.is_active, p.created_at, c.name AS category
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            WHERE p.stock > 0 AND p.is_active = TRUE
            ORDER BY p.created_at DESC
        `;
        const result = await pool.query(query);
        return result.rows;
    },

    findByMerchantId: async (merchantId) => {
        const query = `
            SELECT p.id, p.name, p.description,
                   p.original_price::float AS original_price,
                   p.discount_price::float AS discount_price,
                   p.stock, p.merchant_id, p.merchant_name, p.image_url,
                   p.pickup_time_start, p.pickup_time_end,
                   p.distance_km::float AS distance_km,
                   p.is_active, p.created_at, c.name AS category
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            WHERE p.merchant_id = $1
            ORDER BY p.created_at DESC
        `;
        const result = await pool.query(query, [merchantId]);
        return result.rows;
    },

    toggleAvailability: async (id) => {
        const query = `
            UPDATE products
            SET is_active = NOT is_active
            WHERE id = $1
            RETURNING id, is_active
        `;
        const result = await pool.query(query, [id]);
        return result.rows[0] ?? null;
    },

    create: async (data) => {
        const {
            name, description, original_price, discount_price, stock,
            category_id, merchant_id, merchant_name, image_url,
            pickup_time_start, pickup_time_end, distance_km,
        } = data;

        const query = `
            INSERT INTO products
                (name, description, original_price, discount_price, stock,
                 category_id, merchant_id, merchant_name, image_url,
                 pickup_time_start, pickup_time_end, distance_km)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            RETURNING *
        `;
        const result = await pool.query(query, [
            name, description, original_price, discount_price, stock,
            category_id, merchant_id, merchant_name, image_url,
            pickup_time_start, pickup_time_end, distance_km ?? 0,
        ]);
        return result.rows[0];
    },

    reduceStock: async (id, quantity) => {
        const query = `
            UPDATE products
            SET stock = stock - $1
            WHERE id = $2 AND stock >= $1
            RETURNING *
        `;
        const result = await pool.query(query, [quantity, id]);
        return result.rows[0] ?? null;
    },
};

module.exports = Product;
