import axios from 'axios';
import { Calendar, ExternalLink } from 'lucide-react';
import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.2,
      delayChildren: 0.3
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

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.6,
      ease: "easeOut"
    }
  }
};

export default function Certificate() {
  const [certifications, setCertifications] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchCertifications = async () => {
    try {
      const response = await axios.get('http://localhost:3000/api/certifications');
      setCertifications(response.data);
    } catch (err) {
      console.error('Failed to load certifications', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCertifications();
  }, []);

  return (
    <motion.div
      className="min-h-screen bg-black py-20 px-6"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 1 }}
    >
      <div className="max-w-6xl mx-auto">
        {/* Section Title */}
        <motion.div
          className="mb-16 text-center"
          initial={{ opacity: 0, y: -30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2 className="text-green-500 text-xl md:text-2xl font-medium mb-2">
            Professional Growth
          </h2>
          <motion.h3
            className="text-white text-4xl md:text-5xl font-bold mb-4"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            Certifications
          </motion.h3>
          <motion.p
            className="text-gray-400 text-lg"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            Continuous learning and professional development.
          </motion.p>
        </motion.div>

        {loading ? (
          <motion.div
            className="text-center py-20 text-slate-400"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            Loading certifications...
          </motion.div>
        ) : certifications.length === 0 ? (
          <motion.div
            className="text-center py-20 text-slate-400"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            No certifications uploaded yet.
          </motion.div>
        ) : (
          <motion.div
            className="grid md:grid-cols-2 gap-8"
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.1 }}
          >
            {certifications.map((cert, index) => (
              <motion.div
                key={cert.id}
                className="bg-gray-900 border border-gray-800 rounded-3xl p-8 transition-all duration-300"
                variants={cardVariants}
                whileHover="hover"
                style={{ perspective: "1000px" }}
              >
                {/* Company Logo */}
                <motion.div
                  className="mb-6 flex justify-center"
                  variants={itemVariants}
                >
                  <motion.img
                    src={cert.image || cert.logo || 'https://via.placeholder.com/150'}
                    alt={`${cert.issuer} logo`}
                    className="h-16 object-contain"
                    whileHover={{
                      scale: 1.1,
                      rotate: 5
                    }}
                    transition={{ duration: 0.3 }}
                  />
                </motion.div>

                <motion.div
                  className="space-y-4 text-center"
                  variants={containerVariants}
                >
                  <motion.div variants={itemVariants}>
                    <p className="text-sm uppercase tracking-[0.3em] text-emerald-400 font-semibold mb-2">
                      {cert.issuer}
                    </p>
                    <h3 className="text-2xl font-semibold text-white">{cert.name}</h3>
                  </motion.div>

                  <motion.p
                    className="text-gray-300 text-base leading-relaxed"
                    variants={itemVariants}
                  >
                    {cert.description}
                  </motion.p>

                  <motion.div
                    className="flex items-center justify-center gap-2 text-gray-400 text-sm"
                    variants={itemVariants}
                  >
                    <Calendar size={16} />
                    <span>{cert.date}</span>
                  </motion.div>

                  <motion.div
                    className="text-center"
                    variants={itemVariants}
                  >
                    <motion.a
                      href={cert.certificateLink || cert.image || '#'}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 bg-green-500 hover:bg-green-600 text-black font-medium px-6 py-3 rounded-full transition-colors duration-300"
                      whileHover={{
                        scale: 1.05,
                        boxShadow: "0 0 20px rgba(34, 197, 94, 0.5)"
                      }}
                      whileTap={{ scale: 0.95 }}
                    >
                      View Certificate
                      <ExternalLink size={18} />
                    </motion.a>
                  </motion.div>
                </motion.div>
              </motion.div>
            ))}
          </motion.div>
        )}
      </div>
    </motion.div>
  );
}
