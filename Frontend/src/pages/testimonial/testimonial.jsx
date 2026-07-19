import { AnimatePresence, motion } from 'framer-motion';
import { ChevronLeft, ChevronRight, ExternalLink, Star, X } from "lucide-react";
import { useMemo, useState } from "react";
import { useCarousel } from "../../Hooks/useCarousel";
import { useTestimonials } from "../../Hooks/useTestimonials";
import ConfirmModal from "../../components/ConfirmModal";

const testimonialVariants = {
  enter: (direction) => ({
    x: direction > 0 ? 300 : -300,
    opacity: 0,
    scale: 0.8,
  }),
  center: {
    zIndex: 1,
    x: 0,
    opacity: 1,
    scale: 1,
  },
  exit: (direction) => ({
    zIndex: 0,
    x: direction < 0 ? 300 : -300,
    opacity: 0,
    scale: 0.8,
  }),
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

export default function Testimonial() {
  const { testimonials, submitTestimonial } = useTestimonials();
  const { currentIndex, next, prev, goTo } = useCarousel(testimonials.length);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    role: "",
    company: "",
    text: "",
    project: "",
    phone: "",
    rating: 5,
    imageFile: null
  });

  const handleFormSubmit = (e) => {
    e.preventDefault();
    setIsConfirmOpen(true);
  };

  const handleConfirmAction = async () => {
    try {
      await submitTestimonial(formData);
      setIsModalOpen(false);
      alert("Thank you for your feedback!");
      setFormData({
        name: "",
        role: "",
        company: "",
        text: "",
        project: "",
        phone: "",
        rating: 5,
        imageFile: null
      });
    } catch (err) {
      alert(err.message);
    }
  };

  const slides = useMemo(() => testimonials, [testimonials]);

  if (testimonials.length === 0) return null;

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
      <div className="max-w-5xl mx-auto">
        {/* Section Title */}
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: -30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2 style={{ color: 'var(--accent)' }} className="text-xl md:text-2xl font-medium mb-2">
            Client Feedback
          </h2>
          <motion.h3
            style={{ color: 'var(--text)' }}
            className="text-4xl md:text-5xl font-bold"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            Testimonials
          </motion.h3>
          <motion.p
            style={{ color: 'var(--muted)' }}
            className="text-lg mt-4 max-w-2xl mx-auto"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            Real stories from clients who've experienced the difference quality work makes.
          </motion.p>
          <motion.button
            onClick={() => setIsModalOpen(true)}
            style={{
              background: 'var(--accent)',
              color: 'var(--bg)'
            }}
            className="mt-6 px-6 py-2 rounded-full font-semibold transition duration-300"
            whileHover={{
              scale: 1.05,
              boxShadow: "0 0 20px rgba(34, 197, 94, 0.5)"
            }}
            whileTap={{ scale: 0.95 }}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.6 }}
          >
            Share Your Story
          </motion.button>
        </motion.div>

        {/* Testimonial Carousel */}
        <div className="relative">
          <div className="overflow-hidden">
            <AnimatePresence initial={false} custom={currentIndex}>
              <motion.div
                key={currentIndex}
                custom={currentIndex}
                variants={testimonialVariants}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{
                  x: { type: "spring", stiffness: 300, damping: 30 },
                  opacity: { duration: 0.2 },
                  scale: { duration: 0.3 }
                }}
                className="flex"
                style={{ transform: `translateX(-${currentIndex * 100}%)` }}
              >
                {slides.map((t, idx) => (
                  <div className="w-full flex-shrink-0 px-4" key={`${t.id}-${idx}`}>
                    <motion.div
                      className="max-w-4xl mx-auto text-center"
                      variants={cardVariants}
                      whileHover="hover"
                      style={{ perspective: "1000px" }}
                    >
                      <motion.div
                        className="mb-6"
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        transition={{ duration: 0.5, delay: 0.2 }}
                      >
                        <div style={{ color: 'var(--accent)' }} className="text-6xl font-serif">"</div>
                      </motion.div>

                      <motion.p
                        style={{ color: 'var(--text)' }}
                        className="text-lg md:text-xl leading-relaxed mb-8"
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.6, delay: 0.4 }}
                      >
                        {t.text}
                      </motion.p>

                      <motion.div
                        className="flex justify-center gap-1 mb-6"
                        initial={{ opacity: 0, scale: 0.8 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ duration: 0.5, delay: 0.6 }}
                      >
                        {[...Array(t.rating)].map((_, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, scale: 0 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.3, delay: 0.8 + index * 0.1 }}
                          >
                            <Star
                              size={20}
                              style={{ color: 'var(--accent)', fill: 'var(--accent)' }}
                            />
                          </motion.div>
                        ))}
                      </motion.div>

                      <motion.div
                        className="flex items-center justify-center gap-4 mb-4"
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.6, delay: 0.8 }}
                      >
                        <motion.img
                          src={t.image}
                          alt={t.name}
                          className="w-16 h-16 rounded-full object-cover"
                          whileHover={{
                            scale: 1.1,
                            rotate: 5,
                            boxShadow: "0 0 20px rgba(34, 197, 94, 0.3)"
                          }}
                          transition={{ duration: 0.3 }}
                        />
                        <div className="text-left">
                          <h4 style={{ color: 'var(--text)' }} className="text-xl font-semibold">
                            {t.name}
                          </h4>
                          <p style={{ color: 'var(--muted)' }} className="text-sm">
                            {t.role}
                          </p>
                          <p style={{ color: 'var(--accent)' }} className="text-sm font-medium">
                            {t.company}
                          </p>
                        </div>
                      </motion.div>

                      <motion.div
                        className="inline-block px-4 py-2 text-sm"
                        style={{ color: 'var(--muted)' }}
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 0.6, delay: 1 }}
                      >
                        Project: <span style={{ color: 'var(--accent)' }} className="font-medium">{t.project}</span>
                      </motion.div>
                    </motion.div>
                  </div>
                ))}
              </motion.div>
            </AnimatePresence>
          </div>

          <motion.button
            onClick={prev}
            style={{
              background: 'var(--accent)',
              color: 'var(--bg)'
            }}
            className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-4 md:-translate-x-16 p-3 rounded-full transition duration-300"
            aria-label="Previous testimonial"
            whileHover={{
              scale: 1.1,
              boxShadow: "0 0 20px rgba(34, 197, 94, 0.5)"
            }}
            whileTap={{ scale: 0.9 }}
          >
            <ChevronLeft size={24} />
          </motion.button>

          <motion.button
            onClick={next}
            style={{
              background: 'var(--accent)',
              color: 'var(--bg)'
            }}
            className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-4 md:translate-x-16 p-3 rounded-full transition duration-300"
            aria-label="Next testimonial"
            whileHover={{
              scale: 1.1,
              boxShadow: "0 0 20px rgba(34, 197, 94, 0.5)"
            }}
            whileTap={{ scale: 0.9 }}
          >
            <ChevronRight size={24} />
          </motion.button>
        </div>

        <motion.div
          className="flex justify-center gap-3 mt-8"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
        >
          {testimonials.map((_, index) => (
            <motion.button
              key={index}
              onClick={() => goTo(index)}
              className="rounded-full transition-all duration-300"
              style={{
                background: index === currentIndex ? 'var(--accent)' : 'var(--muted)',
                width: index === currentIndex ? '32px' : '12px',
                height: '12px'
              }}
              aria-label={`Go to testimonial ${index + 1}`}
              whileHover={{ scale: 1.2 }}
              whileTap={{ scale: 0.8 }}
            />
          ))}
        </motion.div>

        <motion.div
          className="text-center mt-12"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.5 }}
        >
          <motion.a
            href="#projects"
            style={{
              background: 'var(--accent)',
              color: 'var(--bg)'
            }}
            className="inline-flex items-center gap-2 px-8 py-4 rounded-lg transition duration-300 text-lg"
            whileHover={{
              scale: 1.05,
              boxShadow: "0 0 25px rgba(34, 197, 94, 0.6)"
            }}
            whileTap={{ scale: 0.95 }}
          >
            See More Works
            <ExternalLink size={20} />
          </motion.a>
        </motion.div>
      </div>

      {/* Submission Modal */}
      <AnimatePresence>
        {isModalOpen && (
          <motion.div
            className="fixed inset-0 flex items-center justify-center p-4 z-50"
            style={{
              background: 'rgba(0, 0, 0, 0.9)',
              backdropFilter: 'blur(4px)'
            }}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
          <div className="max-w-lg w-full rounded-2xl overflow-hidden shadow-2xl" style={{
            background: 'var(--bg)',
            border: '1px solid var(--muted)'
          }}>
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6" style={{ borderBottom: '1px solid var(--muted)' }}>
              <div>
                <h3 style={{ color: 'var(--text)' }} className="text-2xl font-bold mb-1">Share Your Experience</h3>
                <p style={{ color: 'var(--muted)' }} className="text-sm">Your feedback helps us grow</p>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-2 rounded-lg hover:opacity-80 transition-all"
                style={{ color: 'var(--muted)' }}
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Content */}
            <form onSubmit={handleFormSubmit} className="p-6 space-y-5 max-h-[70vh] overflow-y-auto">
              {/* Name Field */}
              <div>
                <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                  Full Name
                </label>
                <input
                  style={{
                    background: 'var(--bg)',
                    color: 'var(--text)',
                    border: '1px solid var(--muted)'
                  }}
                  className="w-full rounded-lg py-3 px-4 placeholder-current focus:outline-none focus:border-current transition-all"
                  placeholder="John Doe"
                  required
                  value={formData.name}
                  onChange={e => setFormData({...formData, name: e.target.value})}
                />
              </div>

              {/* Role & Company Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                    Role
                  </label>
                  <input
                    style={{
                      background: 'var(--bg)',
                      color: 'var(--text)',
                      border: '1px solid var(--muted)'
                    }}
                    className="w-full rounded-lg py-3 px-4 placeholder-current focus:outline-none focus:border-current transition-all"
                    placeholder="CEO, CTO, etc."
                    required
                    value={formData.role}
                    onChange={e => setFormData({...formData, role: e.target.value})}
                  />
                </div>
                <div>
                  <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                    Company
                  </label>
                  <input
                    style={{
                      background: 'var(--bg)',
                      color: 'var(--text)',
                      border: '1px solid var(--muted)'
                    }}
                    className="w-full rounded-lg py-3 px-4 placeholder-current focus:outline-none focus:border-current transition-all"
                    placeholder="Your Company"
                    required
                    value={formData.company}
                    onChange={e => setFormData({...formData, company: e.target.value})}
                  />
                </div>
              </div>

              {/* Phone & Project Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                    Phone Number
                  </label>
                  <input
                    style={{
                      background: 'var(--bg)',
                      color: 'var(--text)',
                      border: '1px solid var(--muted)'
                    }}
                    className="w-full rounded-lg py-3 px-4 placeholder-current focus:outline-none focus:border-current transition-all"
                    placeholder="+1 234 567 8900"
                    required
                    value={formData.phone}
                    onChange={e => setFormData({...formData, phone: e.target.value})}
                  />
                </div>
                <div>
                  <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                    Project Name
                  </label>
                  <input
                    style={{
                      background: 'var(--bg)',
                      color: 'var(--text)',
                      border: '1px solid var(--muted)'
                    }}
                    className="w-full rounded-lg py-3 px-4 placeholder-current focus:outline-none focus:border-current transition-all"
                    placeholder="Project you worked on"
                    required
                    value={formData.project}
                    onChange={e => setFormData({...formData, project: e.target.value})}
                  />
                </div>
              </div>

              {/* File Upload */}
              <div>
                <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                  Your Photo
                </label>
                <div className="relative">
                  <input
                    type="file"
                    accept="image/*"
                    required
                    style={{
                      background: 'var(--bg)',
                      color: 'var(--text)',
                      border: '1px solid var(--muted)'
                    }}
                    className="w-full rounded-lg py-3 px-4 focus:outline-none focus:border-current transition-all"
                    onChange={e => setFormData({...formData, imageFile: e.target.files[0]})}
                  />
                </div>
                <p style={{ color: 'var(--muted)' }} className="text-xs mt-2">Upload a professional photo (JPG, PNG)</p>
              </div>

              {/* Feedback Textarea */}
              <div>
                <label style={{ color: 'var(--muted)' }} className="block text-sm font-medium mb-2 uppercase tracking-wide">
                  Your Feedback
                </label>
                <textarea
                  style={{
                    background: 'var(--bg)',
                    color: 'var(--text)',
                    border: '1px solid var(--muted)'
                  }}
                  className="w-full rounded-lg py-3 px-4 placeholder-current focus:outline-none focus:border-current transition-all min-h-[120px]"
                  placeholder="Share your experience working with us..."
                  required
                  value={formData.text}
                  onChange={e => setFormData({...formData, text: e.target.value})}
                  rows={4}
                />
              </div>
            </form>

            {/* Modal Footer */}
            <div className="flex items-center justify-end gap-3 p-6" style={{
              borderTop: '1px solid var(--muted)',
              background: 'var(--bg)'
            }}>
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="px-6 py-2.5 rounded-lg hover:opacity-80 transition-all"
                style={{
                  background: 'var(--bg)',
                  color: 'var(--text)',
                  border: '1px solid var(--muted)'
                }}
              >
                Cancel
              </button>
              <button
                type="submit"
                onClick={handleFormSubmit}
                style={{
                  background: 'var(--accent)',
                  color: 'var(--bg)'
                }}
                className="px-6 py-2.5 rounded-lg hover:opacity-90 font-semibold transition-all"
              >
                Submit Testimonial
              </button>
            </div>
          </div>
          </motion.div>
      )}
      </AnimatePresence>

      <ConfirmModal
        isOpen={isConfirmOpen}
        onClose={() => setIsConfirmOpen(false)}
        onConfirm={handleConfirmAction}
        title="Submit Testimonial"
        message="Are you sure you want to submit this testimonial?"
        confirmText="Submit"
        cancelText="Cancel"
      />

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
