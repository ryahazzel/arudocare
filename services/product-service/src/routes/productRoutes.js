const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

router.get('/', productController.getAll);
router.get('/merchant/:id', productController.getByMerchant);
router.post('/', productController.create);
router.put('/:id/stock', productController.updateStock);
router.patch('/:id/toggle', productController.toggle);

module.exports = router;
