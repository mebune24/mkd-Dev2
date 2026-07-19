import {
    Facebook,
    Heart,
    Linkedin,
    MessageSquare,
    Twitter,
} from "lucide-react";

export default function Footer() {
  const socialLinks = [
    {
      name: "WhatsApp",
      icon: MessageSquare,
      url: "https://wa.me/YOUR_WHATSAPP_NUMBER",
      color: "#25D366",
    },
    {
      name: "Facebook",
      icon: Facebook,
      url: "https://facebook.com/YOUR_FACEBOOK_PROFILE",
      color: "#1877F2",
    },
    {
      name: "LinkedIn",
      icon: Linkedin,
      url: "https://linkedin.com/in/YOUR_LINKEDIN_PROFILE",
      color: "#0A66C2",
    },
    {
      name: "Twitter",
      icon: Twitter,
      url: "https://twitter.com/YOUR_TWITTER_HANDLE",
      color: "#1DA1F2",
    },
  ];

  return (
    <footer className="py-16 px-6" style={{
      background: `
        radial-gradient(900px 500px at 10% -10%, rgba(34, 197, 94, 0.08), transparent 60%),
        radial-gradient(700px 400px at 90% -5%, rgba(56, 189, 248, 0.06), transparent 55%),
        var(--bg)
      `
    }}>
      <div className="max-w-7xl mx-auto">
        <div className="w-24 h-1 bg-gradient-to-r from-emerald-400 to-cyan-400 mx-auto mb-12 rounded-full" />

        <div className="grid gap-12 md:grid-cols-3">
          <div className="space-y-6">
            <div style={{ color: 'var(--text)' }} className="text-xl font-semibold">
              Mebune Donstand
            </div>
            <p style={{ color: 'var(--muted)' }} className="text-sm leading-relaxed max-w-sm">
              Building reliable, production-grade web experiences for teams and
              businesses. Focused on delivery, performance, and product clarity.
            </p>
            <p style={{ color: 'var(--muted)' }} className="text-sm flex items-center gap-2">
              Built with <span style={{ color: 'var(--text)' }} className="font-medium">React</span>
              <Heart size={14} style={{ color: 'var(--accent)', fill: 'currentColor' }} />
              Hosted on <span style={{ color: 'var(--text)' }} className="font-medium">Vercel</span>
            </p>
          </div>

          <div className="space-y-4">
            <div style={{ color: 'var(--text)' }} className="text-sm font-semibold uppercase tracking-wider">
              Navigation
            </div>
            <div className="flex flex-col gap-3">
              <a style={{ color: 'var(--muted)' }} className="text-sm hover:transition-colors" href="/">
                Home
              </a>
              <a style={{ color: 'var(--muted)' }} className="text-sm hover:transition-colors" href="/project">
                Projects
              </a>
              <a style={{ color: 'var(--muted)' }} className="text-sm hover:transition-colors" href="/blog">
                Blog
              </a>
              <a style={{ color: 'var(--muted)' }} className="text-sm hover:transition-colors" href="/admin/login">
                Admin
              </a>
            </div>
          </div>

          <div className="space-y-4">
            <div style={{ color: 'var(--text)' }} className="text-sm font-semibold uppercase tracking-wider">
              Connect
            </div>
            <div className="flex gap-4">
              {socialLinks.map((social) => {
                const Icon = social.icon;
                return (
                  <a
                    key={social.name}
                    href={social.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{ color: 'var(--muted)' }}
                    className="p-3 hover:transition-colors"
                    aria-label={social.name}
                  >
                    <Icon size={20} />
                  </a>
                );
              })}
            </div>
            <p style={{ color: 'var(--muted)' }} className="text-xs opacity-75">
              All rights reserved © 2026
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}
