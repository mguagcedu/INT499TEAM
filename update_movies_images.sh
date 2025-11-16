#!/usr/bin/env bash
set -e

APP_DIR="/c/Users/gomez/OneDrive - University of Arizona Global Campus/Desktop/React Projects/Week 4/streamlist-app"
cd "$APP_DIR"

echo "Updating MoviesPage.jsx to display TMDB poster images..."

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

  const getPosterUrl = posterPath => {
    if (!posterPath) return null;
    return `${TMDB_POSTER_BASE}${posterPath}`;
  };

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
              maxHeight: "260px"
            }}
          >
            <img
              src={posterUrl}
              alt={movie.title}
              style={{ width: "100%", display: "block", objectFit: "cover" }}
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

echo "MoviesPage.jsx updated. Now restart your dev server."
