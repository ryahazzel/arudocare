const express = require('express');
const proxy = require('express-http-proxy');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

app.use('/api/auth', proxy(process.env.AUTH_SERVICE_URL, {
    proxyReqPathResolver: (req) => `/api/auth${req.url}`,
}));

app.get('/health', (req, res) => {
    res.json({ status: 'API Gateway running', port: PORT });
});

app.listen(PORT, () => {
    console.log(`API Gateway running on http://localhost:${PORT}`);
    console.log(`  /api/auth  ->  ${process.env.AUTH_SERVICE_URL}`);
});
