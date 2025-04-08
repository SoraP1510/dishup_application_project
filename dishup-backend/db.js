// db.js
const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: true,
  },
  waitForConnections: true,
  connectionLimit: 10,
  connectTimeout: 10000,           // 10s timeout for initial connect
  enableKeepAlive: true,           // ✅ keep socket alive
  keepAliveInitialDelay: 10000     // wait 10s before ping
  //Let's see if it works or not
});

module.exports = pool;