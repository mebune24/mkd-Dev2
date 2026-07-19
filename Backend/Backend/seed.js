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
      tags: JSON.stringify(["AI", "DevTools", "Automation"]),
      pages: JSON.stringify([
        `AI-powered development tools are fundamentally transforming the software development landscape. From intelligent code completion to automated testing and bug detection, these tools are making developers significantly more productive while reducing errors and improving code quality.

Machine learning models trained on billions of lines of code can now understand context, predict intentions, and generate relevant code snippets. They analyze patterns across millions of repositories to suggest solutions that follow best practices and common conventions in your specific programming language and framework.`,
        `Tools like GitHub Copilot, Tabnine, Amazon CodeWhisperer, and various ChatGPT integrations have become essential components of modern development workflows. These AI assistants provide real-time suggestions, complete entire functions from comments, and even explain complex code in plain language.

Research indicates that developers using AI coding assistants complete tasks 25-55% faster than their non-assisted counterparts. Beyond speed, these tools help developers learn new languages and frameworks more quickly by providing contextual examples and explanations.`,
        `However, AI development tools are not without challenges. Developers must maintain critical thinking about generated code, verify its correctness, ensure it follows security best practices, and confirm it aligns with project architecture. There are also concerns about code licensing, as models trained on open-source code may inadvertently reproduce copyrighted material.

The future of software development isn"t about replacing developers with AI, but rather augmenting human creativity and problem-solving with intelligent automation. The most effective developers will be those who can leverage these tools while maintaining strong fundamental programming skills and judgment.`,
      ]),
    },
    {
      title: "React Server Components: A Deep Dive",
      excerpt: "Understanding the benefits and implementation strategies of React Server Components and how they changing modern web development.",
      date: "December 28, 2024",
      readTime: "8 min read",
      category: "Web Development",
      image:
        "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=600&h=400&fit=crop",
      tags: JSON.stringify(["React", "Next.js", "Performance"]),
      pages: JSON.stringify([
        `React Server Components represent a paradigm shift in how we architect React applications. By allowing components to run exclusively on the server, we can dramatically reduce JavaScript bundle sizes, improve initial page load times, and simplify data fetching patterns.

Unlike traditional server-side rendering where components render on both server and client, Server Components render only on the server and send their output as serialized data to the client. This means the component code and its dependencies never reach the browser, resulting in zero-bundle-size components.`,
        `The benefits are substantial: Server Components have direct access to backend resources like databases, file systems, and internal services without needing API routes. You can query databases directly in your components, read files, and perform server-side computations without any client-side overhead.

For example, a product listing component can fetch data from your database, process images, and format content entirely on the server. Only the final HTML-like output is sent to the client, eliminating the need for loading states, client-side data fetching libraries, and large serialized data payloads.`,
        `Implementation requires understanding the boundary between server and client code. You explicitly mark client components with the "use client" directive when you need interactivity, browser APIs, or state management. Server Components are the default.

The composition model is powerful: you can nest client components inside server components and vice versa, creating a hybrid architecture where the server handles data-heavy operations and the client manages user interactions.`,
        `Production implementations show impressive results: companies report 30-60% reductions in JavaScript bundle size, significantly faster Time to Interactive metrics, and improved Core Web Vitals scores. Next.js 13+ has made Server Components the default architecture, with frameworks like Remix and others following suit.

The future of React is clearly server-first, with client-side interactivity added strategically only where needed. This approach aligns perfectly with modern performance best practices and user expectations for fast, responsive web applications.`,
      ]),
    },
    {
      title: "WebAssembly in Production: Real-World Use Cases",
      excerpt: "Analyzing how major companies are leveraging WebAssembly to build high-performance web applications that rival native software.",
      date: "December 10, 2024",
      readTime: "6 min read",
      category: "Performance",
      image:
        "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=600&h=400&fit=crop",
      tags: JSON.stringify(["WebAssembly", "Performance", "Architecture"]),
      pages: JSON.stringify([
        `WebAssembly (Wasm) has evolved from an experimental technology to a production-ready platform powering some of the most demanding web applications. By compiling languages like C++, Rust, and Go to a binary format that runs at near-native speed in browsers, WebAssembly enables entirely new classes of web applications.

The performance advantage is substantial: for compute-intensive tasks, WebAssembly typically runs 10-20x faster than JavaScript, making it viable for applications that were previously only possible as native desktop software.`,
        `Real-world implementations demonstrate WebAssembly"s power. Figma built their entire collaborative design editor using WebAssembly compiled from C++, achieving performance that rivals native applications. Adobe brought Photoshop to the web using WebAssembly, enabling professional-grade image editing without installation. AutoCAD"s web application leverages Wasm to render complex 3D models with fluid performance.

Google Earth, video conferencing platforms, and even game engines now run in browsers thanks to WebAssembly. Unity and Unreal Engine both support WebAssembly compilation, enabling AAA-quality games to run without plugins.`,
        `Beyond performance, WebAssembly offers portability. Code written once can run in any browser, on any operating system, without modification. It also provides a secure sandboxed execution environment with fine-grained permissions, making it suitable for running untrusted code safely.

WebAssembly is expanding beyond browsers into serverless platforms, edge computing environments, and IoT devices. It"s becoming a universal compilation target, similar to what JVM promised but with better performance and no runtime overhead.

For developers considering WebAssembly, the best use cases involve CPU-intensive operations like image/video processing, data compression, cryptography, scientific simulations, and game engines. For typical web applications with primarily UI logic and API calls, JavaScript remains more practical.`,
      ]),
    },
    // ... (rest of the blog posts from your provided list)
];


const projects = [
    {
      title: "Property Rental Application",
      description:
        "A comprehensive rental platform connecting landlords and tenants. Features property listings, advanced search filters, booking system, payment integration, and user reviews. Built with modern React and responsive design.",
      image:
        "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&h=400&fit=crop",
      stack: JSON.stringify([
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
      ]),
      github: "https://github.com/yourusername/rental-app",
      demo: "https://demo-rental.vercel.app",
    },
    {
      title: "SEO-Optimized E-Commerce Store",
      description:
        "High-performance e-commerce platform with advanced SEO optimization, structured data, meta tags, sitemap generation, and fast loading speeds. Includes product catalog, shopping cart, checkout flow, and admin dashboard.",
      image:
        "https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=600&h=400&fit=crop",
      stack: JSON.stringify([
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
      ]),
      github: "https://github.com/yourusername/seo-ecommerce",
      demo: "https://demo-seo-store.vercel.app",
    },
    // ... Add more projects as needed
];

async function seed() {
  const db = await initializeDb();

  // Clear existing data
  await db.run('DELETE FROM posts');
  await db.run('DELETE FROM projects');
    await db.run('DELETE FROM users');


  // Seed Posts
  const postStmt = await db.prepare('INSERT INTO posts (title, excerpt, date, readTime, category, image, tags, pages) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
  for (const post of blogPosts) {
    await postStmt.run(post.title, post.excerpt, post.date, post.readTime, post.category, post.image, post.tags, post.pages);
  }
  await postStmt.finalize();
    console.log('Posts seeded successfully');


  // Seed Projects
  const projectStmt = await db.prepare('INSERT INTO projects (title, description, image, stack, github, demo) VALUES (?, ?, ?, ?, ?, ?)');
    for (const project of projects) {
        await projectStmt.run(project.title, project.description, project.image, project.stack, project.github, project.demo);
    }
  await projectStmt.finalize();
  console.log('Projects seeded successfully');

  // Seed Admin User
  const hashedPassword = await bcrypt.hash('password123', 10);
  await db.run('INSERT INTO users (username, password) VALUES (?, ?)', ['admin', hashedPassword]);
  console.log('Admin user seeded successfully');

  // Seed Testimonials
  const testimonials = [
    {
      name: "Sarah Johnson",
      role: "CEO at TechStart Inc",
      company: "TechStart Inc",
      image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop",
      rating: 5,
      text: "Working with Mebune was an absolute pleasure. He delivered our e-commerce platform ahead of schedule with exceptional quality. His expertise in React and Next.js really showed in the final product. The attention to detail and communication throughout the project was outstanding.",
      project: "E-Commerce Platform",
      phone: "+1 555-0123"
    },
    {
      name: "Michael Chen",
      role: "Product Manager at InnovateLabs",
      company: "InnovateLabs",
      image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop",
      rating: 5,
      text: "Mebune's problem-solving skills are exceptional. He took our complex requirements and turned them into a sleek, performant application. His knowledge of modern web technologies and best practices made our collaboration smooth and productive. Highly recommended!",
      project: "Task Management System",
      phone: "+1 555-0124"
    },
    {
      name: "Emily Rodriguez",
      role: "Founder at DesignHub",
      company: "DesignHub",
      image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop",
      rating: 5,
      text: "I was impressed by Mebune's ability to translate our design vision into a fully functional website. His technical skills combined with his understanding of UX principles resulted in a product that exceeded our expectations. Professional, reliable, and talented.",
      project: "Portfolio Website",
      phone: "+1 555-0125"
    },
  ];

  const testimonialStmt = await db.prepare('INSERT INTO testimonials (name, role, company, image, rating, text, project, phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
    for (const t of testimonials) {
        await testimonialStmt.run(t.name, t.role, t.company, t.image, t.rating, t.text, t.project, t.phone);
    }
  await testimonialStmt.finalize();
  console.log('Testimonials seeded successfully');
}

seed().catch(err => console.error(err));
