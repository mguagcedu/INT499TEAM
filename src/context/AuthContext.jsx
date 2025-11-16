import React, { createContext, useContext, useState, useEffect } from "react";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);

  useEffect(() => {
    const saved = localStorage.getItem("streamlist_auth");
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (parsed.isAuthenticated) {
          setIsAuthenticated(true);
          setUser(parsed.user || { name: "Demo User" });
        }
      } catch {
        // ignore
      }
    }
  }, []);

  useEffect(() => {
    localStorage.setItem(
      "streamlist_auth",
      JSON.stringify({ isAuthenticated, user })
    );
  }, [isAuthenticated, user]);

  const signInDemo = () => {
    setIsAuthenticated(true);
    setUser({ name: "Demo User" });
  };

  const signOut = () => {
    setIsAuthenticated(false);
    setUser(null);
    localStorage.removeItem("streamlist_auth");
  };

  const value = {
    isAuthenticated,
    user,
    signInDemo,
    signOut,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
