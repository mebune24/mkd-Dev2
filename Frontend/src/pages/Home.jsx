import { motion } from 'framer-motion';
import Journey from "../components/Journey/Journey";
import About from "./About/About";
import Blogging from "./blogPage/Blogging";
import CtaSection from "./ctaSection/CtaSection";
import HeroSection from "./HeroSection/Hero";
import Tech from "./tech/Tech";
import Testimonial from "./testimonial/testimonial";
import Works from "./works/Works";

const fadeInUp = {
  hidden: { opacity: 0, y: 40 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.7,
      delay: i * 0.1,
      ease: "easeOut"
    }
  })
};

export default function Home() {
  return (
    <motion.div
      className="relative"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.8 }}
    >
      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }}>
        <HeroSection />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={1}>
        <About />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={2}>
        <Journey />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={3}>
        <Tech />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={4}>
        <Works />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={5}>
        <Testimonial />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={6}>
        <Blogging />
      </motion.section>

      <motion.section variants={fadeInUp} initial="hidden" whileInView="visible" viewport={{ once: true, amount: 0.1 }} custom={7}>
        <CtaSection />
      </motion.section>
    </motion.div>
  );
}
