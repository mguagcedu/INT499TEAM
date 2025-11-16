const STORAGE_KEY = "streamlist-cart";

export function readCart() {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return [];
    const parsed = JSON.parse(stored);

    if (Array.isArray(parsed)) return parsed;
    if (parsed && Array.isArray(parsed.items)) return parsed.items;
    return [];
  } catch {
    return [];
  }
}

export function writeCart(items) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    window.dispatchEvent(new CustomEvent("cart-changed"));
  } catch (err) {
    console.error("Error writing cart", err);
  }
}

export function getCartCount() {
  const items = readCart();
  return items.reduce((sum, item) => sum + (item.quantity || 1), 0);
}
