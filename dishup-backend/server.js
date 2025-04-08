const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

//signup
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

//login
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const [rows] = await db.query(
      `SELECT * FROM profiles WHERE email = ? AND password = ?`,
      [email, password]
    );

    if (rows.length === 1) {
      const user = rows[0];
      res.status(200).json({
        message: 'Login successful', user: {
          id: user.id,
          fullname: user.fullname,
          email: user.email,
          age: user.age,
          country: user.country
        }
      });

    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: 'Server error' });
  }
});

//get profile
app.get('/api/profile/:id', async (req, res) => {
  const userId = req.params.id;

  try {
    const [rows] = await db.query(
      `SELECT username, email, password, age, country, avatar_url, weight, height FROM profiles WHERE id = ?`,
      [userId]
    );

    if (rows.length === 1) {
      res.status(200).json(rows[0]);
    } else {
      res.status(404).json({ error: 'Profile not found' });
    }
  } catch (err) {
    console.error('Fetch profile error:', err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

//update profile
app.put('/api/profile/:id', async (req, res) => {
  const userId = req.params.id;
  const {
    username,
    email,
    password,
    age,
    country,
    weight,
    height,
    avatar_url
  } = req.body;

  try {
    await db.query(
      `UPDATE profiles 
       SET username = ?, email = ?, password = ?, age = ?, country = ?, weight = ?, height = ?, avatar_url = ?
       WHERE id = ?`,
      [username, email, password, age, country, weight, height, avatar_url, userId]
    );

    res.status(200).json({ message: 'Profile updated successfully' });
  } catch (err) {
    console.error('Update error:', err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

//meals
app.post('/api/meals', async (req, res) => {
  const { id, user_id, name, type, portion, energy, timestamp } = req.body;

  try {
    await db.query(`
      INSERT INTO meals (id, user_id, name, type, portion, energy, timestamp)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `, [id, user_id, name, type, portion, energy, timestamp]);

    res.status(201).json({ message: 'Meal added successfully' });
  } catch (err) {
    console.error('Insert meal error:', err);
    res.status(500).json({ error: 'Failed to insert meal' });
  }
});

//activities
app.post('/api/activities', async (req, res) => {
  const {
    id,
    user_id,
    activity_type,
    description,
    duration_minutes,
    timestamp,
    sleep_time,
    wake_time,
    cal_burned
  } = req.body;

  try {
    await db.query(`
      INSERT INTO activities (
        id,
        user_id,
        activity_type,
        description,
        duration_minutes,
        timestamp,
        sleep_time,
        wake_time,
        cal_burned
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      id,
      user_id,
      activity_type,
      description,
      duration_minutes,
      timestamp,
      sleep_time || null,
      wake_time || null,
      cal_burned || null
    ]);

    res.status(201).json({ message: 'Activity saved successfully' });
  } catch (err) {
    console.error('Insert activity error:', err);
    res.status(500).json({ error: 'Failed to save activity' });
  }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
