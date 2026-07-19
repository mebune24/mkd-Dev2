import { useProfile } from "../../Hooks/useProfile";
import aboutImg from "../images/mebune.jpg";

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
      <div className="max-w-7xl mx-auto relative">
        {/* Hero Section */}
        <div className="text-center mb-20">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-500/10 mb-6">
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

        {/* Main Content Grid */}
        <div className="grid lg:grid-cols-2 gap-16 items-start mb-20">
          {/* Left Column - About & Focus */}
          <div className="space-y-12">
            {/* About Section */}
            <div>
              <h3 className="text-2xl md:text-3xl font-bold mb-8" style={{ color: 'var(--text)' }}>
                Company-ready <span style={{
                  background: 'linear-gradient(135deg, var(--accent) 0%, #38bdf8 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text'
                }}>profile</span>
              </h3>

              <div className="space-y-6">
                <p style={{ color: 'var(--text)' }} className="text-lg leading-relaxed">
                  I'm <span style={{ color: 'var(--accent)', fontWeight: '600' }}>{profile?.name || 'Mebune Donstand'}</span>, {profile?.bio || 'a self-taught software engineer who builds production-grade web systems for companies that care about reliability and speed. I operate comfortably across product, design, and engineering to ship outcomes that move business metrics.'}
                </p>

                <p style={{ color: 'var(--muted)' }} className="text-lg leading-relaxed">
                  I specialize in modern frontend and full-stack delivery with React, Next.js, and Node.js, with a strong emphasis on system
                  design, accessibility, and performance. My work focuses on scalable architecture, clear component contracts, and
                  maintainable codebases that teams can evolve safely.
                </p>

                <p style={{ color: 'var(--muted)' }} className="text-lg leading-relaxed">
                  My approach is engineering-first: precise requirements, measurable milestones, and clean deployments. I prioritize
                  quality through testing, thoughtful APIs, and consistent code standards, while keeping user experience fast, focused, and intuitive.
                </p>
              </div>
            </div>

            {/* Focus Areas */}
            <div>
              <h4 className="text-xl font-bold mb-6" style={{ color: 'var(--text)' }}>Delivery Snapshot</h4>
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="w-2 h-2 rounded-full mt-2" style={{ backgroundColor: 'var(--accent)' }} />
                  <p style={{ color: 'var(--muted)' }}>Structured scoping and requirements alignment</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-2 h-2 rounded-full mt-2" style={{ backgroundColor: '#38bdf8' }} />
                  <p style={{ color: 'var(--muted)' }}>Performance-first engineering and accessibility</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-2 h-2 rounded-full mt-2" style={{ backgroundColor: 'var(--accent)' }} />
                  <p style={{ color: 'var(--muted)' }}>Reliable releases with clean, maintainable code</p>
                </div>
                <div className="flex items-start gap-3">
                  <div className="w-2 h-2 rounded-full mt-2" style={{ backgroundColor: '#38bdf8' }} />
                  <p style={{ color: 'var(--muted)' }}>Cross-functional collaboration with product & design</p>
                </div>
              </div>
            </div>

            {/* Journey Timeline */}
            <div className="rounded-[28px] border border-white/10 bg-slate-900/80 p-8 shadow-xl">
              <h3 className="text-2xl font-bold mb-6" style={{ color: 'var(--text)' }}>My Journey</h3>
              <div className="space-y-6">
                <div className="flex gap-4">
                  <div className="shrink-0 mt-1 h-3 w-3 rounded-full bg-emerald-400" />
                  <div>
                    <p className="text-sm uppercase tracking-[0.25em] text-emerald-400 font-semibold mb-2">2022–2023</p>
                    <h4 className="text-lg font-semibold text-white mb-1">Secondary School</h4>
                    <p className="text-sm leading-relaxed text-slate-400">
                      Built the foundational knowledge that launched my software engineering journey and honed problem solving in technology-driven studies.
                    </p>
                  </div>
                </div>
                <div className="flex gap-4">
                  <div className="shrink-0 mt-1 h-3 w-3 rounded-full bg-cyan-400" />
                  <div>
                    <p className="text-sm uppercase tracking-[0.25em] text-cyan-400 font-semibold mb-2">2022–Present</p>
                    <h4 className="text-lg font-semibold text-white mb-1">University - Software Engineering</h4>
                    <p className="text-sm leading-relaxed text-slate-400">
                      Studying Software Engineering while growing practical experience through modern web development and systems design.
                    </p>
                  </div>
                </div>
                <div className="flex gap-4">
                  <div className="shrink-0 mt-1 h-3 w-3 rounded-full bg-slate-200" />
                  <div>
                    <p className="text-sm uppercase tracking-[0.25em] text-slate-300 font-semibold mb-2">Present</p>
                    <h4 className="text-lg font-semibold text-white mb-1">Fibre Optics Technician</h4>
                    <p className="text-sm leading-relaxed text-slate-400">
                      Configuring OLT, ONT, and Wi-Fi box equipment, installing and managing end-to-end fibre optics networks for Camtel.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Focus Cards */}
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <div style={{ color: 'var(--accent)' }} className="text-xs uppercase tracking-widest mb-3 font-semibold">
                  Focus
                </div>
                <h5 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-3">
                  Product Delivery
                </h5>
                <p style={{ color: 'var(--muted)' }} className="text-sm leading-relaxed">
                  End-to-end execution with clear scopes, stakeholder alignment, and reliable releases.
                </p>
              </div>

              <div>
                <div style={{ color: '#38bdf8' }} className="text-xs uppercase tracking-widest mb-3 font-semibold">
                  Engineering
                </div>
                <h5 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-3">
                  Quality Systems
                </h5>
                <p style={{ color: 'var(--muted)' }} className="text-sm leading-relaxed">
                  Maintainable architecture, tested flows, and performance-first delivery.
                </p>
              </div>
            </div>
          </div>

          {/* Right Column - Image & Tech Stack */}
          <div className="space-y-12">
            {/* Profile Image */}
            <div className="relative">
              <div className="relative overflow-hidden rounded-xl">
                <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent z-10" />
                <img
                  src={aboutImg}
                  alt="Mebune Donstand"
                  className="w-full h-80 object-cover object-center"
                />
                <div className="absolute bottom-4 left-4 right-4">
                  <h3 style={{ color: 'var(--text)' }} className="text-2xl font-bold">Mebune Donstand</h3>
                  <p style={{ color: 'var(--accent)' }} className="text-sm font-medium">Software Engineer</p>
                </div>
              </div>
            </div>

            {/* Tech Stack */}
            <div>
              <h4 className="text-xl font-bold mb-6" style={{ color: 'var(--text)' }}>My Arsenal</h4>
              <p style={{ color: 'var(--muted)' }} className="mb-6">
                Technologies & Tools - A company-ready stack focused on scalable products, clean delivery, and reliable systems.
              </p>

              {/* Languages */}
              <div className="mb-8">
                <h5 style={{ color: 'var(--text)' }} className="font-semibold mb-4">Languages</h5>
                <div className="flex flex-wrap gap-3">
                  {['HTML5', 'CSS3', 'JavaScript', 'Python'].map((tech) => (
                    <span
                      key={tech}
                      style={{ color: 'var(--text)' }}
                      className="px-3 py-1 text-sm font-medium hover:transition-colors duration-300 cursor-default"
                    >
                      {tech}
                    </span>
                  ))}
                </div>
              </div>

              {/* Frameworks & Libraries */}
              <div className="mb-8">
                <h5 style={{ color: 'var(--text)' }} className="font-semibold mb-4">Frameworks & Libraries</h5>
                <div className="flex flex-wrap gap-3">
                  {['React', 'Next.js', 'Node.js', 'Express', 'Tailwind CSS', 'Bootstrap'].map((tech) => (
                    <span
                      key={tech}
                      style={{ color: 'var(--text)' }}
                      className="px-3 py-1 text-sm font-medium hover:transition-colors duration-300 cursor-default"
                    >
                      {tech}
                    </span>
                  ))}
                </div>
              </div>

              {/* Platforms & Data */}
              <div>
                <h5 style={{ color: 'var(--text)' }} className="font-semibold mb-4">Platforms & Data</h5>
                <div className="flex flex-wrap gap-3">
                  {['PostgreSQL', 'MySQL', 'MongoDB', 'Firebase', 'Git', 'GitHub', 'Docker', 'Figma'].map((tech) => (
                    <span
                      key={tech}
                      style={{ color: 'var(--text)' }}
                      className="px-3 py-1 text-sm font-medium hover:transition-colors duration-300 cursor-default"
                    >
                      {tech}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* Engagement Model */}
            <div>
              <h4 style={{ color: 'var(--text)' }} className="text-xl font-bold mb-6 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-emerald-500/20 flex items-center justify-center">
                  <div className="w-3 h-3 rounded-full bg-emerald-400" />
                </div>
                Engagement Model
              </h4>
              <div className="space-y-4">
                <div className="flex items-start gap-4">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-emerald-500/20 flex items-center justify-center text-emerald-400 font-bold text-sm">
                    01
                  </div>
                  <div>
                    <h6 style={{ color: 'var(--text)' }} className="font-semibold mb-1">Discovery</h6>
                    <p style={{ color: 'var(--muted)' }} className="text-sm">Align goals, scope, timelines, and success metrics.</p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-cyan-500/20 flex items-center justify-center text-cyan-400 font-bold text-sm">
                    02
                  </div>
                  <div>
                    <h6 style={{ color: 'var(--text)' }} className="font-semibold mb-1">Execution</h6>
                    <p style={{ color: 'var(--muted)' }} className="text-sm">Ship in iterations with clear QA and stakeholder updates.</p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="flex-shrink-0 w-8 h-8 rounded-full bg-blue-500/20 flex items-center justify-center text-blue-400 font-bold text-sm">
                    03
                  </div>
                  <div>
                    <h6 style={{ color: 'var(--text)' }} className="font-semibold mb-1">Launch</h6>
                    <p style={{ color: 'var(--muted)' }} className="text-sm">Production release, monitoring, and handoff for scale.</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Collaboration Section */}
        <div className="text-center">
          <h3 className="text-2xl md:text-3xl font-bold mb-6" style={{ color: 'var(--text)' }}>
            Let's build a product your team is proud to ship
          </h3>
          <p style={{ color: 'var(--muted)' }} className="text-lg max-w-3xl mx-auto mb-8">
            I partner with teams to deliver production-grade web experiences with clear scopes, reliable execution, and measurable outcomes.
            If you're hiring or need a product-focused engineer, let's talk.
          </p>

          <div className="grid md:grid-cols-3 gap-6 max-w-2xl mx-auto mb-8">
            <div className="text-center">
              <div style={{ color: 'var(--accent)' }} className="text-2xl font-bold mb-1">Open</div>
              <div style={{ color: 'var(--muted)' }} className="text-sm">Availability</div>
            </div>
            <div className="text-center">
              <div style={{ color: 'var(--text)' }} className="text-2xl font-bold mb-1">Remote / Hybrid</div>
              <div style={{ color: 'var(--muted)' }} className="text-sm">Location</div>
            </div>
            <div className="text-center">
              <div style={{ color: 'var(--text)' }} className="text-2xl font-bold mb-1">24–48 hrs</div>
              <div style={{ color: 'var(--muted)' }} className="text-sm">Response time</div>
            </div>
          </div>

          <div className="flex justify-center gap-4">
            <button className="px-6 py-3 rounded-full font-medium transition-all duration-300 shadow-lg shadow-current/25 hover:shadow-current/40" style={{
              backgroundColor: 'var(--accent)',
              color: 'white'
            }}>
              Start a Conversation
            </button>
            <button className="px-6 py-3 rounded-full font-medium border transition-all duration-300 shadow-lg shadow-slate-900/25 hover:shadow-slate-900/40" style={{
              borderColor: 'var(--accent)',
              color: 'var(--accent)',
              backgroundColor: 'var(--bg)'
            }}>
              View Resume
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
