const { initializeDb } = require('./database');
const bcrypt = require('bcryptjs');

const blogPosts = [
    {
      title: "The Rise of AI-Powered Development Tools",
      excerpt:
        "Exploring how artificial intelligence is revolutionizing the way developers write code, debug applications, and streamline workflows in 2025.",
      date: "January 15, 2025",
      readTime: "5 min read",
      category: "AI & Machine Learning",
      image:
        "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=600&h=400&fit=crop",
      tags: ["AI", "DevTools", "Automation"],
      pages: [
        `AI-powered development tools are fundamentally transforming the software development landscape. From intelligent code completion to automated testing and bug detection, these tools are making developers significantly more productive while reducing errors and improving code quality.`,
        `Tools like GitHub Copilot, Tabnine, Amazon CodeWhisperer, and various ChatGPT integrations have become essential components of modern development workflows. These AI assistants provide real-time suggestions, complete entire functions from comments, and even explain complex code in plain language.`,
        `However, AI development tools are not without challenges. Developers must maintain critical thinking about generated code, verify its correctness, ensure it follows security best practices, and confirm it aligns with project architecture.`,
      ],
    },
    {
      title: "React Server Components: A Deep Dive",
      excerpt: "Understanding the benefits and implementation strategies of React Server Components and how they changing modern web development.",
      date: "December 28, 2024",
      readTime: "8 min read",
      category: "Web Development",
      image:
        "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=600&h=400&fit=crop",
      tags: ["React", "Next.js", "Performance"],
      pages: [
        `React Server Components represent a paradigm shift in how we architect React applications. By allowing components to run exclusively on the server, we can dramatically reduce JavaScript bundle sizes, improve initial page load times, and simplify data fetching patterns.`,
        `The benefits are substantial: Server Components have direct access to backend resources like databases, file systems, and internal services without needing API routes. You can query databases directly in your components, read files, and perform server-side computations without any client-side overhead.`,
        `Implementation requires understanding the boundary between server and client code. You explicitly mark client components with the "use client" directive when you need interactivity, browser APIs, or state management. Server Components are the default.`,
      ],
    },
    {
      title: "WebAssembly in Production: Real-World Use Cases",
      excerpt: "Analyzing how major companies are leveraging WebAssembly to build high-performance web applications that rival native software.",
      date: "December 10, 2024",
      readTime: "6 min read",
      category: "Performance",
      image:
        "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=600&h=400&fit=crop",
      tags: ["WebAssembly", "Performance", "Architecture"],
      pages: [
        `WebAssembly (Wasm) has evolved from an experimental technology to a production-ready platform powering some of the most demanding web applications. By compiling languages like C++, Rust, and Go to a binary format that runs at near-native speed in browsers, WebAssembly enables entirely new classes of web applications.`,
        `Real-world implementations demonstrate WebAssembly's power. Figma built their entire collaborative design editor using WebAssembly compiled from C++, achieving performance that rivals native applications. Adobe brought Photoshop to the web using WebAssembly, enabling professional-grade image editing without installation.`,
        `Beyond performance, WebAssembly offers portability. Code written once can run in any browser, on any operating system, without modification. It also provides a secure sandboxed execution environment with fine-grained permissions.`,
      ],
    },
  ];

  const projects = [
    {
      title: "Property Rental Application",
      description:
        "A comprehensive rental platform connecting landlords and tenants. Features property listings, advanced search filters, booking system, payment integration, and user reviews. Built with modern React and responsive design.",
      image:
        "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&h=400&fit=crop",
      stack: [
        {
          name: "React",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg",
        },
        {
          name: "Next.js",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg",
        },
        {
          name: "Tailwind",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tailwindcss/tailwindcss-original.svg",
        },
        {
          name: "Node.js",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
        },
      ],
      github: "https://github.com/yourusername/rental-app",
      demo: "https://demo-rental.vercel.app",
    },
    {
      title: "SEO-Optimized E-Commerce Store",
      description:
        "High-performance e-commerce platform with advanced SEO optimization, structured data, meta tags, sitemap generation, and fast loading speeds. Includes product catalog, shopping cart, checkout flow, and admin dashboard.",
      image:
        "https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=600&h=400&fit=crop",
      stack: [
        {
          name: "Next.js",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nextjs/nextjs-original.svg",
        },
        {
          name: "React",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg",
        },
        {
          name: "Tailwind",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tailwindcss/tailwindcss-original.svg",
        },
        {
          name: "Node.js",
          logo: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
        },
      ],
      github: "https://github.com/yourusername/seo-ecommerce",
      demo: "https://demo-seo-store.vercel.app",
    },
  ];

  const testimonials = [
    {
      name: "crestlancing.ltd",
      role: "",
      company: "",
      image: null,
      rating: 5,
      text: "Excellent work! Delivered on time and exceeded expectations.",
      project: "SpaceRentals",
      phone: "",
    },
    {
      name: "Sarah Johnson",
      role: "CEO at TechStart Inc",
      company: "TechStart Inc",
      image: null,
      rating: 5,
      text: "Delivered our e-commerce platform ahead of schedule with exceptional quality.",
      project: "E-Commerce Platform",
      phone: "+1 555-0123",
    },
    {
      name: "Michael Chen",
      role: "Product Manager at InnovateLabs",
      company: "InnovateLabs",
      image: null,
      rating: 5,
      text: "Exceptional problem-solving skills. Turned complex requirements into a sleek application.",
      project: "Task Management System",
      phone: "+1 555-0124",
    },
    {
      name: "Emily Rodriguez",
      role: "Founder at DesignHub",
      company: "DesignHub",
      image: null,
      rating: 5,
      text: "Impressed by the ability to translate design vision into a fully functional website.",
      project: "Portfolio Website",
      phone: "+1 555-0125",
    },
    {
      name: "camtel",
      role: "Client",
      company: "camtel",
      image: null,
      rating: 5,
      text: "Great collaboration! The team delivered a robust telecom solution on time and within budget.",
      project: "Telecom Platform",
      phone: "",
    },
  ];

async function seed() {
  const db = await initializeDb();

  await db.query('DELETE FROM posts');
  await db.query('DELETE FROM projects');
  await db.query('DELETE FROM certifications');
  await db.query('DELETE FROM users');
  await db.query('DELETE FROM testimonials');
  await db.query('DELETE FROM profile');

  for (const post of blogPosts) {
    await db.query(
      'INSERT INTO posts (title, excerpt, date, readTime, category, image, tags, pages) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
      [post.title, post.excerpt, post.date, post.readTime, post.category, post.image, JSON.stringify(post.tags), JSON.stringify(post.pages)]
    );
  }
  console.log('Posts seeded successfully');

  for (const project of projects) {
    await db.query(
      'INSERT INTO projects (title, description, image, stack, github, demo) VALUES ($1, $2, $3, $4, $5, $6)',
      [project.title, project.description, project.image, JSON.stringify(project.stack), project.github, project.demo]
    );
  }
  console.log('Projects seeded successfully');

  const hashedPassword = await bcrypt.hash('mebune2005', 10);
  await db.query('INSERT INTO users (username, password) VALUES ($1, $2)', ['mebune', hashedPassword]);
  console.log('Admin user seeded successfully');

  for (const t of testimonials) {
    await db.query(
      'INSERT INTO testimonials (name, role, company, image, rating, text, project, phone) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)',
      [t.name, t.role, t.company, t.image, t.rating, t.text, t.project, t.phone]
    );
  }
  console.log('Testimonials seeded successfully');

  await db.query(
    'INSERT INTO certifications (name, issuer, date, description, image, certificateLink) VALUES ($1, $2, $3, $4, $5, $6)',
    [
      'Fiber Optics Network Installation',
      'CAMTEL',
      'Present',
      'Certification for the installation, configuration, and testing of OLT, ONT, Wi-Fi boxes, and fibre optics network equipment.',
      'https://fiberconnect.camtel.cm/static/media/fiberconnect-logo-no-bg.8c04ab7b302d3d15c623.png',
      '#',
    ]
  );
  await db.query(
    'INSERT INTO certifications (name, issuer, date, description, image, certificateLink) VALUES ($1, $2, $3, $4, $5, $6)',
    [
      'Software Engineering Fundamentals',
      'University Program',
      '2024',
      'Ongoing university studies in software engineering with coursework in systems architecture and application development.',
      'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=600&h=400&fit=crop',
      '#',
    ]
  );
  console.log('Certifications seeded successfully');

  await db.query(
    'INSERT INTO profile (name, title, subtitle, bio, avatar, welcome_message) VALUES ($1, $2, $3, $4, $5, $6)',
    [
      'Mebune Donstand',
      'Software Engineer',
      'Frontend & Full-Stack Developer',
      'A self-taught software engineer who builds production-grade applications with modern technologies. Passionate about creating exceptional user experiences and scalable solutions.',
      '',
      'Welcome mebune',
    ]
  );
  console.log('Profile seeded successfully');
}

seed().catch(err => console.error(err));
