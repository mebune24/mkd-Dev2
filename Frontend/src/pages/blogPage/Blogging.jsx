import { AnimatePresence, motion } from 'framer-motion';
import { ArrowRight, Calendar, Clock, X } from "lucide-react";
import { useEffect, useState } from "react";

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2
    }
  }
};

const cardVariants = {
  hidden: { opacity: 0, y: 50, scale: 0.9 },
  visible: {
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      duration: 0.6,
      ease: "easeOut"
    }
  },
  hover: {
    scale: 1.05,
    rotateY: 5,
    z: 20,
    transition: { duration: 0.3 }
  }
};

const modalVariants = {
  hidden: { opacity: 0, scale: 0.8 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: {
      duration: 0.3,
      ease: "easeOut"
    }
  },
  exit: {
    opacity: 0,
    scale: 0.8,
    transition: {
      duration: 0.2
    }
  }
};

export default function Blogging() {
  const [blogPosts, setBlogPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("http://localhost:3000/api/posts")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Failed to fetch posts");
        }
        return response.json();
      })
      .then((data) => {
        setBlogPosts(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Error fetching posts:", err);
        setError(err.message);
        setLoading(false);
      });
  }, []);

  const [currentPage, setCurrentPage] = useState(1);
  const [postsPerPage] = useState(6);
  const [selectedBlog, setSelectedBlog] = useState(null);
  const [blogPage, setBlogPage] = useState(1);

  // Get current posts
  const indexOfLastPost = currentPage * postsPerPage;
  const indexOfFirstPost = indexOfLastPost - postsPerPage;
  const currentPosts = blogPosts.slice(indexOfFirstPost, indexOfLastPost);

  // Change page
  const paginate = (pageNumber) => setCurrentPage(pageNumber);

  // Blog modal handlers
  const openBlog = (blog) => {
    setSelectedBlog(blog);
    setBlogPage(1);
    document.body.style.overflow = "hidden";
  };

  const closeBlog = () => {
    setSelectedBlog(null);
    setBlogPage(1);
    document.body.style.overflow = "unset";
  };

  const goToNextBlogPage = () => {
    if(selectedBlog && blogPage < selectedBlog.pages.length) {
      setBlogPage(blogPage + 1);
    }
  };

  const goToPreviousBlogPage = () => {
    if(blogPage > 1) {
      setBlogPage(blogPage - 1);
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
            Engineering Insights
          </h2>
          <motion.h3
            style={{ color: 'var(--text)' }}
            className="text-4xl md:text-5xl font-bold mb-4"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            Product & Platform Notes
          </motion.h3>
          <motion.p
            style={{ color: 'var(--muted)' }}
            className="text-lg"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            Practical write‑ups on delivery, performance, and building scalable
            web products for teams.
          </motion.p>
        </motion.div>

        {/* Blog Grid */}
        <motion.div
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-8"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
        >
          {currentPosts.map((post, index) => (
            <motion.article
              key={post.id}
              className="flex flex-col cursor-pointer group"
              variants={cardVariants}
              whileHover="hover"
              style={{ perspective: "1000px" }}
              onClick={() => openBlog(post)}
            >
              {/* Blog Image */}
              <div className="relative h-48 overflow-hidden rounded-xl mb-6">
                <motion.img
                  src={post.image}
                  alt={post.title}
                  className="w-full h-full object-cover"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.5 }}
                />
                <motion.div
                  className="absolute top-4 left-4 flex items-center gap-2"
                  initial={{ opacity: 0, x: -20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: 0.2 }}
                >
                  <span style={{
                    background: 'var(--accent)',
                    color: 'var(--bg)'
                  }} className="text-xs font-semibold px-3 py-1 rounded-full">
                    {post.category}
                  </span>
                </motion.div>
              </div>

              {/* Blog Content */}
              <div className="flex flex-col grow">
                {/* Date and Read Time */}
                <motion.div
                  className="flex items-center gap-4 text-sm mb-3"
                  style={{ color: 'var(--muted)' }}
                  initial={{ opacity: 0 }}
                  whileInView={{ opacity: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: 0.3 }}
                >
                  <div className="flex items-center gap-1">
                    <Calendar size={14} />
                    <span>{post.date}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Clock size={14} />
                    <span>{post.readTime}</span>
                  </div>
                </motion.div>

                <motion.h4
                  style={{ color: 'var(--text)' }}
                  className="text-xl font-semibold mb-3 transition-colors duration-300"
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: 0.4 }}
                >
                  {post.title}
                </motion.h4>

                <motion.p
                  style={{ color: 'var(--muted)' }}
                  className="text-base mb-4 grow"
                  initial={{ opacity: 0 }}
                  whileInView={{ opacity: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: 0.5 }}
                >
                  {post.excerpt}
                </motion.p>

                {/* Tags */}
                <motion.div
                  className="flex flex-wrap gap-2 mb-4"
                  initial={{ opacity: 0 }}
                  whileInView={{ opacity: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: 0.6 }}
                >
                  {post.tags.map((tag, tagIndex) => (
                    <motion.span
                      key={tagIndex}
                      style={{ color: 'var(--muted)' }}
                      className="text-xs px-2 py-1 rounded"
                      whileHover={{ scale: 1.1 }}
                      transition={{ duration: 0.2 }}
                    >
                      #{tag}
                    </motion.span>
                  ))}
                </motion.div>

                {/* Read More Button */}
                <motion.button
                  style={{ color: 'var(--accent)' }}
                  className="flex items-center gap-2 font-medium transition-colors duration-300"
                  whileHover={{ x: 5 }}
                  transition={{ duration: 0.2 }}
                >
                  Read the analysis
                  <motion.div
                    whileHover={{ x: 3 }}
                    transition={{ duration: 0.2 }}
                  >
                    <ArrowRight size={16} />
                  </motion.div>
                </motion.button>
              </div>
            </motion.article>
          ))}
        </motion.div>

        {/* Pagination */}
        <motion.div
          className="mt-16 flex justify-center items-center gap-2"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
        >
          <motion.button
            onClick={() => paginate(currentPage - 1)}
            disabled={currentPage === 1}
            className="py-2 px-4 rounded transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            style={{
              background: 'var(--bg)',
              color: 'var(--text)',
              border: '1px solid var(--muted)'
            }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Previous
          </motion.button>
          {Array.from({
            length: Math.ceil(blogPosts.length / postsPerPage),
          }).map((_, index) => (
            <motion.button
              key={index}
              onClick={() => paginate(index + 1)}
              className="py-2 px-4 rounded transition-all font-semibold"
              style={{
                background: currentPage === index + 1 ? 'var(--accent)' : 'var(--bg)',
                color: currentPage === index + 1 ? 'var(--bg)' : 'var(--text)',
                border: '1px solid var(--muted)'
              }}
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.9 }}
            >
              {index + 1}
            </motion.button>
          ))}
          <motion.button
            onClick={() => paginate(currentPage + 1)}
            disabled={
              currentPage === Math.ceil(blogPosts.length / postsPerPage)
            }
            className="py-2 px-4 rounded transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            style={{
              background: 'var(--bg)',
              color: 'var(--text)',
              border: '1px solid var(--muted)'
            }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Next
          </motion.button>
        </motion.div>

        {/* Blog Post Modal */}
        <AnimatePresence>
          {selectedBlog && (
            <motion.div
              className="fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto"
              style={{ background: 'rgba(0, 0, 0, 0.9)' }}
              variants={modalVariants}
              initial="hidden"
              animate="visible"
              exit="exit"
              onClick={closeBlog}
            >
              <motion.div
                className="rounded-2xl max-w-4xl w-full my-8 max-h-[90vh] overflow-y-auto"
                style={{
                  background: 'var(--bg)',
                  border: '1px solid var(--muted)'
                }}
                onClick={(e) => e.stopPropagation()}
                initial={{ y: 50, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                exit={{ y: 50, opacity: 0 }}
                transition={{ duration: 0.3 }}
              >
                {/* Modal Header */}
                <div className="relative h-64 overflow-hidden rounded-t-lg">
                  <motion.img
                    src={selectedBlog.image}
                    alt={selectedBlog.title}
                    className="w-full h-full object-cover"
                    initial={{ scale: 1.1 }}
                    animate={{ scale: 1 }}
                    transition={{ duration: 0.5 }}
                  />
                  <div style={{
                    background: 'linear-gradient(to top, var(--bg), rgba(0,0,0,0.3), transparent)'
                  }} className="absolute inset-0" />
                  <motion.button
                    onClick={closeBlog}
                    className="absolute top-4 right-4 rounded-full w-10 h-10 flex items-center justify-center hover:opacity-80 transition-all z-10"
                    style={{
                      background: 'var(--bg)',
                      color: 'var(--text)',
                      border: '1px solid var(--muted)'
                    }}
                    aria-label="Close"
                    whileHover={{ scale: 1.1, rotate: 90 }}
                    whileTap={{ scale: 0.9 }}
                  >
                    <X size={20} />
                  </motion.button>
                  <motion.div
                    className="absolute bottom-6 left-6"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.5, delay: 0.2 }}
                  >
                    <span style={{
                      background: 'var(--accent)',
                      color: 'var(--bg)'
                    }} className="text-sm font-semibold px-4 py-1.5 rounded-full inline-block">
                      {selectedBlog.category}
                    </span>
                  </motion.div>
                </div>

                {/* Modal Content */}
                <div className="p-8">
                  <motion.h2
                    style={{ color: 'var(--text)' }}
                    className="text-3xl md:text-4xl font-bold mb-4 leading-tight"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.5, delay: 0.3 }}
                  >
                    {selectedBlog.title}
                  </motion.h2>

                  <motion.div
                    className="flex items-center gap-6 text-sm mb-8 pb-6"
                    style={{
                      color: 'var(--muted)',
                      borderBottom: '1px solid var(--muted)'
                    }}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5, delay: 0.4 }}
                  >
                    <div className="flex items-center gap-2">
                      <Calendar size={16} />
                      <span>{selectedBlog.date}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Clock size={16} />
                      <span>{selectedBlog.readTime}</span>
                    </div>
                    <div style={{ color: 'var(--accent)' }} className="ml-auto font-medium">
                      Page {blogPage} of {selectedBlog.pages.length}
                    </div>
                  </motion.div>

                  <motion.div
                    style={{ color: 'var(--text)' }}
                    className="text-lg leading-relaxed mb-8 whitespace-pre-line"
                    key={blogPage}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    transition={{ duration: 0.3 }}
                  >
                    {selectedBlog.pages[blogPage - 1]}
                  </motion.div>

                  {/* Tags */}
                  <motion.div
                    className="flex flex-wrap gap-2 mb-8 pb-6"
                    style={{ borderBottom: '1px solid var(--muted)' }}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 0.5, delay: 0.5 }}
                  >
                    {selectedBlog.tags.map((tag, tagIndex) => (
                      <motion.span
                        key={tagIndex}
                        style={{ color: 'var(--text)', border: '1px solid var(--muted)' }}
                        className="text-sm px-3 py-1.5 rounded-full hover:opacity-80 transition-opacity"
                        whileHover={{ scale: 1.05 }}
                        transition={{ duration: 0.2 }}
                      >
                        #{tag}
                      </motion.span>
                    ))}
                  </motion.div>

                  {/* Blog Page Navigation */}
                  <motion.div
                    className="flex items-center justify-between"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.5, delay: 0.6 }}
                  >
                    <motion.button
                      onClick={goToPreviousBlogPage}
                      disabled={blogPage === 1}
                      style={{ color: 'var(--accent)' }}
                      className="flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition-opacity font-medium"
                      whileHover={{ scale: 1.05, x: -5 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <ArrowRight size={18} className="rotate-180" />
                      Previous Page
                    </motion.button>

                    <div className="flex gap-2">
                      {selectedBlog.pages.map((_, pageIndex) => (
                        <motion.button
                          key={pageIndex}
                          onClick={() => setBlogPage(pageIndex + 1)}
                          className="rounded-full transition-all"
                          style={{
                            background: blogPage === pageIndex + 1 ? 'var(--accent)' : 'var(--muted)',
                            width: blogPage === pageIndex + 1 ? '32px' : '8px',
                            height: '8px'
                          }}
                          aria-label={`Go to page ${pageIndex + 1}`}
                          whileHover={{ scale: 1.2 }}
                          whileTap={{ scale: 0.8 }}
                        />
                      ))}
                    </div>

                    <motion.button
                      onClick={goToNextBlogPage}
                      disabled={blogPage === selectedBlog.pages.length}
                      style={{ color: 'var(--accent)' }}
                      className="flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed transition-opacity font-medium"
                      whileHover={{ scale: 1.05, x: 5 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      Next Page
                      <ArrowRight size={18} />
                    </motion.button>
                  </motion.div>
                </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}
