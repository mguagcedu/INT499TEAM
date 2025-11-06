import { useState } from 'react';
import { loadEvents } from '../utils/localStorage';

function formatTs(ts) {
  const d = new Date(ts);
  return d.toLocaleString();
}

export default function Events() {
  const [open, setOpen] = useState(false);
  const events = loadEvents();

  return (
    <section className="card page-pad">
      <div className="section-header">
        <h2 className="section-title">User Events</h2>
        <button className="btn-toggle" onClick={() => setOpen(v => !v)}>
          {open ? 'Hide Entries' : 'Show Entries'}
        </button>
      </div>

      {!events.length ? (
        <div className="empty-center">
          <div>
            <div style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: 6 }}>
              No events recorded yet
            </div>
            <div className="subtle">
              Search for movies or add favorites to generate events.
            </div>
          </div>
        </div>
      ) : open ? (
        <div className="events-panel">
          <ul className="events-grid">
            {events.map(e => (
              <li key={e.id} className="events-item meta">
                <span className="badge">{e.type}</span> at {formatTs(e.ts)}{' '}
                {e.detail?.title ? `- ${e.detail.title}` : ''}
              </li>
            ))}
          </ul>
        </div>
      ) : (
        <div className="empty-center subtle">(Hidden — click “Show Entries”)</div>
      )}
    </section>
  );
}
