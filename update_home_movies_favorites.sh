#!/usr/bin/env bash
set -e

APP_DIR="/c/Users/gomez/OneDrive - University of Arizona Global Campus/Desktop/React Projects/Week 4/streamlist-app"
cd "$APP_DIR"

echo "Updating StreamListPage for persistent planner and TMDB-style suggestions..."
cat > src/pages/StreamListPage.jsx << 'STREAM'
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

const STORAGE_KEY = "streamlist-items";
const TMDB_POSTER_BASE = "https://image.tmdb.org/t/p/w185";

export default function StreamListPage() {
  const [text, setText] = useState("");
  const [items, setItems] = useState([]);
  const [editingId, setEditingId] = useState(null);
  const [suggestions, setSuggestions] = useState([]);
  const [suggestError, setSuggestError] = useState("");
  const navigate = useNavigate();
  const apiKey = import.meta.env.VITE_TMDB_API_KEY || "";

  // Load planner items once from localStorage
  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        if (Array.isArray(parsed)) {
          setItems(parsed);
        }
      } catch {
        setItems([]);
      }
    }
  }, []);

  // Persist planner items on every change
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
  }, [items]);

  // TMDB live suggestions, similar to Movies page
  useEffect(() => {
    const value = text.trim();
    if (!value || value.length < 3 || !apiKey) {
      setSuggestions([]);
      setSuggestError("");
      return;
    }

    const controller = new AbortController();
    const timer = setTimeout(async () => {
      try {
        const url = new URL("https://api.themoviedb.org/3/search/movie");
        url.searchParams.set("api_key", apiKey);
        url.searchParams.set("query", value);

        const res = await fetch(url.toString(), { signal: controller.signal });
        if (!res.ok) throw new Error("TMDB request failed");
        const data = await res.json();
        const mapped =
          data.results?.slice(0, 6).map(movie => ({
            id: movie.id,
            title: movie.title,
            year: movie.release_date ? movie.release_date.slice(0, 4) : "",
            rating: movie.vote_average,
            posterPath: movie.poster_path,
            overview: movie.overview,
            tmdbId: movie.id
          })) ?? [];
        setSuggestions(mapped);
        setSuggestError("");
      } catch (err) {
        if (err.name === "AbortError") return;
        console.error(err);
        setSuggestions([]);
        setSuggestError("There was a problem looking up TMDB suggestions.");
      }
    }, 400);

    return () => {
      clearTimeout(timer);
      controller.abort();
    };
  }, [text, apiKey]);

  const addOrUpdateItem = value => {
    if (!value.trim()) return;

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
        text: value.trim(),
        completed: false
      };
      setItems(prev => [...prev, newItem]);
    }
  };

  const handleSubmit = event => {
    event.preventDefault();
    const value = text.trim();
    if (!value) return;
    addOrUpdateItem(value);
    setText("");
  };

  const handleSearchTmdb = () => {
    const value = text.trim();
    if (!value) return;
    addOrUpdateItem(value);
    setText("");
    navigate(`/movies?query=${encodeURIComponent(value)}`);
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

  const handleSuggestionClick = movie => {
    const title = movie.title;
    addOrUpdateItem(title);
    setText("");
    setSuggestions([]);
    navigate(`/movies?query=${encodeURIComponent(title)}`);
  };

  const getPosterUrl = posterPath =>
    posterPath ? `${TMDB_POSTER_BASE}${posterPath}` : null;

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>
        StreamList Planner
      </h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "16px" }}>
        Add shows or movies you want to watch. Your list is stored locally in
        the browser so it persists even if you switch tabs or refresh. Start
        typing to see TMDB suggestions and jump to full details on the Movies
        page.
      </p>

      <form
        onSubmit={handleSubmit}
        style={{
          display: "flex",
          flexWrap: "wrap",
          gap: "8px",
          marginBottom: "8px",
          alignItems: "center"
        }}
      >
        <input
          type="text"
          placeholder="Add a title or note"
          value={text}
          onChange={event => setText(event.target.value)}
          style={{
            flex: "1 1 220px",
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
        <button
          type="button"
          onClick={handleSearchTmdb}
          style={{
            padding: "8px 12px",
            borderRadius: "8px",
            border: "1px solid #22c55e",
            backgroundColor: "transparent",
            color: "#bbf7d0",
            fontSize: "14px",
            cursor: "pointer"
          }}
        >
          Search on TMDB
        </button>
      </form>

      {suggestions.length > 0 && (
        <div
          style={{
            maxWidth: "900px",
            marginBottom: "16px",
            borderRadius: "8px",
            border: "1px solid #1f2933",
            backgroundColor: "#020617",
            padding: "8px 10px"
          }}
        >
          <div
            style={{
              paddingBottom: "6px",
              marginBottom: "6px",
              borderBottom: "1px solid #1f2933",
              fontSize: "12px",
              color: "#9ca3af"
            }}
          >
            TMDB suggestions
          </div>
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
              gap: "8px"
            }}
          >
            {suggestions.map(movie => {
              const posterUrl = getPosterUrl(movie.posterPath);
              return (
                <button
                  key={movie.id}
                  type="button"
                  onClick={() => handleSuggestionClick(movie)}
                  style={{
                    textAlign: "left",
                    borderRadius: "8px",
                    border: "1px solid #111827",
                    backgroundColor: "#020617",
                    padding: "6px",
                    cursor: "pointer",
                    display: "flex",
                    gap: "8px"
                  }}
                >
                  {posterUrl && (
                    <img
                      src={posterUrl}
                      alt={movie.title}
                      style={{
                        width: "60px",
                        height: "90px",
                        borderRadius: "4px",
                        objectFit: "cover",
                        flexShrink: 0
                      }}
                    />
                  )}
                  <div>
                    <div
                      style={{
                        fontSize: "13px",
                        color: "#e5e7eb",
                        marginBottom: "2px"
                      }}
                    >
                      {movie.title}
                      {movie.year && (
                        <span
                          style={{ color: "#9ca3af", marginLeft: "4px" }}
                        >
                          ({movie.year})
                        </span>
                      )}
                    </div>
                    {movie.overview && (
                      <div
                        style={{
                          fontSize: "11px",
                          color: "#9ca3af",
                          maxHeight: "48px",
                          overflow: "hidden",
                          textOverflow: "ellipsis"
                        }}
                      >
                        {movie.overview}
                      </div>
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      )}

      {suggestError && (
        <p style={{ fontSize: "13px", color: "#fca5a5", marginBottom: "12px" }}>
          {suggestError}
        </p>
      )}

      {items.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          No items yet. Add something you want to stream and it will appear
          here, even after refresh.
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
                    fontSize: "16px",
                    cursor: "pointer"
                  }}
                >
                  {item.completed ? "✓" : "○"}
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
                    color: "#e5e7eb",
                    fontSize: "12px"
                  }}
                >
                  edit
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
                    color: "#020617",
                    fontSize: "12px"
                  }}
                >
                  delete
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

echo "Updating MoviesPage poster styling so full posters fit..."
cat > src/pages/MoviesPage.jsx << 'MOVIES'
import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";

const TMDB_POSTER_BASE = "https://image.tmdb.org/t/p/w342";

export default function MoviesPage({ favorites, toggleFavorite, cart, addToCart }) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [searchError, setSearchError] = useState("");
  const [isSearching, setIsSearching] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const [searchParams] = useSearchParams();

  const apiKey = import.meta.env.VITE_TMDB_API_KEY || "";

  useEffect(() => {
    const initialQuery = searchParams.get("query");
    if (initialQuery) {
      setQuery(initialQuery);
      handleSearch(initialQuery);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (results.length === 0) return;
    setActiveIndex(0);
    const id = setInterval(() => {
      setActiveIndex(prev => (prev + 1) % results.length);
    }, 4000);
    return () => clearInterval(id);
  }, [results]);

  const handleSearch = async explicitQuery => {
    const q = (explicitQuery ?? query).trim();
    if (!q) return;

    if (!apiKey) {
      setSearchError(
        "TMDB API key is not configured. Add VITE_TMDB_API_KEY to your .env.local."
      );
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
          tmdbId: movie.id,
          title: movie.title,
          year: movie.release_date ? movie.release_date.slice(0, 4) : "",
          rating: movie.vote_average,
          overview: movie.overview,
          price: 3.99,
          type: "movie",
          posterPath: movie.poster_path
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

  const getPosterUrl = posterPath =>
    posterPath ? `${TMDB_POSTER_BASE}${posterPath}` : null;

  const renderCard = movie => {
    const tmdbUrl = movie.tmdbId
      ? `https://www.themoviedb.org/movie/${movie.tmdbId}`
      : null;

    const posterUrl = getPosterUrl(movie.posterPath);

    return (
      <div
        key={movie.id}
        style={{
          borderRadius: "12px",
          border: "1px solid #1f2933",
          padding: "12px",
          background:
            "linear-gradient(145deg, rgba(15,23,42,0.95), rgba(15,23,42,0.8))",
          display: "flex",
          flexDirection: "column",
          gap: "8px"
        }}
      >
        {posterUrl ? (
          <div
            style={{
              borderRadius: "8px",
              overflow: "hidden",
              alignSelf: "stretch",
              backgroundColor: "#020617",
              aspectRatio: "2 / 3"
            }}
          >
            <img
              src={posterUrl}
              alt={movie.title}
              style={{
                width: "100%",
                height: "100%",
                display: "block",
                objectFit: "contain"
              }}
            />
          </div>
        ) : (
          <div
            style={{
              borderRadius: "8px",
              height: "200px",
              background:
                "repeating-linear-gradient(135deg, #020617, #020617 8px, #0f172a 8px, #0f172a 16px)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "12px",
              color: "#6b7280"
            }}
          >
            No poster available
          </div>
        )}

        <div>
          <h3 style={{ fontSize: "16px", marginBottom: "4px" }}>
            {movie.title}
          </h3>
          <p style={{ fontSize: "12px", color: "#9ca3af" }}>
            {movie.year && <>Year {movie.year} • </>}
            Rating {movie.rating ?? "N/A"} • ${movie.price.toFixed(2)}
          </p>
          {movie.overview && (
            <p
              style={{
                fontSize: "12px",
                color: "#9ca3af",
                marginTop: "6px",
                maxHeight: "60px",
                overflow: "hidden",
                textOverflow: "ellipsis"
              }}
            >
              {movie.overview}
            </p>
          )}
          {tmdbUrl && (
            <a
              href={tmdbUrl}
              target="_blank"
              rel="noreferrer"
              style={{
                display: "inline-block",
                marginTop: "6px",
                fontSize: "12px",
                color: "#93c5fd"
              }}
            >
              View on TMDB
            </a>
          )}
        </div>

        <div style={{ display: "flex", gap: "8px", marginTop: "4px" }}>
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
  };

  const featured = results[activeIndex];

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>Movies</h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "16px" }}>
        This page shows live results from the TMDB catalog only. When you search,
        the carousel updates and rotates through the top matches.
      </p>

      <form
        onSubmit={event => {
          event.preventDefault();
          handleSearch();
        }}
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
        <p style={{ fontSize: "13px", color: "#fca5a5", marginBottom: "12px" }}>
          {searchError}
        </p>
      )}

      {featured && (
        <section
          style={{
            marginBottom: "20px",
            padding: "14px",
            borderRadius: "12px",
            border: "1px solid #1f2933",
            background:
              "linear-gradient(135deg, rgba(8,47,73,0.9), rgba(15,23,42,0.95))"
          }}
        >
          <h2 style={{ fontSize: "18px", marginBottom: "6px" }}>
            Featured result
          </h2>
          {renderCard(featured)}
        </section>
      )}

      <section>
        <h2 style={{ fontSize: "18px", marginBottom: "8px" }}>All results</h2>
        {results.length === 0 ? (
          <p style={{ fontSize: "14px", color: "#9ca3af" }}>
            Enter a title to search the TMDB catalog.
          </p>
        ) : (
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
              gap: "12px"
            }}
          >
            {results.map(movie => renderCard(movie))}
          </div>
        )}
      </section>
    </div>
  );
}
MOVIES

echo "Updating FavoritesPage to show posters and TMDB links..."
cat > src/pages/FavoritesPage.jsx << 'FAV'
import React from "react";

const TMDB_POSTER_BASE = "https://image.tmdb.org/t/p/w185";

export default function FavoritesPage({ favorites }) {
  const getPosterUrl = posterPath =>
    posterPath ? `${TMDB_POSTER_BASE}${posterPath}` : null;

  return (
    <div style={{ padding: "16px" }}>
      <h1 style={{ fontSize: "24px", marginBottom: "8px" }}>Favorites</h1>
      <p style={{ fontSize: "14px", color: "#9ca3af", marginBottom: "16px" }}>
        These are the movies you have marked as favorites. Click a poster to open
        the full title on TMDB in a new tab and see all the details.
      </p>

      {favorites.length === 0 ? (
        <p style={{ fontSize: "14px", color: "#9ca3af" }}>
          No favorites yet. Mark movies as favorites on the Movies page.
        </p>
      ) : (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
            gap: "12px"
          }}
        >
          {favorites.map(movie => {
            const posterUrl = getPosterUrl(movie.posterPath);
            const tmdbUrl = movie.tmdbId
              ? `https://www.themoviedb.org/movie/${movie.tmdbId}`
              : null;

            return (
              <div
                key={movie.id}
                style={{
                  borderRadius: "12px",
                  border: "1px solid #1f2933",
                  padding: "12px",
                  backgroundColor: "#020617",
                  display: "flex",
                  flexDirection: "column",
                  gap: "8px"
                }}
              >
                {posterUrl ? (
                  <a
                    href={tmdbUrl || "#"}
                    target={tmdbUrl ? "_blank" : undefined}
                    rel={tmdbUrl ? "noreferrer" : undefined}
                    style={{
                      borderRadius: "8px",
                      overflow: "hidden",
                      alignSelf: "stretch",
                      backgroundColor: "#020617",
                      aspectRatio: "2 / 3"
                    }}
                  >
                    <img
                      src={posterUrl}
                      alt={movie.title}
                      style={{
                        width: "100%",
                        height: "100%",
                        display: "block",
                        objectFit: "contain"
                      }}
                    />
                  </a>
                ) : (
                  <div
                    style={{
                      borderRadius: "8px",
                      height: "200px",
                      background:
                        "repeating-linear-gradient(135deg, #020617, #020617 8px, #0f172a 8px, #0f172a 16px)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: "12px",
                      color: "#6b7280"
                    }}
                  >
                    No poster available
                  </div>
                )}

                <div>
                  <h3 style={{ fontSize: "16px", marginBottom: "4px" }}>
                    {movie.title}
                  </h3>
                  <p style={{ fontSize: "12px", color: "#9ca3af" }}>
                    {movie.year && <>Year {movie.year} • </>}
                    Rating {movie.rating ?? "N/A"}
                  </p>
                  {movie.overview && (
                    <p
                      style={{
                        fontSize: "12px",
                        color: "#9ca3af",
                        marginTop: "6px",
                        maxHeight: "60px",
                        overflow: "hidden",
                        textOverflow: "ellipsis"
                      }}
                    >
                      {movie.overview}
                    </p>
                  )}
                  {tmdbUrl && (
                    <a
                      href={tmdbUrl}
                      target="_blank"
                      rel="noreferrer"
                      style={{
                        display: "inline-block",
                        marginTop: "4px",
                        fontSize: "12px",
                        color: "#93c5fd"
                      }}
                    >
                      View on TMDB
                    </a>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
FAV

echo "Updating App.jsx to store full TMDB info in favorites..."
cat > src/App.jsx << 'APP'
import React, { useEffect, useState } from "react";
import { Link, Route, Routes, useLocation } from "react-router-dom";
import { useAuth } from "./context/AuthContext.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import StreamListPage from "./pages/StreamListPage.jsx";
import MoviesPage from "./pages/MoviesPage.jsx";
import ShopPage from "./pages/ShopPage.jsx";
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
    const movieObj = {
      id: item.id,
      title: item.title || item.name,
      name: item.title || item.name,
      tmdbId: item.tmdbId ?? null,
      posterPath: item.posterPath ?? null,
      year: item.year ?? null,
      rating: item.rating ?? null,
      overview: item.overview ?? ""
    };

    setFavorites(prev => {
      const exists = prev.some(m => m.id === movieObj.id);
      if (exists) {
        return prev.filter(m => m.id !== movieObj.id);
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
            to="/shop"
            style={{
              fontSize: "13px",
              color: location.pathname === "/shop" ? "#0ea5e9" : "#e5e7eb"
            }}
          >
            Shop
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
              />
            }
          />
          <Route
            path="/shop"
            element={
              <ShopPage addToCart={addToCart} cartWarning={cartWarning} />
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

echo "All updates applied. Now run: npm run dev"
