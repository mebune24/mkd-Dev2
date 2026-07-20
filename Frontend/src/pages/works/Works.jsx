import { motion } from "framer-motion";
import {
  ChevronLeft,
  ChevronRight,
  ExternalLink,
  Github,
  Search,
  Star,
} from "lucide-react";
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { API_ENDPOINTS } from "../../utils/constants";

export default function Works({ limit }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const projectsPerPage = 6;

  /* API Fetching Logic */
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      fetch(API_ENDPOINTS.PROJECTS).then(res => res.ok ? res.json() : []),
      fetch(API_ENDPOINTS.GITHUB_REPOS).then(res => res.ok ? res.json() : [])
    ])
    .then(async ([dbProjects, githubRepos]) => {
      const enrichedGithub = await Promise.all(
        githubRepos.map(repo => {
          if (!repo.fullName) return Promise.resolve(repo);
          const parts = repo.fullName.split('/');
          const owner = parts[0];
          const name = parts[1];
          return fetch(`${API_ENDPOINTS.GITHUB_REPO_LANGUAGES}?owner=${owner}&repo=${encodeURIComponent(name)}`)
            .then(res => res.ok ? res.json() : {})
            .then(languages => {
              const langEntries = Object.entries(languages)
                .sort((a, b) => b[1] - a[1])
                .slice(0, 4)
                .map(([langName]) => ({
                  name: langName,
                  logo: `https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${langName.toLowerCase()}/${langName.toLowerCase()}-original.svg`
                }));
              return {
                ...repo,
                stack: [
                  ...repo.stack.filter(s => !langEntries.find(l => l.name === s.name)),
                  ...langEntries
                ].slice(0, 6)
              };
            })
            .catch(() => repo);
        })
      );
      setProjects([...dbProjects, ...enrichedGithub]);
      setLoading(false);
    })
    .catch((err) => {
      console.error(err);
      setLoading(false);
    });
  }, []);

  // Filter projects based on search query
  const filteredProjects = projects.filter((project) => {
    const searchLower = searchQuery.toLowerCase();
    return (
      project.title.toLowerCase().includes(searchLower) ||
      project.description.toLowerCase().includes(searchLower) ||
      project.stack.some((tech) =>
        tech.name.toLowerCase().includes(searchLower)
      )
    );
  });

  // Calculate pagination
  const totalPages = Math.ceil(filteredProjects.length / projectsPerPage);
  const startIndex = (currentPage - 1) * projectsPerPage;
  const endIndex = startIndex + projectsPerPage;
  const currentProjects = filteredProjects.slice(startIndex, endIndex);

  const projectsToShow = limit
    ? currentProjects.slice(0, limit)
    : currentProjects;

  // Reset to page 1 when search changes
  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
    setCurrentPage(1);
  };

  const goToPage = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

const cardVariants = {
  hidden: { opacity: 0, y: 50, scale: 0.9 },
  visible: (index) => ({
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      duration: 0.6,
      delay: index * 0.1,
      ease: "easeOut"
    }
  }),
  hover: {
    scale: 1.05,
    rotateY: 5,
    rotateX: 2,
    z: 50,
    transition: {
      duration: 0.3,
      type: "spring",
      stiffness: 300
    }
  }
};

const imageVariants = {
  hover: {
    scale: 1.1,
    rotateY: -5,
    transition: { duration: 0.4 }
  }
};

  return (
    <motion.div
      className="py-20 px-6"
      style={{
        background: `
          radial-gradient(900px 500px at 10% -10%, rgba(34, 197, 94, 0.08), transparent 60%),
          radial-gradient(700px 400px at 90% -5%, rgba(56, 189, 248, 0.06), transparent 55%),
          var(--bg)
        `
      }}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 1 }}
    >
      <div className="max-w-7xl mx-auto">
        {/* Section Title */}
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: -30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2 style={{ color: 'var(--accent)' }} className="text-xl md:text-2xl font-medium mb-2">
            What I've Built
          </h2>
          <h3 style={{ color: 'var(--text)' }} className="text-4xl md:text-5xl font-bold">
            Projects
          </h3>
          <p style={{ color: 'var(--muted)' }} className="text-lg mt-4 max-w-2xl mx-auto">
            A showcase of solutions that solve real problems with clean, scalable code.
          </p>

          {/* GitHub Buttons */}
          <motion.div
            className="flex flex-wrap items-center justify-center gap-4 mt-6"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.3 }}
          >
            <Link
              to="/github?url=https://github.com/mebune24"
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-white/5 border border-white/10 text-sm font-medium hover:bg-white/10 hover:border-emerald-400/40 transition-all duration-300"
              style={{ color: 'var(--text)' }}
            >
              <Github size={16} />
              Visit GitHub Profile
            </Link>
            <Link
              to="/github?url=https://github.com/mebune24?tab=repositories"
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-white/5 border border-white/10 text-sm font-medium hover:bg-white/10 hover:border-emerald-400/40 transition-all duration-300"
              style={{ color: 'var(--text)' }}
            >
              <ExternalLink size={16} />
              View All GitHub Repos
            </Link>
          </motion.div>

          {/* Search Bar */}
          <motion.div
            className="max-w-xl mx-auto mt-8"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <div className="relative">
              <Search
                style={{ color: 'var(--muted)' }}
                className="absolute left-4 top-1/2 transform -translate-y-1/2"
                size={20}
              />
              <input
                type="text"
                placeholder="Search projects by name, description, or technology..."
                value={searchQuery}
                onChange={handleSearchChange}
                style={{
                  background: 'var(--bg)',
                  color: 'var(--text)',
                  border: '1px solid var(--muted)',
                }}
                className="w-full rounded-xl pl-12 pr-4 py-3 placeholder-current focus:outline-none focus:border-current transition-colors duration-300"
              />
            </div>
          </motion.div>
        </motion.div>

        {/* Projects List */}
        {projectsToShow.length > 0 ? (
          <>
            <motion.div
              className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4 xl:gap-6"
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.1 }}
            >
              {projectsToShow.map((project, index) => (
                <motion.article
                  key={project.id}
                  className="group flex flex-col overflow-hidden rounded-xl border border-white/10 bg-white/5 shadow-md shadow-black/10 transition-all duration-300 hover:border-emerald-400/30 hover:shadow-emerald-500/10"
                  variants={cardVariants}
                  custom={index}
                  whileHover="hover"
                  style={{ perspective: "1000px" }}
                >
                  {/* Image Section */}
                  <div className="relative overflow-hidden bg-slate-900/50">
                    <div className="aspect-[16/9] overflow-hidden">
                      <img
                        src={project.image}
                        alt={project.title}
                        className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                        loading="lazy"
                      />
                    </div>
                    <div className="absolute inset-x-0 top-0 flex items-center justify-between p-2.5">
                      <span className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-slate-950/80 px-2 py-1 text-[9px] font-semibold uppercase tracking-[0.15em] text-emerald-200 backdrop-blur-md">
                        <span className="block h-1.5 w-1.5 rounded-full bg-emerald-400" />
                        {project.isGithub ? 'GitHub' : 'Portfolio'}
                      </span>
                      <span className="rounded-full bg-white/10 px-2 py-1 text-[9px] font-semibold uppercase tracking-[0.15em] text-slate-200 border border-white/10 backdrop-blur-md">
                        {project.isGithub ? 'Open Source' : 'Featured'}
                      </span>
                    </div>
                  </div>

                  {/* Content Section */}
                  <div className="flex flex-1 flex-col p-3">
                    <div className="mb-2">
                      <h4 className="text-sm font-semibold text-white leading-tight">
                        {project.title}
                      </h4>
                      <p
                        className="mt-1 text-xs leading-relaxed text-slate-400"
                        style={{ display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}
                      >
                        {project.description}
                      </p>
                    </div>

                    {/* Tech Stack */}
                    <div className="mb-2 flex flex-wrap gap-1">
                      {project.stack.slice(0, 3).map((tech, techIndex) => (
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
                        href={project.github}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex flex-1 items-center justify-center gap-1 rounded-full border border-white/10 bg-white/5 px-2.5 py-1.5 text-[11px] font-semibold text-white transition-all duration-200 hover:border-emerald-400/40 hover:bg-emerald-500/10"
                      >
                        <Github size={12} />
                        Open Site
                      </a>
                      {project.demo && (
                        <a
                          href={project.demo}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex flex-1 items-center justify-center gap-1 rounded-full bg-emerald-500 px-2.5 py-1.5 text-[11px] font-semibold text-slate-950 transition-all duration-200 hover:bg-emerald-400"
                        >
                          <ExternalLink size={12} />
                          View Demo
                        </a>
                      )}
                      <a
                        href={project.github}
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

            {/* Pagination */}
            {!limit && totalPages > 1 && (
              <motion.div
                className="mt-12 flex items-center justify-center gap-2"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.3 }}
              >
                {/* Previous Button */}
                <button
                  onClick={() => goToPage(currentPage - 1)}
                  disabled={currentPage === 1}
                  className="p-2 rounded-full transition-all duration-300"
                  style={{
                    background: currentPage === 1 ? 'var(--muted)' : 'var(--bg)',
                    color: currentPage === 1 ? 'var(--bg)' : 'var(--text)',
                    border: '1px solid var(--muted)  ',
                    cursor: currentPage === 1 ? 'not-allowed' : 'pointer',
                    borderRadius: '50%'

                  }}
                >
                  <ChevronLeft size={20} />
                </button>

                {/* Page Numbers */}
                {[...Array(totalPages)].map((_, index) => {
                  const pageNumber = index + 1;
                  return (
                    <button
                      key={pageNumber}
                      onClick={() => goToPage(pageNumber)}
                      className="w-10 h-10 rounded-full font-medium transition-all duration-300"
                      style={{
                        background: currentPage === pageNumber ? 'var(--accent)' : 'var(--bg)',
                        color: currentPage === pageNumber ? 'var(--bg)' : 'var(--text)',
                        border: '1px solid var(--muted)'
                      }}
                    >
                      {pageNumber}
                    </button>
                  );
                })}

                {/* Next Button */}
                <button
                  onClick={() => goToPage(currentPage + 1)}
                  disabled={currentPage === totalPages}
                  className="p-2 rounded-full transition-all duration-300"
                  style={{
                    background: currentPage === totalPages ? 'var(--muted)' : 'var(--bg)',
                    color: currentPage === totalPages ? 'var(--bg)' : 'var(--text)',
                    border: '1px solid var(--muted)',
                    borderRadius: '50%',
                    cursor: currentPage === totalPages ? 'not-allowed' : 'pointer'
                  }}
                >
                  <ChevronRight size={20} />
                </button>
              </motion.div>
            )}
          </>
        ) : (
          // No Results Message
          <div className="text-center py-20">
            <p style={{ color: 'var(--muted)' }} className="text-xl mb-4">
              No projects found matching "{searchQuery}"
            </p>
            <button
              onClick={() => setSearchQuery("")}
              style={{ color: 'var(--accent)' }}
              className="font-medium transition-colors duration-300 hover:opacity-80"
            >
              Clear search
            </button>
          </div>
        )}
      </div>

      <style>{`
        @keyframes fade-in-up {
          from {
            opacity: 0;
            transform: translateY(30px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .animate-fade-in-up {
          animation: fade-in-up 0.6s ease-out forwards;
        }
      `}</style>
    </motion.div>
  );
}
