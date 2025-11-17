import React, { useState, useEffect } from "react";

const KEY = "eztech_credit_card";

const CheckoutPage = () => {
  const [cardName, setCardName] = useState("");
  const [cardNumber, setCardNumber] = useState("");
  const [expiry, setExpiry] = useState("");
  const [cvc, setCvc] = useState("");
  const [message, setMessage] = useState("");

  const formatCard = (value) => {
    const digits = value.replace(/\D/g, "").slice(0, 16);
    return digits.match(/.{1,4}/g)?.join(" ") || "";
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!/^\d{4} \d{4} \d{4} \d{4}$/.test(cardNumber)) {
      setMessage("Card number must match 1234 5678 9012 3456.");
      return;
    }

    const data = { cardName, cardNumber, expiry, cvc };
    localStorage.setItem(KEY, JSON.stringify(data));
    setMessage("Card saved.");
  };

  return (
    <div style={{ padding: "2rem" }}>
      <h1>Checkout</h1>
      <form onSubmit={handleSubmit}>
        <input placeholder="Name on card" value={cardName} onChange={(e) => setCardName(e.target.value)} />
        <input placeholder="1234 5678 9012 3456" value={cardNumber} onChange={(e) => setCardNumber(formatCard(e.target.value))} />
        <input placeholder="MM/YY" value={expiry} onChange={(e) => setExpiry(e.target.value)} />
        <input placeholder="CVC" value={cvc} onChange={(e) => setCvc(e.target.value)} />
        <button type="submit">Save Card</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
};

export default CheckoutPage;
