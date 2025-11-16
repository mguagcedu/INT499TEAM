import React, { useEffect, useRef } from "react";
import { jwtDecode } from "jwt-decode";
import { useAuth } from "../context/AuthContext";

const GOOGLE_CLIENT_ID =
  import.meta.env.VITE_GOOGLE_CLIENT_ID ||
  "762177763504-1tkoj7otg2ubbfr6d1enrfo1kfq4inam.apps.googleusercontent.com";

export default function GoogleSignInButton() {
  const buttonRef = useRef(null);
  const { loginWithGoogleProfile } = useAuth();

  useEffect(() => {
    if (!window.google || !buttonRef.current) return;

    window.google.accounts.id.initialize({
      client_id: GOOGLE_CLIENT_ID,
      callback: (response) => {
        try {
          const decoded = jwtDecode(response.credential);
          const profile = {
            name: decoded.name,
            email: decoded.email,
            picture: decoded.picture,
          };
          loginWithGoogleProfile(profile);
        } catch (err) {
          console.error("Failed to decode Google credential", err);
        }
      },
    });

    window.google.accounts.id.renderButton(buttonRef.current, {
      type: "standard",
      theme: "outline",
      size: "large",
      text: "continue_with",
      shape: "rectangular",
      logo_alignment: "left",
    });
  }, [loginWithGoogleProfile]);

  return <div ref={buttonRef}></div>;
}
