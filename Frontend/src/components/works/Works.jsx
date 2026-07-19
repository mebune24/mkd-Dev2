import {
    ChevronLeft,
    ChevronRight,
    ExternalLink,
    Github,
    Loader2,
    Search
} from "lucide-react";
import { useEffect, useState } from "react";

import { techColors } from "../../config/colors";

export default function Works({ limit }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [projects, setProjects] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const projectsPerPage = 6;

  const placeholderImages = [
    "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1587145820266-a5951ee6f620?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=600&h=400&fit=crop",
    "https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=600&h=400&fit=crop",
  ];

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        setIsLoading(true);
        const response = await fetch(
          "https://api.github.com/users/mkd-Dev2/repos?sort=updated&per_page=12"
        );
        if (!response.ok) {
          throw new Error("Failed to fetch projects");
        }
        const data = await response.json();

        // Need to filter out repos that are empty or have some issue if necessary
        const formattedProjects = data.map((repo, index) => {
          let stack = [];

          if (repo.topics && repo.topics.length > 0) {
            stack = repo.topics.map((topic) => ({
              name: topic.charAt(0).toUpperCase() + topic.slice(1),
              logo: `https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/${topic.toLowerCase()}/${topic.toLowerCase()}-original.svg`,
            }));
          } else if (repo.language) {
            const lang = repo.language.toLowerCase();
            // Map C# and C++ to proper devicon names
            const langMap = {
              'c#': 'csharp',
              'c++': 'cplusplus',
              'html': 'html5',
              'css': 'css3',
              'vue': 'vuejs'
            };
            const iconName = langMap[lang] || lang;

            stack = [{
              name: repo.language,
              logo: `https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/${iconName}/${iconName}-original.svg`,
            }];
          } else {
            stack = [{
              name: "Code",
              logo: "https://upload.wikimedia.org/wikipedia/commons/9/99/Unofficial_JavaScript_logo_2.svg",
            }];
          }

          return {
            id: repo.id,
            title: repo.name.replace(/-/g, " "),
            description: repo.description || "A project developed by mkd-Dev2.",
            image: placeholderImages[index % placeholderImages.length],
            stack: stack,
            github: repo.html_url,
            demo: repo.homepage || repo.html_url,
          };
        });

        setProjects(formattedProjects);
      } catch (err) {
        console.error("Error fetching projects:", err);
        setError(err.message);
      } finally {
        setIsLoading(false);
      }
    };

    fetchProjects();
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

  return (
    <div className="min-h-screen bg-black py-20 px-6">
      <div className="max-w-7xl mx-auto">
        {/* Section Title */}
        <div className="mb-16 mt-15 text-center">
          <h2 className="text-green-500 text-xl md:text-2xl font-medium mb-2">
            What I've Built
          </h2>
          <h3 className="text-white text-4xl md:text-5xl font-bold mb-8">
            Projects
          </h3>

          {/* Search Bar */}
          <div className="max-w-xl mx-auto">
            <div className="relative">
              <Search
                className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-500"
                size={20}
              />
              <input
                type="text"
                placeholder="Search projects by name, description, or technology..."
                value={searchQuery}
                onChange={handleSearchChange}
                className="w-full bg-gray-900 border border-gray-800 rounded-lg pl-12 pr-4 py-3 text-white placeholder-gray-500 focus:outline-none focus:border-green-500 transition-colors duration-300"
              />
            </div>
          </div>
        </div>

        {/* Projects List */}
        {isLoading ? (
          <div className="flex flex-col items-center justify-center py-20">
            <Loader2 className="animate-spin text-green-500 mb-4" size={48} />
            <p className="text-gray-400 text-xl">Loading projects from GitHub...</p>
          </div>
        ) : error ? (
          <div className="text-center py-20">
            <p className="text-red-500 text-xl mb-4">Error: {error}</p>
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-2 bg-gray-800 hover:bg-gray-700 text-green-500 border border-green-500 rounded-lg transition-colors duration-300"
            >
              Try again
            </button>
          </div>
        ) : projectsToShow.length > 0 ? (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {projectsToShow.map((project) => (
                <div
                  key={project.id}
                  className="relative rounded-3xl border border-emerald-400/50 animate-pulse bg-gradient-to-br from-slate-900/80 via-slate-800/60 to-slate-900/80 backdrop-blur-xl overflow-hidden hover:border-emerald-400 transition-all duration-500 flex flex-col shadow-xl shadow-emerald-500/20 hover:shadow-emerald-500/40"
                >
                  {/* Background Pattern */}
                  <div className="absolute inset-0 opacity-5">
                    <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-400 rounded-full blur-2xl" />
                    <div className="absolute bottom-0 left-0 w-12 h-12 bg-cyan-400 rounded-full blur-xl" />
                  </div>
                  {/* Project Image */}
                  <div className="h-64 overflow-hidden">
                    <img
                      src={project.image}
                      alt={project.title}
                      className="w-full h-full object-cover hover:scale-110 transition-transform duration-300"
                    />
                  </div>

                  {/* Project Content */}
                  <div className="relative z-10 p-6 md:p-8 flex flex-col flex-grow">
                    <h4 style={{ color: 'var(--text)' }} className="text-2xl font-bold mb-3 truncate">
                      {project.title}
                    </h4>

                    <p style={{ color: 'var(--muted)' }} className="text-base mb-6 flex-grow line-clamp-3">
                      {project.description}
                    </p>

                    {/* Tech Stack */}
                    <div className="flex flex-wrap gap-3 mb-6">
                      {project.stack.slice(0, 4).map((tech, index) => (
                        <div
                          key={index}
                          className="flex items-center gap-2 bg-gray-800 rounded-md px-3 py-2"
                        >
                          <img
                            src={tech.logo}
                            alt={`${tech.name} logo`}
                            className="w-5 h-5"
                            onError={(e) => { e.target.style.display = 'none'; }}
                          />
                          <span className={`${techColors[tech.name] || 'text-gray-300'} text-sm`}>
                            {tech.name}
                          </span>
                        </div>
                      ))}
                    </div>

                    {/* Buttons */}
                    <div className="flex gap-3 mt-auto">
                      <a
                        href={project.github}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center justify-center gap-2 bg-gradient-to-r from-slate-800 to-slate-700 hover:from-slate-700 hover:to-slate-600 text-white font-medium px-5 py-3 rounded-full border border-slate-600/50 hover:border-emerald-500/50 transition-all duration-300 flex-1 shadow-lg shadow-slate-900/20"
                      >
                        <Github size={18} />
                        Code
                      </a>

                      <a
                        href={project.demo}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center justify-center gap-2 bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white font-medium px-5 py-3 rounded-full transition-all duration-300 flex-1 shadow-lg shadow-emerald-500/25 hover:shadow-emerald-500/40"
                      >
                        <ExternalLink size={18} />
                        Demo
                      </a>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Pagination */}
            {!limit && totalPages > 1 && (
              <div className="mt-12 flex items-center justify-center gap-2">
                {/* Previous Button */}
                <button
                  onClick={() => goToPage(currentPage - 1)}
                  disabled={currentPage === 1}
                  className={`p-2 rounded-full transition-all duration-300 ${
                    currentPage === 1
                      ? "bg-gray-800 text-gray-600 cursor-not-allowed"
                      : "bg-gray-800 text-white hover:bg-gray-700 hover:border-green-500 border border-gray-700"
                  }`}
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
                      className={`w-10 h-10 rounded-full font-medium transition-all duration-300 ${
                        currentPage === pageNumber
                          ? "bg-green-500 text-black"
                          : "bg-gray-800 text-white hover:bg-gray-700 hover:border-green-500 border border-gray-700"
                      }`}
                    >
                      {pageNumber}
                    </button>
                  );
                })}

                {/* Next Button */}
                <button
                  onClick={() => goToPage(currentPage + 1)}
                  disabled={currentPage === totalPages}
                  className={`p-2 rounded-full transition-all duration-300 ${
                    currentPage === totalPages
                      ? "bg-gray-800 text-gray-600 cursor-not-allowed"
                      : "bg-gray-800 text-white hover:bg-gray-700 hover:border-green-500 border border-gray-700"
                  }`}
                >
                  <ChevronRight size={20} />
                </button>
              </div>
            )}
          </>
        ) : (
          // No Results Message
          <div className="text-center py-20">
            <p className="text-gray-400 text-xl mb-4">
              No projects found matching "{searchQuery}"
            </p>
            <button
              onClick={() => setSearchQuery("")}
              className="text-green-500 hover:text-green-400 font-medium transition-colors duration-300"
            >
              Clear search
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
