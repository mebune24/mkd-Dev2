import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { ExternalLink, Github, ArrowLeft, UserPlus, Star } from "lucide-react";
import { Link, useSearchParams } from "react-router-dom";
import { API_ENDPOINTS } from "../../utils/constants";

const cardVariants = {
  hidden: { opacity: 0, y: 30, scale: 0.95 },
  visible: (i) => ({
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      duration: 0.5,
      delay: i * 0.05,
      ease: "easeOut"
    }
  }),
  hover: {
    scale: 1.03,
    y: -5,
    transition: { duration: 0.2 }
  }
};

export default function GitHub() {
  const [searchParams] = useSearchParams();
  const url = searchParams.get("url");
  const [type, setType] = useState(null);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [enrichedRepos, setEnrichedRepos] = useState([]);

  useEffect(() => {
    if (!url) {
      setLoading(false);
      setError("Missing GitHub URL");
      return;
    }

    setLoading(true);
    setError(null);
    setEnrichedRepos([]);

    fetch(`${API_ENDPOINTS.GITHUB_RESOLVE}?url=${encodeURIComponent(url)}`)
      .then(res => {
        if (!res.ok) throw new Error("Failed to resolve GitHub URL");
        return res.json();
      })
      .then(response => {
        setType(response.type);
        setData(response.data);

        if (response.type === 'repos' && Array.isArray(response.data)) {
          Promise.all(
            response.data.map(repo => {
              if (!repo.fullName) return Promise.resolve(repo);
              const parts = repo.fullName.split('/');
              const owner = parts[0];
              const name = parts[1];
              return fetch(`${API_ENDPOINTS.GITHUB_REPO_LANGUAGES}?owner=${owner}&repo=${encodeURIComponent(name)}`)
                .then(res => res.ok ? res.json() : [])
                .then(languages => {
                  const langEntries = Object.entries(languages)
                    .sort((a, b) => b[1] - a[1])
                    .slice(0, 5)
                    .map(([name]) => ({
                      name,
                      logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${name.toLowerCase()}/${name.toLowerCase()}-original.svg`
                    }));

                   return {
                     ...repo,
                     stack: [
                       ...repo.stack.filter(s => !langEntries.find(l => l.name === s.name)),
                       ...langEntries
                     ].slice(0, 6)
                   };
                 })
              })
            ).then(setEnrichedRepos);
        }

        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, [url]);

  const getTitle = () => {
    if (!url) return "GitHub";
    if (url.includes("tab=repositories") || url.includes("/repos")) {
      return "Repositories";
    }
    return "Profile";
  };

  const getSubtitle = () => {
    if (!url) return "@mebune24";
    const match = url.match(/github\.com\/([^\/\?]+)/);
    return match ? `@${match[1]}` : "@mebune24";
  };

  return (
    <motion.div
      className="min-h-screen py-20 px-6"
      style={{
        background: `
          radial-gradient(900px 500px at 10% -10%, rgba(34, 197, 94, 0.08), transparent 60%),
          radial-gradient(700px 400px at 90% -5%, rgba(56, 189, 248, 0.06), transparent 55%),
          var(--bg)
        `
      }}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.8 }}
    >
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          className="text-center mb-12"
          initial={{ opacity: 0, y: -30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          <div className="flex items-center justify-center gap-4 mb-6">
            <Link
              to="/project"
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-white/10 bg-white/5 text-sm font-medium hover:bg-white/10 transition-colors"
              style={{ color: 'var(--text)' }}
            >
              <ArrowLeft size={16} />
              Back to Projects
            </Link>
            {url && (
              <motion.a
                href={url}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-sm font-medium hover:bg-white/10 hover:border-emerald-400/40 transition-all duration-300"
                style={{ color: 'var(--text)' }}
                whileHover={{ scale: 1.05 }}
              >
                <ExternalLink size={16} />
                Open on GitHub
              </motion.a>
            )}
          </div>
          <h2 style={{ color: 'var(--accent)' }} className="text-xl md:text-2xl font-medium mb-2">
            {getTitle()}
          </h2>
          <h3 style={{ color: 'var(--text)' }} className="text-4xl md:text-5xl font-bold">
            {getSubtitle()}
          </h3>
        </motion.div>

        {/* Content */}
        {loading ? (
          <div className="text-center py-20">
            <p style={{ color: 'var(--muted)' }} className="text-lg">Loading...</p>
          </div>
        ) : error ? (
          <div className="text-center py-20">
            <p style={{ color: 'var(--muted)' }} className="text-xl mb-4">{error}</p>
            <Link to="/project" style={{ color: 'var(--accent)' }} className="font-medium transition-colors duration-300 hover:opacity-80">
              Back to Projects
            </Link>
          </div>
        ) : type === "profile" && data ? (
          <motion.div
            className="rounded-2xl border border-white/10 bg-white/5 backdrop-blur-sm p-6 md:p-8 max-w-3xl mx-auto"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <div className="flex flex-col md:flex-row gap-6 items-start">
              <motion.div
                className="relative group"
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.3 }}
              >
                <div className="w-24 h-24 md:w-32 md:h-32 rounded-full border-2 border-emerald-500/30 overflow-hidden bg-white/5">
                  <img
                    src={data.avatar_url}
                    alt={data.name || data.login}
                    className="w-full h-full object-cover object-center"
                  />
                </div>
                <div className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full bg-emerald-500 border-2 border-white/10 flex items-center justify-center">
                  <div className="w-2 h-2 rounded-full bg-white" />
                </div>
              </motion.div>
              <div className="flex-1">
                <h2 style={{ color: 'var(--text)' }} className="text-2xl md:text-3xl font-bold mb-2">{data.name || data.login}</h2>
                <p style={{ color: 'var(--accent)' }} className="text-base md:text-lg font-medium mb-3">@{data.login}</p>
                <p style={{ color: 'var(--muted)' }} className="text-sm md:text-base leading-relaxed mb-4">
                  {data.bio || 'Software Engineer building production-grade web systems.'}
                </p>
                <div className="flex flex-wrap gap-2 mb-4">
                  {data.location && (
                    <span className="px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-medium">
                      📍 {data.location}
                    </span>
                  )}
                  {data.company && (
                    <span className="px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-medium">
                      🏢 {data.company}
                    </span>
                  )}
                  {data.blog && (
                    <a href={data.blog} target="_blank" rel="noopener noreferrer" className="px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-medium hover:bg-emerald-500/20 transition-colors">
                      🔗 {data.blog}
                    </a>
                  )}
                </div>
                <div className="flex flex-wrap gap-4 text-sm">
                  <div className="text-center">
                    <div style={{ color: 'var(--accent)' }} className="text-lg font-bold">{data.public_repos}</div>
                    <div style={{ color: 'var(--muted)' }} className="text-xs">Repositories</div>
                  </div>
                  <div className="text-center">
                    <div style={{ color: 'var(--accent)' }} className="text-lg font-bold">{data.followers}</div>
                    <div style={{ color: 'var(--muted)' }} className="text-xs">Followers</div>
                  </div>
                  <div className="text-center">
                    <div style={{ color: 'var(--accent)' }} className="text-lg font-bold">{data.following}</div>
                    <div style={{ color: 'var(--muted)' }} className="text-xs">Following</div>
                  </div>
                </div>
                <motion.a
                  href={data.html_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="mt-4 inline-flex items-center justify-center gap-2 rounded-full bg-emerald-500 px-6 py-2.5 text-sm font-semibold text-slate-950 transition-all duration-200 hover:bg-emerald-400"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <UserPlus size={16} />
                  Follow
                </motion.a>
              </div>
            </div>
          </motion.div>
        ) : type === "repos" && data ? (
          <motion.div
            className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4 xl:gap-6"
            initial="hidden"
            animate="visible"
            viewport={{ once: true, amount: 0.1 }}
          >
            {data.map((repo, index) => (
              <motion.article
                key={repo.id}
                className="group flex flex-col overflow-hidden rounded-xl border border-white/10 bg-white/5 shadow-md shadow-black/10 transition-all duration-300 hover:border-emerald-400/30 hover:shadow-emerald-500/10"
                variants={cardVariants}
                custom={index}
                whileHover="hover"
              >
                {/* Image Section */}
                <div className="relative overflow-hidden bg-slate-900/50">
                  <div className="aspect-[16/9] overflow-hidden">
                    <img
                      src={repo.image}
                      alt={repo.title}
                      className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                      loading="lazy"
                    />
                  </div>
                  <div className="absolute inset-x-0 top-0 flex items-center justify-between p-2.5">
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-slate-950/80 px-2 py-1 text-[9px] font-semibold uppercase tracking-[0.15em] text-emerald-200 backdrop-blur-md">
                      <span className="block h-1.5 w-1.5 rounded-full bg-emerald-400" />
                      GitHub
                    </span>
                    <span className="rounded-full bg-white/10 px-2 py-1 text-[9px] font-semibold uppercase tracking-[0.15em] text-slate-200 border border-white/10 backdrop-blur-md">
                      Open Source
                    </span>
                  </div>
                </div>

                {/* Content Section */}
                <div className="flex flex-1 flex-col p-3">
                  <div className="mb-2">
                    <h4 className="text-sm font-semibold text-white leading-tight">
                      {repo.title}
                    </h4>
                    <p
                      className="mt-1 text-xs leading-relaxed text-slate-400"
                      style={{ display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}
                    >
                      {repo.description}
                    </p>
                  </div>

                  {/* Tech Stack */}
                  <div className="mb-2 flex flex-wrap gap-1">
                    {repo.stack.slice(0, 3).map((tech, techIndex) => (
                      <span
                        key={techIndex}
                        className="inline-flex items-center gap-1 rounded-md border border-white/10 bg-white/5 px-1.5 py-0.5 text-[9px] font-medium text-slate-300 transition-colors duration-200 hover:border-emerald-400/30 hover:bg-white/10"
                      >
                        {tech.logo && (
                          <img src={tech.logo} alt={`${tech.name} logo`} className="h-2.5 w-2.5 rounded-sm object-contain" />
                        )}
                        {tech.name}
                      </span>
                    ))}
                  </div>

                  {/* Actions */}
                  <div className="mt-auto flex items-center gap-1.5">
                    <a
                      href={repo.github}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex flex-1 items-center justify-center gap-1 rounded-full border border-white/10 bg-white/5 px-2.5 py-1.5 text-[11px] font-semibold text-white transition-all duration-200 hover:border-emerald-400/40 hover:bg-emerald-500/10"
                    >
                      <Github size={12} />
                      Open Site
                    </a>
                    {repo.demo && (
                      <a
                        href={repo.demo}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex flex-1 items-center justify-center gap-1 rounded-full bg-emerald-500 px-2.5 py-1.5 text-[11px] font-semibold text-slate-950 transition-all duration-200 hover:bg-emerald-400"
                      >
                        <ExternalLink size={12} />
                        View Demo
                      </a>
                    )}
                    <a
                      href={repo.github}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center justify-center gap-1 rounded-full border border-white/10 bg-white/5 px-2 py-1.5 text-[11px] font-semibold text-yellow-400 transition-all duration-200 hover:border-yellow-400/40 hover:bg-yellow-400/10"
                      title="Star on GitHub"
                    >
                      <Star size={12} />
                    </a>
                  </div>
                </div>
              </motion.article>
            ))}
          </motion.div>
        ) : (
          <div className="text-center py-20">
            <p style={{ color: 'var(--muted)' }} className="text-xl mb-4">No content found</p>
            <Link to="/project" style={{ color: 'var(--accent)' }} className="font-medium transition-colors duration-300 hover:opacity-80">
              Back to Projects
            </Link>
          </div>
        )}
      </div>
    </motion.div>
  );
}
