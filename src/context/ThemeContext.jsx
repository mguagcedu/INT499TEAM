import React, { createContext, useContext, useEffect, useState } from "react";

const ThemeContext = createContext(null);
const THEME_KEY = "streamlist-theme";

const palettes = {
  default: {
    "--bg": "#020617",
    "--text": "#e5e7eb",
    "--card-bg": "#020617",
    "--accent": "#0ea5e9",
    "--accent-soft": "rgba(14,165,233,0.15)",
  },
  mid: {
    "--bg": "#0f172a",
    "--text": "#f9fafb",
    "--card-bg": "#020617",
    "--accent": "#38bdf8",
    "--accent-soft": "rgba(56,189,248,0.2)",
  },
  high: {
    "--bg": "#000000",
    "--text": "#ffffff",
    "--card-bg": "#000000",
    "--accent": "#facc15",
    "--accent-soft": "rgba(250,204,21,0.25)",
  },
  light: {
    "--bg": "#f9fafb",
    "--text": "#020617",
    "--card-bg": "#ffffff",
    "--accent": "#0f766e",
    "--accent-soft": "rgba(15,118,110,0.12)",
  },
};

function applyTheme(theme) {
  const root = document.documentElement;
  const palette = palettes[theme] || palettes.default;
  root.setAttribute("data-theme", theme);
  Object.entries(palette).forEach(([key, value]) => {
    root.style.setProperty(key, value);
  });
}

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(() => {
    if (typeof window === "undefined") return "default";
    return localStorage.getItem(THEME_KEY) || "default";
  });

  useEffect(() => {
    if (typeof window === "undefined") return;
    localStorage.setItem(THEME_KEY, theme);
    applyTheme(theme);
  }, [theme]);

  const value = {
    theme,
    setTheme,
    themeOptions: [
      { id: "default", label: "Default" },
      { id: "mid", label: "Mid contrast" },
      { id: "high", label: "High contrast" },
      { id: "light", label: "Light / white" },
    ],
  };

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) {
    throw new Error("useTheme must be used inside ThemeProvider");
  }
  return ctx;
}
