import React, { useEffect, useState } from "react";
import { readCart, writeCart } from "../utils/cartUtils";

const MERCH_ITEMS = [
  {
    id: "product-tee",
    refId: "tee",
    type: "product",
    label: "EZTechMovie T-shirt",
    price: 24.99,
    thumb: "",
  },
  {
    id: "product-hoodie",
    refId: "hoodie",
    type: "product",
    label: "StreamList Hoodie",
    price: 39.99,
    thumb: "",
  },
  {
    id: "product-phone-case",
    refId: "phone-case",
    type: "product",
    label: "EZTech Phone Case",
    price: 19.99,
    thumb: "",
  },
];

const SUBSCRIPTIONS = [
  {
    id: "sub-basic",
    refId: "basic",
    type: "subscription",
    label: "Basic Stream (Level 1)",
    price: 8.99,
    thumb: "",
  },
  {
    id: "sub-plus",
    refId: "plus",
    type: "subscription",
    label: "Plus Stream (Level 2)",
    price: 13.99,
    thumb: "",
  },
  {
    id: "sub-premium",
    refId: "premium",
    type: "subscription",
    label: "Premium Stream (Level 3)",
    price: 18.99,
    thumb:
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWC_ePsWFETslNjKtXVysDTItR-uxpaaaP7w&s",
  },
];

function ShopPage() {
  const [cartItems, setCartItems] = useState([]);
  const [subMessage, setSubMessage] = useState("");

  useEffect(() => {
    setCartItems(readCart());
  }, []);

  const cartCount = cartItems.reduce(
    (sum, item) => sum + (item.quantity || 1),
    0
  );

  const hasSubscription = cartItems.some(
    (i) => i.type === "subscription"
  );

  const currentSubscription = cartItems.find(
    (i) => i.type === "subscription"
  );

  const getQuantityForId = (id) => {
    const found = cartItems.find((i) => i.id === id);
    return found ? found.quantity || 1 : 0;
  };

  const updateCartStateFromItems = (items) => {
    writeCart(items);
    setCartItems(items);
  };

  const handleAddClick = (item) => {
    const current = cartItems;
    setSubMessage("");

    if (item.type === "subscription") {
      if (currentSubscription) {
        if (currentSubscription.id === item.id) {
          setSubMessage("This subscription is already in your cart.");
        } else {
          setSubMessage("You already have a subscription in your cart.");
        }
        return;
      }
    }

    const existing = current.find((c) => c.id === item.id);
    let next;

    if (existing) {
      next = current.map((c) =>
        c.id === item.id
          ? { ...c, quantity: (c.quantity || 1) + 1 }
          : c
      );
    } else {
      next = [...current, { ...item, quantity: 1 }];
    }

    updateCartStateFromItems(next);
  };

  const gridStyle = {
    display: "grid",
    gridTemplateColumns: "repeat(3, minmax(0, 1fr))",
    gap: "1rem",
    marginTop: "1rem",
  };

  const cardStyle = {
    border: "1px solid #4b5563",
    borderRadius: "8px",
    padding: "0.75rem 1rem",
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    gap: "1rem",
    minHeight: "80px",
  };

  return (
    <div style={{ padding: "1.5rem", maxWidth: "960px", margin: "0 auto" }}>
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "baseline",
          marginBottom: "1.25rem",
        }}
      >
        <h1 style={{ margin: 0 }}>Shop</h1>
        <div style={{ fontSize: "0.95rem" }}>
          <strong>Cart ({cartCount})</strong>
        </div>
      </header>

      <section style={{ marginBottom: "2rem" }}>
        <h2 style={{ marginBottom: "0.5rem" }}>Merchandise</h2>
        <div style={gridStyle}>
          {MERCH_ITEMS.map((item) => {
            const qty = getQuantityForId(item.id);
            return (
              <div key={item.id} style={cardStyle}>
                <div style={{ flex: 1 }}>
                  <h3
                    style={{
                      margin: 0,
                      marginBottom: "0.25rem",
                      fontSize: "1rem",
                    }}
                  >
                    {item.label}
                  </h3>
                  <p style={{ margin: 0, fontSize: "0.9rem" }}>
                    Product · ${item.price.toFixed(2)}
                  </p>
                  {qty > 0 && (
                    <p
                      style={{
                        margin: 0,
                        marginTop: "0.15rem",
                        fontSize: "0.8rem",
                        opacity: 0.8,
                      }}
                    >
                      In cart: {qty}
                    </p>
                  )}
                </div>
                <div style={{ textAlign: "right" }}>
                  <button
                    type="button"
                    onClick={() => handleAddClick(item)}
                  >
                    Add to Cart
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      <section>
        <h2 style={{ marginBottom: "0.25rem" }}>Subscriptions</h2>
        <p
          style={{
            marginTop: 0,
            fontSize: "0.85rem",
            opacity: 0.8,
          }}
        >
          Only one subscription can be in the cart at a time.
          {currentSubscription && (
            <>
              {" "}
              Current: <strong>{currentSubscription.label}</strong>
            </>
          )}
        </p>
        {subMessage && (
          <p
            style={{
              marginTop: "0.15rem",
              fontSize: "0.8rem",
              color: "#f97373",
            }}
            aria-live="polite"
          >
            {subMessage}
          </p>
        )}
        <div style={gridStyle}>
          {SUBSCRIPTIONS.map((item) => {
            const qty = getQuantityForId(item.id);
            const inCart =
              currentSubscription &&
              currentSubscription.id === item.id;
            const disabled = hasSubscription && !inCart;

            return (
              <div key={item.id} style={cardStyle}>
                <div style={{ flex: 1 }}>
                  <h3
                    style={{
                      margin: 0,
                      marginBottom: "0.25rem",
                      fontSize: "1rem",
                    }}
                  >
                    {item.label}
                  </h3>
                  <p style={{ margin: 0, fontSize: "0.9rem" }}>
                    Subscription · ${item.price.toFixed(2)}
                  </p>
                  {qty > 0 && (
                    <p
                      style={{
                        margin: 0,
                        marginTop: "0.15rem",
                        fontSize: "0.8rem",
                        opacity: 0.8,
                      }}
                    >
                      In cart: {qty}
                    </p>
                  )}
                </div>
                <div style={{ textAlign: "right" }}>
                  <button
                    type="button"
                    onClick={() => handleAddClick(item)}
                    disabled={disabled}
                  >
                    {inCart
                      ? "In Cart"
                      : disabled
                      ? "Subscription in Cart"
                      : "Add to Cart"}
                </button>
                </div>
              </div>
            );
          })}
        </div>
      </section>
    </div>
  );
}

export default ShopPage;
