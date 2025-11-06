const KEYS = {
  events: 'streamlist_events',
  recentSearches: 'streamlist_recent_searches',
  favorites: 'streamlist_favorites'
};

export function saveEvents(events) {
  localStorage.setItem(KEYS.events, JSON.stringify(events));
}

export function loadEvents() {
  try { return JSON.parse(localStorage.getItem(KEYS.events)) || []; }
  catch { return []; }
}

export function addEvent(type, detail = {}) {
  const events = loadEvents();
  const evt = { id: crypto.randomUUID(), type, detail, ts: Date.now() };
  events.unshift(evt);
  saveEvents(events.slice(0, 200));
  return evt;
}

export function getRecentSearches() {
  try { return JSON.parse(localStorage.getItem(KEYS.recentSearches)) || []; }
  catch { return []; }
}

export function pushRecentSearch(q) {
  if (!q) return;
  const list = getRecentSearches().filter(s => s.toLowerCase() !== q.toLowerCase());
  list.unshift(q);
  localStorage.setItem(KEYS.recentSearches, JSON.stringify(list.slice(0, 10)));
}

export function getFavorites() {
  try { return JSON.parse(localStorage.getItem(KEYS.favorites)) || []; }
  catch { return []; }
}

export function toggleFavorite(movie) {
  const favs = getFavorites();
  const exists = favs.find(m => m.id === movie.id);
  let updated;
  if (exists) {
    updated = favs.filter(m => m.id !== movie.id);
    addEvent('favorite_removed', { id: movie.id, title: movie.title });
  } else {
    updated = [{ id: movie.id, title: movie.title, poster_path: movie.poster_path, vote_average: movie.vote_average }, ...favs];
    addEvent('favorite_added', { id: movie.id, title: movie.title });
  }
  localStorage.setItem(KEYS.favorites, JSON.stringify(updated));
  return updated;
}
