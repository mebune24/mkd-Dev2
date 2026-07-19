import { createContext, useContext } from 'react';
import { useTheme } from '../Hooks/useTheme';

const ThemeContext = createContext(undefined);

export const ThemeProvider = ({ children }) => {
  const themeHook = useTheme();

  return (
    <ThemeContext.Provider value={themeHook}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useThemeContext = () => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useThemeContext must be used within a ThemeProvider');
  }
  return context;
};
