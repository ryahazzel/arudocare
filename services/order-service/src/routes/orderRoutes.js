const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');

router.post('/', orderController.create);
router.get('/user/:id', orderController.getByUser);
router.get('/merchant/:id', orderController.getByMerchant);
router.put('/verify', orderController.verify);

module.exports = router;
