import { motion } from "framer-motion";
import { UserPlus } from "lucide-react";
import { useProfile } from "../../Hooks/useProfile";
import aboutImg from "../images/mebune.jpg";

const fadeInUp = {
  hidden: { opacity: 0, y: 30 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.7,
      delay: i * 0.1,
      ease: "easeOut"
    }
  })
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

export default function AboutMe() {
  const { profile } = useProfile();
  return (
    <div className="min-h-screen py-20 px-6 relative overflow-hidden" style={{
      background: `
        radial-gradient(900px 500px at 10% -10%, rgba(34, 197, 94, 0.15), transparent 60%),
        radial-gradient(700px 400px at 90% -5%, rgba(56, 189, 248, 0.12), transparent 55%),
        var(--bg)
      `
    }}>
      <div className="max-w-5xl mx-auto relative">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-500/10 mb-6 border border-emerald-500/20">
            <div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span style={{ color: 'var(--accent)' }} className="text-sm font-medium">Available for software roles</span>
          </div>

          <h1 className="text-4xl md:text-6xl font-bold mb-4 leading-tight" style={{ color: 'var(--text)' }}>
            Hey there, I'm
          </h1>
          <h2 className="text-3xl md:text-5xl font-bold mb-6" style={{
            background: 'linear-gradient(135deg, var(--accent) 0%, #38bdf8 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            backgroundClip: 'text'
          }}>
            {profile?.name || 'Mebune Donstand'}
          </h2>
          <p className="text-xl md:text-2xl mb-8" style={{ color: 'var(--muted)' }}>
            {profile?.title || 'Software Engineer'} · {profile?.subtitle || 'Frontend & Full-Stack'}
          </p>
          <p className="text-lg max-w-3xl mx-auto leading-relaxed" style={{ color: 'var(--text)' }}>
            I deliver production-grade web products for teams and businesses, balancing UX clarity with scalable architecture.
            Expect clean systems, reliable releases, and measurable outcomes.
          </p>
        </div>

        {/* Profile Header - GitHub Style */}
        <motion.div
          className="mb-12"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
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
                  src={aboutImg}
                  alt="Mebune Donstand"
                  className="w-full h-full object-cover object-center"
                />
              </div>
              <div className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full bg-emerald-500 border-2 border-white/10 flex items-center justify-center">
                <div className="w-2 h-2 rounded-full bg-white" />
              </div>
            </motion.div>
            <div className="flex-1">
              <h2 style={{ color: 'var(--text)' }} className="text-2xl md:text-3xl font-bold mb-2">{profile?.name || 'Mebune Donstand'}</h2>
              <p style={{ color: 'var(--accent)' }} className="text-base md:text-lg font-medium mb-3">{profile?.title || 'Software Engineer'} · {profile?.subtitle || 'Frontend & Full-Stack'}</p>
              <p style={{ color: 'var(--muted)' }} className="text-sm md:text-base leading-relaxed mb-4">
                {profile?.bio || 'a self-taught software engineer who builds production-grade web systems for companies that care about reliability and speed. I operate comfortably across product, design, and engineering to ship outcomes that move business metrics.'}
              </p>
              <div className="flex flex-wrap gap-2">
                {['React', 'Next.js', 'Node.js', 'TypeScript', 'PostgreSQL', 'Tailwind'].map((tech) => (
                  <span
                    key={tech}
                    className="px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-medium"
                  >
                    {tech}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </motion.div>

        {/* Main Content Grid */}
        <div className="space-y-12 mb-20">
          {/* About Section */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            <h3 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-4 flex items-center gap-2">
              <span style={{ color: 'var(--accent)' }}>#</span> About
            </h3>
            <div className="space-y-4 text-sm md:text-base leading-relaxed" style={{ color: 'var(--muted)' }}>
              <p>
                I specialize in modern frontend and full-stack delivery with React, Next.js, and Node.js, with a strong emphasis on system design, accessibility, and performance. My work focuses on scalable architecture, clear component contracts, and maintainable codebases that teams can evolve safely.
              </p>
              <p>
                My approach is engineering-first: precise requirements, measurable milestones, and clean deployments. I prioritize quality through testing, thoughtful APIs, and consistent code standards, while keeping user experience fast, focused, and intuitive.
              </p>
            </div>
          </motion.div>

          {/* Delivery Snapshot */}
          <div>
            <h4 className="text-xl font-bold mb-6" style={{ color: 'var(--text)' }}>Delivery Snapshot</h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {[
                {
                  icon: "🎯",
                  title: "Structured Scoping",
                  desc: "Clear requirements alignment and scope definition"
                },
                {
                  icon: "⚡",
                  title: "Performance First",
                  desc: "Engineering focused on accessibility and speed"
                },
                {
                  icon: "🛡️",
                  title: "Reliable Releases",
                  desc: "Clean, maintainable code with reliable delivery"
                },
                {
                  icon: "🤝",
                  title: "Cross-functional",
                  desc: "Collaboration across product and design teams"
                },
              ].map((item, index) => (
                <div
                  key={index}
                  className="p-4 rounded-2xl border border-white/10 bg-white/5 hover:bg-white/10 hover:border-emerald-400/30 transition-all duration-300 cursor-default group"
                >
                  <div className="text-2xl mb-3 group-hover:scale-110 transition-transform duration-300 inline-block">
                    {item.icon}
                  </div>
                  <h5 style={{ color: 'var(--text)' }} className="font-semibold text-sm mb-1">{item.title}</h5>
                  <p style={{ color: 'var(--muted)' }} className="text-xs leading-relaxed">{item.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Engagement Model - Ellipse Horizontal */}
        <motion.div
          className="mb-20"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h3 style={{ color: 'var(--text)' }} className="text-2xl font-bold mb-12 text-center">
            <span style={{ color: 'var(--accent)' }}>#</span> Engagement Model
          </h3>

          {/* Ellipse Container */}
          <div className="relative max-w-4xl mx-auto">
            {/* Elliptical Path SVG */}
            <svg className="absolute inset-0 w-full h-full hidden md:block" viewBox="0 0 800 200" fill="none" xmlns="http://www.w3.org/2000/svg">
              <ellipse cx="400" cy="100" rx="350" ry="80" stroke="url(#engagementGradient2)" strokeWidth="2" strokeDasharray="8 4" opacity="0.5" />
              <defs>
                <linearGradient id="engagementGradient2" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#10b981" />
                  <stop offset="50%" stopColor="#06b6d4" />
                  <stop offset="100%" stopColor="#3b82f6" />
                </linearGradient>
              </defs>
            </svg>

            {/* Nodes */}
            <div className="flex flex-col md:flex-row items-center justify-center gap-8 md:gap-4 relative">
              {[
                { number: "01", title: "Discovery", description: "Align goals, scope, timelines, and success metrics.", color: "emerald", icon: "🎯" },
                { number: "02", title: "Execution", description: "Ship in iterations with clear QA and stakeholder updates.", color: "cyan", icon: "⚡" },
                { number: "03", title: "Launch", description: "Production release, monitoring, and handoff for scale.", color: "blue", icon: "🚀" }
              ].map((item, index) => (
                <div key={item.number} className="flex-1 relative">
                  {/* Node */}
                  <motion.div
                    className="flex flex-col items-center text-center relative z-10"
                    initial={{ opacity: 0, scale: 0 }}
                    whileInView={{ opacity: 1, scale: 1 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.5, delay: index * 0.2 }}
                  >
                    {/* Ellipse circle background */}
                    <div className="relative mb-4">
                      <div className={`w-20 h-20 md:w-24 md:h-24 rounded-full bg-${item.color}-500/10 border-2 border-${item.color}-400/30 flex items-center justify-center mb-3 shadow-lg shadow-${item.color}-500/10`}>
                        <div className={`w-12 h-12 md:w-14 md:h-14 rounded-full bg-${item.color}-500/20 border-2 border-${item.color}-400 flex items-center justify-center text-${item.color}-400 font-bold text-sm shadow-lg shadow-${item.color}-500/20`}>
                          {item.number}
                        </div>
                      </div>
                      <div className="absolute -bottom-1 left-1/2 transform -translate-x-1/2 text-2xl">
                        {item.icon}
                      </div>
                    </div>
                    <h4 style={{ color: 'var(--text)' }} className="text-lg font-bold mb-2">{item.title}</h4>
                    <p style={{ color: 'var(--muted)' }} className="text-sm max-w-xs">
                      {item.description}
                    </p>
                  </motion.div>

                  {/* Arrow between steps */}
                  {index < 2 && (
                    <div className="hidden md:flex absolute top-1/2 -right-4 transform translate-x-1/2 -translate-y-1/2 z-20">
                      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: 'var(--accent)' }}>
                        <path d="M5 12h14M12 5l7 7-7 7"/>
                      </svg>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </motion.div>

        {/* Stats */}
        <motion.div
          className="mb-20"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <div className="flex justify-center gap-8 md:gap-16">
            <div className="text-center">
              <div style={{ color: 'var(--accent)' }} className="text-2xl font-bold">8+</div>
              <div style={{ color: 'var(--muted)' }} className="text-xs uppercase tracking-wider">GitHub Repos</div>
            </div>
            <div className="text-center">
              <div style={{ color: 'var(--accent)' }} className="text-2xl font-bold">5+</div>
              <div style={{ color: 'var(--muted)' }} className="text-xs uppercase tracking-wider">Tech Stacks</div>
            </div>
            <div className="text-center">
              <div style={{ color: 'var(--accent)' }} className="text-2xl font-bold">100%</div>
              <div style={{ color: 'var(--muted)' }} className="text-xs uppercase tracking-wider">Clean Code</div>
            </div>
          </div>
        </motion.div>

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
            className="text-2xl md:text-3xl font-bold mb-8"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8 }}
          >
            Core <span style={{
              background: 'linear-gradient(135deg, var(--accent) 0%, #38bdf8 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              backgroundClip: 'text'
            }}>Stack</span>
          </motion.h2>
          <motion.div
            className="flex flex-wrap justify-center gap-4 md:gap-6 max-w-4xl mx-auto"
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
              { name: 'PostgreSQL', hoverColor: '#3b82f6' },
              { name: 'Tailwind', hoverColor: '#06b6d4' },
              { name: 'Docker', hoverColor: '#2496ed' },
              { name: 'GitHub', hoverColor: '#8b949e' }
            ].map((tech, index) => (
              <motion.div
                key={tech.name}
                variants={fadeInUp}
                custom={index}
                whileHover={{
                  scale: 1.1,
                  color: tech.hoverColor,
                  textShadow: `0 0 10px ${tech.hoverColor}50`
                }}
                transition={{ duration: 0.3 }}
              >
                <span
                  style={{ color: 'var(--text)' }}
                  className="text-sm md:text-base font-medium cursor-default inline-block"
                >
                  {tech.name}
                </span>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* Floating Follow Button */}
        <motion.a
          href="https://github.com/mebune24"
          target="_blank"
          rel="noopener noreferrer"
          className="fixed bottom-6 right-6 z-50 inline-flex items-center justify-center gap-2 rounded-full bg-emerald-500 px-5 py-3 text-sm font-semibold text-slate-950 shadow-lg shadow-emerald-500/30 transition-all duration-200 hover:bg-emerald-400 hover:shadow-emerald-500/50"
          initial={{ opacity: 0, scale: 0, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          whileHover={{ scale: 1.05, y: -2 }}
          whileTap={{ scale: 0.95 }}
          transition={{ delay: 1, duration: 0.5 }}
        >
          <UserPlus size={16} />
          Follow
        </motion.a>
      </div>
    </div>
  );
}
