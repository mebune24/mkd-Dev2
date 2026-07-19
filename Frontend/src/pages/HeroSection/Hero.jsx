import { motion } from 'framer-motion';
import { Facebook, Github, Instagram, Linkedin, Mail, MessageCircle } from "lucide-react";
import { useEffect, useState } from "react";
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

  const techGroups = [
    {
      title: "Languages",
      items: [
        {
          name: "HTML",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/html5/html5-original.svg",
          color: "#E34F26",
        },
        {
          name: "CSS",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/css3/css3-original.svg",
          color: "#1572B6",
        },
        {
          name: "JavaScript",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/javascript/javascript-original.svg",
          color: "#F7DF1E",
        },
        {
          name: "Python",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg",
          color: "#3776AB",
        },
      ],
    },
    {
      title: "Frameworks & Libraries",
      items: [
        {
          name: "React",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg",
          color: "#61DAFB",
        },
        {
          name: "Next.js",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg",
          color: "#000000",
        },
        {
          name: "Express",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/express/express-original.svg",
          color: "#000000",
        },
        {
          name: "Flask",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flask/flask-original.svg",
          color: "#000000",
        },
        {
          name: "Bootstrap",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/bootstrap/bootstrap-original.svg",
          color: "#7952B3",
        },
        {
          name: "Tailwind",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tailwindcss/tailwindcss-original.svg",
          color: "#06B6D4",
        },
      ],
    },
    {
      title: "Platforms & Tools",
      items: [
        {
          name: "Node.js",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
          color: "#339933",
        },
        {
          name: "MongoDB",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mongodb/mongodb-original.svg",
          color: "#47A248",
        },
        {
          name: "PostgreSQL",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/postgresql/postgresql-original.svg",
          color: "#4169E1",
        },
        {
          name: "MySQL",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg",
          color: "#4479A1",
        },
        {
          name: "GitHub",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg",
          color: "#181717",
        },
        {
          name: "Docker",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg",
          color: "#2496ED",
        },
        {
          name: "Figma",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/figma/figma-original.svg",
          color: "#F24E1E",
        },
      ],
    },
  ];

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
                className="text-4xl md:text-5xl font-bold leading-tight mb-4 text-emerald-400 min-h-[3rem] flex items-center"
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
            </motion.div>

            {/* CTA Buttons */}
            <motion.div
              className="flex flex-wrap gap-4"
              variants={itemVariants}
            >
              <motion.a
                href="https://github.com/mkd-Dev2"
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  backgroundColor: 'var(--accent)',
                  color: 'var(--bg)'
                }}
                className="flex items-center gap-2 font-semibold px-6 py-3 rounded-lg transition-colors duration-300"
                whileHover={{
                  scale: 1.05,
                  boxShadow: "0 0 20px rgba(34, 197, 94, 0.5)"
                }}
                whileTap={{ scale: 0.95 }}
              >
                <Github size={20} />
                GitHub
              </motion.a>

              <motion.a
                href="https://www.linkedin.com/feed/"
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  backgroundColor: 'var(--text)',
                  color: 'var(--bg)'
                }}
                className="flex items-center gap-2 font-semibold px-6 py-3 rounded-lg transition-colors duration-300"
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
                className="flex items-center gap-2 font-semibold px-6 py-3 rounded-lg border transition-all duration-300"
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

            {/* Social Icons */}
            <motion.div
              className="flex items-center gap-4"
              variants={itemVariants}
            >
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
              <div className="space-y-4">
                {[
                  "Structured scoping and requirements alignment",
                  "Performance-first engineering and accessibility",
                  "Reliable releases with clean, maintainable code",
                  "Cross-functional collaboration with product & design"
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className="flex items-start gap-3"
                    initial={{ opacity: 0, x: index % 2 === 0 ? -30 : 30 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.6, delay: index * 0.1 }}
                  >
                    <motion.div
                      className="w-2 h-2 rounded-full mt-2"
                      style={{ backgroundColor: index % 2 === 0 ? 'var(--accent)' : '#38bdf8' }}
                      animate={{ scale: [1, 1.2, 1] }}
                      transition={{ duration: 2, repeat: Infinity, delay: index * 0.5 }}
                    />
                    <p style={{ color: 'var(--muted)' }}>{item}</p>
                  </motion.div>
                ))}
              </div>
            </motion.div>

            {/* Technologies */}
            <motion.div
              className="space-y-8"
              variants={containerVariants}
            >
              {techGroups.map((group, groupIndex) => (
                <motion.div
                  key={group.title}
                  variants={itemVariants}
                >
                  <motion.div
                    className="flex items-center gap-4 mb-4"
                    initial={{ opacity: 0, scale: 0.9 }}
                    whileInView={{ opacity: 1, scale: 1 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.6 }}
                  >
                    <h4 style={{ color: 'var(--text)' }} className="font-semibold">
                      {group.title}
                    </h4>
                    <motion.div
                      className="flex-1 h-px bg-gradient-to-r from-emerald-400/50 to-transparent"
                      initial={{ scaleX: 0 }}
                      whileInView={{ scaleX: 1 }}
                      viewport={{ once: true }}
                      transition={{ duration: 0.8, delay: 0.2 }}
                    />
                  </motion.div>
                  <motion.div
                    className="flex flex-wrap gap-4"
                    variants={containerVariants}
                    initial="hidden"
                    whileInView="visible"
                    viewport={{ once: true, amount: 0.3 }}
                  >
                    {group.items.map((tech, techIndex) => (
                      <motion.div
                        key={tech.name}
                        className="flex flex-col items-center gap-2 p-3 rounded-lg hover:bg-white/5 transition-colors cursor-default group"
                        title={tech.name}
                        variants={techItemVariants}
                        custom={techIndex}
                        whileHover="hover"
                        style={{ perspective: "1000px" }}
                      >
                        <motion.img
                          src={tech.logo}
                          alt={tech.name}
                          className="w-8 h-8 transition-all duration-300"
                          style={{ filter: `drop-shadow(0 0 8px ${tech.color}20)` }}
                          whileHover={{
                            filter: `drop-shadow(0 0 15px ${tech.color}50) brightness(1.2)`,
                            rotate: [0, -10, 10, 0],
                            scale: 1.1
                          }}
                          transition={{ duration: 0.4 }}
                        />
                        <motion.span
                          style={{ color: 'var(--muted)' }}
                          className="text-xs font-medium text-center"
                          whileHover={{ scale: 1.05 }}
                        >
                          {tech.name}
                        </motion.span>
                      </motion.div>
                    ))}
                  </motion.div>
                </motion.div>
              ))}
            </motion.div>
          </motion.div>
        </div>
      </div>
    </motion.div>
  );
}
