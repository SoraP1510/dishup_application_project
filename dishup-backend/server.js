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
      `SELECT username, email, password, age, country, avatar_url, weight, height, kcal_target FROM profiles WHERE id = ?`,
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
  const updateFields = [];
  const values = [];

  for (const [key, value] of Object.entries(req.body)) {
    updateFields.push(`${key} = ?`);
    values.push(value);
  }
  values.push(userId);

  const sql = `UPDATE profiles SET ${updateFields.join(', ')} WHERE id = ?`;

  try {
    await db.query(sql, values);
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

app.get('/api/meals/day', async (req, res) => {
  const { user_id, start, end } = req.query;

  try {
    const [rows] = await db.query(
      `SELECT * FROM meals WHERE user_id = ? AND timestamp BETWEEN ? AND ? ORDER BY timestamp ASC`,
      [user_id, start, end]
    );

    res.status(200).json(rows);
  } catch (err) {
    console.error('Fetch meals by day error:', err);
    res.status(500).json({ error: 'Failed to fetch meals' });
  }
});

// Update meal
app.put('/api/meals/:id', async (req, res) => {
  const { name, type, portion, energy, timestamp } = req.body;
  const { id } = req.params;

  try {
    await db.query(
      `UPDATE meals SET name=?, type=?, portion=?, energy=?, timestamp=? WHERE id=?`,
      [name, type, portion, energy, timestamp, id]
    );
    res.status(200).json({ message: 'Meal updated' });
  } catch (err) {
    console.error('Update meal error:', err);
    res.status(500).json({ error: 'Failed to update meal' });
  }
});

// Delete meal
app.delete('/api/meals/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await db.query(`DELETE FROM meals WHERE id = ?`, [id]);
    res.status(200).json({ message: 'Meal deleted' });
  } catch (err) {
    console.error('Delete meal error:', err);
    res.status(500).json({ error: 'Failed to delete meal' });
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

app.get('/api/activities/day', async (req, res) => {
  const { user_id, start, end } = req.query;

  try {
    const [rows] = await db.query(
      `SELECT * FROM activities WHERE user_id = ? AND timestamp BETWEEN ? AND ? ORDER BY timestamp ASC`,
      [user_id, start, end]
    );

    res.status(200).json(rows);
  } catch (err) {
    console.error('Fetch activities by day error:', err);
    res.status(500).json({ error: 'Failed to fetch activities' });
  }
});

app.delete('/api/activities/:id', async (req, res) => {
  try {
    await db.query('DELETE FROM activities WHERE id = ?', [req.params.id]);
    res.status(200).json({ message: 'Activity deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete activity' });
  }
});

// Update activity
app.put('/api/activities/:id', async (req, res) => {
  const { id } = req.params;
  const {
    activity_type,
    description,
    duration_minutes,
    timestamp,
    sleep_time,
    wake_time,
    cal_burned
  } = req.body;

  try {
    await db.query(
      `UPDATE activities SET
        activity_type = ?,
        description = ?,
        duration_minutes = ?,
        timestamp = ?,
        sleep_time = ?,
        wake_time = ?,
        cal_burned = ?
      WHERE id = ?`,
      [
        activity_type,
        description,
        duration_minutes,
        timestamp,
        sleep_time || null,
        wake_time || null,
        cal_burned || null,
        id
      ]
    );

    res.status(200).json({ message: 'Activity updated successfully' });
  } catch (err) {
    console.error('Update activity error:', err);
    res.status(500).json({ error: 'Failed to update activity' });
  }
});

//random quotes
app.get('/api/quotes/random', async (req, res) => {
  try {
    const [rows] = await db.query(`SELECT text FROM quotes ORDER BY RAND() LIMIT 1`);
    if (rows.length > 0) {
      res.status(200).json({ quote: rows[0].text });
    } else {
      res.status(404).json({ error: 'No quote found' });
    }
  } catch (err) {
    console.error('Fetch quote error:', err);
    res.status(500).json({ error: 'Failed to fetch quote' });
  }
});




const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
