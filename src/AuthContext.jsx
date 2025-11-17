import React, { createContext, useContext, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const stored = localStorage.getItem("eztech_user");
    if (stored) setUser(JSON.parse(stored));
  }, []);

  const loginWithGoogle = async () => {
    const fakeUser = {
      id: "1234567890",
      name: "Demo User",
      email: "demo@example.com",
      provider: "google"
    };
    setUser(fakeUser);
    localStorage.setItem("eztech_user", JSON.stringify(fakeUser));
    navigate("/");
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("eztech_user");
    navigate("/login");
  };

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, loginWithGoogle, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
