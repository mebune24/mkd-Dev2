import axios from 'axios';
import { useEffect, useState } from 'react';

/**
 * Custom hook for managing testimonials
 * @returns {Object} - { testimonials, loading, fetchTestimonials, submitTestimonial }
 */
export const useTestimonials = () => {
  const [testimonials, setTestimonials] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchTestimonials = async () => {
    setLoading(true);
    try {
      const res = await axios.get('http://localhost:3000/api/testimonials');
      setTestimonials(res.data);
    } catch (err) {
      console.error('Failed to fetch testimonials', err);
    } finally {
      setLoading(false);
    }
  };

  const submitTestimonial = async (formData) => {
    const data = new FormData();
    data.append('name', formData.name);
    data.append('role', formData.role);
    data.append('company', formData.company);
    data.append('text', formData.text);
    data.append('project', formData.project);
    data.append('phone', formData.phone);
    data.append('rating', formData.rating);

    if (formData.imageFile) {
      data.append('image', formData.imageFile);
    } else {
      throw new Error('Please upload a photo.');
    }

    try {
      await axios.post('http://localhost:3000/api/testimonials', data, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      await fetchTestimonials();
      return { success: true };
    } catch (err) {
      console.error(err);
      throw new Error('Failed to submit testimonial');
    }
  };

  useEffect(() => {
    fetchTestimonials();
  }, []);

  return { testimonials, loading, fetchTestimonials, submitTestimonial };
};
