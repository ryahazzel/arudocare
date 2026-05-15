const Order = require('../models/orderModel');

const orderController = {
    create: async (req, res) => {
        const { user_id, product_id, merchant_id, product_name, merchant_name, quantity, total_price } = req.body;

        if (!user_id || !product_id || !merchant_id || !product_name || !merchant_name || !quantity || !total_price) {
            return res.status(400).json({ message: 'Semua field wajib diisi' });
        }

        try {
            const order = await Order.create(req.body);
            res.status(201).json({ message: 'Pesanan berhasil dibuat', order });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    getByUser: async (req, res) => {
        try {
            const orders = await Order.findByUserId(req.params.id);
            res.json(orders);
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    getByMerchant: async (req, res) => {
        try {
            const orders = await Order.findByMerchantId(req.params.id);
            res.json(orders);
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    verify: async (req, res) => {
        const { qr_code } = req.body;

        if (!qr_code) {
            return res.status(400).json({ message: 'qr_code wajib diisi' });
        }

        try {
            const order = await Order.verifyByQrCode(qr_code);
            if (!order) {
                return res.status(404).json({ message: 'Pesanan tidak ditemukan atau sudah selesai' });
            }
            res.json({ message: 'Pesanan berhasil diverifikasi', order });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
};

module.exports = orderController;
