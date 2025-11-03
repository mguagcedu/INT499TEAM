import React from 'react'
import { Link } from 'react-router-dom'

export default function CartPage({ items, total, inc, dec, remove }){
  return (
    <div className="container">
      <h2>Your Cart</h2>
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
                  <button onClick={()=>dec(i.id)}>-</button>
                  <span>{i.qty}</span>
                  <button onClick={()=>inc(i.id)}>+</button>
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
      <div style={{display:'flex',gap:'.5rem',justifyContent:'flex-end',marginTop:'.75rem'}}>
        <Link to="/checkout" className="btn">Proceed to checkout</Link>
      </div>
    </div>
  )
}
