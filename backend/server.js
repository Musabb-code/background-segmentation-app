require('dotenv').config();

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const env = require('./src/config/env');
require('./src/config/firebase');
const logger = require('./src/utils/logger');
const routes = require('./src/routes/index');
const errorHandler = require('./src/middleware/errorHandler');

const app = express();

// §6.3: helmet → cors → express.json → rateLimiter (on routes) → routes → errorHandler
app.use(helmet());
app.use(cors({ origin: env.CLIENT_URL, credentials: true }));
app.use(express.json());
app.use('/api', routes);
app.use(errorHandler);

if (require.main === module) {
  app.listen(env.PORT, () => {
    logger.info(`Server listening on port ${env.PORT}`);
  });
}

module.exports = app;
