import './search.css';
import { useEffect, useState } from 'react';
import MovieCard from '../components/MovieCard';
import { addEvent, pushRecentSearch } from '../utils/localStorage';

const API_KEY = import.meta.env.VITE_TMDB_API_KEY;
const API_BASE = 'https://api.themoviedb.org/3';

async function tmdbSearch(query) {
  const url = new URL(API_BASE + '/search/movie');
  url.searchParams.set('api_key', API_KEY);
  url.searchParams.set('query', query);
  const res = await fetch(url);
  if (!res.ok) throw new Error('TMDB error');
  const data = await res.json();
  return data.results || [];
}

export default function Search() {
  const [q, setQ] = useState('');
  const [results, setResults] = useState([]);
  const [lastSearched, setLastSearched] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const onSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (!q.trim()) return;
    setLoading(true);
    try {
      const items = await tmdbSearch(q.trim());
      setResults(items);
      addEvent('search', { query: q.trim(), count: items.length });
      pushRecentSearch(q.trim());
      setLastSearched(q.trim());
    } catch {
      setError('Failed to fetch from TMDB');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { addEvent('visit_search'); }, []);

  return (
    <section className="search-wrap">
      <div className="card">
        <div className="section-header centered">
          <h2 className="section-title">TMDB Search</h2>
          <span className="subtle">Search live data from TMDB</span>
        </div>
        <form onSubmit={onSubmit} className="search-form">
          <input
            type="text"
            placeholder="Search movies"
            value={q}
            onChange={(e) => setQ(e.target.value)}
            aria-label="Movie search input"
          />
          <button type="submit">Search</button>
        </form>
        {loading && <p className="meta">Loading...</p>}
        {error && <p className="meta" role="alert">{error}</p>}
      </div>

      <div className="movie-grid">
        {results.map(m => <MovieCard key={m.id} movie={m} />)}
      </div>
    </section>
  );
}
