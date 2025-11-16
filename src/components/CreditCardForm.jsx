import React, { useEffect, useState } from "react";

const STORAGE_KEY = "eztechmovie-credit-card";

const defaultForm = {
  cardNumber: "",
  nameOnCard: "",
  expiry: "",
  cvv: ""
};

export default function CreditCardForm({ onSubmitSuccess }) {
  const [form, setForm] = useState(defaultForm);
  const [error, setError] = useState("");

  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        setForm(prev => ({ ...prev, ...parsed }));
      } catch {
      }
    }
  }, []);

  const handleChange = event => {
    const { name, value } = event.target;

    if (name === "cardNumber") {
      const digitsOnly = value.replace(/\D/g, "").slice(0, 16);
      const groups = digitsOnly.match(/.{1,4}/g) || [];
      const formatted = groups.join(" ");
      setForm(prev => ({ ...prev, cardNumber: formatted }));
      return;
    }

    setForm(prev => ({ ...prev, [name]: value }));
  };

  const validate = () => {
    if (form.cardNumber.length !== 19) {
      return "Card number must be 16 digits in the format 1234 5678 9012 3456.";
    }
    if (!form.nameOnCard.trim()) {
      return "Name on card is required.";
    }
    if (!/^\d{2}\/\d{2}$/.test(form.expiry)) {
      return "Expiry must be in MM/YY format.";
    }
    if (!/^\d{3,4}$/.test(form.cvv)) {
      return "CVV must be 3 or 4 digits.";
    }
    return "";
  };

  const handleSubmit = event => {
    event.preventDefault();
    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        cardNumber: form.cardNumber,
        nameOnCard: form.nameOnCard,
        expiry: form.expiry
      })
    );

    setError("");
    if (onSubmitSuccess) {
      onSubmitSuccess(form);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginTop: "16px" }}>
      <h2 style={{ fontSize: "18px", fontWeight: 600 }}>Payment Details</h2>

      <div style={{ marginTop: "8px" }}>
        <label style={{ display: "block", fontSize: "14px" }}>Card Number</label>
        <input
          type="text"
          name="cardNumber"
          value={form.cardNumber}
          onChange={handleChange}
          placeholder="1234 5678 9012 3456"
          style={{ width: "100%", padding: "8px", marginTop: "4px" }}
        />
      </div>

      <div style={{ marginTop: "8px" }}>
        <label style={{ display: "block", fontSize: "14px" }}>Name on Card</label>
        <input
          type="text"
          name="nameOnCard"
          value={form.nameOnCard}
          onChange={handleChange}
          placeholder="Full name"
          style={{ width: "100%", padding: "8px", marginTop: "4px" }}
        />
      </div>

      <div style={{ display: "flex", gap: "12px", marginTop: "8px" }}>
        <div style={{ flex: 1 }}>
          <label style={{ display: "block", fontSize: "14px" }}>Expiry (MM/YY)</label>
          <input
            type="text"
            name="expiry"
            value={form.expiry}
            onChange={handleChange}
            placeholder="08/28"
            style={{ width: "100%", padding: "8px", marginTop: "4px" }}
          />
        </div>
        <div style={{ flex: 1 }}>
          <label style={{ display: "block", fontSize: "14px" }}>CVV</label>
          <input
            type="password"
            name="cvv"
            value={form.cvv}
            onChange={handleChange}
            placeholder="123"
            style={{ width: "100%", padding: "8px", marginTop: "4px" }}
          />
        </div>
      </div>

      {error && (
        <p style={{ marginTop: "8px", fontSize: "13px", color: "#f97373" }}>
          {error}
        </p>
      )}

      <button
        type="submit"
        style={{
          marginTop: "12px",
          padding: "8px 12px",
          borderRadius: "6px",
          border: "none",
          backgroundColor: "#0ea5e9",
          color: "#020617",
          fontSize: "14px",
          fontWeight: 500,
          cursor: "pointer"
        }}
      >
        Save Card and Complete Checkout
      </button>
    </form>
  );
}
