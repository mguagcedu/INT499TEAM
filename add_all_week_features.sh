#!/usr/bin/env bash
set -e

APP_DIR="/c/Users/gomez/OneDrive - University of Arizona Global Campus/Desktop/React Projects/Week 4/streamlist-app"
cd "$APP_DIR"

echo "Installing any missing deps..."
npm install react-router-dom @react-oauth/google jwt-decode --save

echo "Updating index.html to include Material Icons..."
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

    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght@400;600&display=swap"
    />

    <script type="module" src="/src/main.jsx"></script>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
HTML

echo "Ensuring base styles..."
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

.material-symbols-outlined {
  font-family: "Material Symbols Outlined";
  font-weight: 400;
  font-style: normal;
  font-size: 18px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
}
CSS

echo "Adding data file for subscriptions and accessories..."
mkdir -p src/data
cat > src/data/subscriptions.js << 'DATA'
export const subscriptions = [
  {
    id: "sub-basic",
    name: "EZTech Basic",
    description: "1 screen, HD",
    price: 9.99,
    type: "subscription"
  },
  {
    id: "sub-premium",
    name: "EZTech Premium",
    description: "4 screens, 4K",
    price: 19.99,
    type: "subscription"
  }
];

export const accessories = [
  {
    id: "tee-logo",
    name: "EZTech T-Shirt",
    description: "Black tee with StreamList logo",
    price: 19.99,
    type: "accessory"
  },
  {
    id: "case-phone",
    name: "Phone Case",
    description: "Shockproof EZTech case",
    price: 24.99,
    type: "accessory"
  },
  {
    id: "mug-logo",
    name: "EZTech Mug",
    description: "Ceramic mug for late night binging",
    price: 12.99,
    type: "accessory"
  }
];
DATA

echo "StreamList page (Week 1 and 2 input list)..."
mkdir -p src/pages
cat > src/pages/StreamListPage.jsx << 'STREAM'
import React, { useEffect, useState } from "react";

const STORAGE_KEY = "streamlist-items";

export default function StreamListPage() {
  const [text, setText] = useState("");
  const [items, setItems] = useState([]);
  const [editingId, setEditingId] = useState(null);

  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        setItems(JSON.parse(stored));
      } catch {
        setItems([]);
      }
    }
  }, []);

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
  }, [items]);

  const handleSubmit = event => {
    event.preventDefault();
    const value = text.trim();
    if (!value) return;

    console.log("New StreamList item:", value);

    if (editingId) {
      setItems(prev =>
        prev.map(item =>
          item.id === editingId ? { ...item, text: value } : item
        )
      );
      setEditingId(null);
    } else {
      const newItem = {
        id: crypto.randomUUID(),
        text: value,
        completed: false
      };
      setItems(prev => [...prev, newItem]);
    }

    setText("");
  };

  const handleToggleComplete = id => {
    setItems(prev =>
      prev.map(item =>
        item.id === id ? { ...item, completed: !item.completed } : item
      )
    );
  };

  const handleEdit = item => {
    setEditingId(item.id);
    setText(item.text);
  };

  const handleDelete = id => {
    setItems(prev => prev.filter(item => item.id !== id));
    if (editingId === id) {
      setEditingId(null);
      setText("");
    }
  };

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>
        StreamList Planner
      </h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "16px" }}>
        Add shows or movies you want to watch. Your list is stored locally in
        the browser so it persists on refresh.
      </p>

      <form
        onSubmit={handleSubmit}
        style={{
          display: "flex",
          gap: "8px",
          marginBottom: "16px",
          alignItems: "center"
        }}
      >
        <input
          type="text"
          placeholder="Add a title or note"
          value={text}
          onChange={event => setText(event.target.value)}
          style={{
            flex: 1,
            padding: "8px 10px",
            borderRadius: "8px",
            border: "1px solid #1f2933",
            backgroundColor: "#020617",
            color: "#e5e7eb"
          }}
        />
        <button
          type="submit"
          style={{
            padding: "8px 12px",
            borderRadius: "8px",
            border: "none",
            backgroundColor: "#0ea5e9",
            color: "#020617",
            fontSize: "14px",
            fontWeight: 500,
            cursor: "pointer"
          }}
        >
          {editingId ? "Update" : "Add"}
        </button>
      </form>

      {items.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          No items yet. Add something you want to stream and it will appear
          here.
        </p>
      ) : (
        <ul style={{ listStyle: "none", paddingLeft: 0, margin: 0 }}>
          {items.map(item => (
            <li
              key={item.id}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "8px 10px",
                marginBottom: "8px",
                borderRadius: "8px",
                border: "1px solid #1f2933",
                backgroundColor: "#020617"
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                <button
                  type="button"
                  onClick={() => handleToggleComplete(item.id)}
                  style={{
                    borderRadius: "999px",
                    width: "28px",
                    height: "28px",
                    border: "1px solid #4b5563",
                    backgroundColor: item.completed ? "#22c55e" : "transparent",
                    color: item.completed ? "#020617" : "#e5e7eb",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    cursor: "pointer"
                  }}
                >
                  <span className="material-symbols-outlined">
                    {item.completed ? "check" : "radio_button_unchecked"}
                  </span>
                </button>
                <span
                  style={{
                    fontSize: "14px",
                    textDecoration: item.completed ? "line-through" : "none",
                    color: item.completed ? "#6b7280" : "#e5e7eb"
                  }}
                >
                  {item.text}
                </span>
              </div>
              <div style={{ display: "flex", gap: "4px" }}>
                <button
                  type="button"
                  onClick={() => handleEdit(item)}
                  style={{
                    padding: "4px 6px",
                    borderRadius: "6px",
                    border: "1px solid #374151",
                    backgroundColor: "transparent",
                    cursor: "pointer",
                    color: "#e5e7eb"
                  }}
                >
                  <span className="material-symbols-outlined">edit</span>
                </button>
                <button
                  type="button"
                  onClick={() => handleDelete(item.id)}
                  style={{
                    padding: "4px 6px",
                    borderRadius: "6px",
                    border: "none",
                    backgroundColor: "#ef4444",
                    cursor: "pointer",
                    color: "#020617"
                  }}
                >
                  <span className="material-symbols-outlined">delete</span>
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
STREAM

echo "Movies page with TMDB search, subscriptions and accessories..."
cat > src/pages/MoviesPage.jsx << 'MOVIES'
import React, { useState } from "react";
import { subscriptions, accessories } from "../data/subscriptions.js";

const sampleMovies = [
  { id: "sm-1", title: "Inception", year: 2010, rating: 8.8, price: 4.99 },
  { id: "sm-2", title: "The Matrix", year: 1999, rating: 8.7, price: 3.99 },
  { id: "sm-3", title: "Interstellar", year: 2014, rating: 8.6, price: 4.99 }
];

export default function MoviesPage({
  favorites,
  toggleFavorite,
  cart,
  addToCart,
  cartWarning
}) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [searchError, setSearchError] = useState("");
  const [isSearching, setIsSearching] = useState(false);

  const apiKey = import.meta.env.VITE_TMDB_API_KEY || "";

  const handleSearch = async event => {
    event.preventDefault();
    const q = query.trim();
    if (!q) return;

    if (!apiKey) {
      setSearchError("TMDB API key is not configured in .env.local");
      setResults([]);
      return;
    }

    setIsSearching(true);
    setSearchError("");

    try {
      const url = new URL("https://api.themoviedb.org/3/search/movie");
      url.searchParams.set("api_key", apiKey);
      url.searchParams.set("query", q);

      const response = await fetch(url.toString());
      if (!response.ok) {
        throw new Error("TMDB request failed");
      }
      const data = await response.json();
      const mapped =
        data.results?.slice(0, 12).map(movie => ({
          id: `tmdb-${movie.id}`,
          title: movie.title,
          year: movie.release_date ? movie.release_date.slice(0, 4) : "",
          rating: movie.vote_average,
          price: 3.99,
          type: "movie"
        })) ?? [];
      setResults(mapped);
    } catch (error) {
      console.error(error);
      setSearchError("There was a problem searching TMDB.");
      setResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const isFavorite = id => favorites.some(m => m.id === id);
  const cartCount = id => {
    const found = cart.find(item => item.id === id);
    return found ? found.quantity : 0;
  };

  const renderCard = movie => (
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
      <h3 style={{ fontSize: "16px", marginBottom: "4px" }}>{movie.title}</h3>
      <p style={{ fontSize: "12px", color: "#9ca3af" }}>
        {movie.year && <>Year {movie.year} • </>}
        Rating {movie.rating ?? "N/A"} • ${movie.price.toFixed(2)}
      </p>
      <div style={{ display: "flex", gap: "8px", marginTop: "8px" }}>
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
            fontSize: "12px",
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
            backgroundColor: "#10b981",
            color: "#020617",
            fontSize: "12px",
            cursor: "pointer"
          }}
        >
          Add to Cart {cartCount(movie.id) > 0 ? `(${cartCount(movie.id)})` : ""}
        </button>
      </div>
    </div>
  );

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>Movies</h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "16px" }}>
        Browse EZTech subscriptions and accessories or search TMDB for titles.
      </p>

      {cartWarning && (
        <div
          style={{
            marginBottom: "12px",
            padding: "8px 10px",
            borderRadius: "8px",
            border: "1px solid #f97316",
            backgroundColor: "rgba(248, 153, 31, 0.1)",
            fontSize: "13px",
            color: "#fed7aa"
          }}
        >
          {cartWarning}
        </div>
      )}

      <section style={{ marginBottom: "24px" }}>
        <h2 style={{ fontSize: "18px", marginBottom: "8px" }}>
          Subscription plans
        </h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
            gap: "12px"
          }}
        >
          {subscriptions.map(sub => (
            <div
              key={sub.id}
              style={{
                borderRadius: "12px",
                border: "1px solid #1f2933",
                padding: "12px",
                backgroundColor: "#020617"
              }}
            >
              <h3 style={{ fontSize: "16px", marginBottom: "4px" }}>
                {sub.name}
              </h3>
              <p style={{ fontSize: "13px", color: "#9ca3af" }}>
                {sub.description}
              </p>
              <p style={{ fontSize: "13px", marginTop: "4px" }}>
                ${sub.price.toFixed(2)} per month
              </p>
              <button
                type="button"
                onClick={() => addToCart(sub)}
                style={{
                  marginTop: "8px",
                  width: "100%",
                  padding: "6px 8px",
                  borderRadius: "8px",
                  border: "none",
                  backgroundColor: "#0ea5e9",
                  color: "#020617",
                  fontSize: "13px",
                  cursor: "pointer"
                }}
              >
                Add Subscription
              </button>
            </div>
          ))}
        </div>
      </section>

      <section style={{ marginBottom: "24px" }}>
        <h2 style={{ fontSize: "18px", marginBottom: "8px" }}>Accessories</h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
            gap: "12px"
          }}
        >
          {accessories.map(acc =>
            renderCard({
              id: acc.id,
              title: acc.name,
              year: "",
              rating: "",
              price: acc.price,
              type: acc.type
            })
          )}
        </div>
      </section>

      <section style={{ marginBottom: "24px" }}>
        <h2 style={{ fontSize: "18px", marginBottom: "8px" }}>Sample Movies</h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
            gap: "12px"
          }}
        >
          {sampleMovies.map(movie =>
            renderCard({ ...movie, type: "movie" })
          )}
        </div>
      </section>

      <section>
        <h2 style={{ fontSize: "18px", marginBottom: "8px" }}>
          Search TMDB catalog
        </h2>
        <form
          onSubmit={handleSearch}
          style={{ display: "flex", gap: "8px", marginBottom: "12px" }}
        >
          <input
            type="text"
            value={query}
            onChange={event => setQuery(event.target.value)}
            placeholder="Search TMDB by title"
            style={{
              flex: 1,
              padding: "8px 10px",
              borderRadius: "8px",
              border: "1px solid #1f2933",
              backgroundColor: "#020617",
              color: "#e5e7eb"
            }}
          />
          <button
            type="submit"
            style={{
              padding: "8px 12px",
              borderRadius: "8px",
              border: "none",
              backgroundColor: "#22c55e",
              color: "#020617",
              fontSize: "14px",
              fontWeight: 500,
              cursor: "pointer"
            }}
            disabled={isSearching}
          >
            {isSearching ? "Searching..." : "Search"}
          </button>
        </form>
        {searchError && (
          <p style={{ fontSize: "13px", color: "#fca5a5", marginBottom: "8px" }}>
            {searchError}
          </p>
        )}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
            gap: "12px"
          }}
        >
          {results.map(movie => renderCard(movie))}
        </div>
      </section>
    </div>
  );
}
MOVIES

echo "About page..."
cat > src/pages/AboutPage.jsx << 'ABOUT'
import React from "react";

export default function AboutPage() {
  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>About StreamList</h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "8px" }}>
        StreamList is an internal demo application for EZTechMovie. It showcases
        how the IT team manages user events, shopping carts, and a secure
        checkout experience while preparing the system to become a progressive
        web app.
      </p>
      <p style={{ fontSize: "14px", color: "#9ca3af" }}>
        This version includes:
      </p>
      <ul style={{ fontSize: "14px", color: "#e5e7eb" }}>
        <li>StreamList planner page with editable items</li>
        <li>Movies page with subscriptions, accessories, and TMDB search</li>
        <li>Cart and checkout with credit card management</li>
        <li>Google OAuth login and basic PWA support</li>
      </ul>
    </div>
  );
}
ABOUT

echo "Favorites page (already mostly fine)..."
cat > src/pages/FavoritesPage.jsx << 'FAV'
import React from "react";

export default function FavoritesPage({ favorites }) {
  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "12px" }}>Favorites</h1>
      {favorites.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          You have not favorited any movies or products yet.
        </p>
      ) : (
        <ul style={{ listStyle: "none", paddingLeft: 0 }}>
          {favorites.map(item => (
            <li
              key={item.id}
              style={{
                marginBottom: "8px",
                padding: "8px",
                borderRadius: "8px",
                border: "1px solid #1f2933"
              }}
            >
              {item.title || item.name}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
FAV

echo "Cart page with quantities and total..."
cat > src/pages/CartPage.jsx << 'CART'
import React from "react";
import { Link } from "react-router-dom";

export default function CartPage({
  cart,
  removeFromCart,
  updateQuantity,
  cartWarning
}) {
  const total = cart.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "12px" }}>Cart</h1>

      {cartWarning && (
        <div
          style={{
            marginBottom: "12px",
            padding: "8px 10px",
            borderRadius: "8px",
            border: "1px solid #f97316",
            backgroundColor: "rgba(248, 153, 31, 0.1)",
            fontSize: "13px",
            color: "#fed7aa"
          }}
        >
          {cartWarning}
        </div>
      )}

      {cart.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          Your cart is empty. Add a subscription, accessory, or movie from the
          Movies page.
        </p>
      ) : (
        <>
          <ul style={{ listStyle: "none", paddingLeft: 0 }}>
            {cart.map(item => (
              <li
                key={item.id}
                style={{
                  marginBottom: "8px",
                  padding: "8px",
                  borderRadius: "8px",
                  border: "1px solid #1f2933",
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  gap: "8px"
                }}
              >
                <div>
                  <div style={{ fontSize: "14px" }}>
                    {item.title || item.name}
                  </div>
                  <div
                    style={{
                      fontSize: "12px",
                      color: "#9ca3af",
                      marginTop: "2px"
                    }}
                  >
                    {item.type === "subscription"
                      ? "Subscription"
                      : item.type === "accessory"
                      ? "Accessory"
                      : "Movie"}{" "}
                    • ${item.price.toFixed(2)} each
                  </div>
                </div>
                <div
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: "6px"
                  }}
                >
                  <button
                    type="button"
                    onClick={() => updateQuantity(item.id, -1)}
                    style={{
                      width: "26px",
                      height: "26px",
                      borderRadius: "6px",
                      border: "1px solid #374151",
                      backgroundColor: "transparent",
                      color: "#e5e7eb",
                      cursor: "pointer"
                    }}
                  >
                    −
                  </button>
                  <span style={{ minWidth: "24px", textAlign: "center" }}>
                    {item.quantity}
                  </span>
                  <button
                    type="button"
                    onClick={() => updateQuantity(item.id, 1)}
                    style={{
                      width: "26px",
                      height: "26px",
                      borderRadius: "6px",
                      border: "1px solid #374151",
                      backgroundColor: "transparent",
                      color: "#e5e7eb",
                      cursor: "pointer"
                    }}
                  >
                    +
                  </button>
                  <button
                    type="button"
                    onClick={() => removeFromCart(item.id)}
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
                </div>
              </li>
            ))}
          </ul>
          <div
            style={{
              marginTop: "16px",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center"
            }}
          >
            <div style={{ fontSize: "16px", fontWeight: 600 }}>
              Total: ${total.toFixed(2)}
            </div>
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

echo "Checkout page (uses existing CreditCardForm)..."
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
          Your cart is empty. Add items before checking out.
        </p>
      ) : (
        <>
          <p style={{ fontSize: "14px", color: "#9ca3af" }}>
            This checkout simulates EZTechMovie credit card management by saving
            card details in localStorage and clearing the cart.
          </p>
          <CreditCardForm onSubmitSuccess={handleSuccess} />
        </>
      )}
    </div>
  );
}
CHECK

echo "Rewriting App.jsx to wire everything together..."
cat > src/App.jsx << 'APP'
import React, { useEffect, useState } from "react";
import { Link, Route, Routes, useLocation } from "react-router-dom";
import { useAuth } from "./context/AuthContext.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import StreamListPage from "./pages/StreamListPage.jsx";
import MoviesPage from "./pages/MoviesPage.jsx";
import FavoritesPage from "./pages/FavoritesPage.jsx";
import CartPage from "./pages/CartPage.jsx";
import CheckoutPage from "./pages/CheckoutPage.jsx";
import AboutPage from "./pages/AboutPage.jsx";

const CART_STORAGE_KEY = "eztechmovie-cart";
const FAVORITES_STORAGE_KEY = "eztechmovie-favorites";

function AppShell() {
  const { user, logout } = useAuth();
  const [cart, setCart] = useState([]);
  const [favorites, setFavorites] = useState([]);
  const [cartWarning, setCartWarning] = useState("");
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

  const toggleFavorite = item => {
    const id = item.id;
    const title = item.title || item.name;
    const movieObj = {
      id,
      title,
      name: title
    };

    setFavorites(prev => {
      const exists = prev.some(m => m.id === id);
      if (exists) {
        return prev.filter(m => m.id !== id);
      }
      return [...prev, movieObj];
    });
  };

  const addToCart = item => {
    const baseItem = {
      id: item.id,
      title: item.title,
      name: item.name,
      price: item.price ?? 0,
      type: item.type ?? "movie"
    };

    setCart(prev => {
      if (baseItem.type === "subscription") {
        const hasOtherSubscription = prev.some(
          existing =>
            existing.type === "subscription" && existing.id !== baseItem.id
        );
        if (hasOtherSubscription) {
          setCartWarning(
            "Only one subscription can be added to the cart at a time."
          );
          return prev;
        }
      }

      setCartWarning("");

      const existing = prev.find(entry => entry.id === baseItem.id);
      if (existing) {
        return prev.map(entry =>
          entry.id === baseItem.id
            ? { ...entry, quantity: entry.quantity + 1 }
            : entry
        );
      }

      return [...prev, { ...baseItem, quantity: 1 }];
    });
  };

  const removeFromCart = id => {
    setCart(prev => prev.filter(item => item.id !== id));
  };

  const updateQuantity = (id, delta) => {
    setCart(prev => {
      return prev
        .map(item =>
          item.id === id ? { ...item, quantity: item.quantity + delta } : item
        )
        .filter(item => item.quantity > 0);
    });
  };

  const clearCart = () => {
    setCart([]);
  };

  const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);

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
            <div style={{ fontSize: "11px", color: "#9ca3af" }}>
              EZTechMovie
            </div>
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
            StreamList
          </Link>
          <Link
            to="/movies"
            style={{
              fontSize: "13px",
              color: location.pathname === "/movies" ? "#0ea5e9" : "#e5e7eb"
            }}
          >
            Movies
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
                location.pathname === "/cart" ||
                location.pathname === "/checkout"
                  ? "#0ea5e9"
                  : "#e5e7eb"
            }}
          >
            Cart ({cartCount})
          </Link>
          <Link
            to="/about"
            style={{
              fontSize: "13px",
              color: location.pathname === "/about" ? "#0ea5e9" : "#e5e7eb"
            }}
          >
            About
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
          <Route path="/" element={<StreamListPage />} />
          <Route
            path="/movies"
            element={
              <MoviesPage
                favorites={favorites}
                toggleFavorite={toggleFavorite}
                cart={cart}
                addToCart={addToCart}
                cartWarning={cartWarning}
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
              <CartPage
                cart={cart}
                removeFromCart={removeFromCart}
                updateQuantity={updateQuantity}
                cartWarning={cartWarning}
              />
            }
          />
          <Route
            path="/checkout"
            element={<CheckoutPage cart={cart} clearCart={clearCart} />}
          />
          <Route path="/about" element={<AboutPage />} />
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

echo "All Week 1-4 features wired in. You can now run: npm run dev"
