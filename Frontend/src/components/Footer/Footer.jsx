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
      color: "hover:text-[#25D366]",
      bgColor: "hover:bg-[#25D366]",
    },
    {
      name: "Facebook",
      icon: Facebook,
      url: "https://facebook.com/YOUR_FACEBOOK_PROFILE",
      color: "hover:text-[#1877F2]",
      bgColor: "hover:bg-[#1877F2]",
    },
    {
      name: "LinkedIn",
      icon: Linkedin,
      url: "https://linkedin.com/in/YOUR_LINKEDIN_PROFILE",
      color: "hover:text-[#0A66C2]",
      bgColor: "hover:bg-[#0A66C2]",
    },
    {
      name: "Twitter",
      icon: Twitter,
      url: "https://twitter.com/YOUR_TWITTER_HANDLE",
      color: "hover:text-[#1DA1F2]",
      bgColor: "hover:bg-[#1DA1F2]",
    },
  ];

  return (
    <footer className="bg-black border-t border-gray-800 py-8 px-6">
      <div className="max-w-7xl mx-auto">
        {/* Main Footer Text */}
        <p className="text-gray-400 text-base md:text-lg mb-2 flex items-center justify-center gap-2">
          Designed and Developed by{" "}
          <span className="text-green-500 font-semibold">Mebune Donstand</span>
        </p>

        {/* Tech Stack Info */}
        <p className="text-gray-500 text-sm md:text-base flex items-center justify-center gap-2">
          Built with <span className="text-white font-medium">React</span>
          <Heart size={14} className="fill-green-500 text-green-500" />
          Hosted on <span className="text-white font-medium">Vercel</span>
        </p>

        {/* Copyright */}
        <p className="text-gray-500 text-sm md:text-base mt-2 flex items-center justify-center gap-2">
          All rights reserved © 2026
        </p>

        <div className="text-center">
          {/* Social Media Links */}
          <div className="flex justify-center gap-4 mb-6 mt-4">
            {socialLinks.map((social) => {
              const Icon = social.icon;
              return (
                <a
                  key={social.name}
                  href={social.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className={`text-gray-400 ${social.color} transition-colors duration-300 p-3 rounded-full bg-gray-900 hover:bg-opacity-20`}
                  aria-label={social.name}
                >
                  <Icon size={24} />
                </a>
              );
            })}
          </div>
        </div>
      </div>
    </footer>
  );
}
