import { motion } from "framer-motion";
import { ChevronLeft, ChevronRight, Star } from "lucide-react";
import { useMemo, useState } from "react";
import { useCarousel } from "../../Hooks/useCarousel";
import { useTestimonials } from "../../Hooks/useTestimonials";

export default function Testimonial() {
  const { testimonials } = useTestimonials();
  const { currentIndex, next, prev, goTo } = useCarousel(testimonials.length);

  const getInitials = (name) => {
    if (!name) return "?";
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.slice(0, 2).toUpperCase();
  };

  const current = testimonials[currentIndex];

  if (testimonials.length === 0) return null;

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
      <div className="max-w-3xl mx-auto">
        <div className="text-center mb-12">
          <h2 style={{ color: 'var(--accent)' }} className="text-xl font-medium mb-2">Client Feedback</h2>
          <h3 style={{ color: 'var(--text)' }} className="text-4xl font-bold">Testimonials</h3>
        </div>

        <div className="relative">
          <div className="rounded-2xl border border-white/10 bg-white/5 p-8 md:p-10">
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 rounded-full bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center mb-4">
                <span className="text-emerald-400 font-bold text-lg">{getInitials(current.name)}</span>
              </div>

              <p style={{ color: 'var(--text)' }} className="text-lg md:text-xl leading-relaxed mb-6">
                "{current.text}"
              </p>

              <div className="flex gap-1 mb-4">
                {[...Array(current.rating)].map((_, i) => (
                  <Star key={i} size={18} style={{ color: 'var(--accent)', fill: 'var(--accent)' }} />
                ))}
              </div>

              <h4 style={{ color: 'var(--text)' }} className="text-xl font-semibold">{current.name}</h4>
              {(current.role || current.company) && (
                <p style={{ color: 'var(--muted)' }} className="text-sm">
                  {current.role}{current.role && current.company ? " at " : ""}{current.company}
                </p>
              )}
              {current.project && (
                <p style={{ color: 'var(--accent)' }} className="text-sm font-medium mt-1">
                  {current.project}
                </p>
              )}
            </div>
          </div>

          {testimonials.length > 1 && (
            <>
              <button
                onClick={prev}
                className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-4 md:-translate-x-12 p-3 rounded-full border border-white/10 bg-white/5 hover:bg-white/10 transition-colors"
                style={{ color: 'var(--text)' }}
                aria-label="Previous testimonial"
              >
                <ChevronLeft size={20} />
              </button>
              <button
                onClick={next}
                className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-4 md:translate-x-12 p-3 rounded-full border border-white/10 bg-white/5 hover:bg-white/10 transition-colors"
                style={{ color: 'var(--text)' }}
                aria-label="Next testimonial"
              >
                <ChevronRight size={20} />
              </button>
            </>
          )}
        </div>

        {testimonials.length > 1 && (
          <div className="flex justify-center gap-2 mt-8">
            {testimonials.map((_, index) => (
              <button
                key={index}
                onClick={() => goTo(index)}
                className="rounded-full transition-all duration-300"
                style={{
                  background: index === currentIndex ? 'var(--accent)' : 'var(--muted)',
                  width: index === currentIndex ? '24px' : '10px',
                  height: '10px'
                }}
                aria-label={`Go to testimonial ${index + 1}`}
              />
            ))}
          </div>
        )}
      </div>
    </motion.div>
  );
}
