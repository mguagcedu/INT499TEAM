import React from 'react'
import { Link } from 'react-router-dom'

export default function Home(){
  return (
    <div className="container">
      <h1>Welcome to EZTech Store</h1>
      <p className="price">Choose a subscription, add accessories, and manage your cart.</p>
      <div style={{display:'flex',gap:'.75rem',marginTop:'1rem'}}>
        <Link to="/subscriptions" className="btn">View Subscriptions</Link>
        <Link to="/accessories" className="btn secondary">Shop Accessories</Link>
        <Link to="/checkout" className="btn ghost">Checkout</Link>
      </div>
    </div>
  )
}
