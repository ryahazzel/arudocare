const express = require('express');
const cors = require('cors');
require('dotenv').config();

const orderRoutes = require('./src/routes/orderRoutes');

const app = express();
const PORT = process.env.PORT || 8003;

app.use(cors());
app.use(express.json());

app.use('/api/orders', orderRoutes);

app.listen(PORT, () => {
    console.log(`Order Service running on http://localhost:${PORT}`);
});
