import React from "react";
import { Routes, Route } from "react-router-dom";
import { AuthProvider } from "./AuthContext";
import PrivateRoute from "./PrivateRoute";
import Login from "./Login";
import StreamListPage from "./pages/StreamListPage";
import CartPage from "./pages/CartPage";
import CheckoutPage from "./CheckoutPage";

const App = () => {
  return (
    <AuthProvider>
      <Routes>
        {/* Public login route */}
        <Route path="/login" element={<Login />} />

        {/* Protected main app interface */}
        <Route
          path="/"
          element={
            <PrivateRoute>
              <StreamListPage />
            </PrivateRoute>
          }
        />

        {/* Protected cart */}
        <Route
          path="/cart"
          element={
            <PrivateRoute>
              <CartPage />
            </PrivateRoute>
          }
        />

        {/* Protected checkout */}
        <Route
          path="/checkout"
          element={
            <PrivateRoute>
              <CheckoutPage />
            </PrivateRoute>
          }
        />

        {/* Fallback */}
        <Route
          path="*"
          element={
            <PrivateRoute>
              <StreamListPage />
            </PrivateRoute>
          }
        />
      </Routes>
    </AuthProvider>
  );
};

export default App;
