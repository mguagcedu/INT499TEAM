import React, { useState } from "react";
import { useApp } from "../context/AppContext";

export default function CheckoutPage() {
  const { cart, cartTotal, saveCard } = useApp();
  const [nameOnCard, setNameOnCard] = useState("");
  const [cardNumber, setCardNumber] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvv, setCvv] = useState("");
  const [message, setMessage] = useState("");

  function handleSubmit(e) {
    e.preventDefault();

    const cardRegex = /^\d{4} \d{4} \d{4} \d{4}$/;
    if (!cardRegex.test(cardNumber)) {
      setMessage("Card number must be in the format 1234 5678 9012 3456.");
      return;
    }

    saveCard({
      nameOnCard,
      cardNumber,
      expiry,
      last4: cardNumber.slice(-4)
    });

    setMessage("Card saved locally for this demo checkout.");
  }

  return (
    <section>
      <h2 style={{ fontSize: 22, marginBottom: 8 }}>Secure checkout</h2>
      <p style={{ fontSize: 13, color: "#9ca3af", marginBottom: 14 }}>
        For this project demo, card information is stored only in local
        storage, not sent to a real gateway. In production a PCI compliant
        provider would handle all payment data.
      </p>

      {cart.length === 0 ? (
        <p style={{ fontSize: 13, color: "#6b7280" }}>
          Your cart is empty. Add items on the Shop tab first.
        </p>
      ) : (
        <>
          <div
            style={{
              marginBottom: 12,
              fontSize: 13
            }}
          >
            <div style={{ marginBottom: 4 }}>Items:</div>
            <ul style={{ paddingLeft: 18, marginTop: 0 }}>
              {cart.map((item) => (
                <li key={item.id}>
                  {item.quantity} x {item.name} (${item.price.toFixed(2)} each)
                </li>
              ))}
            </ul>
            <div
              style={{
                fontSize: 14,
                fontWeight: 600,
                marginTop: 4
              }}
            >
              Order total: ${cartTotal.toFixed(2)}
            </div>
          </div>

          <form
            onSubmit={handleSubmit}
            style={{
              maxWidth: 420,
              display: "flex",
              flexDirection: "column",
              gap: 8
            }}
          >
            <label style={{ fontSize: 12 }}>
              Name on card
              <input
                type="text"
                value={nameOnCard}
                onChange={(e) => setNameOnCard(e.target.value)}
                style={{
                  width: "100%",
                  padding: "6px 8px",
                  borderRadius: 8,
                  border: "1px solid #374151",
                  backgroundColor: "#020617",
                  color: "#e5e7eb",
                  fontSize: 13,
                  marginTop: 2
                }}
              />
            </label>

            <label style={{ fontSize: 12 }}>
              Card number (format 1234 5678 9012 3456)
              <input
                type="text"
                value={cardNumber}
                onChange={(e) => setCardNumber(e.target.value)}
                placeholder="1234 5678 9012 3456"
                style={{
                  width: "100%",
                  padding: "6px 8px",
                  borderRadius: 8,
                  border: "1px solid #374151",
                  backgroundColor: "#020617",
                  color: "#e5e7eb",
                  fontSize: 13,
                  marginTop: 2
                }}
              />
            </label>

            <div
              style={{
                display: "flex",
                gap: 8
              }}
            >
              <label style={{ fontSize: 12, flex: 1 }}>
                Expiry (MM/YY)
                <input
                  type="text"
                  value={expiry}
                  onChange={(e) => setExpiry(e.target.value)}
                  placeholder="08/28"
                  style={{
                    width: "100%",
                    padding: "6px 8px",
                    borderRadius: 8,
                    border: "1px solid #374151",
                    backgroundColor: "#020617",
                    color: "#e5e7eb",
                    fontSize: 13,
                    marginTop: 2
                  }}
                />
              </label>
              <label style={{ fontSize: 12, width: 80 }}>
                CVV
                <input
                  type="password"
                  value={cvv}
                  onChange={(e) => setCvv(e.target.value)}
                  style={{
                    width: "100%",
                    padding: "6px 8px",
                    borderRadius: 8,
                    border: "1px solid #374151",
                    backgroundColor: "#020617",
                    color: "#e5e7eb",
                    fontSize: 13,
                    marginTop: 2
                  }}
                />
              </label>
            </div>

            <button
              type="submit"
              style={{
                marginTop: 6,
                padding: "8px 14px",
                borderRadius: 999,
                border: "none",
                backgroundColor: "#22c55e",
                color: "#020617",
                fontSize: 13,
                fontWeight: 600,
                cursor: "pointer"
              }}
            >
              Save card (demo)
            </button>

            {message && (
              <p
                style={{
                  marginTop: 6,
                  fontSize: 12,
                  color: "#a5b4fc"
                }}
              >
                {message}
              </p>
            )}
          </form>
        </>
      )}
    </section>
  );
}
