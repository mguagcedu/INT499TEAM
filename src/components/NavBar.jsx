import React from "react";
import { NavLink } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useCartCount } from "../hooks/useCartCount";

export default function NavBar() {
  const cartCount = useCartCount();
  const { isAuthenticated, logout } = useAuth();

  return (
    <header className="app-header">
      <div className="app-header-inner">
        <NavLink to="/" className="brand">
          StreamList
        </NavLink>

        <div className="nav-links">
          <NavLink to="/planner">Planner</NavLink>
          <NavLink to="/movies">Movies</NavLink>
          <NavLink to="/shop">Shop</NavLink>
          <NavLink to="/favorites">Favorites</NavLink>

          {/* Updated Cart button */}
          <NavLink to="/cart" className="btn-secondary-small">
            Cart{cartCount > 0 ? ` (${cartCount})` : ""}
          </NavLink>

          {isAuthenticated ? (
            <button
              type="button"
              className="btn-secondary-small"
              onClick={logout}
            >
              Sign out
            </button>
          ) : (
            <NavLink to="/login" className="btn-secondary-small">
              Sign in
            </NavLink>
          )}
        </div>
      </div>
    </header>
  );
}
