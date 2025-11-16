#!/usr/bin/env bash
set -e

APP_DIR="/c/Users/gomez/OneDrive - University of Arizona Global Campus/Desktop/React Projects/Week 4/streamlist-app"
cd "$APP_DIR"

echo "Writing .env.local with TMDB credentials..."

cat > .env.local << 'ENV'
VITE_TMDB_API_KEY=8c4123c5aa15296823fbcc28c219147c
VITE_TMDB_READ_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4YzQxMjNjNWFhMTUyOTY4MjNmYmNjMjhjMjE5MTQ3YyIsIm5iZiI6MTc2MjM5NDc5OC40OTksInN1YiI6IjY5MGMwMmFlMGFlOTFiYmEyOGQ3MzQ1MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nPYVKXp7lbQRZTAgI6ySWdRPwCvo4deXZh-cSF3giLo
ENV

echo "Ensuring .env.local is gitignored..."
if [ ! -f .gitignore ]; then
  echo ".gitignore not found, creating it..."
  touch .gitignore
fi

if ! grep -q "^\.env.local$" .gitignore; then
  echo ".env.local" >> .gitignore
fi

echo "Done. Restart your dev server if it's running."
