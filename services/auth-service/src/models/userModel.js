const pool = require('../config/db');

const User = {
    findByEmail: async (email) => {
        const query = 'SELECT * FROM users WHERE email = $1';
        const result = await pool.query(query, [email]);
        return result.rows[0];
    },

    create: async (name, email, passwordHash, role) => {
        const query = `
            INSERT INTO users (name, email, password_hash, role) 
            VALUES ($1, $2, $3, $4) 
            RETURNING id, name, email, role, created_at
        `;
        const result = await pool.query(query, [name, email, passwordHash, role || 'customer']);
        return result.rows[0];
    }
};

module.exports = User;