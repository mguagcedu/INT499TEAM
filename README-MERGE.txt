DROP-IN UPDATE for Week 3: LocalStorage and TMDB

This package only adds new files. Your existing styling and components remain.

1. Copy these new files into your project:
   - src/utils/localStorage.js
   - src/pages/Search.jsx
   - src/pages/Events.jsx
   - src/pages/Favorites.jsx
   - src/components/MovieCard.jsx

2. Edit your src/App.jsx
   - Import the new pages
   - Add the routes and nav links as shown in App.merge.example.jsx
   - Do not remove your existing routes

3. Create .env if missing
   - Copy .env.sample to .env and set:
     VITE_TMDB_API_KEY=your_tmdb_api_key_here

4. Run the app
   npm install
   npm run dev

5. Verify
   - Search page fetches from TMDB
   - Events and Favorites persist after refresh
   - Home can show recent searches if you read from localStorage in your Home page