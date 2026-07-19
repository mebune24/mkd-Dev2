import { Github, Linkedin, Mail } from "lucide-react";
import { useParallax } from "../../Hooks/useParallax";

export default function HeroSection() {
  const { transform } = useParallax(0.3);

  const technologies = [
      {
           name: "Html",
            logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/html5/html5-original.svg",
      },
      {
        name: "CSS",
        logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/css3/css3-original.svg",
      },

    {
      name: "JavaScript",
      logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/javascript/javascript-original.svg",
    },
    {
      name: "React",
      logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg",
    },
    {
      name: "Next.js",
      logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg",
    },
    {
      name: "Git/GitHub",
      logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg",
    },
    {
      name: "Bootstrap",
      logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/bootstrap/bootstrap-original.svg",
    },
    {
      name: "Tailwind",
      logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tailwindcss/tailwindcss-original.svg",
    },
    {
       name: "node.js",
        logo: " https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
    },
    {
       name: "Express",
        logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/express/express-original.svg",
    },
    {
        name: "MongoDB",
        logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mongodb/mongodb-original.svg",
    },
    {
       name: "MySQL",
        logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg",
    },
    {
          name: "Python",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg",
    },
    {
          name: "postgre",
          logo: " https://cdn.jsdelivr.net/gh/devicons/devicon/icons/postgresql/postgresql-original.svg",
    },
    {
          name: "Flask",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flask/flask-original.svg",
    },
    {
          name: "Docker",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg",
    },
    {
      name : "Figma",
      logo : "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/figma/figma-original.svg",

    }
  ];

  return (
    <div className="min-h-screen bg-black flex items-center justify-center px-6 relative overflow-hidden">
      {/* Parallax Background */}
      <div
        className="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-10"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80)',
          transform
        }}
      />

      <div className="max-w-4xl w-full relative z-10">
        {/* Greeting */}
        <div className="mb-6 mt-30">
          <h2 className="text-green-500 text-2xl md:text-3xl font-medium mb-2">
            Hey There! 👋
          </h2>
          <h1 className="text-white text-5xl md:text-7xl font-bold">
            I'm <span className="text-green-500">MEBUNE DONSTAND</span>
          </h1>
        </div>

        {/* Title */}
        <div className="mb-8">
          <h3 className="text-gray-400 text-2xl md:text-3xl font-light">
            Software Engineer
          </h3>
        </div>

        {/* Description */}
        <div className="mb-10">
          <p className="text-gray-300 text-lg md:text-xl leading-relaxed max-w-3xl">
            A self-taught developer with an interest in computer science,
            currently specialized in modern web technologies and frameworks.
          </p>
        </div>

        {/* Technologies */}
        <div className="mb-12">
          <div className="flex flex-wrap gap-4">
            {technologies.map((tech, index) => (
              <div
                key={index}
                className="flex items-center gap-3 bg-gray-900 border border-gray-800 rounded-lg px-5 py-3 hover:border-green-500 transition-colors duration-300"
              >
                <img
                  src={tech.logo}
                  alt={`${tech.name} logo`}
                  className="w-6 h-6"
                />
                <span className="text-white font-medium">{tech.name}</span>
              </div>
            ))}
          </div>
        </div>

        {/* CTA Buttons */}
        <div className="flex flex-wrap gap-4">
          <a
            href="https://github.com/mkd-Dev2"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 bg-green-500 hover:bg-green-600 text-black font-semibold px-6 py-3 rounded-full transition-all duration-300 shadow-lg shadow-green-500/25 hover:shadow-green-500/40"
          >
            <Github size={20} />
            GitHub
          </a>

          <a
            href="https://www.linkedin.com/feed/"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 bg-white hover:bg-gray-200 text-black font-semibold px-6 py-3 rounded-full transition-all duration-300 shadow-lg shadow-white/25 hover:shadow-white/40"
          >
            <Linkedin size={20} />
            LinkedIn
          </a>

          <a
            href="mailto:mebunedonstand797@gmail.com"
            className="flex items-center gap-2 bg-gray-800 hover:bg-gray-700 text-white font-semibold px-6 py-3 rounded-full border border-gray-700 hover:border-green-500 transition-all duration-300 shadow-lg shadow-gray-900/25 hover:shadow-gray-900/40"
          >
            <Mail size={20} />
            Email
          </a>
        </div>
      </div>
    </div>
  );
}
