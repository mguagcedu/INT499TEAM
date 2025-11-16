import React, { useEffect, useState } from "react";
import { NavLink } from "react-router-dom";
import { readCart, writeCart } from "../utils/cartUtils";

function CartPage() {
  const [cartItems, setCartItems] = useState([]);
  const [nameOnCard, setNameOnCard] = useState("");
  const [cardNumber, setCardNumber] = useState("");
  const [expiration, setExpiration] = useState("");
  const [cvc, setCvc] = useState("");

  useEffect(() => {
    setCartItems(readCart());
  }, []);

  const syncAndSet = (items) => {
    setCartItems(items);
    writeCart(items);
  };

  const handleRemoveItem = (id) => {
    const updated = cartItems.filter((item) => item.id !== id);
    syncAndSet(updated);
  };

  const handleClearCart = () => {
    syncAndSet([]);
  };

  const total = cartItems.reduce((sum, item) => {
    const price = Number(item.price) || 0;
    const qty = Number(item.quantity) || 1;
    return sum + price * qty;
  }, 0);

  const itemCount = cartItems.reduce(
    (sum, item) => sum + (item.quantity || 1),
    0
  );

  const handleCheckout = (e) => {
    e.preventDefault();
    if (!itemCount) {
      return;
    }
    alert("Checkout submitted. Demo only.");
  };

  const getDisplayTitle = (item) =>
    item.label || item.title || item.name || item.refId || "Untitled item";

  const getTypeLabel = (item) => {
    if (item.type === "subscription") return "Subscription";
    if (item.type === "product") return "Product";
    return null;
  };

  const isEmpty = cartItems.length === 0;

  return (
    <div style={{ padding: "1.5rem", maxWidth: "960px", margin: "0 auto" }}>
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "baseline",
          marginBottom: "1rem",
        }}
      >
        <h1 style={{ margin: 0 }}>Cart ({itemCount})</h1>
        {!isEmpty && (
          <div style={{ textAlign: "right", fontSize: "0.95rem" }}>
            <div>Total: ${total.toFixed(2)}</div>
          </div>
        )}
      </header>

      {isEmpty ? (
        <div>
          <p>Your cart is empty.</p>
          <NavLink
            to="/shop"
            className="btn-secondary-small"
            style={{
              display: "inline-block",
              marginTop: "0.75rem",
            }}
          >
            Browse the Shop
          </NavLink>
        </div>
      ) : (
        <>
          <section
            style={{
              marginBottom: "1.5rem",
              border: "1px solid #1f2933",
              borderRadius: "12px",
              padding: "1rem",
            }}
          >
            <h2 style={{ marginTop: 0, marginBottom: "0.75rem" }}>
              Cart Items
            </h2>

            {cartItems.map((item, index) => {
              const title = getDisplayTitle(item);
              const typeLabel = getTypeLabel(item);

              return (
                <div
                  key={item.id || index}
                  style={{
                    border: "1px solid #4b5563",
                    borderRadius: "8px",
                    padding: "0.75rem",
                    marginBottom: "0.75rem",
                    display: "flex",
                    gap: "1rem",
                    alignItems: "center",
                  }}
                >
                  {item.thumb && (
                    <div
                      style={{
                        width: "72px",
                        height: "72px",
                        borderRadius: "8px",
                        overflow: "hidden",
                        flexShrink: 0,
                        backgroundColor: "#020617",
                      }}
                    >
                      <img
                        src={item.thumb}
                        alt={title}
                        style={{
                          width: "100%",
                          height: "100%",
                          objectFit: "cover",
                          display: "block",
                        }}
                      />
                    </div>
                  )}

                  <div style={{ flex: 1 }}>
                    <div
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        marginBottom: "0.25rem",
                      }}
                    >
                      <h3 style={{ margin: 0, fontSize: "1rem" }}>{title}</h3>
                      {typeLabel && (
                        <span
                          style={{
                            fontSize: "0.7rem",
                            padding: "0.1rem 0.5rem",
                            borderRadius: "999px",
                            border: "1px solid #4b5563",
                            textTransform: "uppercase",
                            letterSpacing: "0.05em",
                          }}
                        >
                          {typeLabel}
                        </span>
                      )}
                    </div>

                    <div
                      style={{
                        display: "flex",
                        gap: "1rem",
                        fontSize: "0.9rem",
                      }}
                    >
                      <span>Qty: {item.quantity || 1}</span>
                      <span>
                        Price: ${Number(item.price || 0).toFixed(2)}
                      </span>
                    </div>

                    <button
                      type="button"
                      onClick={() => handleRemoveItem(item.id)}
                      style={{ marginTop: "0.5rem" }}
                    >
                      Remove
                    </button>
                  </div>
                </div>
              );
            })}

            <div
              style={{
                marginTop: "0.75rem",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <strong>Cart total: ${total.toFixed(2)}</strong>
              <button type="button" onClick={handleClearCart}>
                Clear Cart
              </button>
            </div>
          </section>

          <section
            style={{
              border: "1px solid #1f2933",
              borderRadius: "12px",
              padding: "1rem",
            }}
          >
            <h2 style={{ marginTop: 0 }}>Checkout</h2>

            <div
              style={{
                marginBottom: "1rem",
                paddingBottom: "0.75rem",
                borderBottom: "1px solid #111827",
                fontSize: "0.95rem",
              }}
            >
              <h3
                style={{
                  margin: "0 0 0.5rem 0",
                  fontSize: "0.95rem",
                  textTransform: "uppercase",
                  letterSpacing: "0.05em",
                }}
              >
                Order Summary
              </h3>
              <ul style={{ margin: 0, paddingLeft: "1.1rem" }}>
                {cartItems.map((item, index) => (
                  <li key={item.id || index}>
                    {getDisplayTitle(item)} &times; {item.quantity || 1} (
                    ${Number(item.price || 0).toFixed(2)} each)
                  </li>
                ))}
              </ul>
              <p style={{ marginTop: "0.5rem" }}>
                <strong>Total: ${total.toFixed(2)}</strong>
              </p>
            </div>

            <form onSubmit={handleCheckout}>
              <div style={{ marginBottom: "0.75rem" }}>
                <label>
                  Name on Card
                  <input
                    type="text"
                    value={nameOnCard}
                    onChange={(e) => setNameOnCard(e.target.value)}
                    required
                    style={{
                      display: "block",
                      width: "100%",
                      marginTop: "0.25rem",
                    }}
                  />
                </label>
              </div>

              <div style={{ marginBottom: "0.75rem" }}>
                <label>
                  Card Number
                  <input
                    type="text"
                    value={cardNumber}
                    onChange={(e) => setCardNumber(e.target.value)}
                    required
                    inputMode="numeric"
                    style={{
                      display: "block",
                      width: "100%",
                      marginTop: "0.25rem",
                    }}
                  />
                </label>
              </div>

              <div
                style={{
                  display: "flex",
                  gap: "0.75rem",
                  marginBottom: "0.75rem",
                  flexWrap: "wrap",
                }}
              >
                <label style={{ flex: "1 1 120px" }}>
                  Expiration (MM/YY)
                  <input
                    type="text"
                    value={expiration}
                    onChange={(e) => setExpiration(e.target.value)}
                    required
                    placeholder="MM/YY"
                    style={{
                      display: "block",
                      width: "100%",
                      marginTop: "0.25rem",
                    }}
                  />
                </label>

                <label style={{ flex: "1 1 80px" }}>
                  CVC
                  <input
                    type="text"
                    value={cvc}
                    onChange={(e) => setCvc(e.target.value)}
                    required
                    inputMode="numeric"
                    style={{
                      display: "block",
                      width: "100%",
                      marginTop: "0.25rem",
                    }}
                  />
                </label>
              </div>

              <button type="submit" disabled={!itemCount}>
                Submit Payment
              </button>
            </form>
          </section>
        </>
      )}
    </div>
  );
}

export default CartPage;
