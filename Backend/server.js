const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { pool } = require('./database');

const app = express();
const port = process.env.PORT || 3000;
const SECRET_KEY = process.env.JWT_SECRET || 'your_super_secret_key_change_this_in_production';

app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    const isLocalhost = origin.startsWith('http://localhost:');
    const isVercelDomain = origin.includes('portfolio24') && origin.endsWith('.vercel.app');

    if (isLocalhost || isVercelDomain) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

app.use('/uploads', express.static('uploads'));

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

function parseJsonField(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === 'object') return value;
  try {
    return JSON.parse(value);
  } catch {
    return value;
  }
}

// --- Auth Routes ---
app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    const user = result.rows[0];
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
    const result = await pool.query('SELECT * FROM posts');
    const parsedPosts = result.rows.map(post => ({
      ...post,
      tags: parseJsonField(post.tags),
      pages: parseJsonField(post.pages)
    }));
    res.json(parsedPosts);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/posts/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM posts WHERE id = $1', [req.params.id]);
    const post = result.rows[0];
    if (!post) return res.status(404).json({ error: 'Post not found' });
    post.tags = parseJsonField(post.tags);
    post.pages = parseJsonField(post.pages);
    res.json(post);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/posts', authenticateToken, async (req, res) => {
  const { title, excerpt, date, readTime, category, image, tags, pages } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO posts (title, excerpt, date, readTime, category, image, tags, pages) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id',
      [title, excerpt, date, readTime, category, image, tags, pages]
    );
    res.json({ id: result.rows[0].id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/posts/:id', authenticateToken, async (req, res) => {
  const { title, excerpt, date, readTime, category, image, tags, pages } = req.body;
  try {
    await pool.query(
      'UPDATE posts SET title = $1, excerpt = $2, date = $3, readTime = $4, category = $5, image = $6, tags = $7, pages = $8 WHERE id = $9',
      [title, excerpt, date, readTime, category, image, tags, pages, req.params.id]
    );
    res.json({ message: 'Post updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/posts/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM posts WHERE id = $1', [req.params.id]);
    res.json({ message: 'Post deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Project Routes ---
app.get('/api/projects', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM projects');
    const parsedProjects = result.rows.map(p => ({
      ...p,
      stack: parseJsonField(p.stack)
    }));
    res.json(parsedProjects);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/projects', authenticateToken, async (req, res) => {
  const { title, description, image, stack, github, demo } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO projects (title, description, image, stack, github, demo) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
      [title, description, image, stack, github, demo]
    );
    res.json({ id: result.rows[0].id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/projects/:id', authenticateToken, async (req, res) => {
  const { title, description, image, stack, github, demo } = req.body;
  try {
    await pool.query(
      'UPDATE projects SET title = $1, description = $2, image = $3, stack = $4, github = $5, demo = $6 WHERE id = $7',
      [title, description, image, stack, github, demo, req.params.id]
    );
    res.json({ message: 'Project updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/projects/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM projects WHERE id = $1', [req.params.id]);
    res.json({ message: 'Project deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- GitHub Repos Proxy ---
app.get('/api/github/repos', async (req, res) => {
  try {
    const response = await fetch('https://api.github.com/users/mebune24/repos?sort=updated&per_page=50');
    if (!response.ok) throw new Error('Failed to fetch GitHub repos');
    const repos = await response.json();
    const formatted = repos.map(repo => {
      const techStack = [];
      if (repo.language) {
        techStack.push({ name: repo.language, logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${repo.language.toLowerCase()}/${repo.language.toLowerCase()}-original.svg` });
      }
      const topics = (repo.topics || []).slice(0, 4).map(topic => ({
        name: topic,
        logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${topic.toLowerCase()}/${topic.toLowerCase()}-original.svg`
      }));
      return {
        id: `github-${repo.id}`,
        title: repo.name.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
        description: repo.description || 'No description provided.',
        image: `https://opengraph.githubassets.com/1/${repo.full_name}`,
        stack: [...techStack, ...topics],
        github: repo.html_url,
        demo: repo.homepage || null,
        isGithub: true,
        fullName: repo.full_name,
        languagesUrl: repo.languages_url
      };
    });
    res.json(formatted);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- GitHub Repo Languages Proxy ---
app.get('/api/github/repos/languages', async (req, res) => {
  try {
    const { owner, repo } = req.query;
    if (!owner || !repo) {
      return res.status(400).json({ error: 'Missing owner or repo parameter' });
    }

    const response = await fetch(`https://api.github.com/repos/${owner}/${repo}/languages`);
    if (!response.ok) throw new Error('Failed to fetch repo languages');
    const languages = await response.json();

    const formatted = Object.entries(languages).map(([name, bytes]) => ({
      name,
      logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${name.toLowerCase()}/${name.toLowerCase()}-original.svg`
    }));

    res.json(formatted);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- GitHub Profile Proxy ---
app.get('/api/github/profile', async (req, res) => {
  try {
    const response = await fetch('https://api.github.com/users/mebune24');
    if (!response.ok) throw new Error('Failed to fetch GitHub profile');
    const profile = await response.json();
    res.json({
      login: profile.login,
      name: profile.name,
      bio: profile.bio,
      avatar_url: profile.avatar_url,
      html_url: profile.html_url,
      public_repos: profile.public_repos,
      followers: profile.followers
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- GitHub Resolve Proxy ---
app.get('/api/github/resolve', async (req, res) => {
  try {
    const { url } = req.query;
    if (!url || typeof url !== 'string') {
      return res.status(400).json({ error: 'Missing url parameter' });
    }

    const normalizedUrl = url.trim();
    const isReposUrl = normalizedUrl.includes('tab=repositories') || normalizedUrl.includes('/repos');
    const usernameMatch = normalizedUrl.match(/github\.com\/([^\/\?]+)/);

    if (!usernameMatch) {
      return res.status(400).json({ error: 'Invalid GitHub URL' });
    }

    const username = usernameMatch[1];

    if (isReposUrl) {
      const response = await fetch(`https://api.github.com/users/${username}/repos?sort=updated&per_page=50`);
      if (!response.ok) throw new Error('Failed to fetch GitHub repos');
      const repos = await response.json();
      const formatted = repos.map(repo => {
        const techStack = [];
        if (repo.language) {
          techStack.push({ name: repo.language, logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${repo.language.toLowerCase()}/${repo.language.toLowerCase()}-original.svg` });
        }
        const topics = (repo.topics || []).slice(0, 4).map(topic => ({
          name: topic,
          logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${topic.toLowerCase()}/${topic.toLowerCase()}-original.svg`
        }));
        return {
          id: `github-${repo.id}`,
          title: repo.name.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
          description: repo.description || 'No description provided.',
          image: `https://opengraph.githubassets.com/1/${repo.full_name}`,
          stack: [...techStack, ...topics],
          github: repo.html_url,
          demo: repo.homepage || null,
          isGithub: true
        };
      });
      return res.json({ type: 'repos', data: formatted });
    } else {
      const response = await fetch(`https://api.github.com/users/${username}`);
      if (!response.ok) throw new Error('Failed to fetch GitHub profile');
      const profile = await response.json();
      const profileData = {
        login: profile.login,
        name: profile.name,
        bio: profile.bio,
        avatar_url: profile.avatar_url,
        html_url: profile.html_url,
        public_repos: profile.public_repos,
        followers: profile.followers,
        following: profile.following,
        location: profile.location,
        blog: profile.blog,
        company: profile.company,
        created_at: profile.created_at
      };
      return res.json({ type: 'profile', data: profileData });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Certification Routes ---
app.get('/api/certifications', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM certifications');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/certifications', authenticateToken, upload.single('certificateFile'), async (req, res) => {
  const { name, issuer, date, description, image, certificateLink } = req.body;
  const link = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : certificateLink;
  try {
    const result = await pool.query(
      'INSERT INTO certifications (name, issuer, date, description, image, certificateLink) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
      [name, issuer, date, description, image, link]
    );
    res.json({ id: result.rows[0].id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/certifications/:id', authenticateToken, upload.single('certificateFile'), async (req, res) => {
  const { name, issuer, date, description, image, certificateLink } = req.body;
  const link = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : certificateLink;
  try {
    await pool.query(
      'UPDATE certifications SET name = $1, issuer = $2, date = $3, description = $4, image = $5, certificateLink = $6 WHERE id = $7',
      [name, issuer, date, description, image, link, req.params.id]
    );
    res.json({ message: 'Certification updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/certifications/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM certifications WHERE id = $1', [req.params.id]);
    res.json({ message: 'Certification deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Testimonial Routes ---
app.get('/api/testimonials', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM testimonials');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/testimonials', upload.single('image'), async (req, res) => {
  const { name, role, company, rating, text, project, phone } = req.body;
  const image = req.file ? `http://localhost:3000/uploads/${req.file.filename}` : req.body.image;

  try {
    const result = await pool.query(
      'INSERT INTO testimonials (name, role, company, image, rating, text, project, phone) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id',
      [name, role, company, image, rating, text, project, phone]
    );
    res.json({ id: result.rows[0].id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/testimonials/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM testimonials WHERE id = $1', [req.params.id]);
    res.json({ message: 'Testimonial deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- Profile Routes ---
app.get('/api/profile', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM profile LIMIT 1');
    const profile = result.rows[0];
    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/profile', authenticateToken, upload.single('avatar'), async (req, res) => {
  const { name, title, subtitle, bio, welcome_message } = req.body;
  const avatar = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : req.body.avatar;

  try {
    const existingProfile = await pool.query('SELECT id FROM profile LIMIT 1');
    const existing = existingProfile.rows[0];

    if (existing) {
      await pool.query(
        'UPDATE profile SET name = $1, title = $2, subtitle = $3, bio = $4, avatar = $5, welcome_message = $6, updated_at = CURRENT_TIMESTAMP WHERE id = $7',
        [name, title, subtitle, bio, avatar, welcome_message, existing.id]
      );
    } else {
      await pool.query(
        'INSERT INTO profile (name, title, subtitle, bio, avatar, welcome_message) VALUES ($1, $2, $3, $4, $5, $6)',
        [name, title, subtitle, bio, avatar, welcome_message]
      );
    }

    res.json({ message: 'Profile updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
