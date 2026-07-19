import { motion } from 'framer-motion';
import Journey from "../components/Journey/Journey";
import About from "./About/About";
import Blogging from "./blogPage/Blogging";
import CtaSection from "./ctaSection/CtaSection";
import HeroSection from "./HeroSection/Hero";
import Tech from "./tech/Tech";
import Testimonial from "./testimonial/testimonial";
import Works from "./works/Works";

const sectionVariants = {
  hidden: { opacity: 0, y: 50 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  }
};

const slideInFromRight = {
  hidden: { opacity: 0, x: 100 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  }
};

const slideInFromLeft = {
  hidden: { opacity: 0, x: -100 },
  visible: {
    opacity: 1,
    x: 0,
    transition: {
      duration: 0.8,
      ease: "easeOut"
    }
  }
};

export default function Home() {
  // Remove global parallax transform that was causing shaking
  // const { transform } = useParallax(0.3);

  return (
    <motion.div
      className="relative"
      // Remove the transform style that was causing the shaking
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 1 }}
    >
      <motion.div
        variants={sectionVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <HeroSection />
      </motion.div>

      <motion.div
        variants={slideInFromLeft}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <About />
      </motion.div>

      <motion.div
        variants={slideInFromRight}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <Journey />
      </motion.div>

      <motion.div
        variants={slideInFromLeft}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <Tech />
      </motion.div>

      <motion.div
        variants={slideInFromRight}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <Works />
      </motion.div>

      <motion.div
        variants={slideInFromLeft}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <Testimonial />
      </motion.div>

      <motion.div
        variants={slideInFromRight}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <Blogging />
      </motion.div>

      <motion.div
        variants={sectionVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <CtaSection />
      </motion.div>
    </motion.div>
  );
}
