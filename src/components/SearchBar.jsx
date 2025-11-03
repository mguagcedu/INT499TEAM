import React from 'react'
export default function SearchBar({query,setQuery}){
  return (
    <div className="searchbar">
      <span role="img" aria-label="search">🔎</span>
      <input value={query} onChange={e=>setQuery(e.target.value)} placeholder="Search accessories..." />
    </div>
  )
}
