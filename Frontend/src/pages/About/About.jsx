import { motion } from 'framer-motion';
import syfer from "../../components/images/mebune.jpg";

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

const imageVariants = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: {
    opacity: 1,
    scale: 1,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  },
  hover: {
    scale: 1.05,
    rotateY: 5,
    transition: { duration: 0.3 }
  }
};

export default function About() {
  return (
    <motion.div
      className="min-h-screen py-20 px-6 relative overflow-hidden"
      style={{
        background: `
          radial-gradient(900px 500px at 10% -10%, rgba(34, 197, 94, 0.15), transparent 60%),
          radial-gradient(700px 400px at 90% -5%, rgba(56, 189, 248, 0.12), transparent 55%),
          var(--bg)
        `
      }}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 1 }}
    >
      <div className="max-w-7xl mx-auto relative">
        {/* Hero Section */}
        <motion.div
          className="text-center mb-20"
          initial={{ opacity: 0, y: -30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <motion.div
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-500/10 mb-6"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.2 }}
            whileHover={{ scale: 1.05 }}
          >
            <motion.div
              className="w-2 h-2 rounded-full bg-emerald-400"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
            />
            <span style={{ color: 'var(--accent)' }} className="text-sm font-medium">Company-ready profile</span>
          </motion.div>
          <motion.h1
            className="text-5xl md:text-7xl font-bold mb-6 leading-tight"
            style={{ color: 'var(--text)' }}
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            About
            <motion.span
              className="block"
              style={{
                background: 'linear-gradient(135deg, var(--accent) 0%, #38bdf8 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text'
              }}
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: 0.6 }}
            >
              Mebune
            </motion.span>
          </motion.h1>
          <motion.div
            className="w-24 h-1 bg-gradient-to-r from-emerald-400 to-cyan-400 mx-auto rounded-full"
            initial={{ scaleX: 0 }}
            whileInView={{ scaleX: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: 0.8 }}
          />
        </motion.div>

        {/* Main Content Grid */}
        <div className="grid lg:grid-cols-2 gap-16 items-start mb-20">
          {/* Left Column - Bio */}
          <motion.div
            className="space-y-8"
            variants={slideInLeftVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.3 }}
          >
            <motion.div
              className="space-y-8"
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true }}
            >
              <motion.div
                className="rounded-[28px] border border-white/10 bg-slate-900/80 p-8 shadow-xl"
                variants={itemVariants}
                whileHover={{
                  scale: 1.02,
                  boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.25)"
                }}
                transition={{ duration: 0.3 }}
              >
                <p className="text-lg leading-8 text-slate-200">
                  I’m <span className="text-emerald-400 font-semibold">Mebune Donstand</span>, a self-taught software engineer who builds production-grade web systems with reliability, speed, and strong product focus.
                </p>
              </motion.div>

              <motion.div
                className="grid gap-4 sm:grid-cols-2"
                variants={containerVariants}
              >
                <motion.div
                  className="rounded-[28px] border border-white/10 bg-slate-900/80 p-6 shadow-lg"
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.05,
                    rotateY: 5,
                    boxShadow: "0 20px 40px -12px rgba(34, 197, 94, 0.2)"
                  }}
                  style={{ perspective: "1000px" }}
                >
                  <h4 className="text-lg font-semibold text-white mb-3">Modern full-stack delivery</h4>
                  <p className="text-sm leading-6 text-slate-300">
                    React, Next.js and Node.js solutions built for accessible, performant, and scalable products.
                  </p>
                </motion.div>
                <motion.div
                  className="rounded-[28px] border border-white/10 bg-slate-900/80 p-6 shadow-lg"
                  variants={itemVariants}
                  whileHover={{
                    scale: 1.05,
                    rotateY: -5,
                    boxShadow: "0 20px 40px -12px rgba(34, 197, 94, 0.2)"
                  }}
                  style={{ perspective: "1000px" }}
                >
                  <h4 className="text-lg font-semibold text-white mb-3">Engineering-first process</h4>
                  <p className="text-sm leading-6 text-slate-300">
                    Precise requirements, measurable milestones, and clean deployments backed by testing and strong API design.
                  </p>
                </motion.div>
              </motion.div>
            </motion.div>

            <motion.div
              className="grid md:grid-cols-2 gap-8"
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.3 }}
            >
              <motion.div
                className="group"
                variants={itemVariants}
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.3 }}
              >
                <div style={{ color: 'var(--accent)' }} className="text-xs uppercase tracking-widest mb-3 font-semibold">
                  Impact
                </div>
                <h3 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-3">
                  Business-ready systems
                </h3>
                <p style={{ color: 'var(--muted)' }} className="text-sm leading-relaxed">
                  I build systems that help teams move fast while keeping architecture clean and easy to maintain.
                </p>
              </motion.div>

              <motion.div
                className="group"
                variants={itemVariants}
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.3 }}
              >
                <div style={{ color: '#38bdf8' }} className="text-xs uppercase tracking-widest mb-3 font-semibold">
                  Experience
                </div>
                <h3 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-3">
                  Cross-functional delivery
                </h3>
                <p style={{ color: 'var(--muted)' }} className="text-sm leading-relaxed">
                  Comfortable working across product, design and engineering to translate goals into measurable outcomes.
                </p>
              </motion.div>
            </motion.div>
          </motion.div>

          {/* Right Column - Image and Details */}
          <motion.div
            className="space-y-8"
            variants={slideInRightVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.3 }}
          >
            {/* Profile Image */}
            <motion.div
              className="relative group"
              variants={imageVariants}
              whileHover="hover"
              style={{ perspective: "1000px" }}
            >
              <div className="relative overflow-hidden rounded-xl">
                <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent z-10" />
                <motion.img
                  src={syfer}
                  alt="Mebune Donstand"
                  className="w-full h-80 object-cover object-center"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.5 }}
                />
                <motion.div
                  className="absolute bottom-4 left-4 right-4"
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: 0.3 }}
                >
                  <h3 style={{ color: 'var(--text)' }} className="text-2xl font-bold">Mebune Donstand</h3>
                  <p style={{ color: 'var(--accent)' }} className="text-sm font-medium">Software Engineer</p>
                </motion.div>
              </div>
            </motion.div>

            {/* Engagement Model */}
            <motion.div
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.3 }}
            >
              <motion.h3
                style={{ color: 'var(--text)' }}
                className="text-xl font-bold mb-6 flex items-center gap-3"
                variants={itemVariants}
              >
                <motion.div
                  className="w-8 h-8 rounded-full bg-emerald-500/20 flex items-center justify-center"
                  whileHover={{ scale: 1.1, rotate: 5 }}
                >
                  <motion.div
                    className="w-3 h-3 rounded-full bg-emerald-400"
                    animate={{ scale: [1, 1.2, 1] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  />
                </motion.div>
                Engagement Model
              </motion.h3>
              <div className="space-y-4">
                {[
                  { number: "01", title: "Discovery", description: "Align goals, scope, timelines, and success metrics.", color: "emerald" },
                  { number: "02", title: "Execution", description: "Ship in iterations with clear QA and stakeholder updates.", color: "cyan" },
                  { number: "03", title: "Launch", description: "Production release, monitoring, and handoff for scale.", color: "blue" }
                ].map((item, index) => (
                  <motion.div
                    key={item.number}
                    className="flex items-start gap-4"
                    variants={itemVariants}
                    whileHover={{ scale: 1.02, x: 10 }}
                    transition={{ duration: 0.3 }}
                  >
                    <motion.div
                      className={`flex-shrink-0 w-8 h-8 rounded-full bg-${item.color}-500/20 flex items-center justify-center text-${item.color}-400 font-bold text-sm`}
                      whileHover={{ scale: 1.1, rotate: 5 }}
                      animate={{ scale: [1, 1.05, 1] }}
                      transition={{ duration: 2, repeat: Infinity, delay: index * 0.5 }}
                    >
                      {item.number}
                    </motion.div>
                    <div>
                      <h4 style={{ color: 'var(--text)' }} className="font-semibold mb-1">{item.title}</h4>
                      <p style={{ color: 'var(--muted)' }} className="text-sm">{item.description}</p>
                    </div>
                  </motion.div>
                ))}
              </div>
            </motion.div>
          </motion.div>
        </div>

        {/* Core Stack Section */}
        <motion.div
          className="text-center"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <motion.h2
            style={{ color: 'var(--text)' }}
            className="text-3xl md:text-4xl font-bold mb-12"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            Core <motion.span
              style={{
                background: 'linear-gradient(135deg, var(--accent) 0%, #38bdf8 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text'
              }}
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              Stack
            </motion.span>
          </motion.h2>
          <motion.div
            className="flex flex-wrap justify-center gap-6 max-w-4xl mx-auto"
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
          >
            {[
              { name: 'React', hoverColor: '#3b82f6' },
              { name: 'Next.js', hoverColor: '#9ca3af' },
              { name: 'Node.js', hoverColor: '#10b981' },
              { name: 'TypeScript', hoverColor: '#2563eb' },
              { name: 'PostgreSQL', hoverColor: '#3b82f6' }
            ].map((tech, index) => (
              <motion.div
                key={tech.name}
                variants={itemVariants}
                whileHover={{
                  scale: 1.1,
                  color: tech.hoverColor,
                  textShadow: `0 0 10px ${tech.hoverColor}50`
                }}
                transition={{ duration: 0.3 }}
              >
                <span
                  style={{ color: 'var(--text)' }}
                  className="text-lg font-semibold cursor-default"
                >
                  {tech.name}
                </span>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>
      </div>
    </motion.div>
  );
}
