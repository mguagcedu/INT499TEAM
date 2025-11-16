#!/usr/bin/env bash
set -e

BASE_DIR="/c/Users/gomez/OneDrive - University of Arizona Global Campus/Desktop/React Projects/Week 4"
APP_NAME="streamlist-app"
GOOGLE_CLIENT_ID="762177763504-1tkoj7otg2ubbfr6d1enrfo1kfq4inam.apps.googleusercontent.com"

echo "Using base directory: $BASE_DIR"
cd "$BASE_DIR/$APP_NAME"

echo "Installing required packages..."
npm install react-router-dom @react-oauth/google jwt-decode --save

echo "Rewriting index.html..."
cat > index.html << 'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>StreamList EZTechMovie</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <link rel="manifest" href="/manifest.webmanifest" />
    <meta name="theme-color" content="#0ea5e9" />
    <meta name="mobile-web-app-capable" content="yes" />
    <link rel="apple-touch-icon" href="/icons/icon-192.png" />

    <script type="module" src="/src/main.jsx"></script>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
HTML

echo "Rewriting manifest.webmanifest without icons (to avoid invalid image error)..."
cat > public/manifest.webmanifest << 'MANIFEST'
{
  "name": "StreamList EZTechMovie",
  "short_name": "StreamList",
  "description": "EZTechMovie customer app to browse, favorite and track movies.",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "background_color": "#020617",
  "theme_color": "#0ea5e9",
  "orientation": "portrait-primary"
}
MANIFEST

echo "Ensuring service worker exists..."
mkdir -p public
cat > public/sw.js << 'SW'
const CACHE_NAME = "streamlist-cache-v1";

const URLS_TO_CACHE = [
  "/",
  "/index.html",
  "/manifest.webmanifest"
];

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(URLS_TO_CACHE))
  );
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
      )
    )
  );
});

self.addEventListener("fetch", event => {
  if (event.request.method !== "GET") return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).catch(() => caches.match("/"));
    })
  );
});
SW

echo "Writing global styles..."
mkdir -p src
cat > src/index.css << 'CSS'
*,
*::before,
*::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  background-color: #020617;
  color: #e2e8f0;
}

a {
  color: inherit;
  text-decoration: none;
}

button {
  font-family: inherit;
}
CSS

echo "Auth context..."
mkdir -p src/context src/components src/pages
cat > src/context/AuthContext.jsx << 'AUTH'
import React, { createContext, useContext, useEffect, useState } from "react";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem("authUser");
    return stored ? JSON.parse(stored) : null;
  });

  useEffect(() => {
    if (user) {
      localStorage.setItem("authUser", JSON.stringify(user));
    } else {
      localStorage.removeItem("authUser");
    }
  }, [user]);

  const login = userData => {
    setUser(userData);
  };

  const logout = () => {
    setUser(null);
  };

  const value = { user, login, logout, isAuthenticated: !!user };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
AUTH

echo "ProtectedRoute component..."
cat > src/components/ProtectedRoute.jsx << 'PROTECT'
import React from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return children;
}
PROTECT

echo "Google login button..."
cat > src/components/GoogleLoginButton.jsx << 'GOOGLE'
import React from "react";
import { GoogleOAuthProvider, GoogleLogin } from "@react-oauth/google";
import { jwtDecode } from "jwt-decode";
import { useAuth } from "../context/AuthContext.jsx";

const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID || "REPLACE_ME";

export default function GoogleLoginButton() {
  const { login } = useAuth();

  const handleSuccess = credentialResponse => {
    try {
      if (!credentialResponse.credential) {
        console.error("No credential returned from Google");
        return;
      }

      const decoded = jwtDecode(credentialResponse.credential);
      const userData = {
        name: decoded.name,
        email: decoded.email,
        picture: decoded.picture
      };

      login(userData);
      window.location.assign("/");
    } catch (error) {
      console.error("Error decoding Google token:", error);
    }
  };

  const handleError = () => {
    console.error("Google login failed");
  };

  return (
    <GoogleOAuthProvider clientId={clientId}>
      <GoogleLogin onSuccess={handleSuccess} onError={handleError} />
    </GoogleOAuthProvider>
  );
}
GOOGLE

echo "Credit card form..."
cat > src/components/CreditCardForm.jsx << 'CARD'
import React, { useEffect, useState } from "react";

const STORAGE_KEY = "eztechmovie-credit-card";

const defaultForm = {
  cardNumber: "",
  nameOnCard: "",
  expiry: "",
  cvv: ""
};

export default function CreditCardForm({ onSubmitSuccess }) {
  const [form, setForm] = useState(defaultForm);
  const [error, setError] = useState("");

  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        setForm(prev => ({ ...prev, ...parsed }));
      } catch {
      }
    }
  }, []);

  const handleChange = event => {
    const { name, value } = event.target;

    if (name === "cardNumber") {
      const digitsOnly = value.replace(/\D/g, "").slice(0, 16);
      const groups = digitsOnly.match(/.{1,4}/g) || [];
      const formatted = groups.join(" ");
      setForm(prev => ({ ...prev, cardNumber: formatted }));
      return;
    }

    setForm(prev => ({ ...prev, [name]: value }));
  };

  const validate = () => {
    if (form.cardNumber.length !== 19) {
      return "Card number must be 16 digits in the format 1234 5678 9012 3456.";
    }
    if (!form.nameOnCard.trim()) {
      return "Name on card is required.";
    }
    if (!/^\d{2}\/\d{2}$/.test(form.expiry)) {
      return "Expiry must be in MM/YY format.";
    }
    if (!/^\d{3,4}$/.test(form.cvv)) {
      return "CVV must be 3 or 4 digits.";
    }
    return "";
  };

  const handleSubmit = event => {
    event.preventDefault();
    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        cardNumber: form.cardNumber,
        nameOnCard: form.nameOnCard,
        expiry: form.expiry
      })
    );

    setError("");
    if (onSubmitSuccess) {
      onSubmitSuccess(form);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginTop: "16px" }}>
      <h2 style={{ fontSize: "18px", fontWeight: 600 }}>Payment Details</h2>

      <div style={{ marginTop: "8px" }}>
        <label style={{ display: "block", fontSize: "14px" }}>Card Number</label>
        <input
          type="text"
          name="cardNumber"
          value={form.cardNumber}
          onChange={handleChange}
          placeholder="1234 5678 9012 3456"
          style={{ width: "100%", padding: "8px", marginTop: "4px" }}
        />
      </div>

      <div style={{ marginTop: "8px" }}>
        <label style={{ display: "block", fontSize: "14px" }}>Name on Card</label>
        <input
          type="text"
          name="nameOnCard"
          value={form.nameOnCard}
          onChange={handleChange}
          placeholder="Full name"
          style={{ width: "100%", padding: "8px", marginTop: "4px" }}
        />
      </div>

      <div style={{ display: "flex", gap: "12px", marginTop: "8px" }}>
        <div style={{ flex: 1 }}>
          <label style={{ display: "block", fontSize: "14px" }}>Expiry (MM/YY)</label>
          <input
            type="text"
            name="expiry"
            value={form.expiry}
            onChange={handleChange}
            placeholder="08/28"
            style={{ width: "100%", padding: "8px", marginTop: "4px" }}
          />
        </div>
        <div style={{ flex: 1 }}>
          <label style={{ display: "block", fontSize: "14px" }}>CVV</label>
          <input
            type="password"
            name="cvv"
            value={form.cvv}
            onChange={handleChange}
            placeholder="123"
            style={{ width: "100%", padding: "8px", marginTop: "4px" }}
          />
        </div>
      </div>

      {error && (
        <p style={{ marginTop: "8px", fontSize: "13px", color: "#f97373" }}>
          {error}
        </p>
      )}

      <button
        type="submit"
        style={{
          marginTop: "12px",
          padding: "8px 12px",
          borderRadius: "6px",
          border: "none",
          backgroundColor: "#0ea5e9",
          color: "#020617",
          fontSize: "14px",
          fontWeight: 500,
          cursor: "pointer"
        }}
      >
        Save Card and Complete Checkout
      </button>
    </form>
  );
}
CARD

echo "Login page..."
cat > src/pages/LoginPage.jsx << 'LOGIN'
import React from "react";
import GoogleLoginButton from "../components/GoogleLoginButton.jsx";
import { useAuth } from "../context/AuthContext.jsx";

export default function LoginPage() {
  const { user } = useAuth();

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#020617",
        color: "#e2e8f0"
      }}
    >
      <div
        style={{
          maxWidth: "420px",
          width: "100%",
          backgroundColor: "#020617",
          border: "1px solid #1e293b",
          padding: "24px",
          borderRadius: "12px",
          boxShadow: "0 10px 25px rgba(15,23,42,0.6)"
        }}
      >
        <h1 style={{ fontSize: "22px", fontWeight: 600, textAlign: "center" }}>
          EZTechMovie StreamList Login
        </h1>
        <p
          style={{
            fontSize: "14px",
            textAlign: "center",
            marginTop: "8px",
            marginBottom: "16px",
            color: "#9ca3af"
          }}
        >
          Sign in with your Google account to manage your StreamList movies and checkout.
        </p>
        <div style={{ display: "flex", justifyContent: "center" }}>
          <GoogleLoginButton />
        </div>
        {user && (
          <p style={{ fontSize: "12px", textAlign: "center", marginTop: "12px" }}>
            Logged in as {user.name} ({user.email})
          </p>
        )}
      </div>
    </div>
  );
}
LOGIN

echo "Dashboard and pages..."
cat > src/pages/Dashboard.jsx << 'DASH'
import React, { useEffect, useState } from "react";

const sampleMovies = [
  { id: 1, title: "Inception", year: 2010, rating: 8.8 },
  { id: 2, title: "The Matrix", year: 1999, rating: 8.7 },
  { id: 3, title: "Interstellar", year: 2014, rating: 8.6 },
  { id: 4, title: "The Dark Knight", year: 2008, rating: 9.0 }
];

export default function Dashboard({ favorites, toggleFavorite, cart, addToCart }) {
  const [movies, setMovies] = useState(sampleMovies);

  useEffect(() => {
    setMovies(sampleMovies);
  }, []);

  const isFavorite = id => favorites.some(m => m.id === id);
  const inCart = id => cart.some(m => m.id === id);

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "12px" }}>Recommended Movies</h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "16px" }}>
        Browse a sample catalog and simulate EZTechMovie customer events:
        favorites, cart and checkout.
      </p>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
          gap: "16px"
        }}
      >
        {movies.map(movie => (
          <div
            key={movie.id}
            style={{
              borderRadius: "12px",
              border: "1px solid #1f2933",
              padding: "12px",
              background:
                "linear-gradient(145deg, rgba(15,23,42,0.95), rgba(15,23,42,0.8))"
            }}
          >
            <h2 style={{ fontSize: "18px", marginBottom: "4px" }}>{movie.title}</h2>
            <p style={{ fontSize: "13px", color: "#9ca3af" }}>
              Year {movie.year} • Rating {movie.rating}
            </p>
            <div style={{ display: "flex", gap: "8px", marginTop: "10px" }}>
              <button
                type="button"
                onClick={() => toggleFavorite(movie)}
                style={{
                  flex: 1,
                  padding: "6px 8px",
                  borderRadius: "6px",
                  border: "1px solid #0ea5e9",
                  backgroundColor: isFavorite(movie.id) ? "#0ea5e9" : "transparent",
                  color: isFavorite(movie.id) ? "#020617" : "#e5e7eb",
                  fontSize: "13px",
                  cursor: "pointer"
                }}
              >
                {isFavorite(movie.id) ? "Unfavorite" : "Favorite"}
              </button>
              <button
                type="button"
                onClick={() => addToCart(movie)}
                style={{
                  flex: 1,
                  padding: "6px 8px",
                  borderRadius: "6px",
                  border: "none",
                  backgroundColor: inCart(movie.id) ? "#22c55e" : "#10b981",
                  color: "#020617",
                  fontSize: "13px",
                  cursor: "pointer"
                }}
              >
                {inCart(movie.id) ? "In Cart" : "Add to Cart"}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
DASH

cat > src/pages/FavoritesPage.jsx << 'FAV'
import React from "react";

export default function FavoritesPage({ favorites }) {
  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "12px" }}>Favorites</h1>
      {favorites.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          You have not favorited any movies yet.
        </p>
      ) : (
        <ul style={{ listStyle: "none", paddingLeft: 0 }}>
          {favorites.map(movie => (
            <li
              key={movie.id}
              style={{
                marginBottom: "8px",
                padding: "8px",
                borderRadius: "8px",
                border: "1px solid #1f2933"
              }}
            >
              {movie.title} {movie.year ? `(${movie.year})` : ""}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
FAV

cat > src/pages/CartPage.jsx << 'CART'
import React from "react";
import { Link } from "react-router-dom";

export default function CartPage({ cart, removeFromCart }) {
  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "12px" }}>Cart</h1>
      {cart.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          Your cart is empty. Add a movie from the dashboard.
        </p>
      ) : (
        <>
          <ul style={{ listStyle: "none", paddingLeft: 0 }}>
            {cart.map(movie => (
              <li
                key={movie.id}
                style={{
                  marginBottom: "8px",
                  padding: "8px",
                  borderRadius: "8px",
                  border: "1px solid #1f2933",
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center"
                }}
              >
                <span>
                  {movie.title} {movie.year ? `(${movie.year})` : ""}
                </span>
                <button
                  type="button"
                  onClick={() => removeFromCart(movie.id)}
                  style={{
                    padding: "4px 8px",
                    borderRadius: "6px",
                    border: "none",
                    backgroundColor: "#ef4444",
                    color: "#020617",
                    fontSize: "12px",
                    cursor: "pointer"
                  }}
                >
                  Remove
                </button>
              </li>
            ))}
          </ul>
          <div style={{ marginTop: "16px" }}>
            <Link
              to="/checkout"
              style={{
                display: "inline-block",
                padding: "8px 12px",
                borderRadius: "8px",
                backgroundColor: "#0ea5e9",
                color: "#020617",
                fontSize: "14px",
                fontWeight: 500
              }}
            >
              Proceed to Checkout
            </Link>
          </div>
        </>
      )}
    </div>
  );
}
CART

cat > src/pages/CheckoutPage.jsx << 'CHECK'
import React from "react";
import CreditCardForm from "../components/CreditCardForm.jsx";

export default function CheckoutPage({ cart, clearCart }) {
  const handleSuccess = () => {
    clearCart();
    alert("Payment details saved locally and cart cleared for this demo.");
  };

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "12px" }}>Checkout</h1>
      {cart.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          Your cart is empty. Add a movie before checking out.
        </p>
      ) : (
        <>
          <p style={{ fontSize: "14px", color: "#9ca3af" }}>
            This checkout simulates EZTechMovie credit card management by saving card
            details in localStorage and clearing the cart.
          </p>
          <CreditCardForm onSubmitSuccess={handleSuccess} />
        </>
      )}
    </div>
  );
}
CHECK

echo "Writing App.jsx (routes, shell)..."
cat > src/App.jsx << 'APP'
import React, { useEffect, useState } from "react";
import { Link, Route, Routes, useLocation } from "react-router-dom";
import { useAuth } from "./context/AuthContext.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import FavoritesPage from "./pages/FavoritesPage.jsx";
import CartPage from "./pages/CartPage.jsx";
import CheckoutPage from "./pages/CheckoutPage.jsx";

const CART_STORAGE_KEY = "eztechmovie-cart";
const FAVORITES_STORAGE_KEY = "eztechmovie-favorites";

function AppShell() {
  const { user, logout } = useAuth();
  const [cart, setCart] = useState([]);
  const [favorites, setFavorites] = useState([]);
  const location = useLocation();

  useEffect(() => {
    const storedCart = localStorage.getItem(CART_STORAGE_KEY);
    const storedFavs = localStorage.getItem(FAVORITES_STORAGE_KEY);

    if (storedCart) {
      try {
        setCart(JSON.parse(storedCart));
      } catch {
        setCart([]);
      }
    }
    if (storedFavs) {
      try {
        setFavorites(JSON.parse(storedFavs));
      } catch {
        setFavorites([]);
      }
    }
  }, []);

  useEffect(() => {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
  }, [cart]);

  useEffect(() => {
    localStorage.setItem(FAVORITES_STORAGE_KEY, JSON.stringify(favorites));
  }, [favorites]);

  const toggleFavorite = movie => {
    setFavorites(prev => {
      const exists = prev.some(m => m.id === movie.id);
      if (exists) {
        return prev.filter(m => m.id !== movie.id);
      }
      return [...prev, movie];
    });
  };

  const addToCart = movie => {
    setCart(prev => {
      const exists = prev.some(m => m.id === movie.id);
      if (exists) return prev;
      return [...prev, movie];
    });
  };

  const removeFromCart = id => {
    setCart(prev => prev.filter(m => m.id !== id));
  };

  const clearCart = () => {
    setCart([]);
  };

  return (
    <div>
      <header
        style={{
          position: "sticky",
          top: 0,
          zIndex: 10,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "10px 16px",
          borderBottom: "1px solid #1e293b",
          background: "rgba(15,23,42,0.95)",
          backdropFilter: "blur(10px)"
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          <span
            style={{
              width: "28px",
              height: "28px",
              borderRadius: "999px",
              background:
                "radial-gradient(circle at 30 percent 20 percent, #38bdf8, #0f172a 70 percent)",
              display: "inline-block"
            }}
          />
          <div>
            <div style={{ fontSize: "16px", fontWeight: 600 }}>StreamList</div>
            <div style={{ fontSize: "11px", color: "#9ca3af" }}>EZTechMovie</div>
          </div>
        </div>
        <nav style={{ display: "flex", alignItems: "center", gap: "12px" }}>
          <Link
            to="/"
            style={{
              fontSize: "13px",
              color: location.pathname === "/" ? "#0ea5e9" : "#e5e7eb"
            }}
          >
            Dashboard
          </Link>
          <Link
            to="/favorites"
            style={{
              fontSize: "13px",
              color: location.pathname === "/favorites" ? "#0ea5e9" : "#e5e7eb"
            }}
          >
            Favorites
          </Link>
          <Link
            to="/cart"
            style={{
              fontSize: "13px",
              color:
                location.pathname === "/cart" || location.pathname === "/checkout"
                  ? "#0ea5e9"
                  : "#e5e7eb"
            }}
          >
            Cart ({cart.length})
          </Link>
        </nav>
        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
          {user && (
            <span style={{ fontSize: "12px", color: "#9ca3af" }}>
              {user.name}
            </span>
          )}
          <button
            type="button"
            onClick={logout}
            style={{
              padding: "4px 8px",
              borderRadius: "999px",
              border: "1px solid #4b5563",
              backgroundColor: "transparent",
              color: "#e5e7eb",
              fontSize: "11px",
              cursor: "pointer"
            }}
          >
            Sign out
          </button>
        </div>
      </header>

      <main style={{ maxWidth: "1100px", margin: "0 auto" }}>
        <Routes>
          <Route
            path="/"
            element={
              <Dashboard
                favorites={favorites}
                toggleFavorite={toggleFavorite}
                cart={cart}
                addToCart={addToCart}
              />
            }
          />
          <Route
            path="/favorites"
            element={<FavoritesPage favorites={favorites} />}
          />
          <Route
            path="/cart"
            element={
              <CartPage cart={cart} removeFromCart={removeFromCart} />
            }
          />
          <Route
            path="/checkout"
            element={<CheckoutPage cart={cart} clearCart={clearCart} />}
          />
        </Routes>
      </main>
    </div>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/*"
        element={
          <ProtectedRoute>
            <AppShell />
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}
APP

echo "Writing main.jsx entry..."
cat > src/main.jsx << 'MAIN'
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App.jsx";
import "./index.css";
import { AuthProvider } from "./context/AuthContext.jsx";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <AuthProvider>
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </AuthProvider>
  </React.StrictMode>
);

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker
      .register("/sw.js")
      .catch(error => {
        console.error("Service worker registration failed:", error);
      });
  });
}
MAIN

echo "Creating .env.local with Google client id..."
cat > .env.local << ENV
VITE_GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
ENV

echo "Done writing files. You can now run: npm run dev"
