import { MessageCircle, Moon, Sun } from "lucide-react";
import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { useProfile } from "../Hooks/useProfile";
import { useTheme } from "../Hooks/useTheme";
import { NAV_ITEMS, WHATSAPP_URL } from "../utils/constants";

export default function NavigationMenu() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { theme, toggleTheme } = useTheme();
  const { profile } = useProfile();
  const location = useLocation();

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
  };

  const closeMobileMenu = () => {
    setIsMobileMenuOpen(false);
  };

  return (
    <nav className="fixed w-full z-20 py-6">
      <div className="max-w-7xl mx-auto px-6">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <div className="flex-shrink-0">
            <Link to="/" className="flex items-center gap-3 cursor-pointer transition-colors group">
              <div className="flex items-center justify-center w-12 h-12 rounded-full overflow-hidden" style={{ backgroundColor: 'var(--accent)', opacity: 0.1 }}>
                <img
                  src={profile?.avatar || "http://localhost:3000/uploads/test_avatar.png"}
                  alt={profile?.name || "Mebune Donstand"}
                  className="w-full h-full object-cover rounded-full"
                  onError={(e) => {
                    // Fallback to initials if image fails to load
                    e.target.style.display = 'none';
                    e.target.parentElement.innerHTML = `<span style="color: var(--accent); font-weight: bold; font-size: 18px;">${(profile?.name || 'MD').split(' ').map(n => n[0]).join('').toUpperCase()}</span>`;
                  }}
                />
              </div>
              <div className="leading-tight">
                <div style={{ color: 'var(--text)' }} className="text-lg font-semibold group-hover:transition-colors">
                  {profile?.name || 'Mebune Donstand'}
                </div>
                <div style={{ color: 'var(--muted)' }} className="text-xs uppercase tracking-wider">
                  {profile?.title || 'Software Engineer'}
                </div>
              </div>
            </Link>
          </div>

          {/* Navigation Links */}
          <div className="hidden md:flex items-center gap-8">
            <div className="flex items-center gap-6">
              {NAV_ITEMS.map((item) => (
                <Link
                  key={item.id}
                  to={item.to}
                  style={{
                    color: location.pathname === item.to ? 'var(--accent)' : 'var(--muted)',
                    fontWeight: location.pathname === item.to ? '600' : '500'
                  }}
                  className="text-sm transition-colors hover:transition-colors"
                >
                  {item.label}
                </Link>
              ))}
            </div>

            <div className="flex items-center gap-4">
              <button
                type="button"
                onClick={toggleTheme}
                style={{ color: 'var(--muted)' }}
                className="p-2 hover:transition-colors"
                aria-label="Toggle light and dark mode"
                title="Toggle light and dark mode"
              >
                {theme === "dark" ? <Sun size={20} /> : <Moon size={20} />}
              </button>

              <a
                href={WHATSAPP_URL}
                target="_blank"
                rel="noopener noreferrer"
                style={{ color: 'var(--accent)' }}
                className="p-2 hover:transition-colors"
                aria-label="Contact on WhatsApp"
                title="Contact on WhatsApp"
              >
                <MessageCircle size={20} />
              </a>
            </div>
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden">
            <button
              onClick={toggleMobileMenu}
              style={{ color: 'var(--muted)' }}
              className="p-2 hover:transition-colors"
            >
              <svg
                className="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d={isMobileMenuOpen ? "M6 18L18 6M6 6l12 12" : "M4 6h16M4 12h16M4 18h16"}
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      {isMobileMenuOpen && (
        <div className="md:hidden bg-black/90 border-t border-white/10 backdrop-blur-xl">
          <div className="px-2 pt-2 pb-3 space-y-1">
            {NAV_ITEMS.map((item) => (
              <Link
                key={item.id}
                to={item.to}
                onClick={closeMobileMenu}
                className={`block w-full text-left px-3 py-2 rounded-md text-base font-medium transition-colors ${
                  location.pathname === item.to
                    ? "text-emerald-400 bg-white/5"
                    : "text-slate-300 hover:text-white hover:bg-white/5"
                }`}
              >
                {item.label}
              </Link>
            ))}
            <button
              type="button"
              onClick={toggleTheme}
              className="theme-toggle-mobile flex items-center gap-2 px-3 py-2 text-base font-medium text-slate-200 hover:text-white"
            >
              {theme === "dark" ? <Sun size={18} /> : <Moon size={18} />}
              Theme
            </button>
            <a
              href={WHATSAPP_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 px-3 py-2 text-base font-medium text-emerald-400 hover:text-emerald-300"
            >
              <MessageCircle size={18} />
              WhatsApp
            </a>
          </div>
        </div>
      )}
    </nav>
  );
}
