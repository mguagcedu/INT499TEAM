import { useState, useEffect } from 'react';
import { toggleFavorite, getFavorites } from '../utils/localStorage';
import './MovieCard.css';

export default function MovieCard({ movie, compact = false }) {
  const [isFav, setIsFav] = useState(false);
  const [flash, setFlash] = useState(''); // '', 'added', or 'removed'

  useEffect(() => {
    const favs = getFavorites();
    setIsFav(favs.some(f => f.id === movie.id));
  }, [movie.id]);

  const onFav = () => {
    const wasFav = isFav;
    toggleFavorite(movie);
    const favs = getFavorites();
    const nowFav = favs.some(f => f.id === movie.id);
    setIsFav(nowFav);
    setFlash(nowFav ? 'added' : 'removed');
    setTimeout(() => setFlash(''), 600); // brief highlight
  };

  const posterUrl = movie.poster_path
    ? `https://image.tmdb.org/t/p/w342${movie.poster_path}`
    : 'https://placehold.co/342x513?text=No+Image';

  return (
    <div className={`card movie-card ${flash ? `flash-${flash}` : ''} ${isFav ? 'is-fav' : ''}`}>
      {!compact && <h4 className="movie-title">{movie.title}</h4>}
      <div className="poster-wrap">
        <img className="poster" src={posterUrl} alt={movie.title} />
      </div>
      <div className="meta">Rating {movie.vote_average?.toFixed?.(1) ?? 'N/A'}</div>
      {isFav && <div className="favorite-badge">⭐ Added to Favorites</div>}
      <button className="btn-fav" onClick={onFav}>
        {isFav ? 'Remove Favorite' : 'Add to Favorites'}
      </button>
    </div>
  );
}
