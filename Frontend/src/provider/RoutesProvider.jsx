
import { createBrowserRouter } from "react-router-dom";
import App from "../App";
import AboutMe from "../components/About/AboutMe";
import Blogging from "../components/blogPage/Blogging";
import Certificate from "../components/certifications/Certificate";
import CtaSection from "../components/ctaSection/CtaSection";
import Hero from "../components/HeroSection/Hero";
import Tech from "../components/tech/Tech";
import Testimonial from "../components/testimonial/testimonial";
import Works from "../components/works/Works";

const Home = () => (
  <>
    <Hero />
    <AboutMe />
    <Works limit={3} />
    <Testimonial />
    <Tech />
    <Certificate />
    <CtaSection />
  </>
);

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      {
        path: "/",
        element: <Home />,
      },
      {
        path: "/about",
        element: <AboutMe />,
      },
      {
        path: "/blog",
        element: <Blogging />,
      },
      {
        path: "/project",
        element: <Works />,
      },
      {
        path: "*",
        element: <div>Page Not Found</div>,
      },
    ],
  },
]);

export default router;
