
import { motion } from 'framer-motion';

const techItemVariants = {
  hidden: { opacity: 0, scale: 0.8, y: 20 },
  visible: (index) => ({
    opacity: 1,
    scale: 1,
    y: 0,
    transition: {
      duration: 0.5,
      delay: index * 0.05,
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

const groupVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2
    }
  }
};

export default function Tech() {
  const techGroups = [
    {
      title: "Languages",
      description: "Core programming foundations for web and backend work.",
      items: [
        { name: "HTML5", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/html5/html5-original.svg", color: "#E34F26" },
        { name: "CSS3", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/css3/css3-original.svg", color: "#1572B6" },
        { name: "JavaScript", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/javascript/javascript-original.svg", color: "#F7DF1E" },
        { name: "Python", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg", color: "#3776AB" },
      ],
    },
    {
      title: "Frameworks & Libraries",
      description: "Modern UI and API delivery with maintainable components.",
      items: [
        { name: "React", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg", color: "#61DAFB" },
        { name: "Next.js", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg", color: "#000000" },
        { name: "Node.js", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg", color: "#339933" },
        { name: "Express", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/express/express-original.svg", color: "#000000" },
        { name: "Tailwind CSS", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tailwindcss/tailwindcss-original.svg", color: "#06B6D4" },
        { name: "Bootstrap", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/bootstrap/bootstrap-original.svg", color: "#7952B3" },
      ],
    },
    {
      title: "Platforms & Data",
      description: "Databases and tools that support production readiness.",
      items: [
        { name: "PostgreSQL", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/postgresql/postgresql-original.svg", color: "#4169E1" },
        { name: "MySQL", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg", color: "#4479A1" },
        { name: "MongoDB", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mongodb/mongodb-original.svg", color: "#47A248" },
        { name: "Firebase", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/firebase/firebase-plain.svg", color: "#FFCA28" },
        { name: "Git", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg", color: "#F05032" },
        { name: "GitHub", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg", color: "#181717" },
        { name: "Docker", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg", color: "#2496ED" },
        { name: "Figma", logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/figma/figma-original.svg", color: "#F24E1E" },
      ],
    },
  ];

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
            My Arsenal
          </h2>
          <h3 style={{ color: 'var(--text)' }} className="text-4xl md:text-5xl font-bold">
            Technologies & Tools
          </h3>
          <p style={{ color: 'var(--muted)' }} className="text-lg mt-4 max-w-2xl mx-auto">
            A company-ready stack focused on scalable products, clean delivery,
            and reliable systems.
          </p>
        </motion.div>

        <motion.div
          className="space-y-16"
          variants={groupVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
        >
          {techGroups.map((group, groupIndex) => (
            <motion.div
              key={group.title}
              className="space-y-6"
              variants={techItemVariants}
              custom={groupIndex}
            >
              <motion.div
                className="text-center"
                initial={{ opacity: 0, scale: 0.9 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
              >
                <h4 style={{ color: 'var(--accent)' }} className="text-lg font-semibold mb-2">
                  {group.title}
                </h4>
                <p style={{ color: 'var(--muted)' }} className="text-sm max-w-2xl mx-auto">
                  {group.description}
                </p>
              </motion.div>

              <div className="relative overflow-hidden">
                <motion.div
                  className={`flex gap-8`}
                  style={{
                    width: '200%',
                  }}
                  animate={{
                    x: groupIndex % 2 === 0 ? ["0%", "-50%"] : ["-50%", "0%"]
                  }}
                  transition={{
                    duration: 30,
                    repeat: Infinity,
                    ease: "linear"
                  }}
                >
                  {[...group.items, ...group.items].map((tech, i) => (
                    <motion.div
                      key={`${tech.name}-${i}`}
                      className="flex-shrink-0"
                      variants={techItemVariants}
                      custom={i}
                      whileHover="hover"
                      style={{ perspective: "1000px" }}
                    >
                      <motion.div
                        className="flex flex-col items-center gap-2 p-4 rounded-lg hover:bg-white/5 transition-colors cursor-default group"
                        whileHover={{
                          backgroundColor: "rgba(255, 255, 255, 0.05)",
                          boxShadow: `0 0 20px ${tech.color}30`
                        }}
                      >
                        <motion.img
                          src={tech.logo}
                          alt={tech.name}
                          className="w-10 h-10 transition-all duration-300"
                          style={{ filter: `drop-shadow(0 0 8px ${tech.color}20)` }}
                          whileHover={{
                            filter: `drop-shadow(0 0 15px ${tech.color}50) brightness(1.2)`,
                            rotate: [0, -10, 10, 0],
                            scale: 1.1
                          }}
                          transition={{ duration: 0.4 }}
                        />
                        <motion.span
                          style={{ color: 'var(--text)' }}
                          className="text-sm font-medium text-center whitespace-nowrap"
                          whileHover={{ scale: 1.05 }}
                        >
                          {tech.name}
                        </motion.span>
                      </motion.div>
                    </motion.div>
                  ))}
                </motion.div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </motion.div>
  );
}
