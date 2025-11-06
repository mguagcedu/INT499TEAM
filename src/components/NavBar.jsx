import React from 'react'
import { NavLink } from 'react-router-dom'

export default function NavBar({ onOpenCart, count }){
  return (
    <div className="header">
      <div className="container" style={{display:'flex',gap:'1rem',alignItems:'center'}}>
        <div className="brand">
          <span className="badge">EZ</span>
          <span>EZTech Store</span>
        </div>
        <nav className="nav navlinks">
          <NavLink to="/" end>Home</NavLink>
          <NavLink to="/subscriptions">Subscriptions</NavLink>
          <NavLink to="/accessories">Accessories</NavLink>
          <NavLink to="/cart">Cart</NavLink>
          <NavLink to="/checkout">Checkout</NavLink>
          <NavLink to="/search">Search</NavLink>
  <NavLink to="/favorites">Favorites</NavLink>
  <NavLink to="/events">Events</NavLink>
</nav>
        <div className="spacer" />
        <button className="cartbtn" onClick={onOpenCart}>
          View Cart
          <span className="badge-count">{count}</span>
        </button>
      </div>
    </div>
  )
}
