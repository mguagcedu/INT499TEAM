import { useEffect, useRef } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

/**
 * Watches auth state changes and handles global navigation rules:
 * - If the user just signed out, send them to the landing page (/).
 * - Login navigation to /home is handled in LoginPage + LandingPage.
 */
export default function AuthRedirector() {
  const { user, isLoading } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const prevUserRef = useRef(null);

  useEffect(() => {
    if (isLoading) return;

    const prevUser = prevUserRef.current;
    prevUserRef.current = user;

    // If user just logged out, redirect to landing page
    if (prevUser && !user) {
      if (location.pathname !== "/") {
        navigate("/", { replace: true });
      }
    }
  }, [user, isLoading, location.pathname, navigate]);

  return null;
}
