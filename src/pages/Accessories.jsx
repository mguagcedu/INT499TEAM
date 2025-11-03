import React, { useMemo, useState } from 'react'
import { accessories } from '../Data'
import SearchBar from '../components/SearchBar.jsx'

export default function Accessories({ add }){
  const [q,setQ] = useState('')
  const list = useMemo(()=>{
    const s = q.trim().toLowerCase()
    if(!s) return accessories
    return accessories.filter(a => a.name.toLowerCase().includes(s))
  },[q])
  return (
    <div className="container">
      <h2>Accessories</h2>
      <SearchBar query={q} setQuery={setQ} />
      <div className="grid">
        {list.map(p => (
          <div className="card" key={p.id}>
            <h3>{p.name}</h3>
            <p className="price">${p.price.toFixed(2)}</p>
            <button className="btn" onClick={() => add({ id: p.id, name: p.name, price: p.price, qty: 1, kind: 'accessory' })}>
              Add to cart
            </button>
          </div>
        ))}
        {list.length===0 && <p>No matches. Try a different search.</p>}
      </div>
    </div>
  )
}
