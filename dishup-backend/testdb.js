const pool = require('./db');

(async () => {
  try {
    const [rows] = await pool.query('SELECT NOW()');
    console.log('✅ Connected:', rows);
  } catch (err) {
    console.error('❌ Connection failed:', err);
  }
})();
