import React from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function LandingPage() {
  const navigate = useNavigate();
  const auth = useAuth();

  const handleBrowse = () => {
    navigate("/planner");
  };

  const handleDemo = () => {
    if (auth?.demoSignIn) {
      auth.demoSignIn();
    }
    navigate("/planner");
  };

  const handleGoogle = () => {
    navigate("/login");
  };

  return (
    <div className="landing-shell">
      <div className="landing-overlay" />
      <div className="landing-inner">
        <div className="landing-header">
          <span className="landing-logo-dot" /> EZTechMovie
        </div>
        <div className="landing-main">
          <div className="landing-copy">
            <h1>Plan, shop, and track your streaming life in one place.</h1>
            <p>
              StreamList helps you remember what to watch next, manage
              subscriptions, and keep your EZTechMovie extras in sync across
              devices.
            </p>
            <div className="landing-actions">
              <button
                type="button"
                className="btn-primary-hero"
                onClick={handleBrowse}
              >
                Browse with limited access
              </button>
              <button
                type="button"
                className="btn-secondary-hero"
                onClick={handleDemo}
              >
                Continue with demo account
              </button>
            </div>
            <button
              type="button"
              className="btn-google-hero"
              onClick={handleGoogle}
            >
              Sign in with Google
            </button>
          </div>
          <div className="landing-panel">
            <div className="landing-card">
              <p className="landing-card-title">Real time planner</p>
              <p className="landing-card-text">
                Add movies to your watch planner and never forget that
                recommendation again.
              </p>
            </div>
            <div className="landing-card">
              <p className="landing-card-title">Smart favorites</p>
              <p className="landing-card-text">
                Save movies from TMDB search directly into your favorites list.
              </p>
            </div>
            <div className="landing-card">
              <p className="landing-card-title">Cart and checkout demo</p>
              <p className="landing-card-text">
                Simulate subscriptions and merch purchases to showcase checkout
                flows.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
