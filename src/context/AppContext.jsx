import React, { createContext, useContext, useEffect, useState } from "react";

const AppContext = createContext(null);

const STORAGE_KEY = "streamlist_app_state_v1";

const defaultShopItems = [
  {
    id: "sub-basic",
    name: "Basic Subscription",
    type: "subscription",
    level: 1,
    description: "720p streaming on 1 device",
    price: 9.99,
    imageUrl:
      "https://static.vecteezy.com/system/resources/previews/025/437/982/non_2x/game-level-up-shield-badge-win-icon-bonus-award-vector.jpg",
  },
  {
    id: "sub-standard",
    name: "Standard Subscription",
    type: "subscription",
    level: 2,
    description: "1080p streaming on 2 devices",
    price: 14.99,
    imageUrl:
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvdwVRbBdbV8prg18ao7o_zzzDwOFodVrPRA&s",
  },
  {
    id: "sub-premium",
    name: "Premium Subscription",
    type: "subscription",
    level: 3,
    description: "4K streaming on 4 devices",
    price: 19.99,
    imageUrl:
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWC_ePsWFETslNjKtXVysDTItR-uxpaaaP7w&s",
  },
  {
    id: "shirt",
    name: "EZTechMovie T-Shirt",
    type: "merch",
    description: "Soft cotton tee with EZTechMovie logo",
    price: 24.99,
    imageUrl:
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeIY969YenTvHsgWRjmSsFWgpWdnRS0aEaYw&s",
  },
  {
    id: "hoodie",
    name: "EZTechMovie Hoodie",
    type: "merch",
    description: "Cozy hoodie for binge sessions",
    price: 39.99,
    imageUrl:
      "https://static.vecteezy.com/system/resources/thumbnails/026/325/400/small/white-hoodie-mockup-empty-and-3d-isolated-on-a-plain-background-ai-generated-photo.jpg",
  },
  {
    id: "case",
    name: "EZTechMovie Phone Case",
    type: "merch",
    description: "Protect your phone in streaming style",
    price: 19.99,
    imageUrl:
      "https://cdn.thewirecutter.com/wp-content/media/2024/10/BEST-IPHONE-16-CASES-2048px-4833-2x1-1.jpg?width=2048&quality=75&crop=2:1&auto=webp",
  },
];

const defaultState = {
  plannerItems: [],
  favorites: [],
  cart: [],
  shopItems: defaultShopItems,
};

export function AppProvider({ children }) {
  const [plannerItems, setPlannerItems] = useState(defaultState.plannerItems);
  const [favorites, setFavorites] = useState(defaultState.favorites);
  const [cart, setCart] = useState(defaultState.cart);
  const [shopItems] = useState(defaultState.shopItems);

  // load from localStorage on first mount
  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return;
      const parsed = JSON.parse(raw);
      if (parsed.plannerItems) setPlannerItems(parsed.plannerItems);
      if (parsed.favorites) setFavorites(parsed.favorites);
      if (parsed.cart) setCart(parsed.cart);
    } catch (e) {
      console.error("Failed to load state from localStorage", e);
    }
  }, []);

  // persist on change
  useEffect(() => {
    const data = {
      plannerItems,
      favorites,
      cart,
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  }, [plannerItems, favorites, cart]);

  // planner actions
  const addPlannerItem = (text) => {
    if (!text?.trim()) return;
    const item = {
      id: crypto.randomUUID(),
      text: text.trim(),
      createdAt: new Date().toISOString(),
      completed: false,
    };
    setPlannerItems((prev) => [item, ...prev]);
  };

  const updatePlannerItem = (id, newText) => {
    setPlannerItems((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, text: newText.trim() } : item
      )
    );
  };

  const togglePlannerComplete = (id) => {
    setPlannerItems((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, completed: !item.completed } : item
      )
    );
  };

  const deletePlannerItem = (id) => {
    setPlannerItems((prev) => prev.filter((item) => item.id !== id));
  };

  // favorites actions
  const addFavorite = (movie) => {
    if (!movie || !movie.id) return;
    setFavorites((prev) => {
      if (prev.some((f) => f.id === movie.id)) return prev;
      const favorite = {
        id: movie.id,
        title: movie.title || movie.name || "Untitled",
        posterUrl: movie.posterUrl || movie.poster_path || movie.poster,
        overview: movie.overview || "",
        tmdbUrl:
          movie.tmdbUrl ||
          (movie.id ? `https://www.themoviedb.org/movie/${movie.id}` : null),
      };
      return [favorite, ...prev];
    });
  };

  const removeFavorite = (id) => {
    setFavorites((prev) => prev.filter((f) => f.id !== id));
  };

  // cart actions
  const addToCart = (item) => {
    if (!item || !item.id) return;
    setCart((prev) => {
      const existing = prev.find((c) => c.id === item.id);
      if (existing) {
        return prev.map((c) =>
          c.id === item.id ? { ...c, quantity: c.quantity + 1 } : c
        );
      }
      return [
        ...prev,
        {
          id: item.id,
          name: item.name,
          price: item.price ?? 0,
          quantity: 1,
          imageUrl: item.imageUrl || null,
          type: item.type || "item",
        },
      ];
    });
  };

  const updateCartItemQty = (id, qty) => {
    const quantity = Number(qty);
    if (Number.isNaN(quantity) || quantity <= 0) {
      setCart((prev) => prev.filter((c) => c.id !== id));
    } else {
      setCart((prev) =>
        prev.map((c) => (c.id === id ? { ...c, quantity } : c))
      );
    }
  };

  const removeFromCart = (id) => {
    setCart((prev) => prev.filter((c) => c.id !== id));
  };

  const clearCart = () => {
    setCart([]);
  };

  const value = {
    plannerItems,
    addPlannerItem,
    updatePlannerItem,
    togglePlannerComplete,
    deletePlannerItem,
    favorites,
    addFavorite,
    removeFavorite,
    cart,
    addToCart,
    updateCartItemQty,
    removeFromCart,
    clearCart,
    shopItems,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp() {
  return useContext(AppContext);
}
