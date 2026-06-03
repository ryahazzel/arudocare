const pool = require('../config/db');

const User = {
    findByEmail: async (email) => {
        const query = 'SELECT * FROM users WHERE email = $1';
        const result = await pool.query(query, [email]);
        return result.rows[0];
    },

    create: async (name, email, passwordHash, role, latitude, longitude) => {
        const query = `
            INSERT INTO users (name, email, password_hash, role, latitude, longitude)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, name, email, role, latitude, longitude, created_at
        `;
        const result = await pool.query(query, [
            name, email, passwordHash, role || 'customer',
            latitude ?? null, longitude ?? null,
        ]);
        return result.rows[0];
    }
};

module.exports = User;