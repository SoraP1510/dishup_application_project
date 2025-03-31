const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/signup', async (req, res) => {
  const {
    id, fullname, email, password,
    gender, username, age, weight,
    height, kcal_target, avatar_url
  } = req.body;

  try {
    await db.query(
      `INSERT INTO profiles (id, fullname, email, password, gender, username, age, weight, height, kcal_target, avatar_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, fullname, email, password, gender, username, age, weight, height, kcal_target, avatar_url]
    );    

    res.status(201).json({ message: 'Profile created successfully' });
  } catch (err) {
    console.error("🔥 DB ERROR:", err);
    res.status(500).json({ error: 'Failed to insert profile' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
