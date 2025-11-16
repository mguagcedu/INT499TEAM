import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useApp } from "../context/AppContext";

export default function FloatingCart() {
  const [open, setOpen] = useState(false);
  const { cart, cartCount, cartTotal } = useApp();
  const navigate = useNavigate();

  if (cartCount === 0) return null;

  function goToCart() {
    setOpen(false);
    navigate("/cart");
  }

  return (
    <div className="floating-cart-root">
      <button
        type="button"
        className="floating-cart-button"
        onClick={() => setOpen((v) => !v)}
        aria-label="Open cart"
      >
        <span className="floating-cart-icon">🛒</span>
        <span className="floating-cart-count">{cartCount}</span>
      </button>

      {open && (
        <div className="floating-cart-panel">
          <h3>Cart</h3>
          <ul className="floating-cart-list">
            {cart.slice(0, 4).map((item) => (
              <li key={item.id}>
                <span className="floating-cart-label">
                  {item.label}
                </span>
                <span className="floating-cart-meta">
                  x{item.quantity} · ${item.price.toFixed(2)}
                </span>
              </li>
            ))}
            {cart.length > 4 && (
              <li className="floating-cart-more">
                +{cart.length - 4} more item(s)
              </li>
            )}
          </ul>
          <p className="floating-cart-total">
            Total: <strong>${cartTotal.toFixed(2)}</strong>
          </p>
          <button
            type="button"
            className="btn-primary-sm"
            onClick={goToCart}
          >
            Go to cart
          </button>
        </div>
      )}
    </div>
  );
}
