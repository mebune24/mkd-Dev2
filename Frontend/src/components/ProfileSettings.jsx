import axios from 'axios';
import { AlertCircle, CheckCircle, Save, User } from 'lucide-react';
import { useEffect, useState } from 'react';

export default function ProfileSettings() {
  const [profile, setProfile] = useState({
    name: '',
    title: '',
    subtitle: '',
    bio: '',
    avatar: '',
    welcome_message: ''
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState('');

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const response = await axios.get('http://localhost:3000/api/profile');
      setProfile(response.data);
      setPreviewUrl(response.data.avatar);
    } catch (error) {
      console.error('Error fetching profile:', error);
      setMessage('Failed to load profile data');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setProfile(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedFile(file);
      const url = URL.createObjectURL(file);
      setPreviewUrl(url);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setMessage('');

    try {
      const formData = new FormData();
      formData.append('name', profile.name);
      formData.append('title', profile.title);
      formData.append('subtitle', profile.subtitle);
      formData.append('bio', profile.bio);
      formData.append('welcome_message', profile.welcome_message);

      if (selectedFile) {
        formData.append('avatar', selectedFile);
      } else {
        formData.append('avatar', profile.avatar);
      }

      const token = localStorage.getItem('token');
      const response = await axios.put('http://localhost:3000/api/profile', formData, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'multipart/form-data'
        }
      });

      setMessage('Profile updated successfully!');
      setSelectedFile(null);

      // Refresh profile data
      await fetchProfile();
    } catch (error) {
      console.error('Error updating profile:', error);
      setMessage('Failed to update profile. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-16">
        <div className="inline-block w-8 h-8 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin mb-4" />
        <p className="text-slate-400">Loading profile...</p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-white mb-2">Profile Settings</h2>
        <p className="text-slate-400">Update your profile information that appears throughout the website</p>
      </div>

      {message && (
        <div className={`mb-6 p-4 rounded-lg flex items-center gap-3 ${
          message.includes('successfully')
            ? 'bg-green-500/10 border border-green-500/20 text-green-400'
            : 'bg-red-500/10 border border-red-500/20 text-red-400'
        }`}>
          {message.includes('successfully') ? (
            <CheckCircle size={20} />
          ) : (
            <AlertCircle size={20} />
          )}
          {message}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Avatar Section */}
        <div className="section-surface rounded-2xl p-6">
          <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
            <User size={20} />
            Profile Picture
          </h3>

          <div className="flex items-center gap-6">
            <div className="relative">
              <img
                src={previewUrl || '/placeholder-avatar.png'}
                alt="Profile"
                className="w-24 h-24 rounded-full object-cover border-2 border-white/20"
                onError={(e) => {
                  e.target.src = 'https://via.placeholder.com/96x96?text=MD';
                }}
              />
            </div>

            <div className="flex-1">
              <label className="block">
                <span className="sr-only">Choose profile photo</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="block w-full text-sm text-slate-400
                    file:mr-4 file:py-2 file:px-4
                    file:rounded-lg file:border-0
                    file:text-sm file:font-medium
                    file:bg-emerald-500 file:text-white
                    hover:file:bg-emerald-600
                    file:cursor-pointer file:transition-colors"
                />
              </label>
              <p className="text-xs text-slate-500 mt-2">
                JPG, PNG or GIF. Max size 5MB.
              </p>
            </div>
          </div>
        </div>

        {/* Basic Information */}
        <div className="section-surface rounded-2xl p-6">
          <h3 className="text-lg font-semibold text-white mb-4">Basic Information</h3>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Full Name *
              </label>
              <input
                type="text"
                name="name"
                value={profile.name}
                onChange={handleInputChange}
                required
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none transition-colors"
                placeholder="Enter your full name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Title *
              </label>
              <input
                type="text"
                name="title"
                value={profile.title}
                onChange={handleInputChange}
                required
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none transition-colors"
                placeholder="e.g., Software Engineer"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Subtitle
              </label>
              <input
                type="text"
                name="subtitle"
                value={profile.subtitle}
                onChange={handleInputChange}
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none transition-colors"
                placeholder="e.g., Frontend & Full-Stack Developer"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Welcome Message
              </label>
              <input
                type="text"
                name="welcome_message"
                value={profile.welcome_message}
                onChange={handleInputChange}
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none transition-colors"
                placeholder="e.g., Welcome mebune"
              />
            </div>
          </div>
        </div>

        {/* Bio Section */}
        <div className="section-surface rounded-2xl p-6">
          <h3 className="text-lg font-semibold text-white mb-4">Bio</h3>

          <div>
            <label className="block text-sm font-medium text-slate-300 mb-2">
              About You
            </label>
            <textarea
              name="bio"
              value={profile.bio}
              onChange={handleInputChange}
              rows={4}
              className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none transition-colors resize-none"
              placeholder="Tell visitors about yourself..."
            />
          </div>
        </div>

        {/* Submit Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={saving}
            className="flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 disabled:bg-emerald-500/50 text-white px-6 py-3 rounded-lg font-medium transition-all shadow-lg shadow-emerald-500/20 disabled:cursor-not-allowed"
          >
            {saving ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Save size={18} />
                Save Changes
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
