import React from 'react'
import { Link } from 'react-router-dom'

export default function CartDrawer({ open, items, total, onClose, inc, dec, remove }){
  if(!open) return null
  return (
    <aside className="drawer" role="dialog" aria-modal="true" aria-label="Cart">
      <div className="header container" style={{padding:0}}>
        <div className="container" style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:0}}>
          <h2 style={{margin:0}}>Your Cart</h2>
          <button className="btn ghost" onClick={onClose}>Close</button>
        </div>
      </div>
      <div className="container">
        <div className="items">
          {items.length===0 && <p>No items yet.</p>}
          {items.map(i=>(
            <div className="item" key={i.id}>
              <div>
                <strong>{i.name}</strong>
                <div className="price">${i.price.toFixed(2)} {i.kind==='subscription'?'(subscription)':''}</div>
              </div>
              <div style={{display:'grid',gap:'.5rem',justifyItems:'end'}}>
                {i.kind==='accessory' ? (
                  <div className="qty">
                    <button onClick={()=>dec(i.id)} aria-label={"Decrease "+i.name}>-</button>
                    <span>{i.qty}</span>
                    <button onClick={()=>inc(i.id)} aria-label={"Increase "+i.name}>+</button>
                  </div>
                ) : <span>Qty 1</span>}
                <button className="btn secondary" onClick={()=>remove(i.id)}>Remove</button>
              </div>
            </div>
          ))}
        </div>
        <div className="total">
          <span>Total</span><span>${total.toFixed(2)}</span>
        </div>
        <div style={{display:'flex',gap:'.5rem',marginTop:'.75rem',justifyContent:'flex-end'}}>
          <Link to="/cart" className="btn secondary" onClick={onClose}>View cart</Link>
          <Link to="/checkout" className="btn" onClick={onClose}>Checkout</Link>
        </div>
      </div>
    </aside>
  )
}
