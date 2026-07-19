import { useEffect, useState } from 'react';

/**
 * Custom hook for carousel functionality
 * @param {number} itemsCount - Total number of items in carousel
 * @param {number} autoPlayInterval - Auto play interval in milliseconds
 * @returns {Object} - { currentIndex, setCurrentIndex, next, prev }
 */
export const useCarousel = (itemsCount, autoPlayInterval = 6000) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    if (itemsCount < 2) return;

    const id = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % itemsCount);
    }, autoPlayInterval);

    return () => clearInterval(id);
  }, [itemsCount, autoPlayInterval]);

  const next = () => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % itemsCount);
  };

  const prev = () => {
    setCurrentIndex((prevIndex) => (prevIndex - 1 + itemsCount) % itemsCount);
  };

  const goTo = (index) => {
    setCurrentIndex(index);
  };

  return { currentIndex, setCurrentIndex, next, prev, goTo };
};
