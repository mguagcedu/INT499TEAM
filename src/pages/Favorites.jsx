import { getFavorites } from '../utils/localStorage';
import MovieCard from '../components/MovieCard';

export default function Favorites() {
  const favs = getFavorites();
  return (
    <section className="page-pad">
      <div className="section-header"><h2 className="section-title">Favorites</h2></div>
      {favs.length === 0 ? (
        <div className="empty-center"><div>
          <div style={{fontSize:'1.25rem', fontWeight:700, marginBottom:6}}>No favorites added</div>
          <div className="subtle">Browse the Search page and click “Add to Favorites” to save movies here.</div>
        </div></div>
      ) : (
        <div className="grid">
          {favs.map(m => <MovieCard key={m.id} movie={m} compact />)}
        </div>
      )}
    </section>
  );
}
