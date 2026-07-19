import { FileText, Linkedin, Mail } from "lucide-react";

export default function CtaSection() {
  return (
    <div className="min-h-screen bg-black flex items-center justify-center px-6 py-20">
      <div className="max-w-4xl w-full text-center">
        {/* Main Heading */}
        <h2 className="text-green-500 text-2xl md:text-3xl font-medium mb-4">
          Let's Collaborate
        </h2>
        <h3 className="text-white text-5xl md:text-7xl font-bold mb-8">
          Keep in Touch
        </h3>

        {/* Description */}
        <p className="text-gray-300 text-lg md:text-xl leading-relaxed mb-12 max-w-2xl mx-auto">
          I am currently specializing in frontend development. Feel free to get
          in touch and talk more about your projects. I'd love to hear from you
          and discuss how we can work together.
        </p>

        {/* CTA Buttons */}
        <div className="flex flex-wrap justify-center gap-4">
          <a
            href="https://linkedin.com/in/yourprofile"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-3 bg-white hover:bg-gray-200 text-black font-semibold px-8 py-4 rounded-lg transition-colors duration-300"
          >
            <Linkedin size={24} />
            LinkedIn
          </a>

          <a
            href="mailto:your.email@example.com"
            className="flex items-center gap-3 bg-green-500 hover:bg-green-600 text-black font-semibold px-8 py-4 rounded-lg transition-colors duration-300"
          >
            <Mail size={24} />
            Email Me
          </a>

          <a
            href="/resume.pdf"
            download
            className="flex items-center gap-3 bg-gray-800 hover:bg-gray-700 text-white font-semibold px-8 py-4 rounded-lg border border-gray-700 hover:border-green-500 transition-all duration-300"
          >
            <FileText size={24} />
            Resume
          </a>
        </div>

        {/* Decorative Element */}
        <div className="mt-16 flex justify-center">
          <div className="w-24 h-1 bg-linear-to-r from-transparent via-green-500 to-transparent"></div>
        </div>
      </div>
    </div>
  );
}
