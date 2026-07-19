/**
 * Parse JSON string safely
 * @param {string} str - String to parse
 * @param {*} fallback - Fallback value if parsing fails
 * @returns {*} Parsed value or fallback
 */
export const safeJSONParse = (str, fallback = []) => {
  if (typeof str !== 'string') return str;
  try {
    return JSON.parse(str);
  } catch (e) {
    return fallback;
  }
};

/**
 * Format form data for submission
 * @param {Object} formData - Raw form data
 * @param {string} activeTab - Active tab (projects/posts/testimonials)
 * @returns {Object} Formatted data
 */
export const formatFormData = (formData, activeTab) => {
  if (activeTab === 'certifications') {
    if (formData.certificateFile) {
      const formPayload = new FormData();
      formPayload.append('name', formData.name || '');
      formPayload.append('issuer', formData.issuer || '');
      formPayload.append('date', formData.date || '');
      formPayload.append('description', formData.description || '');
      formPayload.append('image', formData.image || '');
      formPayload.append('certificateLink', formData.certificateLink || '');
      formPayload.append('certificateFile', formData.certificateFile);
      return formPayload;
    }
    return {
      name: formData.name || '',
      issuer: formData.issuer || '',
      date: formData.date || '',
      description: formData.description || '',
      image: formData.image || '',
      certificateLink: formData.certificateLink || '',
    };
  }

  const submitData = { ...formData };

  if (activeTab === 'projects') {
    if (typeof submitData.stack === 'string') {
      submitData.stack = safeJSONParse(submitData.stack, []);
    }
  } else if (activeTab === 'posts') {
    if (typeof submitData.pages === 'string') {
      submitData.pages = safeJSONParse(submitData.pages, []);
    }
    if (typeof submitData.tags === 'string') {
      submitData.tags = safeJSONParse(submitData.tags, []);
    }
  }

  return submitData;
};

/**
 * Get initial form data for different tabs
 * @param {string} tab - Tab name
 * @param {Object} item - Existing item (for edit)
 * @returns {Object} Initial form data
 */
export const getInitialFormData = (tab, item = null) => {
  if (item) return item;

  const formDataMap = {
    projects: {
      title: '',
      description: '',
      image: '',
      github: '',
      demo: '',
      stack: [],
    },
    posts: {
      title: '',
      excerpt: '',
      category: '',
      image: '',
      pages: [],
      tags: [],
    },
    testimonials: {
      name: '',
      role: '',
      company: '',
      image: '',
      text: '',
      project: '',
      phone: '',
      rating: 5,
    },
    certifications: {
      name: '',
      issuer: '',
      date: '',
      description: '',
      image: '',
      certificateLink: '',
      certificateFile: null,
    },
  };

  return formDataMap[tab] || {};
};
