import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import { AppProvider } from "./context/AppContext";
import Layout from "./components/Layout";

import LandingPage from "./pages/LandingPage";
import PlannerPage from "./pages/PlannerPage";
import MoviesPage from "./pages/MoviesPage";
import ShopPage from "./pages/ShopPage";
import FavoritesPage from "./pages/FavoritesPage";
import CartPage from "./pages/CartPage";
import LoginPage from "./pages/LoginPage";

function AppRoutes() {
  return (
    <Routes>
      {/* Landing / splash page */}
      <Route path="/" element={<LandingPage />} />

      {/* All main app pages share the dashboard layout */}
      <Route element={<Layout />}>
        <Route path="/planner" element={<PlannerPage />} />
        <Route path="/movies" element={<MoviesPage />} />
        <Route path="/shop" element={<ShopPage />} />
        <Route path="/favorites" element={<FavoritesPage />} />
        <Route path="/cart" element={<CartPage />} />
      </Route>

      {/* Dedicated login page for real Google OAuth */}
      <Route path="/login" element={<LoginPage />} />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppProvider>
          <AppRoutes />
        </AppProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
