import { FileText, Linkedin, Mail } from "lucide-react";
import { useParallax } from "../../Hooks/useParallax";

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

const itemVariants = {
  hidden: { opacity: 0, y: 30 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  }
};

const slideInLeftVariants = {
  hidden: { opacity: 0, x: -50 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  }
};

const slideInRightVariants = {
  hidden: { opacity: 0, x: 50 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  }
};

export default function CtaSection() {
  const backgroundParallax = useParallax(0.4);
  return (
    <motion.div
      className="py-20 px-6 flex items-center justify-center relative overflow-hidden"
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
      {/* Parallax Background Elements */}
      <motion.div
        className="absolute inset-0 opacity-30"
        style={{
          background: `
            radial-gradient(600px 300px at 20% 20%, rgba(34, 197, 94, 0.05), transparent 70%),
            radial-gradient(500px 250px at 80% 80%, rgba(56, 189, 248, 0.04), transparent 65%)
          `,
          transform: backgroundParallax.transform
        }}
        animate={{
          scale: [1, 1.1, 1],
          opacity: [0.3, 0.4, 0.3]
        }}
        transition={{
          duration: 8,
          repeat: Infinity,
          ease: "easeInOut"
        }}
      />

      <div className="max-w-6xl w-full relative z-10">
        <motion.div
          className="rounded-3xl p-8 md:p-12 lg:p-14"
          style={{
            background: 'var(--bg)',
            border: '1px solid var(--muted)'
          }}
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          whileHover={{
            boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.25)"
          }}
        >
          <div className="grid gap-10 lg:grid-cols-[1.1fr_0.9fr] items-center">
            <motion.div
              variants={slideInLeftVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.3 }}
            >
              <motion.h2
                style={{ color: 'var(--accent)' }}
                className="text-xl md:text-2xl font-medium mb-3"
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.2 }}
              >
                Collaboration
              </motion.h2>
              <motion.h3
                style={{ color: 'var(--text)' }}
                className="text-4xl md:text-6xl font-semibold mb-6"
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 0.4 }}
              >
                Let's build a product your team is proud to ship.
              </motion.h3>
              <motion.p
                style={{ color: 'var(--muted)' }}
                className="text-lg leading-relaxed max-w-2xl"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 0.6 }}
              >
                I partner with teams to deliver production-grade web experiences
                with clear scopes, reliable execution, and measurable outcomes.
                If you're hiring or need a product-focused engineer, let's talk.
              </motion.p>
            </motion.div>

            <motion.div
              className="space-y-6"
              variants={slideInRightVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.3 }}
            >
              <motion.div
                className="grid gap-3"
                variants={containerVariants}
                initial="hidden"
                whileInView="visible"
                viewport={{ once: true }}
              >
                <motion.div
                  className="flex items-center justify-between rounded-lg px-4 py-3 text-sm"
                  style={{
                    background: 'var(--bg)',
                    color: 'var(--text)',
                    border: '1px solid var(--muted)'
                  }}
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.02,
                    boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)"
                  }}
                  transition={{ duration: 0.3 }}
                >
                  <span>Availability</span>
                  <motion.span
                    style={{ color: 'var(--accent)' }}
                    className="font-semibold"
                    animate={{ scale: [1, 1.1, 1] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  >
                    Open
                  </motion.span>
                </motion.div>
                <motion.div
                  className="flex items-center justify-between rounded-lg px-4 py-3 text-sm"
                  style={{
                    background: 'var(--bg)',
                    color: 'var(--text)',
                    border: '1px solid var(--muted)'
                  }}
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.02,
                    boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)"
                  }}
                  transition={{ duration: 0.3 }}
                >
                  <span>Location</span>
                  <span style={{ color: 'var(--text)' }} className="font-medium">Remote / Hybrid</span>
                </motion.div>
                <motion.div
                  className="flex items-center justify-between rounded-lg px-4 py-3 text-sm"
                  style={{
                    background: 'var(--bg)',
                    color: 'var(--text)',
                    border: '1px solid var(--muted)'
                  }}
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.02,
                    boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)"
                  }}
                  transition={{ duration: 0.3 }}
                >
                  <span>Response time</span>
                  <span style={{ color: 'var(--text)' }} className="font-medium">24–48 hrs</span>
                </motion.div>
              </motion.div>

              <motion.div
                className="flex flex-wrap gap-3"
                variants={containerVariants}
                initial="hidden"
                whileInView="visible"
                viewport={{ once: true }}
              >
                <motion.a
                  href="mailto:your.email@example.com"
                  style={{
                    background: 'var(--accent)',
                    color: 'var(--bg)'
                  }}
                  className="flex items-center gap-3 font-semibold px-6 py-3 rounded-full transition-all duration-300 shadow-lg shadow-current/25"
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.05,
                    boxShadow: "0 0 25px rgba(34, 197, 94, 0.6)"
                  }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Mail size={20} />
                  Start a Conversation
                </motion.a>

                <motion.a
                  href="https://linkedin.com/in/yourprofile"
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{
                    background: 'var(--text)',
                    color: 'var(--bg)'
                  }}
                  className="flex items-center gap-3 font-semibold px-6 py-3 rounded-full transition-all duration-300 shadow-lg shadow-current/25"
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.05,
                    boxShadow: "0 0 25px rgba(0, 0, 0, 0.6)"
                  }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Linkedin size={20} />
                  LinkedIn
                </motion.a>

                <motion.a
                  href="/resume.pdf"
                  download
                  style={{
                    background: 'var(--bg)',
                    color: 'var(--text)',
                    border: '1px solid var(--muted)'
                  }}
                  className="flex items-center gap-3 font-semibold px-6 py-3 rounded-full transition-all duration-300 shadow-lg shadow-slate-900/25"
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.05,
                    boxShadow: "0 4px 20px rgba(0, 0, 0, 0.2)"
                  }}
                  whileTap={{ scale: 0.95 }}
                >
                  <FileText size={20} />
                  Resume
                </motion.a>
              </motion.div>
            </motion.div>
          </div>

          <motion.div
            style={{ borderTop: '1px solid var(--muted)' }}
            className="mt-10 pt-8"
            initial={{ scaleX: 0 }}
            whileInView={{ scaleX: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.5 }}
          />
        </motion.div>
      </div>
    </motion.div>
  );
}
