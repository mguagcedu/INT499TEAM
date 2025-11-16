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
