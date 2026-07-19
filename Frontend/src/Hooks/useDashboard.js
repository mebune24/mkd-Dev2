import axios from 'axios';
import { useEffect, useState } from 'react';
import { API_ENDPOINTS } from '../utils/constants';

/**
 * Custom hook for admin dashboard data management
 * @param {string} activeTab - Current active tab (projects/posts/testimonials/certifications)
 * @returns {Object} - Dashboard data and CRUD operations
 */
export const useDashboard = (activeTab) => {
  const [items, setItems] = useState([]);
  const [stats, setStats] = useState({ projects: 0, posts: 0, testimonials: 0, certifications: 0 });
  const [loading, setLoading] = useState(true);

  const getEndpoint = (tab, id = '') => {
    const endpoint =
      tab === 'projects'
        ? API_ENDPOINTS.PROJECTS
        : tab === 'posts'
        ? API_ENDPOINTS.POSTS
        : tab === 'testimonials'
        ? API_ENDPOINTS.TESTIMONIALS
        : API_ENDPOINTS.CERTIFICATIONS;
    return id ? `${endpoint}/${id}` : endpoint;
  };

  const getAuthHeaders = () => ({
    Authorization: `Bearer ${localStorage.getItem('token')}`,
  });

  const fetchStats = async () => {
    try {
      const [projectsRes, postsRes, testimonialsRes, certificationsRes] = await Promise.all([
        axios.get(API_ENDPOINTS.PROJECTS),
        axios.get(API_ENDPOINTS.POSTS),
        axios.get(API_ENDPOINTS.TESTIMONIALS),
        axios.get(API_ENDPOINTS.CERTIFICATIONS),
      ]);
      setStats({
        projects: projectsRes.data.length,
        posts: postsRes.data.length,
        testimonials: testimonialsRes.data.length,
        certifications: certificationsRes.data.length,
      });
    } catch (err) {
      console.error('Failed to fetch stats', err);
    }
  };

  const fetchItems = async () => {
    setLoading(true);
    try {
      const endpoint = getEndpoint(activeTab);
      const res = await axios.get(endpoint);
      setItems(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const createItem = async (data) => {
    const endpoint = getEndpoint(activeTab);
    const headers = getAuthHeaders();

    try {
      await axios.post(endpoint, data, { headers });
      await fetchItems();
      await fetchStats();
      return { success: true };
    } catch (err) {
      console.error(err);
      return { success: false, error: 'Failed to create item' };
    }
  };

  const updateItem = async (id, data) => {
    const endpoint = getEndpoint(activeTab, id);
    const headers = getAuthHeaders();

    try {
      await axios.put(endpoint, data, { headers });
      await fetchItems();
      await fetchStats();
      return { success: true };
    } catch (err) {
      console.error(err);
      return { success: false, error: 'Failed to update item' };
    }
  };

  const deleteItem = async (id) => {
    const endpoint = getEndpoint(activeTab, id);
    const headers = getAuthHeaders();

    try {
      await axios.delete(endpoint, { headers });
      await fetchItems();
      await fetchStats();
      return { success: true };
    } catch (err) {
      console.error(err);
      return { success: false, error: 'Failed to delete item' };
    }
  };

  useEffect(() => {
    fetchItems();
    fetchStats();
  }, [activeTab]);

  return {
    items,
    stats,
    loading,
    fetchItems,
    createItem,
    updateItem,
    deleteItem,
  };
};
