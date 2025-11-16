import React from "react";
import { useApp } from "../context/AppContext";

export default function FavoritesPage() {
  const { favorites, removeFavorite } = useApp();

  return (
    <div className="page">
      <div className="page-header">
        <h2 className="page-title">Favorites</h2>
        <p className="page-subtitle">
          Movies you have saved from TMDB search.
        </p>
      </div>

      {favorites.length === 0 && (
        <p className="muted">
          No favorites yet. Use the Movies page to add some.
        </p>
      )}

      {favorites.length > 0 && (
        <div className="card-grid">
          {favorites.map((fav) => (
            <div key={fav.id} className="card">
              {fav.posterUrl && (
                <img
                  src={fav.posterUrl}
                  alt={fav.title}
                  className="movie-poster"
                />
              )}
              <h3 className="card-title">{fav.title}</h3>
              {fav.overview && (
                <p className="card-meta multi-line">{fav.overview}</p>
              )}
              <div className="card-actions">
                {fav.tmdbUrl && (
                  <a
                    href={fav.tmdbUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="btn-secondary"
                  >
                    Open on TMDB
                  </a>
                )}
                <button
                  type="button"
                  className="btn-secondary"
                  onClick={() => removeFavorite(fav.id)}
                >
                  Remove
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
