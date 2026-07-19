import { ArrowRight, Calendar, Clock, X } from "lucide-react";
import { useState } from "react";

export default function Blogging() {
  const blogPosts = [
    {
      id: 1,
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
        "AI-powered development tools are fundamentally transforming the software development landscape. From intelligent code completion to automated testing and bug detection, these tools are making developers significantly more productive while reducing errors and improving code quality.\n\nMachine learning models trained on billions of lines of code can now understand context, predict intentions, and generate relevant code snippets. They analyze patterns across millions of repositories to suggest solutions that follow best practices and common conventions in your specific programming language and framework.",
        "Tools like GitHub Copilot, Tabnine, Amazon CodeWhisperer, and various ChatGPT integrations have become essential components of modern development workflows. These AI assistants provide real-time suggestions, complete entire functions from comments, and even explain complex code in plain language.\n\nResearch indicates that developers using AI coding assistants complete tasks 25-55% faster than their non-assisted counterparts. Beyond speed, these tools help developers learn new languages and frameworks more quickly by providing contextual examples and explanations.",
        "However, AI development tools are not without challenges. Developers must maintain critical thinking about generated code, verify its correctness, ensure it follows security best practices, and confirm it aligns with project architecture. There are also concerns about code licensing, as models trained on open-source code may inadvertently reproduce copyrighted material.\n\nThe future of software development isn't about replacing developers with AI, but rather augmenting human creativity and problem-solving with intelligent automation. The most effective developers will be those who can leverage these tools while maintaining strong fundamental programming skills and judgment.",
      ],
    },
    {
      id: 2,
      title: "React Server Components: A Deep Dive",
      excerpt:
        "Understanding the benefits and implementation strategies of React Server Components and how they're changing modern web development.",
      date: "December 28, 2024",
      readTime: "8 min read",
      category: "Web Development",
      image:
        "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=600&h=400&fit=crop",
      tags: ["React", "Next.js", "Performance"],
      pages: [
        "React Server Components represent a paradigm shift in how we architect React applications. By allowing components to run exclusively on the server, we can dramatically reduce JavaScript bundle sizes, improve initial page load times, and simplify data fetching patterns.\n\nUnlike traditional server-side rendering where components render on both server and client, Server Components render only on the server and send their output as serialized data to the client. This means the component code and its dependencies never reach the browser, resulting in zero-bundle-size components.",
        "The benefits are substantial: Server Components have direct access to backend resources like databases, file systems, and internal services without needing API routes. You can query databases directly in your components, read files, and perform server-side computations without any client-side overhead.\n\nFor example, a product listing component can fetch data from your database, process images, and format content entirely on the server. Only the final HTML-like output is sent to the client, eliminating the need for loading states, client-side data fetching libraries, and large serialized data payloads.",
        "Implementation requires understanding the boundary between server and client code. You explicitly mark client components with the 'use client' directive when you need interactivity, browser APIs, or state management. Server Components are the default.\n\nThe composition model is powerful: you can nest client components inside server components and vice versa, creating a hybrid architecture where the server handles data-heavy operations and the client manages user interactions.",
        "Production implementations show impressive results: companies report 30-60% reductions in JavaScript bundle size, significantly faster Time to Interactive metrics, and improved Core Web Vitals scores. Next.js 13+ has made Server Components the default architecture, with frameworks like Remix and others following suit.\n\nThe future of React is clearly server-first, with client-side interactivity added strategically only where needed. This approach aligns perfectly with modern performance best practices and user expectations for fast, responsive web applications.",
      ],
    },
    {
      id: 3,
      title: "WebAssembly in Production: Real-World Use Cases",
      excerpt:
        "Analyzing how major companies are leveraging WebAssembly to build high-performance web applications that rival native software.",
      date: "December 10, 2024",
      readTime: "6 min read",
      category: "Performance",
      image:
        "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=600&h=400&fit=crop",
      tags: ["WebAssembly", "Performance", "Architecture"],
      pages: [
        "WebAssembly (Wasm) has evolved from an experimental technology to a production-ready platform powering some of the most demanding web applications. By compiling languages like C++, Rust, and Go to a binary format that runs at near-native speed in browsers, WebAssembly enables entirely new classes of web applications.\n\nThe performance advantage is substantial: for compute-intensive tasks, WebAssembly typically runs 10-20x faster than JavaScript, making it viable for applications that were previously only possible as native desktop software.",
        "Real-world implementations demonstrate WebAssembly's power. Figma built their entire collaborative design editor using WebAssembly compiled from C++, achieving performance that rivals native applications. Adobe brought Photoshop to the web using WebAssembly, enabling professional-grade image editing without installation. AutoCAD's web application leverages Wasm to render complex 3D models with fluid performance.\n\nGoogle Earth, video conferencing platforms, and even game engines now run in browsers thanks to WebAssembly. Unity and Unreal Engine both support WebAssembly compilation, enabling AAA-quality games to run without plugins.",
        "Beyond performance, WebAssembly offers portability. Code written once can run in any browser, on any operating system, without modification. It also provides a secure sandboxed execution environment with fine-grained permissions, making it suitable for running untrusted code safely.\n\nWebAssembly is expanding beyond browsers into serverless platforms, edge computing environments, and IoT devices. It's becoming a universal compilation target, similar to what JVM promised but with better performance and no runtime overhead.\n\nFor developers considering WebAssembly, the best use cases involve CPU-intensive operations like image/video processing, data compression, cryptography, scientific simulations, and game engines. For typical web applications with primarily UI logic and API calls, JavaScript remains more practical.",
      ],
    },
    {
      id: 4,
      title: "Tailwind CSS 4.0: What's New and Improved",
      excerpt:
        "Breaking down the latest features in Tailwind CSS 4.0, including new utilities, improved performance, and enhanced developer experience.",
      date: "November 22, 2024",
      readTime: "4 min read",
      category: "CSS & Styling",
      image:
        "https://images.unsplash.com/photo-1507721999472-8ed4421c4af2?w=600&h=400&fit=crop",
      tags: ["Tailwind", "CSS", "Frontend"],
      pages: [
        "Tailwind CSS 4.0 introduces significant performance improvements and new features that enhance developer experience. The completely rewritten engine processes styles up to 10x faster than version 3, with build times reduced from seconds to milliseconds for large projects.\n\nThe new architecture leverages Rust under the hood (via the Lightning CSS parser), providing native-level performance while maintaining backward compatibility with existing Tailwind projects. This performance boost is particularly noticeable in development mode with hot module replacement.",
        "Key new features include native CSS nesting support, eliminating the need for plugins. The improved color palette includes enhanced contrast ratios for better accessibility, with new color variants specifically designed for dark mode. Container queries are now first-class citizens with intuitive utility classes like @md: and @lg: prefixes.\n\nThe JIT (Just-In-Time) compiler is now the only mode, simplifying the mental model and ensuring development and production builds work identically. This eliminates the common pitfall of classes working in development but not appearing in production.\n\nNew utility classes for modern CSS features like cascade layers, scroll-snap, and view transitions make cutting-edge CSS accessible through Tailwind's familiar utility-first approach. The framework now supports more granular breakpoints and custom media queries without configuration bloat.",
      ],
    },
    {
      id: 5,
      title: "Edge Computing: The Future of Web Applications",
      excerpt:
        "How edge computing is reducing latency and improving user experiences by bringing computation closer to the end user.",
      date: "November 5, 2024",
      readTime: "7 min read",
      category: "Cloud & Infrastructure",
      image:
        "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&h=400&fit=crop",
      tags: ["Edge Computing", "CDN", "Performance"],
      pages: [
        "Edge computing represents a fundamental shift in web application architecture. Instead of centralizing computation in a few large data centers, edge computing distributes processing across hundreds of locations globally, placing computation physically closer to end users.\n\nThe latency improvement is dramatic: traditional cloud computing involves round trips of 200-500ms for users far from data centers. Edge computing reduces this to 10-50ms by processing requests at the nearest edge location. This difference is imperceptible for simple tasks but crucial for real-time interactions.",
        "Modern edge platforms like Cloudflare Workers, Vercel Edge Functions, AWS Lambda@Edge, and Fastly Compute@Edge make this power accessible to all developers. You write standard JavaScript, TypeScript, or WebAssembly code that automatically deploys to hundreds of locations worldwide.\n\nEdge computing excels at tasks like API response optimization, authentication and authorization, A/B testing, content personalization, image optimization, and dynamic HTML rendering. These operations happen instantly because they're processed within milliseconds of the user.",
        "Real-world impact is measurable: e-commerce sites see 7% increases in conversion rates for every 100ms of latency reduction. Media sites reduce bounce rates significantly with faster initial page loads. SaaS applications feel more responsive and competitive with desktop software.\n\nThe edge is particularly powerful when combined with edge databases like Cloudflare D1, Upstash Redis, or PlanetScale's edge read replicas. You can query databases from edge functions with single-digit millisecond latency globally.\n\nLimitations exist: edge functions have memory and execution time constraints, cold starts (though typically under 10ms), and limited access to traditional server resources. They're best for lightweight operations that enhance rather than replace traditional backend services.",
      ],
    },
    {
      id: 6,
      title: "TypeScript 5.5: Advanced Type Features",
      excerpt:
        "Exploring the new type system enhancements in TypeScript 5.5 that make your code more type-safe and maintainable.",
      date: "October 18, 2024",
      readTime: "6 min read",
      category: "Programming Languages",
      image:
        "https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=600&h=400&fit=crop",
      tags: ["TypeScript", "JavaScript", "Types"],
      pages: [
        "TypeScript 5.5 introduces sophisticated type system enhancements that catch more bugs at compile time and reduce boilerplate. The most significant addition is inferred type predicates, which automatically narrow types based on function return values without explicit type guards.\n\nPreviously, you needed to manually define type predicates for validation functions. Now TypeScript infers them automatically from return statements, making code more concise and maintainable while preserving full type safety.",
        "Const type parameters preserve literal types through generic functions, enabling more precise type inference. When you pass a string literal to a generic function, TypeScript now maintains that exact literal type rather than widening it to string, catching more potential errors.\n\nImproved discriminated union handling catches exhaustiveness errors more reliably. When you use switch statements or if-else chains with union types, TypeScript ensures you've handled all possible cases, preventing runtime errors from unhandled variants.\n\nPerformance improvements are substantial: type checking is 20-30% faster for large codebases, and memory usage is reduced significantly. These optimizations make TypeScript viable for even the largest monorepos without sacrificing the development experience.",
      ],
    },
    {
      id: 7,
      title: "Modern State Management Patterns in React",
      excerpt:
        "Comparing Redux, Zustand, Jotai, and Context API for effective state management in 2025.",
      date: "September 30, 2024",
      readTime: "7 min read",
      category: "Web Development",
      image:
        "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&h=400&fit=crop",
      tags: ["React", "State Management", "Architecture"],
      pages: [
        "State management remains one of the most crucial architectural decisions in React applications. While Redux dominated for years with its predictable state container approach, modern alternatives like Zustand, Jotai, and improved Context API patterns offer compelling benefits.\n\nThe landscape has evolved significantly: we now understand that not all state needs global management. Component state, server state, URL state, and global UI state each have optimal handling strategies.",
        "Redux excels in large applications with complex state logic, especially when you need time-travel debugging, middleware for side effects, and strong typing. Its Redux Toolkit has dramatically reduced boilerplate, making it more accessible. Use Redux when multiple teams work on interconnected features requiring centralized state logic.\n\nZustand provides Redux-like patterns with minimal setup and no boilerplate. Its hook-based API feels natural in React, and it includes built-in TypeScript support and devtools. Zustand shines in medium-sized applications where Redux feels heavy-handed but Context API isn't sufficient.",
        "Jotai takes an atomic approach, defining independent state atoms that components subscribe to. This fine-grained reactivity prevents unnecessary re-renders and keeps state collocated near components that use it. Jotai works beautifully for complex forms and derived state calculations.\n\nContext API is sufficient for many applications when combined with useReducer and proper optimization. It's built-in, requires no dependencies, and works well for theming, authentication, and other infrequently changing global state. Avoid it for high-frequency updates without careful memoization.\n\nThe best choice depends on your application's complexity, team size, performance requirements, and whether you need features like middleware, persistence, or time-travel debugging. Start simple with Context or Zustand, graduate to Redux only when complexity demands it.",
      ],
    },
    {
      id: 8,
      title: "Building Accessible Web Applications",
      excerpt:
        "Practical strategies for creating inclusive digital experiences that work for everyone.",
      date: "September 15, 2024",
      readTime: "8 min read",
      category: "Web Development",
      image:
        "https://images.unsplash.com/photo-1573164713714-d95e436ab8d6?w=600&h=400&fit=crop",
      tags: ["Accessibility", "A11y", "UX"],
      pages: [
        "Web accessibility is both a moral imperative and increasingly a legal requirement. The Web Content Accessibility Guidelines (WCAG) 2.1 provide standards for making digital content accessible to people with visual, auditory, motor, and cognitive disabilities. Building accessible applications from the start is significantly easier than retrofitting accessibility later.\n\nAccessibility benefits everyone, not just users with disabilities. Captions help in noisy environments, keyboard navigation speeds up power users, clear content structure improves SEO, and high contrast benefits users in bright sunlight.",
        "Fundamental practices include semantic HTML with proper heading hierarchy and landmark regions, keyboard accessibility for all interactive elements, sufficient color contrast (4.5:1 for normal text, 3:1 for large text), ARIA labels for screen readers when semantic HTML isn't sufficient, and visible focus indicators that aren't removed.\n\nFocus management is critical in single-page applications. When navigating between routes, focus should move to the main content. When opening modals, focus should trap inside. When closing modals, focus should return to the trigger element.",
        "Testing should include automated tools like axe DevTools, Lighthouse audits, and jest-axe for catching common issues. However, automated testing catches only 30-40% of accessibility issues. Manual testing with actual screen readers (NVDA on Windows, VoiceOver on Mac/iOS) and keyboard-only navigation is essential.\n\nCommon frameworks and component libraries often have accessibility built-in. React Aria, Radix UI, and Reach UI provide accessible primitives that handle complex interactions correctly. Use these rather than building from scratch unless you have specific requirements.",
        "Accessibility should be part of your definition of done, not an afterthought. Include it in code reviews, add automated tests, and periodically audit with screen readers. The investment pays dividends in user satisfaction, reduced support costs, legal compliance, and broader market reach. Accessible applications are simply better applications for everyone.",
      ],
    },
    {
      id: 9,
      title: "Microservices Architecture: Lessons Learned",
      excerpt:
        "Real-world experiences with microservices: when they work, when they don't, and how to decide.",
      date: "August 28, 2024",
      readTime: "9 min read",
      category: "Architecture",
      image:
        "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600&h=400&fit=crop",
      tags: ["Architecture", "Microservices", "DevOps"],
      pages: [
        "Microservices architecture promises independent deployability, technology flexibility, and better scalability. However, it introduces significant complexity that many organizations underestimate. After years of production experience, clear patterns have emerged about when microservices work and when a well-structured monolith is superior.\n\nMicroservices shine for large organizations with multiple teams working on distinct product areas. They enable teams to deploy independently, choose appropriate technology stacks, and scale services differently based on load. They're particularly valuable when different services have vastly different scaling characteristics.",
        "The challenges are substantial: distributed systems are inherently complex, requiring sophisticated monitoring, tracing, and debugging tools. Network calls between services add latency and failure points. Data consistency across services requires careful design with eventual consistency patterns. Testing becomes more complex as you need to coordinate multiple services.\n\nOperational overhead increases dramatically: you need service discovery, load balancing, circuit breakers, distributed tracing, centralized logging, and orchestration platforms like Kubernetes. Each service needs its own CI/CD pipeline, monitoring, and alerting. This infrastructure requires significant investment and expertise.",
        "Many organizations rush into microservices prematurely. Start with a well-architected monolith using clear module boundaries and dependency rules. When specific modules need independent scaling or deployment, extract them as services. This gradual approach avoids premature complexity while maintaining architectural clarity.\n\nSuccess factors include: strong DevOps culture and automation, experienced distributed systems engineers, clear service boundaries aligned with business domains, robust monitoring and observability, and organizational buy-in for the increased operational complexity.",
        "Alternatives to consider: modular monoliths can provide many benefits of microservices without the operational overhead. Services can be separate deployment units sharing a database, reducing distributed transaction complexity. Serverless functions can handle specific workloads without full microservice infrastructure.\n\nMicroservices are a tool, not a goal. Choose them when you have organizational scale, clear service boundaries, and resources to manage complexity. For most applications, a well-structured monolith or modular architecture is more pragmatic and maintainable.",
      ],
    },
  ];

  const [currentPage, setCurrentPage] = useState(1);
  const [postsPerPage] = useState(6);
  const [selectedBlog, setSelectedBlog] = useState(null);
  const [blogPage, setBlogPage] = useState(1);

  // Get current posts
  const indexOfLastPost = currentPage * postsPerPage;
  const indexOfFirstPost = indexOfLastPost - postsPerPage;
  const currentPosts = blogPosts.slice(indexOfFirstPost, indexOfLastPost);

  // Change page
  const paginate = (pageNumber) => setCurrentPage(pageNumber);

  // Blog modal handlers
  const openBlog = (blog) => {
    setSelectedBlog(blog);
    setBlogPage(1);
    document.body.style.overflow = "hidden";
  };

  const closeBlog = () => {
    setSelectedBlog(null);
    setBlogPage(1);
    document.body.style.overflow = "unset";
  };

  const goToNextBlogPage = () => {
  if(selectedBlog && blogPage < selectedBlog.pages.length) {

      setBlogPage(blogPage + 1);
    }
  };

  const goToPreviousBlogPage = () => {
    if(blogPage > 1) {

      setBlogPage(blogPage - 1);
    }
  };

  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-center py-20 px-6">
      <div className="max-w-7xl mx-auto w-full">
        {/* Section Title */}
        <div className="mb-16 text-center flex flex-col items-center">
          <span className="inline-flex items-center gap-2 text-xs uppercase tracking-[0.35em] text-emerald-400 font-semibold justify-center">
            <span className="w-2 h-2 rounded-full bg-emerald-400" />
            Latest Insights
          </span>
          <h3 style={{ color: 'var(--text)' }} className="mt-4 text-4xl font-bold text-center">Engineering Blog</h3>
          <p style={{ color: 'var(--muted)' }} className="mt-2 text-sm text-center max-w-2xl">Product & Platform Notes - Practical write‑ups on delivery, performance, and building  scalable web products for teams.</p>
        </div>

        {/* Blog Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {currentPosts.map((post) => (
            <article
              key={post.id}
              className="relative rounded-3xl border border-emerald-400/50 animate-pulse bg-gradient-to-br from-slate-900/80 via-slate-800/60 to-slate-900/80 backdrop-blur-xl overflow-hidden hover:border-emerald-400 transition-all duration-500 flex flex-col cursor-pointer shadow-xl shadow-emerald-500/20 hover:shadow-emerald-500/40"
              onClick={() => openBlog(post)}
            >
              {/* Background Pattern */}
              <div className="absolute inset-0 opacity-5">
                <div className="absolute top-0 right-0 w-16 h-16 bg-emerald-400 rounded-full blur-2xl" />
                <div className="absolute bottom-0 left-0 w-12 h-12 bg-cyan-400 rounded-full blur-xl" />
              </div>

              {/* Blog Image */}
              <div className="relative h-48 overflow-hidden z-10">
                <img
                  src={post.image}
                  alt={post.title}
                  className="w-full h-full object-cover hover:scale-110 transition-transform duration-300"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-slate-950/80 to-transparent" />
                <div className="absolute top-4 left-4">
                  <span className="bg-gradient-to-r from-emerald-500 to-cyan-500 text-white text-xs font-semibold px-3 py-1 rounded-full shadow-lg shadow-emerald-500/25">
                    {post.category}
                  </span>
                </div>
              </div>

              {/* Blog Content */}
              <div className="relative z-10 p-6 flex flex-col grow">
                {/* Date and Read Time */}
                <div className="flex items-center gap-4 text-sm mb-3" style={{ color: 'var(--muted)' }}>
                  <div className="flex items-center gap-1">
                    <Calendar size={14} />
                    <span>{post.date}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Clock size={14} />
                    <span>{post.readTime}</span>
                  </div>
                </div>

                <h4 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-3 hover:text-emerald-400 transition-colors duration-300">
                  {post.title}
                </h4>

                <p style={{ color: 'var(--muted)' }} className="text-base mb-4 grow">
                  {post.excerpt}
                </p>

                {/* Tags */}
                <div className="flex flex-wrap gap-2 mb-4">
                  {post.tags.map((tag, index) => (
                    <span
                      key={index}
                      className="text-xs px-3 py-1 rounded-full bg-gradient-to-r from-emerald-500/10 to-cyan-500/10 border border-emerald-500/20 text-emerald-300 font-medium"
                    >
                      #{tag}
                    </span>
                  ))}
                </div>

                {/* Read More Button */}
                <button className="flex items-center gap-2 text-emerald-400 hover:text-emerald-300 font-medium transition-all duration-300 group hover:translate-x-1">
                  Read the analysis
                  <ArrowRight
                    size={16}
                    className="group-hover:translate-x-1 transition-transform duration-300"
                  />
                </button>
              </div>
            </article>
          ))}
        </div>

        {/* Pagination */}
        <div className="mt-16 flex justify-center items-center gap-4">
          <button
            onClick={() => paginate(currentPage - 1)}
            disabled={currentPage === 1}
            className="p-2 rounded-full bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white transition-all duration-300 shadow-lg shadow-emerald-500/25 hover:shadow-emerald-500/40 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ArrowRight size={20} className="rotate-180" />
          </button>
          {Array.from({
            length: Math.ceil(blogPosts.length / postsPerPage),
          }).map((_, index) => (
            <button
              key={index}
              onClick={() => paginate(index + 1)}
              className={`w-10 h-10 font-semibold rounded-full transition-all duration-300 ${
                currentPage === index + 1
                  ? "bg-gradient-to-r from-emerald-500 to-cyan-500 text-white shadow-lg shadow-emerald-500/25"
                  : "bg-slate-800 text-white hover:bg-slate-700 border border-slate-600/50 hover:border-emerald-500/50"
              }`}
            >
              {index + 1}
            </button>
          ))}
          <button
            onClick={() => paginate(currentPage + 1)}
            disabled={
              currentPage === Math.ceil(blogPosts.length / postsPerPage)
            }
            className="p-2 rounded-full bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white transition-all duration-300 shadow-lg shadow-emerald-500/25 hover:shadow-emerald-500/40 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ArrowRight size={20} />
          </button>
        </div>

        {/* Blog Post Modal */}
        {selectedBlog && (
          <div
            className="fixed inset-0 bg-black bg-opacity-95 z-50 flex items-center justify-center p-4 overflow-y-auto"
            onClick={closeBlog}
          >
            <div
              className="bg-gray-900 border border-gray-800 rounded-lg max-w-4xl w-full my-8 max-h-[90vh] overflow-y-auto"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <div className="relative h-64 overflow-hidden rounded-t-lg">
                <img
                  src={selectedBlog.image}
                  alt={selectedBlog.title}
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-linear-to-t from-gray-900 via-gray-900/50 to-transparent" />
                <button
                  onClick={closeBlog}
                  className="absolute top-4 right-4 bg-gray-800 text-white rounded-full w-10 h-10 flex items-center justify-center hover:bg-gray-700 transition-colors z-10"
                  aria-label="Close"
                >
                  <X size={20} />
                </button>
                <div className="absolute bottom-6 left-6">
                  <span className="bg-green-500 text-black text-sm font-semibold px-4 py-1.5 rounded-full">
                    {selectedBlog.category}
                  </span>
                </div>
              </div>

              {/* Modal Content */}
              <div className="p-8">
                <h2 className="text-white text-3xl md:text-4xl font-bold mb-4 leading-tight">
                  {selectedBlog.title}
                </h2>

                <div className="flex items-center gap-6 text-gray-400 text-sm mb-8 pb-6 border-b border-gray-800">
                  <div className="flex items-center gap-2">
                    <Calendar size={16} />
                    <span>{selectedBlog.date}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Clock size={16} />
                    <span>{selectedBlog.readTime}</span>
                  </div>
                  <div className="ml-auto text-green-500 font-medium">
                    Page {blogPage} of {selectedBlog.pages.length}
                  </div>
                </div>

                <div className="text-gray-300 text-lg leading-relaxed mb-8 whitespace-pre-line">
                  {selectedBlog.pages[blogPage - 1]}
                </div>

                {/* Tags */}
                <div className="flex flex-wrap gap-2 mb-8 pb-6 border-b border-gray-800">
                  {selectedBlog.tags.map((tag, index) => (
                    <span
                      key={index}
                      className="text-gray-400 text-sm bg-gray-800 px-3 py-1.5 rounded-full hover:bg-gray-700 transition-colors"
                    >
                      #{tag}
                    </span>
                  ))}
                </div>

                {/* Blog Page Navigation */}
                <div className="flex items-center justify-between">
                  <button
                    onClick={goToPreviousBlogPage}
                    disabled={blogPage === 1}
                    className="flex items-center gap-2 text-green-500 hover:text-green-400 disabled:text-gray-600 disabled:cursor-not-allowed transition-colors font-medium"
                  >
                    <ArrowRight size={18} className="rotate-180" />
                    Previous Page
                  </button>

                  <div className="flex gap-2">
                    {selectedBlog.pages.map((_, index) => (
                      <button
                        key={index}
                        onClick={() => setBlogPage(index + 1)}
                        className={`w-2 h-2 rounded-full transition-all ${
                          blogPage === index + 1
                            ? "bg-green-500 w-8"
                            : "bg-gray-700 hover:bg-gray-600"
                        }`}
                        aria-label={`Go to page ${index + 1}`}
                      />
                    ))}
                  </div>

                  <button
                    onClick={goToNextBlogPage}
                    disabled={blogPage === selectedBlog.pages.length}
                    className="flex items-center gap-2 text-green-500 hover:text-green-400 disabled:text-gray-600 disabled:cursor-not-allowed transition-colors font-medium"
                  >
                    Next Page
                    <ArrowRight size={18} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
