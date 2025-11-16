import React from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useApp } from "../context/AppContext";
import { useAuth } from "../context/AuthContext";

export default function Layout() {
  const app = useApp();
  const auth = useAuth();
  const navigate = useNavigate();

  const cart = app?.cart || [];
  const cartCount = Array.isArray(cart)
    ? cart.reduce((sum, item) => sum + (item.quantity || 0), 0)
    : 0;

  const navLinkClass = ({ isActive }) =>
    "nav-link" + (isActive ? " nav-link-active" : "");

  const handleDemoSignIn = () => {
    if (auth?.demoSignIn) {
      auth.demoSignIn();
    }
    navigate("/planner");
  };

  const handleSignOut = () => {
    if (auth?.signOut) {
      auth.signOut();
    }
    navigate("/");
  };

  return (
    <div className="app-shell">
      <aside className="app-sidebar">
        <div className="logo">EZTechMovie</div>
        <nav className="sidebar-nav">
          <NavLink to="/planner" className={navLinkClass}>
            Planner
          </NavLink>
          <NavLink to="/movies" className={navLinkClass}>
            Movies
          </NavLink>
          <NavLink to="/shop" className={navLinkClass}>
            Shop
          </NavLink>
          <NavLink to="/favorites" className={navLinkClass}>
            Favorites
          </NavLink>
          <NavLink to="/cart" className={navLinkClass}>
            Cart{" "}
            {cartCount > 0 && (
              <span className="cart-count">({cartCount})</span>
            )}
          </NavLink>
        </nav>
      </aside>

      <div className="app-main">
        <header className="app-header">
          <div className="header-left">
            <h1 className="app-title">StreamList Dashboard</h1>
          </div>
          <div className="header-right">
            <NavLink to="/cart" className="nav-link nav-link-pill">
              Cart {cartCount > 0 && <span className="cart-count">({cartCount})</span>}
            </NavLink>

            {auth?.user ? (
              <>
                <span className="user-label">
                  Signed in as {auth.user.name || "User"}
                </span>
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={handleSignOut}
                >
                  Sign out
                </button>
              </>
            ) : (
              <>
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={handleDemoSignIn}
                >
                  Continue demo
                </button>
                <NavLink to="/login" className="btn-primary-link">
                  Google sign in
                </NavLink>
              </>
            )}
          </div>
        </header>

        <main className="app-content">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
