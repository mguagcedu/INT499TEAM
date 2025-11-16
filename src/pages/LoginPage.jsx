/* global google */
import React from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { jwtDecode } from "jwt-decode";

export default function LoginPage() {
  const navigate = useNavigate();
  const { isAuthenticated, signIn } = useAuth();
  const buttonRef = React.useRef(null);

  React.useEffect(() => {
    if (isAuthenticated) {
      navigate("/overview");
      return;
    }

    const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
    if (!clientId) {
      console.error("VITE_GOOGLE_CLIENT_ID is not set in .env.local");
      return;
    }

    if (!window.google || !buttonRef.current) {
      return;
    }

    try {
      google.accounts.id.initialize({
        client_id: clientId,
        callback: (response) => {
          try {
            const decoded = jwtDecode(response.credential);
            const profile = {
              name: decoded.name,
              email: decoded.email,
              picture: decoded.picture
            };
            signIn(profile);
            navigate("/overview");
          } catch (err) {
            console.error("Failed to decode Google credential", err);
          }
        }
      });

      google.accounts.id.renderButton(buttonRef.current, {
        type: "standard",
        theme: "outline",
        size: "large",
        width: "100%"
      });
    } catch (e) {
      console.error("Error initializing Google Identity Services", e);
    }
  }, [isAuthenticated, navigate, signIn]);

  const handleBack = () => {
    navigate("/");
  };

  const handleDemoLogin = () => {
    // Fallback if Google OAuth has config issues
    signIn({
      name: "Demo EZTech User",
      email: "manuel.gomez2@student.uagc.edu"
    });
    navigate("/overview");
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "radial-gradient(circle at top, #0ea5e9 0, #020617 55%)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 24
      }}
    >
      <div
        style={{
          maxWidth: 420,
          width: "100%",
          backgroundColor: "rgba(15,23,42,0.96)",
          borderRadius: 20,
          padding: 28,
          boxShadow: "0 24px 60px rgba(15,23,42,0.95)",
          border: "1px solid rgba(148,163,184,0.5)"
        }}
      >
        <button
          type="button"
          onClick={handleBack}
          style={{
            fontSize: 11,
            marginBottom: 12,
            background: "transparent",
            border: "none",
            color: "#9ca3af",
            cursor: "pointer"
          }}
        >
          ← Back to landing
        </button>

        <h1
          style={{
            fontSize: 22,
            color: "#f9fafb",
            marginBottom: 6
          }}
        >
          Sign in with Google
        </h1>
        <p
          style={{
            fontSize: 13,
            color: "#d1d5db",
            marginBottom: 18
          }}
        >
          Use your Google account to unlock the full StreamList experience. Your
          basic profile information is used only for this internal prototype.
        </p>

        {/* Real Google button */}
        <div
          ref={buttonRef}
          style={{
            display: "flex",
            justifyContent: "center",
            marginBottom: 12
          }}
        />

        {/* Fallback demo sign in so you are never stuck */}
        <button
          type="button"
          onClick={handleDemoLogin}
          style={{
            width: "100%",
            padding: "9px 14px",
            borderRadius: 999,
            border: "1px dashed rgba(148,163,184,0.7)",
            backgroundColor: "transparent",
            color: "#e5e7eb",
            fontSize: 12,
            cursor: "pointer",
            marginBottom: 10
          }}
        >
          Or continue with demo sign in
        </button>

        <p
          style={{
            fontSize: 11,
            color: "#9ca3af"
          }}
        >
          The Google button above uses Google Identity Services when your client
          ID is configured correctly. The demo option below is provided so you
          can always access full functionality for this course project, even if
          OAuth settings are still being finalized.
        </p>
      </div>
    </div>
  );
}
