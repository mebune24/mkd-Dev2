import { useEffect, useState } from 'react';

/**
 * Custom hook for managing theme (dark/light mode)
 * @returns {Object} - { theme, toggleTheme }
 */
export const useTheme = () => {
  const [theme, setTheme] = useState('dark');

  useEffect(() => {
    const savedTheme = localStorage.getItem('theme');
    const preferredTheme = savedTheme || 'dark';
    setTheme(preferredTheme);
    document.documentElement.setAttribute('data-theme', preferredTheme);
  }, []);

  const toggleTheme = () => {
    const nextTheme = theme === 'dark' ? 'light' : 'dark';
    setTheme(nextTheme);
    localStorage.setItem('theme', nextTheme);
    document.documentElement.setAttribute('data-theme', nextTheme);
  };

  return { theme, toggleTheme };
};
