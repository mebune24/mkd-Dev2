import { motion } from 'framer-motion';
import { Facebook, Github, Instagram, Linkedin, Mail, MessageCircle, Target, Zap, ShieldCheck, Users } from "lucide-react";
import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useProfile } from "../../Hooks/useProfile";

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

const techItemVariants = {
  hidden: { opacity: 0, scale: 0.8 },
  visible: (index) => ({
    opacity: 1,
    scale: 1,
    transition: {
      duration: 0.5,
      delay: index * 0.1,
      ease: "easeOut"
    }
  }),
  hover: {
    scale: 1.1,
    rotateY: 10,
    z: 20,
    transition: { duration: 0.3 }
  }
};

export default function HeroSection() {
  const { profile } = useProfile();
  const [currentText, setCurrentText] = useState("");
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);

  const texts = [
    " Mebune Donstand",
    "Software Developer",
    "Graphics Designer",
    "Web Developer",
    "UI/UX Designer",
    "Fiber Optics Technician"
  ];

  useEffect(() => {
    const current = texts[currentIndex];
    const timeout = setTimeout(() => {
      if (!isDeleting) {
        // Typing effect
        setCurrentText(current.substring(0, currentText.length + 1));
        if (currentText === current) {
          setTimeout(() => setIsDeleting(true), 2000); // Pause before deleting
        }
      } else {
        // Deleting effect
        setCurrentText(current.substring(0, currentText.length - 1));
        if (currentText === "") {
          setIsDeleting(false);
          setCurrentIndex((prev) => (prev + 1) % texts.length);
        }
      }
    }, isDeleting ? 100 : 150);

    return () => clearTimeout(timeout);
  }, [currentText, currentIndex, isDeleting, texts]);



  return (
    <motion.div
      className="min-h-screen flex items-center justify-center px-6 pt-28 pb-16 relative"
      style={{
        background: `
          radial-gradient(900px 500px at 10% -10%, rgba(34, 197, 94, 0.15), transparent 60%),
          radial-gradient(700px 400px at 90% -5%, rgba(56, 189, 248, 0.12), transparent 55%),
          var(--bg)
        `
      }}
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      <div className="max-w-7xl w-full relative">
        <div className="grid gap-16 lg:grid-cols-2 items-start">
          {/* Left Column - Main Content */}
          <motion.div
            className="space-y-8"
            variants={containerVariants}
          >
            {/* Greeting */}
            <motion.div variants={itemVariants}>
              <motion.div
                className="inline-flex items-center gap-2 px-4 py-2 rounded-full mb-6 bg-emerald-500/20 border border-emerald-400/50"
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.2 }}
              >
                <motion.span
                  className="w-2 h-2 rounded-full bg-emerald-400"
                  animate={{ scale: [1, 1.2, 1] }}
                  transition={{ duration: 2, repeat: Infinity }}
                />
                <span style={{ color: '#34d399' }} className="text-sm font-medium">Available for software roles</span>
              </motion.div>

              <h2 style={{ color: 'var(--accent)' }} className="text-xl md:text-2xl font-medium mb-3">
                Hey there, I'm
              </h2>

              <motion.h1
                className="text-4xl md:text-5xl font-bold leading-tight mb-4 text-emerald-400 min-h-12 flex items-center"
                initial={{ opacity: 0, x: -50 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.8, delay: 0.5 }}
              >
                {currentText}
                <motion.span
                  className="animate-pulse text-emerald-300 ml-1"
                  animate={{ opacity: [1, 0, 1] }}
                  transition={{ duration: 1, repeat: Infinity }}
                >
                  |
                </motion.span>
              </motion.h1>

              <motion.h3
                style={{ color: 'var(--muted)' }}
                className="text-base md:text-lg font-medium mb-6"
                variants={itemVariants}
              >
                {profile?.title || 'Software Engineer'} · {profile?.subtitle || 'Frontend & Full-Stack'}
              </motion.h3>

              <motion.p
                style={{ color: 'var(--text)' }}
                className="text-sm md:text-base leading-relaxed max-w-2xl"
                variants={itemVariants}
              >
                I deliver production-grade web products for teams and businesses,
                balancing UX clarity with scalable architecture. Expect clean
                systems, reliable releases, and measurable outcomes.
              </motion.p>

              <motion.div
                className="flex flex-wrap gap-3"
                variants={itemVariants}
              >
                {[
                  { label: "Full-Stack", color: "emerald" },
                  { label: "React / Next.js", color: "cyan" },
                  { label: "Node.js", color: "emerald" },
                  { label: "TypeScript", color: "blue" },
                  { label: "PostgreSQL", color: "cyan" }
                ].map((tag) => (
                  <span
                    key={tag.label}
                    className={`px-3 py-1 rounded-full border border-${tag.color}-400/30 bg-${tag.color}-500/10 text-${tag.color}-300 text-xs font-medium`}
                  >
                    {tag.label}
                  </span>
                ))}
              </motion.div>
            </motion.div>

            {/* CTA Buttons */}
            <motion.div
              className="flex flex-wrap gap-4"
              variants={itemVariants}
            >
                <Link
                  to="/github?url=https://github.com/mebune24"
                  className="flex items-center gap-2 font-semibold px-6 py-3 rounded-full transition-all duration-300 hover:scale-105"
                  style={{
                    backgroundColor: 'var(--accent)',
                    color: 'var(--bg)'
                  }}
                >
                  <Github size={20} />
                  Visit GitHub Profile
                </Link>

                <Link
                  to="/github?url=https://github.com/mebune24?tab=repositories"
                  className="flex items-center gap-2 font-semibold px-6 py-3 rounded-full transition-all duration-300 hover:scale-105"
                  style={{
                    backgroundColor: 'var(--accent)',
                    color: 'var(--bg)'
                  }}
                >
                  <Github size={20} />
                  View All GitHub Repo
                </Link>

                <motion.a
                  href="https://www.linkedin.com/feed/"
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{
                    backgroundColor: 'var(--text)',
                    color: 'var(--bg)'
                  }}
                  className="flex items-center gap-2 font-semibold px-6 py-3 rounded-full transition-colors duration-300"
                  whileHover={{
                    scale: 1.05,
                    boxShadow: "0 0 20px rgba(255, 255, 255, 0.2)"
                  }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Linkedin size={20} />
                  LinkedIn
                </motion.a>

                <motion.a
                  href="mailto:mebunedonstand797@gmail.com"
                  style={{
                    color: 'var(--text)',
                    borderColor: 'var(--accent)'
                  }}
                  className="flex items-center gap-2 font-semibold px-6 py-3 rounded-full border transition-all duration-300"
                  whileHover={{
                    scale: 1.05,
                    borderColor: 'var(--accent)',
                    boxShadow: "0 0 20px rgba(34, 197, 94, 0.3)"
                  }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Mail size={20} />
                  Email
                </motion.a>
              </motion.div>

             {/* Social & Stats Row */}
             <motion.div
               className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4"
               variants={itemVariants}
             >
               {/* Social Icons */}
               <div className="flex items-center gap-4">
                 <span style={{ color: 'var(--muted)' }} className="text-xs uppercase tracking-wider">
                   Social
                 </span>
                 <div className="flex items-center gap-3">
                   <motion.a
                     href="https://wa.me/652856939"
                     target="_blank"
                     rel="noopener noreferrer"
                     style={{ color: 'var(--accent)' }}
                     className="p-2 hover:transition-colors"
                     aria-label="WhatsApp"
                     title="WhatsApp"
                     whileHover={{ scale: 1.2, rotate: 5 }}
                     whileTap={{ scale: 0.9 }}
                   >
                     <MessageCircle size={20} />
                   </motion.a>
                   <motion.a
                     href="https://facebook.com/YOUR_FACEBOOK_PROFILE"
                     target="_blank"
                     rel="noopener noreferrer"
                     style={{ color: 'var(--muted)' }}
                     className="p-2 hover:transition-colors"
                     aria-label="Facebook"
                     title="Facebook"
                     whileHover={{ scale: 1.2, rotate: -5 }}
                     whileTap={{ scale: 0.9 }}
                   >
                     <Facebook size={20} />
                   </motion.a>
                   <motion.a
                     href="https://instagram.com/YOUR_INSTAGRAM_PROFILE"
                     target="_blank"
                     rel="noopener noreferrer"
                     style={{ color: 'var(--muted)' }}
                     className="p-2 hover:transition-colors"
                     aria-label="Instagram"
                     title="Instagram"
                     whileHover={{ scale: 1.2, rotate: 5 }}
                     whileTap={{ scale: 0.9 }}
                   >
                     <Instagram size={20} />
                   </motion.a>
                 </div>
               </div>

               {/* Developer Stats */}
               <div className="grid grid-cols-3 gap-3">
                 {[
                   { value: "8+", label: "GitHub Repos" },
                   { value: "5+", label: "Tech Stacks" },
                   { value: "100%", label: "Clean Code" }
                 ].map((stat, idx) => (
                   <motion.div
                     key={stat.label}
                     className="text-center p-2.5 rounded-xl border border-white/10 bg-white/5"
                     whileHover={{ scale: 1.05, rotateY: 10 }}
                     transition={{ duration: 0.3 }}
                     style={{ perspective: "1000px" }}
                   >
                     <div style={{ color: 'var(--accent)' }} className="text-lg font-bold">{stat.value}</div>
                     <div style={{ color: 'var(--muted)' }} className="text-[10px]">{stat.label}</div>
                   </motion.div>
                 ))}
               </div>
             </motion.div>
          </motion.div>

          <motion.div
            className="space-y-12 flex flex-col items-center lg:items-start"
            variants={containerVariants}
          >
            {/* Delivery Snapshot */}
            <motion.div variants={itemVariants}>
              <h4 style={{ color: 'var(--text)' }} className="text-lg font-semibold mb-6">
                Delivery Snapshot
              </h4>
              <div className="grid grid-cols-2 gap-4">
                {[
                  {
                    icon: Target,
                    title: "Structured Scoping",
                    desc: "Clear requirements alignment and scope definition"
                  },
                  {
                    icon: Zap,
                    title: "Performance First",
                    desc: "Engineering focused on accessibility and speed"
                  },
                  {
                    icon: ShieldCheck,
                    title: "Reliable Releases",
                    desc: "Clean, maintainable code with reliable delivery"
                  },
                  {
                    icon: Users,
                    title: "Cross-functional",
                    desc: "Collaboration across product and design teams"
                  },
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className="p-4 rounded-2xl border border-white/10 bg-white/5 backdrop-blur-sm hover:bg-white/10 transition-all duration-300 cursor-default group"
                    whileHover={{ scale: 1.02, y: -4 }}
                    transition={{ duration: 0.2 }}
                  >
                    <div className="w-10 h-10 rounded-xl bg-emerald-500/20 flex items-center justify-center mb-3 group-hover:shadow-[0_0_20px_rgba(34,197,94,0.3)] transition-shadow duration-300">
                      <item.icon size={20} className="text-emerald-400" />
                    </div>
                    <h5 style={{ color: 'var(--text)' }} className="font-semibold text-sm mb-1">{item.title}</h5>
                    <p style={{ color: 'var(--muted)' }} className="text-xs leading-relaxed">{item.desc}</p>
                  </motion.div>
                ))}
              </div>
            </motion.div>
          </motion.div>
        </div>
      </div>
    </motion.div>
  );
}
