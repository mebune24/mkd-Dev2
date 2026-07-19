import { motion } from "framer-motion";
import {
  ChevronLeft,
  ChevronRight,
  ExternalLink,
  Github,
  Search,
} from "lucide-react";
import { useEffect, useState } from "react";

export default function Works({ limit }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const projectsPerPage = 6;

  /* API Fetching Logic */
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fetch projects from backend
  useEffect(() => {
    fetch("http://localhost:3000/api/projects")
      .then((res) => {
        if (!res.ok) throw new Error("Failed to fetch projects");
        return res.json();
      })
      .then((data) => {
        setProjects(data);
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
    window.scrollTo({ top: 0, behavior: "smooth" });
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
              className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6 xl:gap-8"
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.1 }}
            >
              {projectsToShow.map((project, index) => (
                <motion.article
                  key={project.id}
                  className="group overflow-hidden rounded-[32px] border border-emerald-400/50 bg-slate-950/95 shadow-2xl shadow-emerald-500/20 hover:shadow-emerald-500/40 transition duration-300"
                  variants={cardVariants}
                  custom={index}
                  whileHover="hover"
                  style={{ perspective: "1000px" }}
                >
                  <div className="relative overflow-hidden h-54 sm:h-60">
                    <motion.img
                      src={project.image}
                      alt={project.title}
                      className="w-full h-full object-cover transition duration-500"
                      variants={imageVariants}
                      whileHover="hover"
                    />

                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950/95 via-slate-950/20 to-transparent" />

                    <div className="absolute inset-x-5 top-5 flex items-center justify-between gap-3">
                      <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-slate-950/70 px-3 py-2 text-[11px] font-semibold uppercase tracking-[0.24em] text-emerald-200 backdrop-blur-sm">
                        <span className="block h-2.5 w-2.5 rounded-full bg-emerald-400" />
                        Portfolio
                      </span>
                      <span className="rounded-full bg-white/10 px-3 py-2 text-[11px] font-semibold uppercase tracking-[0.2em] text-slate-200 border border-white/10">
                        Featured
                      </span>
                    </div>

                    <div className="absolute inset-x-5 bottom-5 rounded-[28px] border border-white/10 bg-slate-950/80 p-4 shadow-2xl backdrop-blur-sm">
                      <h4 className="text-lg font-semibold text-white sm:text-xl">
                        {project.title}
                      </h4>
                      <p
                        className="mt-2 text-sm leading-6 text-slate-300"
                        style={{ display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}
                      >
                        {project.description}
                      </p>
                    </div>
                  </div>

                  <div className="p-5 flex flex-col gap-4">
                    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
                      {project.stack.slice(0, 3).map((tech, techIndex) => (
                        <motion.span
                          key={techIndex}
                          className="inline-flex items-center gap-2 rounded-2xl border border-white/10 bg-white/5 px-3 py-2 text-[11px] font-medium text-slate-100"
                          whileHover={{
                            scale: 1.05,
                            backgroundColor: "rgba(34, 197, 94, 0.1)",
                            borderColor: "rgba(34, 197, 94, 0.3)"
                          }}
                          transition={{ duration: 0.2 }}
                        >
                          <motion.img
                            src={tech.logo}
                            alt={`${tech.name} logo`}
                            className="w-4 h-4 rounded-sm"
                            whileHover={{ rotate: 360 }}
                            transition={{ duration: 0.5 }}
                          />
                          {tech.name}
                        </motion.span>
                      ))}
                    </div>

                    <div className="mt-auto flex flex-wrap gap-3">
                      <motion.a
                        href={project.github}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex min-w-[110px] items-center justify-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-2 text-sm font-semibold text-white transition hover:border-emerald-400/40 hover:bg-emerald-500/10"
                        whileHover={{
                          scale: 1.05,
                          boxShadow: "0 0 20px rgba(34, 197, 94, 0.3)"
                        }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <Github size={16} />
                        Code
                      </motion.a>
                      <motion.a
                        href={project.demo}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex min-w-[110px] items-center justify-center gap-2 rounded-full bg-emerald-400 px-4 py-2 text-sm font-semibold text-slate-950 transition hover:bg-emerald-300"
                        whileHover={{
                          scale: 1.05,
                          boxShadow: "0 0 20px rgba(34, 197, 94, 0.5)"
                        }}
                        whileTap={{ scale: 0.95 }}
                      >
                        <ExternalLink size={16} />
                        Demo
                      </motion.a>
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
