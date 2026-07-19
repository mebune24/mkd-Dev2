import { motion } from 'framer-motion';
import { useParallax } from "../../Hooks/useParallax";

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
    rotateX: 5,
    transition: {
      duration: 0.3
    }
  }
};

const nodeVariants = {
  hidden: { scale: 0, opacity: 0 },
  visible: {
    scale: 1,
    opacity: 1,
    transition: {
      duration: 0.5,
      delay: 0.2
    }
  }
};

export default function Journey() {
  const trunkParallax = useParallax(0.2);
  const nodesParallax = useParallax(-0.1);

  return (
    <motion.div
      className="min-h-screen w-full flex flex-col items-center justify-center py-20 px-6"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 1 }}
    >
      <div className="max-w-4xl mx-auto w-full">
        <motion.div
          className="mb-12 text-center flex flex-col items-center"
          initial={{ opacity: 0, y: -30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <span className="inline-flex items-center gap-2 text-xs uppercase tracking-[0.35em] text-emerald-400 font-semibold justify-center">
            <motion.span
              className="w-2 h-2 rounded-full bg-emerald-400"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            My Journey
          </span>
          <h3 style={{ color: 'var(--text)' }} className="mt-4 text-3xl font-bold text-center">Career Growth Architecture</h3>
          <p style={{ color: 'var(--muted)' }} className="mt-2 text-sm text-center max-w-2xl">A structured pathway connecting education and hands-on technical delivery</p>
        </motion.div>

        {/* Tree Structure */}
        <div className="relative w-full">
          {/* Main trunk line */}
          <motion.div
            className="absolute inset-y-0 left-1/2 w-px bg-gradient-to-b from-emerald-500/20 via-cyan-500/20 to-slate-400/20 transform -translate-x-1/2"
            style={{ transform: `translateX(-50%) ${trunkParallax.transform}` }}
            initial={{ scaleY: 0 }}
            whileInView={{ scaleY: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 1.5, delay: 0.5 }}
          />

          <div className="space-y-12">
            {/* Level 1: Secondary School */}
            <motion.div
              className="flex items-center justify-center relative"
              variants={cardVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.3 }}
            >
              <motion.div
                className="absolute -left-3 w-6 h-6 rounded-full bg-emerald-400/20 border-2 border-emerald-400"
                style={nodesParallax}
                variants={nodeVariants}
                whileHover={{ scale: 1.2, boxShadow: "0 0 20px rgba(52, 211, 153, 0.5)" }}
              />
              <motion.div
                className="max-w-sm mx-auto"
                variants={cardVariants}
                whileHover="hover"
                style={{ perspective: "1000px" }}
              >
                <motion.div
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-950/30 backdrop-blur-sm p-6 text-center shadow-lg shadow-emerald-500/5 hover:border-emerald-500/50 transition-all duration-300"
                  whileHover={{
                    boxShadow: "0 25px 50px -12px rgba(52, 211, 153, 0.25)",
                    transform: "translateY(-5px)"
                  }}
                >
                  <p className="text-xs uppercase tracking-[0.35em] text-emerald-300 font-semibold">2022 – 2023</p>
                  <h4 style={{ color: 'var(--text)' }} className="mt-3 text-lg font-bold">Secondary School</h4>
                  <p style={{ color: 'var(--muted)' }} className="mt-1 text-xs font-semibold text-emerald-400">General Education Award</p>
                  <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs leading-5">
                    Foundation in problem solving and technology-driven studies
                  </p>
                  <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs font-semibold text-cyan-300">
                    Grade: GCE Advanced Level /GCE Ordinary Level
                  </p>
                </motion.div>
              </motion.div>
              <motion.div
                className="absolute -right-3 w-6 h-6 rounded-full bg-emerald-400/20 border-2 border-emerald-400"
                style={nodesParallax}
                variants={nodeVariants}
                whileHover={{ scale: 1.2, boxShadow: "0 0 20px rgba(52, 211, 153, 0.5)" }}
              />
            </motion.div>

            {/* Branch connector to University */}
            <motion.div
              className="flex justify-center"
              initial={{ scaleY: 0 }}
              whileInView={{ scaleY: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: 0.3 }}
            >
              <div className="relative h-8 w-px bg-gradient-to-b from-emerald-400/30 to-cyan-400/30" />
            </motion.div>

            {/* Level 2: University & HND Split */}
            <motion.div
              className="grid grid-cols-2 gap-8 relative"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, staggerChildren: 0.2 }}
            >
              {/* Left branch - University */}
              <motion.div
                className="flex flex-col items-center"
                variants={cardVariants}
              >
                {/* Branch line */}
                <motion.div
                  className="absolute -top-8 left-1/2 h-8 border-l-2 border-b-2 border-cyan-400/30 transform -translate-x-1/2 w-32"
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.8 }}
                />

                <div className="w-full">
                  <motion.div
                    className="relative flex justify-center mb-4"
                    variants={nodeVariants}
                  >
                    <motion.div
                      className="w-6 h-6 rounded-full bg-cyan-400/20 border-2 border-cyan-400"
                      style={nodesParallax}
                      whileHover={{ scale: 1.3, boxShadow: "0 0 25px rgba(34, 211, 238, 0.6)" }}
                    />
                  </motion.div>
                  <motion.div
                    className="rounded-2xl border border-cyan-500/30 bg-cyan-950/30 backdrop-blur-sm p-6 text-center shadow-lg shadow-cyan-500/5 hover:border-cyan-500/50 transition-all duration-300"
                    variants={cardVariants}
                    whileHover={{
                      scale: 1.05,
                      rotateY: 5,
                      boxShadow: "0 25px 50px -12px rgba(34, 211, 238, 0.25)",
                      transform: "translateY(-5px)"
                    }}
                    style={{ perspective: "1000px" }}
                  >
                    <p className="text-xs uppercase tracking-[0.35em] text-cyan-300 font-semibold">2023-2024</p>
                    <h4 style={{ color: 'var(--text)' }} className="mt-3 text-lg font-bold">University Year-1</h4>
                    <p style={{ color: 'var(--muted)' }} className="mt-1 text-xs font-semibold text-cyan-400">Introduction to Computer Engineering</p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs font-semibold text-cyan-300">Field:Software Engineering</p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs leading-5">
                      Modern web development and system architecture fundamentals
                    </p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs font-semibold text-cyan-300">
                      Gpa:3.0/5.0
                    </p>
                  </motion.div>
                </div>
              </motion.div>

              {/* Right branch - HND */}
              <motion.div
                className="flex flex-col items-center"
                variants={cardVariants}
              >
                {/* Branch line */}
                <motion.div
                  className="absolute -top-8 right-1/2 h-8 border-r-2 border-b-2 border-cyan-400/30 transform translate-x-1/2 w-32"
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.8 }}
                />

                <div className="w-full">
                  <motion.div
                    className="relative flex justify-center mb-4"
                    variants={nodeVariants}
                  >
                    <motion.div
                      className="w-6 h-6 rounded-full bg-cyan-400/20 border-2 border-cyan-400"
                      style={nodesParallax}
                      whileHover={{ scale: 1.3, boxShadow: "0 0 25px rgba(34, 211, 238, 0.6)" }}
                    />
                  </motion.div>
                  <motion.div
                    className="rounded-2xl border border-cyan-500/30 bg-cyan-950/30 backdrop-blur-sm p-6 text-center shadow-lg shadow-cyan-500/5 hover:border-cyan-500/50 transition-all duration-300"
                    variants={cardVariants}
                    whileHover={{
                      scale: 1.05,
                      rotateY: -5,
                      boxShadow: "0 25px 50px -12px rgba(34, 211, 238, 0.25)",
                      transform: "translateY(-5px)"
                    }}
                    style={{ perspective: "1000px" }}
                  >
                    <p className="text-xs uppercase tracking-[0.35em] text-cyan-300 font-semibold">Completed</p>
                    <h4 style={{ color: 'var(--text)' }} className="mt-3 text-lg font-bold">HND-Year 2 </h4>
                    <p style={{ color: 'var(--muted)' }} className="mt-1 text-xs font-semibold text-cyan-400">Higher National Diploma</p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs leading-5">
                      Advanced technical certification in computing
                    </p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs font-semibold text-cyan-300">
                      Grade: Lower-Credit
                    </p>
                  </motion.div>
                </div>
              </motion.div>

              {/* Converging lines from both branches */}
              <motion.div
                className="absolute bottom-0 left-1/2 h-8 transform -translate-x-1/2"
                initial={{ scaleX: 0 }}
                whileInView={{ scaleX: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 0.5 }}
              >
                <div className="flex h-full">
                  <div className="border-b-2 border-l-2 border-slate-400/30" style={{ width: '50%' }} />
                  <div className="border-b-2 border-r-2 border-slate-400/30" style={{ width: '50%' }} />
                </div>
              </motion.div>
            </motion.div>

            {/* Branch connector to Fibre Optics */}
            <motion.div
              className="flex justify-center"
              initial={{ scaleY: 0 }}
              whileInView={{ scaleY: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: 0.3 }}
            >
              <div className="relative h-8 w-px bg-gradient-to-b from-cyan-400/30 to-slate-400/30" />
            </motion.div>

            {/* Level 3: Fibre Optics Technician & Business School Split */}
            <motion.div
              className="grid grid-cols-2 gap-8 relative"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, staggerChildren: 0.3 }}
            >
              {/* Left branch - Fibre Optics */}
              <motion.div
                className="flex flex-col items-center"
                variants={cardVariants}
              >
                {/* Branch line */}
                <motion.div
                  className="absolute -top-8 left-1/2 h-8 border-l-2 border-b-2 border-slate-400/30 transform -translate-x-1/2 w-32"
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.8 }}
                />

                <div className="w-full">
                  <motion.div
                    className="relative flex justify-center mb-4"
                    variants={nodeVariants}
                  >
                    <motion.div
                      className="w-6 h-6 rounded-full bg-slate-400/20 border-2 border-slate-400"
                      style={nodesParallax}
                      whileHover={{ scale: 1.3, boxShadow: "0 0 25px rgba(148, 163, 184, 0.6)" }}
                    />
                  </motion.div>
                  <motion.div
                    className="rounded-2xl border border-slate-400/30 bg-slate-950/30 backdrop-blur-sm p-6 text-center shadow-lg shadow-slate-400/5 hover:border-slate-400/50 transition-all duration-300"
                    variants={cardVariants}
                    whileHover={{
                      scale: 1.05,
                      rotateY: 5,
                      boxShadow: "0 25px 50px -12px rgba(148, 163, 184, 0.25)",
                      transform: "translateY(-5px)"
                    }}
                    style={{ perspective: "1000px" }}
                  >
                    <p className="text-xs uppercase tracking-[0.35em] text-slate-300 font-semibold">Present</p>
                    <h4 style={{ color: 'var(--text)' }} className="mt-3 text-lg font-bold">Fibre Optics Technician</h4>
                    <p style={{ color: 'var(--muted)' }} className="mt-1 text-xs font-semibold text-slate-400">Professional Certification </p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs font-semibold text-slate-300">Camtel</p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs leading-5">
                      OLT, ONT, Wi-Fi configuration · Fibre network installation & management
                    </p>
                  </motion.div>
                </div>
              </motion.div>

              {/* Right branch - Yaounde International Business School - Software Engineering */}
              <motion.div
                className="flex flex-col items-center"
                variants={cardVariants}
              >
                {/* Branch line */}
                <motion.div
                  className="absolute -top-8 right-1/2 h-8 border-r-2 border-b-2 border-blue-400/30 transform translate-x-1/2 w-32"
                  initial={{ pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.8 }}
                />

                <div className="w-full">
                  <motion.div
                    className="relative flex justify-center mb-4"
                    variants={nodeVariants}
                  >
                    <motion.div
                      className="w-6 h-6 rounded-full bg-blue-400/20 border-2 border-blue-400"
                      style={nodesParallax}
                      whileHover={{ scale: 1.3, boxShadow: "0 0 25px rgba(59, 130, 246, 0.6)" }}
                    />
                  </motion.div>
                  <motion.div
                    className="rounded-2xl border border-blue-500/50 bg-gradient-to-br from-blue-950/40 to-cyan-950/40 backdrop-blur-sm p-6 text-center shadow-lg shadow-blue-500/10 hover:border-blue-400/70 transition-all duration-300"
                    variants={cardVariants}
                    whileHover={{
                      scale: 1.05,
                      rotateY: -5,
                      boxShadow: "0 25px 50px -12px rgba(59, 130, 246, 0.25)",
                      transform: "translateY(-5px)"
                    }}
                    style={{ perspective: "1000px" }}
                  >
                    <p className="text-xs uppercase tracking-[0.35em] text-blue-300 font-semibold">Present</p>
                    <h4 style={{ color: 'var(--text)' }} className="mt-3 text-lg font-bold">Software Engineering</h4>
                    <p style={{ color: 'var(--muted)' }} className="mt-1 text-xs font-semibold text-blue-400">Bachelor's Degree</p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs font-semibold text-blue-300">Yaounde International Business School</p>
                    <p style={{ color: 'var(--muted)' }} className="mt-2 text-xs leading-5">
                      Advanced software development and enterprise architecture
                    </p>
                  </motion.div>
                </div>
              </motion.div>

              {/* Converging lines from both branches */}
              <motion.div
                className="absolute bottom-0 left-1/2 h-8 transform -translate-x-1/2"
                initial={{ scaleX: 0 }}
                whileInView={{ scaleX: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 0.5 }}
              >
                <div className="flex h-full">
                  <div className="border-b-2 border-l-2 border-slate-400/30" style={{ width: '50%' }} />
                  <div className="border-b-2 border-r-2 border-slate-400/30" style={{ width: '50%' }} />
                </div>
              </motion.div>
            </motion.div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}
