const express = require('express');
const cors = require('cors');
require('dotenv').config();

const productRoutes = require('./src/routes/productRoutes');

const app = express();
const PORT = process.env.PORT || 8002;

app.use(cors());
app.use(express.json());

app.use('/api/products', productRoutes);

app.listen(PORT, () => {
    console.log(`Product Service running on http://localhost:${PORT}`);
});
