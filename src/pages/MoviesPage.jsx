import React, { useState } from "react";
import { useApp } from "../context/AppContext";

const TMDB_IMAGE_BASE = "https://image.tmdb.org/t/p/w342";

export default function MoviesPage() {
  const { addFavorite } = useApp();
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [status, setStatus] = useState("idle"); // idle | loading | error
  const [message, setMessage] = useState("");

  const apiKey = import.meta.env.VITE_TMDB_API_KEY;

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!query.trim() || !apiKey) return;

    try {
      setStatus("loading");
      setMessage("");
      const url = `https://api.themoviedb.org/3/search/movie?api_key=${apiKey}&query=${encodeURIComponent(
        query.trim()
      )}`;
      const res = await fetch(url);
      if (!res.ok) throw new Error("TMDB request failed");
      const data = await res.json();
      setResults(data.results || []);
      setStatus("idle");
    } catch (err) {
      console.error(err);
      setStatus("error");
      setMessage("There was a problem searching TMDB. Try again.");
      setResults([]);
    }
  };

  const handleAddFavorite = (movie) => {
    addFavorite({
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterUrl: movie.poster_path ? TMDB_IMAGE_BASE + movie.poster_path : null,
      tmdbUrl: `https://www.themoviedb.org/movie/${movie.id}`,
    });
    setMessage(`Added "${movie.title}" to favorites.`);
    setTimeout(() => setMessage(""), 2500);
  };

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h2 className="page-title">Movies search</h2>
          <p className="page-subtitle">
            Search TMDB and add movies directly into your favorites list.
          </p>
        </div>
      </div>

      <form onSubmit={handleSearch} className="form-row">
        <input
          type="search"
          placeholder="Search for a movie (for example, Coco)"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <button type="submit" className="btn-primary-link">
          Search TMDB
        </button>
      </form>

      {status === "loading" && <p className="muted">Searching TMDB...</p>}
      {status === "error" && <p className="error-text">{message}</p>}
      {message && status !== "error" && (
        <div className="toast">{message}</div>
      )}

      {results.length > 0 && (
        <div className="card-grid">
          {results.map((movie) => {
            const posterUrl = movie.poster_path
              ? TMDB_IMAGE_BASE + movie.poster_path
              : null;

            return (
              <div key={movie.id} className="card">
                {posterUrl && (
                  <img
                    src={posterUrl}
                    alt={movie.title}
                    className="movie-poster"
                  />
                )}
                <h3 className="card-title">{movie.title}</h3>
                <p className="card-meta">
                  {movie.release_date
                    ? new Date(movie.release_date).getFullYear()
                    : "Release date not available"}
                </p>
                <p className="card-meta multi-line">
                  {movie.overview || "No overview available."}
                </p>
                <div className="card-actions">
                  <a
                    href={`https://www.themoviedb.org/movie/${movie.id}`}
                    target="_blank"
                    rel="noreferrer"
                    className="btn-secondary"
                  >
                    View on TMDB
                  </a>
                  <button
                    type="button"
                    className="btn-primary-small"
                    onClick={() => handleAddFavorite(movie)}
                  >
                    Add to favorites
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {status === "idle" && results.length === 0 && (
        <p className="muted">
          Start typing a movie title above and search TMDB to see results here.
        </p>
      )}
    </div>
  );
}
