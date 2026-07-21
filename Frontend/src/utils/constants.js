// API Base URL (Smart runtime checking logic to bypass dashboard variable bugs)
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL
  ? `${import.meta.env.VITE_API_BASE_URL}/api`
  : typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1')
    ? 'http://localhost:3000/api'                     // Local environment fallback
    : 'https://mkd-dev2-backend.onrender.com/api';    // Render production fallback

// API Endpoints
export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: `${API_BASE_URL}/auth/login`,
  },
  PROJECTS: `${API_BASE_URL}/projects`,
  POSTS: `${API_BASE_URL}/posts`,
  TESTIMONIALS: `${API_BASE_URL}/testimonials`,
  CERTIFICATIONS: `${API_BASE_URL}/certifications`,
  GITHUB_REPOS: `${API_BASE_URL}/github/repos`,
  GITHUB_PROFILE: `${API_BASE_URL}/github/profile`,
  GITHUB_RESOLVE: `${API_BASE_URL}/github/resolve`,
  GITHUB_REPO_LANGUAGES: `${API_BASE_URL}/github/repos/languages`,
};

// Navigation Items
export const NAV_ITEMS = [
  { id: 'home', label: 'Home', to: '/' },
  { id: 'about', label: 'About', to: '/about' },
  { id: 'journey', label: 'Journey', to: '/journey' },
  { id: 'project', label: 'Project', to: '/project' },
  { id: 'blog', label: 'Blog', to: '/blog' },
  { id: 'certifications', label: 'Certifications', to: '/certifications' },
  { id: 'admin', label: 'Admin', to: '/admin/login' },
];

// WhatsApp URL (Update with actual number)
export const WHATSAPP_URL = 'https://wa.me';

// Dashboard Tabs
export const DASHBOARD_TABS = [
  { id: 'projects', label: 'Projects', resource: 'projects' },
  { id: 'posts', label: 'Blog Posts', resource: 'posts' },
  { id: 'testimonials', label: 'Testimonials', resource: 'testimonials' },
];

// Theme Constants
export const THEMES = {
  DARK: 'dark',
  LIGHT: 'light',
};

// Storage Keys
export const STORAGE_KEYS = {
  THEME: 'theme',
  TOKEN: 'token',
};
