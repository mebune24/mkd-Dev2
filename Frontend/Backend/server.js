const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { initializeDb } = require('./database');

const app = express();
const port = 3000;
const SECRET_KEY = 'your_super_secret_key_change_this_in_production'; // In a real app, use .env

app.use(cors());
app.use(express.json());

let db;

(async () => {
  db = await initializeDb();
})();

// Middleware to authenticate token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// --- Auth Routes ---
app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await db.get('SELECT * FROM users WHERE username = ?', username);
    if (!user) return res.status(400).json({ error: 'User not found' });

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(400).json({ error: 'Invalid password' });

    const token = jwt.sign({ id: user.id, username: user.username }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Blog Post Routes ---
app.get('/api/posts', async (req, res) => {
  try {
    const posts = await db.all('SELECT * FROM posts');
    const parsedPosts = posts.map(post => ({
      ...post,
      tags: JSON.parse(post.tags),
      pages: JSON.parse(post.pages)
    }));
    res.json(parsedPosts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/posts/:id', async (req, res) => {
  try {
    const post = await db.get('SELECT * FROM posts WHERE id = ?', req.params.id);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    post.tags = JSON.parse(post.tags);
    post.pages = JSON.parse(post.pages);
    res.json(post);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/posts', authenticateToken, async (req, res) => {
  const { title, excerpt, date, readTime, category, image, tags, pages } = req.body;
  try {
    const result = await db.run(
      'INSERT INTO posts (title, excerpt, date, readTime, category, image, tags, pages) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [title, excerpt, date, readTime, category, image, JSON.stringify(tags), JSON.stringify(pages)]
    );
    res.json({ id: result.lastID });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/posts/:id', authenticateToken, async (req, res) => {
  const { title, excerpt, date, readTime, category, image, tags, pages } = req.body;
  try {
    await db.run(
      'UPDATE posts SET title = ?, excerpt = ?, date = ?, readTime = ?, category = ?, image = ?, tags = ?, pages = ? WHERE id = ?',
      [title, excerpt, date, readTime, category, image, JSON.stringify(tags), JSON.stringify(pages), req.params.id]
    );
    res.json({ message: 'Post updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/posts/:id', authenticateToken, async (req, res) => {
  try {
    await db.run('DELETE FROM posts WHERE id = ?', req.params.id);
    res.json({ message: 'Post deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Project Routes ---
app.get('/api/projects', async (req, res) => {
  try {
    const projects = await db.all('SELECT * FROM projects');
    const parsedProjects = projects.map(p => ({
      ...p,
      stack: JSON.parse(p.stack)
    }));
    res.json(parsedProjects);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/projects', authenticateToken, async (req, res) => {
  const { title, description, image, stack, github, demo } = req.body;
  try {
    const result = await db.run(
      'INSERT INTO projects (title, description, image, stack, github, demo) VALUES (?, ?, ?, ?, ?, ?)',
      [title, description, image, JSON.stringify(stack), github, demo]
    );
    res.json({ id: result.lastID });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/projects/:id', authenticateToken, async (req, res) => {
  const { title, description, image, stack, github, demo } = req.body;
  try {
    await db.run(
      'UPDATE projects SET title = ?, description = ?, image = ?, stack = ?, github = ?, demo = ? WHERE id = ?',
      [title, description, image, JSON.stringify(stack), github, demo, req.params.id]
    );
    res.json({ message: 'Project updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/projects/:id', authenticateToken, async (req, res) => {
  try {
    await db.run('DELETE FROM projects WHERE id = ?', req.params.id);
    res.json({ message: 'Project deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const fs = require('fs');
const path = require('path');
const multer = require('multer');

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Multer Storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Serve static files
app.use('/uploads', express.static('uploads'));

// --- Testimonial Routes ---
app.get('/api/testimonials', async (req, res) => {
  try {
    const testimonials = await db.all('SELECT * FROM testimonials');
    res.json(testimonials);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/testimonials', upload.single('image'), async (req, res) => {
  const { name, role, company, rating, text, project, phone } = req.body;
  const image = req.file ? `http://localhost:3000/uploads/${req.file.filename}` : req.body.image; // Fallback if no file (or manual URL?) but user requirement says upload

  try {
    const result = await db.run(
      'INSERT INTO testimonials (name, role, company, image, rating, text, project, phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [name, role, company, image, rating, text, project, phone]
    );
    res.json({ id: result.lastID });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/testimonials/:id', authenticateToken, async (req, res) => {
  try {
    await db.run('DELETE FROM testimonials WHERE id = ?', req.params.id);
    res.json({ message: 'Testimonial deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
