const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

const Order = {
    create: async (data) => {
        const { user_id, product_id, merchant_id, product_name, merchant_name, quantity, total_price } = data;
        const qr_code = uuidv4();

        const query = `
            INSERT INTO orders
                (user_id, product_id, merchant_id, product_name, merchant_name, quantity, total_price, status, qr_code)
            VALUES ($1, $2, $3, $4, $5, $6, $7, 'pending', $8)
            RETURNING *
        `;
        const result = await pool.query(query, [
            user_id, product_id, merchant_id, product_name, merchant_name, quantity, total_price, qr_code,
        ]);
        return result.rows[0];
    },

    findByUserId: async (user_id) => {
        const query = `
            SELECT * FROM orders
            WHERE user_id = $1
            ORDER BY created_at DESC
        `;
        const result = await pool.query(query, [user_id]);
        return result.rows;
    },

    findByMerchantId: async (merchant_id) => {
        const query = `
            SELECT * FROM orders
            WHERE merchant_id = $1
            ORDER BY created_at DESC
        `;
        const result = await pool.query(query, [merchant_id]);
        return result.rows;
    },

    verifyByQrCode: async (qr_code) => {
        const query = `
            UPDATE orders
            SET status = 'completed', completed_at = NOW()
            WHERE qr_code = $1 AND status = 'pending'
            RETURNING *
        `;
        const result = await pool.query(query, [qr_code]);
        return result.rows[0] ?? null;
    },
};

module.exports = Order;
