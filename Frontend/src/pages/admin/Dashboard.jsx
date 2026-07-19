import {
    AlertCircle,
    BarChart3,
    Building2,
    CheckCircle,
    Edit,
    FileText,
    Layout,
    LogOut,
    MessageSquare,
    Plus,
    Trash2,
    User,
    X
} from 'lucide-react';
import { useState } from 'react';
import ConfirmModal from '../../components/ConfirmModal';
import ProfileSettings from '../../components/ProfileSettings';
import { useAuth } from '../../Hooks/useAuth';
import { useDashboard } from '../../Hooks/useDashboard';
import { useProfile } from '../../Hooks/useProfile';
import { formatFormData, getInitialFormData } from '../../utils/helpers';

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState('projects');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  const [confirmConfig, setConfirmConfig] = useState({ isOpen: false, action: null, title: '', message: '', isDestructive: false });
  const [formData, setFormData] = useState({});

  const { items, stats, loading, createItem, updateItem, deleteItem } = useDashboard(activeTab);
  const { logout } = useAuth();
  const { profile } = useProfile();

  const handleDeleteClick = (id) => {
    setConfirmConfig({
      isOpen: true,
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item? This action cannot be undone.',
      isDestructive: true,
      action: async () => {
        const result = await deleteItem(id);
        if (!result.success) alert(result.error);
      }
    });
  };

  const openModal = (item = null) => {
    setEditingItem(item);
    setFormData(getInitialFormData(activeTab, item));
    setIsModalOpen(true);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const isEditing = !!editingItem;
    setConfirmConfig({
      isOpen: true,
      title: isEditing ? 'Update Item' : 'Create Item',
      message: `Are you sure you want to ${isEditing ? 'update' : 'create'} this item?`,
      isDestructive: false,
      action: async () => {
        const submitData = formatFormData(formData, activeTab);
        const result = isEditing
          ? await updateItem(editingItem.id, submitData)
          : await createItem(submitData);

        if (result.success) {
          setIsModalOpen(false);
        } else {
          alert(result.error);
        }
      }
    });
  };

  const statsData = [
    { label: 'Projects', value: stats.projects, icon: Layout, color: 'emerald' },
    { label: 'Blog Posts', value: stats.posts, icon: FileText, color: 'blue' },
    { label: 'Testimonials', value: stats.testimonials, icon: MessageSquare, color: 'purple' },
    { label: 'Certifications', value: stats.certifications, icon: CheckCircle, color: 'teal' }
  ];

  const tabs = [
    { id: 'profile', label: 'Profile', icon: User },
    { id: 'projects', label: 'Projects', icon: Layout },
    { id: 'posts', label: 'Blog Posts', icon: FileText },
    { id: 'testimonials', label: 'Testimonials', icon: MessageSquare },
    { id: 'certifications', label: 'Certifications', icon: CheckCircle }
  ];

  return (
    <div className="min-h-screen bg-black">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-black/80 backdrop-blur-xl border-b border-white/10">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-600 flex items-center justify-center shadow-lg shadow-emerald-500/20">
                <Building2 className="text-white" size={20} />
              </div>
              <div>
                <h1 className="text-xl font-bold text-white tracking-tight">
                  {profile?.welcome_message || 'Welcome mebune'}
                </h1>
                <p className="text-xs text-slate-400">add your content here</p>
              </div>
            </div>
            <button
              onClick={logout}
              className="flex items-center gap-2 px-4 py-2 rounded-lg bg-red-500/10 text-red-400 hover:bg-red-500/20 border border-red-500/20 transition-all"
            >
              <LogOut size={18} />
              <span className="hidden sm:inline">Logout</span>
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          {statsData.map((stat) => {
            const Icon = stat.icon;
            return (
              <div
                key={stat.label}
                className="section-surface rounded-2xl p-6 hover:border-white/20 transition-all group"
              >
                <div className="flex items-center justify-between mb-4">
                  <div className={`w-12 h-12 rounded-xl bg-${stat.color}-500/10 flex items-center justify-center group-hover:scale-110 transition-transform`}>
                    <Icon className={`text-${stat.color}-400`} size={24} />
                  </div>
                  <BarChart3 className="text-slate-600" size={20} />
                </div>
                <div>
                  <p className="text-3xl font-bold text-white mb-1">{stat.value}</p>
                  <p className="text-sm text-slate-400 uppercase tracking-wide">{stat.label}</p>
                </div>
              </div>
            );
          })}
        </div>

        {/* Tabs */}
        <div className="flex gap-3 mb-6 overflow-x-auto pb-2">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-5 py-3 rounded-xl font-medium transition-all whitespace-nowrap ${
                  activeTab === tab.id
                    ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/20'
                    : 'bg-white/5 text-slate-400 hover:bg-white/10 border border-white/10'
                }`}
              >
                <Icon size={18} />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Content Area */}
        {activeTab === 'profile' ? (
          <ProfileSettings />
        ) : (
          <div className="section-surface rounded-2xl overflow-hidden">
            {/* Table Header */}
            <div className="flex items-center justify-between p-6 border-b border-white/10">
              <div>
                <h2 className="text-lg font-semibold text-white capitalize">{activeTab} Management</h2>
                <p className="text-sm text-slate-400 mt-1">Manage your {activeTab} content</p>
              </div>
              <button
                onClick={() => openModal()}
                className="flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2.5 rounded-lg font-medium transition-all shadow-lg shadow-emerald-500/20"
              >
                <Plus size={18} />
                Add New
              </button>
            </div>

            {/* Table Content */}
            <div className="p-6">
              {loading ? (
                <div className="text-center py-16">
                  <div className="inline-block w-8 h-8 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin mb-4" />
                  <p className="text-slate-400">Loading {activeTab}...</p>
                </div>
              ) : items.length === 0 ? (
                <div className="text-center py-16">
                  <AlertCircle className="mx-auto text-slate-600 mb-4" size={48} />
                  <p className="text-slate-400">No {activeTab} found</p>
                  <button
                    onClick={() => openModal()}
                    className="mt-4 text-emerald-400 hover:text-emerald-300"
                  >
                    Create your first one
                  </button>
                </div>
              ) : (
                <div className="space-y-3">
                  {items.map((item) => (
                    <div
                      key={item.id}
                      className="flex items-center gap-4 bg-white/5 border border-white/10 rounded-xl p-4 hover:border-white/20 transition-all group"
                    >
                      <img
                        src={item.image}
                        alt={item.title || item.name}
                        className="w-16 h-16 object-cover rounded-lg border border-white/10"
                      />
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-white truncate">
                          {item.title || item.name}
                        </h3>
                        {activeTab === 'projects' && (
                          <p className="text-sm text-slate-400 truncate">{item.description}</p>
                        )}
                        {activeTab === 'posts' && (
                          <p className="text-sm text-slate-400 truncate">{item.excerpt}</p>
                        )}
                        {activeTab === 'testimonials' && (
                          <div className="text-xs text-slate-400">
                            <p className="truncate">"{item.text}"</p>
                            <p className="text-emerald-400 mt-1">📞 {item.phone}</p>
                          </div>
                        )}
                        {activeTab === 'certifications' && (
                          <div className="text-xs text-slate-400">
                            <p className="truncate">{item.issuer}</p>
                            <p className="text-emerald-400 mt-1">{item.date}</p>
                          </div>
                        )}
                      </div>
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => openModal(item)}
                          className="p-2.5 rounded-lg bg-blue-500/10 text-blue-400 hover:bg-blue-500/20 border border-blue-500/20 transition-all"
                          title="Edit"
                        >
                          <Edit size={16} />
                        </button>
                        <button
                          onClick={() => handleDeleteClick(item.id)}
                          className="p-2.5 rounded-lg bg-red-500/10 text-red-400 hover:bg-red-500/20 border border-red-500/20 transition-all"
                          title="Delete"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-gray-900 border border-white/10 rounded-2xl w-full max-w-2xl max-h-[85vh] overflow-hidden shadow-2xl">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-white/10">
              <div>
                <h3 className="text-xl font-bold text-white">
                  {editingItem ? 'Edit' : 'Add New'} {activeTab.slice(0, -1)}
                </h3>
                <p className="text-sm text-slate-400 mt-1">
                  Fill in the details below
                </p>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-2 rounded-lg bg-white/5 hover:bg-white/10 text-slate-400 hover:text-white transition-all"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Content */}
            <form onSubmit={handleSubmit} className="p-6 overflow-y-auto max-h-[calc(85vh-140px)]">
              <div className="space-y-5">
                {/* Title/Name Field */}
                <div>
                  <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">
                    {activeTab === 'testimonials'
                      ? 'Name'
                      : activeTab === 'certifications'
                      ? 'Certificate Title'
                      : 'Title'}
                  </label>
                  <input
                    className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                    placeholder={`Enter ${activeTab === 'testimonials' ? 'name' : activeTab === 'certifications' ? 'certificate title' : 'title'}`}
                    value={formData.title || formData.name || ''}
                    onChange={e => activeTab === 'testimonials'
                      ? setFormData({...formData, name: e.target.value})
                      : setFormData({...formData, title: e.target.value})}
                    required
                  />
                </div>

                {/* Project-specific fields */}
                {activeTab === 'projects' && (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Description</label>
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all min-h-[100px]"
                        placeholder="Project description"
                        value={formData.description || ''}
                        onChange={e => setFormData({...formData, description: e.target.value})}
                        required
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Tech Stack (JSON Array)</label>
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all font-mono text-sm min-h-[80px]"
                        placeholder='["React", "Node.js", "Tailwind"]'
                        value={typeof formData.stack === 'object' ? JSON.stringify(formData.stack, null, 2) : formData.stack}
                        onChange={e => setFormData({...formData, stack: e.target.value})}
                      />
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Github URL</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="https://github.com/..."
                          value={formData.github || ''}
                          onChange={e => setFormData({...formData, github: e.target.value})}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Demo URL</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="https://demo.com/..."
                          value={formData.demo || ''}
                          onChange={e => setFormData({...formData, demo: e.target.value})}
                        />
                      </div>
                    </div>
                  </>
                )}

                {/* Post-specific fields */}
                {activeTab === 'posts' && (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Excerpt</label>
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all min-h-[80px]"
                        placeholder="Brief description"
                        value={formData.excerpt || ''}
                        onChange={e => setFormData({...formData, excerpt: e.target.value})}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Content Pages (JSON Array)</label>
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all font-mono text-sm min-h-[100px]"
                        placeholder='["Page 1 content...", "Page 2 content..."]'
                        value={typeof formData.pages === 'object' ? JSON.stringify(formData.pages, null, 2) : formData.pages}
                        onChange={e => setFormData({...formData, pages: e.target.value})}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Category</label>
                      <input
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                        placeholder="Technology, Design, etc."
                        value={formData.category || ''}
                        onChange={e => setFormData({...formData, category: e.target.value})}
                      />
                    </div>
                  </>
                )}

                {/* Testimonial-specific fields */}
                {activeTab === 'testimonials' && (
                  <>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Role</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="CEO, CTO, etc."
                          value={formData.role || ''}
                          onChange={e => setFormData({...formData, role: e.target.value})}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Company</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="Company name"
                          value={formData.company || ''}
                          onChange={e => setFormData({...formData, company: e.target.value})}
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Feedback</label>
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all min-h-[100px]"
                        placeholder="Client's testimonial"
                        value={formData.text || ''}
                        onChange={e => setFormData({...formData, text: e.target.value})}
                      />
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Phone (Private)</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="+1234567890"
                          value={formData.phone || ''}
                          onChange={e => setFormData({...formData, phone: e.target.value})}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Project Name</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="Project they worked on"
                          value={formData.project || ''}
                          onChange={e => setFormData({...formData, project: e.target.value})}
                        />
                      </div>
                    </div>
                  </>
                )}

                {/* Certification-specific fields */}
                {activeTab === 'certifications' && (
                  <>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Issuer</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="Organization or company"
                          value={formData.issuer || ''}
                          onChange={e => setFormData({...formData, issuer: e.target.value})}
                          required
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Date</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="e.g. May 2026"
                          value={formData.date || ''}
                          onChange={e => setFormData({...formData, date: e.target.value})}
                          required
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Description</label>
                      <textarea
                        className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all min-h-[100px]"
                        placeholder="Brief certification summary"
                        value={formData.description || ''}
                        onChange={e => setFormData({...formData, description: e.target.value})}
                      />
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Certificate Link</label>
                        <input
                          className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                          placeholder="Optional PDF or hosted certificate URL"
                          value={formData.certificateLink || ''}
                          onChange={e => setFormData({...formData, certificateLink: e.target.value})}
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Upload Certificate</label>
                        <input
                          type="file"
                          accept="image/*,.pdf"
                          className="w-full text-sm text-slate-300 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-emerald-500 file:text-slate-950"
                          onChange={e => setFormData({...formData, certificateFile: e.target.files?.[0] || null})}
                        />
                      </div>
                    </div>
                  </>
                )}

                {/* Image URL - Common for all */}
                <div>
                  <label className="block text-sm font-medium text-slate-300 mb-2 uppercase tracking-wide">Image URL</label>
                  <input
                    className="w-full bg-white/5 border border-white/10 rounded-lg py-3 px-4 text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500/50 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                    placeholder="https://example.com/image.jpg"
                    value={formData.image || ''}
                    onChange={e => setFormData({...formData, image: e.target.value})}
                    required
                  />
                </div>
              </div>
            </form>

            {/* Modal Footer */}
            <div className="flex items-center justify-end gap-3 p-6 border-t border-white/10 bg-gray-900/50">
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="px-6 py-2.5 rounded-lg bg-white/5 text-slate-300 hover:bg-white/10 border border-white/10 transition-all"
              >
                Cancel
              </button>
              <button
                onClick={handleSubmit}
                className="px-6 py-2.5 rounded-lg bg-emerald-500 text-white hover:bg-emerald-600 font-medium transition-all shadow-lg shadow-emerald-500/20 flex items-center gap-2"
              >
                <CheckCircle size={18} />
                {editingItem ? 'Update' : 'Create'}
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmModal
        isOpen={confirmConfig.isOpen}
        onClose={() => setConfirmConfig({ ...confirmConfig, isOpen: false })}
        onConfirm={() => {
          if (confirmConfig.action) Object.assign(confirmConfig).action();
        }}
        title={confirmConfig.title}
        message={confirmConfig.message}
        isDestructive={confirmConfig.isDestructive}
      />
    </div>
  );
}
