const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { initializeDb } = require('./database');

const app = express();
const port = 3000;
const SECRET_KEY = 'your_super_secret_key_change_this_in_production'; // In a real app, use .env

// Configure CORS to allow requests from frontend
app.use(cors({
  origin: ['https://portfolio24-mu.vercel.app', 'http://localhost:5173', 'http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
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
      followers: profile.followers,
      following: profile.following,
      location: profile.location,
      blog: profile.blog,
      company: profile.company,
      created_at: profile.created_at
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

    // Determine if it's a repos page or profile page
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

// --- Certification Routes ---
app.get('/api/certifications', async (req, res) => {
  try {
    const certifications = await db.all('SELECT * FROM certifications');
    res.json(certifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/certifications', authenticateToken, upload.single('certificateFile'), async (req, res) => {
  const { name, issuer, date, description, image, certificateLink } = req.body;
  const link = req.file ? `http://localhost:3000/uploads/${req.file.filename}` : certificateLink;
  try {
    const result = await db.run(
      'INSERT INTO certifications (name, issuer, date, description, image, certificateLink) VALUES (?, ?, ?, ?, ?, ?)',
      [name, issuer, date, description, image, link]
    );
    res.json({ id: result.lastID });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/certifications/:id', authenticateToken, upload.single('certificateFile'), async (req, res) => {
  const { name, issuer, date, description, image, certificateLink } = req.body;
  const link = req.file ? `http://localhost:3000/uploads/${req.file.filename}` : certificateLink;
  try {
    await db.run(
      'UPDATE certifications SET name = ?, issuer = ?, date = ?, description = ?, image = ?, certificateLink = ? WHERE id = ?',
      [name, issuer, date, description, image, link, req.params.id]
    );
    res.json({ message: 'Certification updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/certifications/:id', authenticateToken, async (req, res) => {
  try {
    await db.run('DELETE FROM certifications WHERE id = ?', req.params.id);
    res.json({ message: 'Certification deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

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

// --- Profile Routes ---
app.get('/api/profile', async (req, res) => {
  try {
    const profile = await db.get('SELECT * FROM profile LIMIT 1');
    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    res.json(profile);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/profile', authenticateToken, upload.single('avatar'), async (req, res) => {
  const { name, title, subtitle, bio, welcome_message } = req.body;
  const avatar = req.file ? `http://localhost:3000/uploads/${req.file.filename}` : req.body.avatar;

  try {
    // Check if profile exists
    const existingProfile = await db.get('SELECT id FROM profile LIMIT 1');

    if (existingProfile) {
      // Update existing profile
      await db.run(
        'UPDATE profile SET name = ?, title = ?, subtitle = ?, bio = ?, avatar = ?, welcome_message = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [name, title, subtitle, bio, avatar, welcome_message, existingProfile.id]
      );
    } else {
      // Create new profile
      await db.run(
        'INSERT INTO profile (name, title, subtitle, bio, avatar, welcome_message) VALUES (?, ?, ?, ?, ?, ?)',
        [name, title, subtitle, bio, avatar, welcome_message]
      );
    }

    res.json({ message: 'Profile updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
