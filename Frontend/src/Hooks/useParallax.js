import { useEffect, useRef, useState } from 'react';

export function useParallax(speed = 0.5) {
  const [offsetY, setOffsetY] = useState(0);
  const frame = useRef(null);

  useEffect(() => {
    const handleScroll = () => {
      if (frame.current !== null) return;
      frame.current = requestAnimationFrame(() => {
        setOffsetY(window.pageYOffset);
        frame.current = null;
      });
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => {
      window.removeEventListener('scroll', handleScroll);
      if (frame.current !== null) cancelAnimationFrame(frame.current);
    };
  }, [frame]);

  return {
    transform: `translateY(${offsetY * speed}px)`,
    offsetY
  };
}

export function useParallaxX(speed = 0.5) {
  const [offsetY, setOffsetY] = useState(0);
  const frame = useRef(null);

  useEffect(() => {
    const handleScroll = () => {
      if (frame.current !== null) return;
      frame.current = requestAnimationFrame(() => {
        setOffsetY(window.pageYOffset);
        frame.current = null;
      });
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => {
      window.removeEventListener('scroll', handleScroll);
      if (frame.current !== null) cancelAnimationFrame(frame.current);
    };
  }, [frame]);

  return {
    transform: `translateX(${offsetY * speed}px)`,
    offsetY
  };
}

export function useScrollDirection() {
  const [scrollDirection, setScrollDirection] = useState('up');
  const [lastScrollY, setLastScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.pageYOffset;
      if (currentScrollY > lastScrollY) {
        setScrollDirection('down');
      } else {
        setScrollDirection('up');
      }
      setLastScrollY(currentScrollY);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [lastScrollY]);

  return scrollDirection;
}
