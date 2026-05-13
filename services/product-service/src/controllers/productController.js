const Product = require('../models/productModel');

const productController = {
    getAll: async (req, res) => {
        try {
            const products = await Product.findAll();
            res.json(products);
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    create: async (req, res) => {
        try {
            const product = await Product.create(req.body);
            res.status(201).json({ message: 'Product created', product });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    updateStock: async (req, res) => {
        try {
            const { id } = req.params;
            const { quantity } = req.body;

            if (!quantity || quantity < 1) {
                return res.status(400).json({ message: 'Invalid quantity' });
            }

            const product = await Product.reduceStock(id, quantity);
            if (!product) {
                return res.status(400).json({ message: 'Insufficient stock or product not found' });
            }

            res.json({ message: 'Stock updated', product });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
};

module.exports = productController;
