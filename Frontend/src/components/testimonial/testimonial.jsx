import { ChevronLeft, ChevronRight, ExternalLink, Quote, Star } from "lucide-react";
import { useState } from "react";

export default function Testimonial() {
  const [currentIndex, setCurrentIndex] = useState(0);

  const testimonials = [
    {
      id: 1,
      name: "Sarah Johnson",
      role: "CEO at TechStart Inc",
      company: "TechStart Inc",
      image:
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop",
      rating: 5,
      text: "Working with Mebune was an absolute pleasure. He delivered our e-commerce platform ahead of schedule with exceptional quality. His expertise in React and Next.js really showed in the final product. The attention to detail and communication throughout the project was outstanding.",
      project: "E-Commerce Platform",
    },
    {
      id: 2,
      name: "Michael Chen",
      role: "Product Manager at InnovateLabs",
      company: "InnovateLabs",
      image:
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop",
      rating: 5,
      text: "Mebune's problem-solving skills are exceptional. He took our complex requirements and turned them into a sleek, performant application. His knowledge of modern web technologies and best practices made our collaboration smooth and productive. Highly recommended!",
      project: "Task Management System",
    },
    {
      id: 3,
      name: "Emily Rodriguez",
      role: "Founder at DesignHub",
      company: "DesignHub",
      image:
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop",
      rating: 5,
      text: "I was impressed by Mebune's ability to translate our design vision into a fully functional website. His technical skills combined with his understanding of UX principles resulted in a product that exceeded our expectations. Professional, reliable, and talented.",
      project: "Portfolio Website",
    },
  ];

  const nextTestimonial = () => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % testimonials.length);
  };

  const prevTestimonial = () => {
    setCurrentIndex(
      (prevIndex) => (prevIndex - 1 + testimonials.length) % testimonials.length
    );
  };

  const currentTestimonial = testimonials[currentIndex];

  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-center py-20 px-6">
      <div className="max-w-6xl mx-auto w-full">
        {/* Section Title */}
        <div className="mb-16 text-center flex flex-col items-center">
          <span className="inline-flex items-center gap-2 text-xs uppercase tracking-[0.35em] text-emerald-400 font-semibold justify-center">
            <span className="w-2 h-2 rounded-full bg-emerald-400" />
            Client Testimonials
          </span>
          <h3 style={{ color: 'var(--text)' }} className="mt-4 text-4xl font-bold text-center">What Clients Say</h3>
          <p style={{ color: 'var(--muted)' }} className="mt-2 text-sm text-center max-w-2xl">Trusted partnerships built on excellence and results</p>
        </div>

        {/* Testimonial Card */}
        <div className="relative max-w-4xl mx-auto">
          <div className="relative rounded-3xl border border-emerald-400/50 animate-pulse bg-gradient-to-br from-slate-900/80 via-slate-800/60 to-slate-900/80 backdrop-blur-xl p-8 md:p-12 shadow-2xl shadow-emerald-500/30 hover:shadow-emerald-500/50 transition-all duration-500 overflow-hidden hover:border-emerald-400">
            {/* Background Pattern */}
            <div className="absolute inset-0 opacity-5">
              <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-400 rounded-full blur-3xl" />
              <div className="absolute bottom-0 left-0 w-24 h-24 bg-cyan-400 rounded-full blur-2xl" />
            </div>

            {/* Quote Icon */}
            <div className="relative z-10 flex justify-center mb-8">
              <div className="p-4 rounded-full bg-gradient-to-br from-emerald-500/20 to-cyan-500/20 border border-emerald-500/30">
                <Quote size={32} className="text-emerald-400" />
              </div>
            </div>

            {/* Testimonial Text */}
            <blockquote className="relative z-10 text-center mb-10">
              <p style={{ color: 'var(--text)' }} className="text-xl md:text-2xl leading-relaxed font-medium italic">
                "{currentTestimonial.text}"
              </p>
            </blockquote>

            {/* Rating */}
            <div className="relative z-10 flex justify-center gap-1 mb-8">
              {[...Array(currentTestimonial.rating)].map((_, index) => (
                <Star
                  key={index}
                  size={20}
                  className="fill-amber-400 text-amber-400 drop-shadow-sm"
                />
              ))}
            </div>

            {/* Client Info */}
            <div className="relative z-10 flex flex-col md:flex-row items-center justify-center gap-6 mb-8">
              <div className="relative">
                <img
                  src={currentTestimonial.image}
                  alt={currentTestimonial.name}
                  className="w-20 h-20 rounded-full border-4 border-emerald-500/30 shadow-lg shadow-emerald-500/10"
                />
                <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-emerald-500 rounded-full border-2 border-slate-800 flex items-center justify-center">
                  <div className="w-2 h-2 bg-white rounded-full" />
                </div>
              </div>
              <div className="text-center md:text-left">
                <h4 style={{ color: 'var(--text)' }} className="text-2xl font-bold mb-1">
                  {currentTestimonial.name}
                </h4>
                <p style={{ color: 'var(--muted)' }} className="text-sm font-medium mb-1">
                  {currentTestimonial.role}
                </p>
                <p className="text-emerald-400 text-sm font-semibold">
                  {currentTestimonial.company}
                </p>
              </div>
            </div>

            {/* Project Tag */}
            <div className="relative z-10 flex justify-center">
              <div className="inline-flex items-center gap-2 px-6 py-3 rounded-full bg-gradient-to-r from-emerald-500/10 to-cyan-500/10 border border-emerald-500/20 backdrop-blur-sm">
                <span style={{ color: 'var(--muted)' }} className="text-sm font-medium">Project:</span>
                <span className="text-emerald-400 font-semibold text-sm">
                  {currentTestimonial.project}
                </span>
              </div>
            </div>
          </div>

          {/* Navigation Arrows */}
          <button
            onClick={prevTestimonial}
            className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-6 bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white p-4 rounded-full transition-all duration-300 shadow-xl shadow-emerald-500/25 hover:shadow-emerald-500/40 hover:scale-110"
            aria-label="Previous testimonial"
          >
            <ChevronLeft size={24} />
          </button>

          <button
            onClick={nextTestimonial}
            className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-6 bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white p-4 rounded-full transition-all duration-300 shadow-xl shadow-emerald-500/25 hover:shadow-emerald-500/40 hover:scale-110"
            aria-label="Next testimonial"
          >
            <ChevronRight size={24} />
          </button>
        </div>

        {/* Dots Indicator */}
        <div className="flex justify-center gap-4 mt-12">
          {testimonials.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentIndex(index)}
              className={`transition-all duration-300 rounded-full ${
                index === currentIndex
                  ? "w-12 h-3 bg-gradient-to-r from-emerald-500 to-cyan-500 shadow-lg shadow-emerald-500/30"
                  : "w-3 h-3 bg-slate-600 hover:bg-slate-500"
              }`}
              aria-label={`Go to testimonial ${index + 1}`}
            />
          ))}
        </div>

        {/* See More Link */}
        <div className="text-center mt-12">
          <a
            href="#projects"
            className="inline-flex items-center gap-2 bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white font-semibold px-8 py-4 rounded-full transition-all duration-300 shadow-lg shadow-emerald-500/25 hover:shadow-emerald-500/40 hover:scale-105"
          >
            See More Works
            <ExternalLink size={20} />
          </a>
        </div>
      </div>
    </div>
  );
}
