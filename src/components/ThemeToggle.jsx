import React from "react";
import { useTheme } from "../context/ThemeContext";

export default function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  function handleChange(e) {
    setTheme(e.target.value);
  }

  return (
    <label
      style={{
        display: "flex",
        alignItems: "center",
        gap: 4,
        fontSize: 11,
        color: "var(--text-muted)"
      }}
    >
      Theme
      <select
        value={theme}
        onChange={handleChange}
        style={{
          fontSize: 11,
          padding: "3px 6px",
          borderRadius: 999,
          border: "1px solid var(--border-subtle)",
          backgroundColor: "var(--bg-surface)",
          color: "var(--text-main)",
          outline: "none",
          cursor: "pointer"
        }}
      >
        <option value="dark">Dark</option>
        <option value="soft">Soft</option>
        <option value="light">Light</option>
        <option value="high-contrast">High contrast</option>
      </select>
    </label>
  );
}
