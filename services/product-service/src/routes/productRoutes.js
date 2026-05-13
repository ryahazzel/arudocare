const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

router.get('/', productController.getAll);
router.post('/', productController.create);
router.put('/:id/stock', productController.updateStock);

module.exports = router;
