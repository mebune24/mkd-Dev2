import axios from 'axios';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

/**
 * Custom hook for authentication
 * @returns {Object} - { login, logout, loading, error }
 */
export const useAuth = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const login = async (username, password) => {
    setError('');
    setLoading(true);

    try {
      const response = await axios.post('http://localhost:3000/api/auth/login', {
        username,
        password,
      });
      localStorage.setItem('token', response.data.token);
      navigate('/admin/dashboard');
      return { success: true };
    } catch (err) {
      const errorMessage = err.response?.data?.error || 'Invalid credentials. Please try again.';
      setError(errorMessage);
      return { success: false, error: errorMessage };
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    navigate('/admin/login');
  };

  const getToken = () => {
    return localStorage.getItem('token');
  };

  return { login, logout, getToken, loading, error, setError };
};
