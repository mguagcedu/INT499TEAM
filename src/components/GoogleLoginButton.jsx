import React, { useEffect, useRef } from "react";
import { useAuth } from "../context/AuthContext";

export default function GoogleLoginButton() {
  const buttonRef = useRef(null);
  const { handleGoogleCredential } = useAuth();

  useEffect(() => {
    const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;

    if (!clientId) {
      console.error("VITE_GOOGLE_CLIENT_ID is missing in .env.local");
      return;
    }

    function handleCredentialResponse(response) {
      if (!response.credential) return;
      handleGoogleCredential(response.credential);
    }

    if (window.google && window.google.accounts && buttonRef.current) {
      window.google.accounts.id.initialize({
        client_id: clientId,
        callback: handleCredentialResponse
      });

      window.google.accounts.id.renderButton(buttonRef.current, {
        type: "standard",
        theme: "outline",
        size: "large",
        text: "continue_with",
        shape: "pill"
      });
    }
  }, [handleGoogleCredential]);

  return (
    <div
      style={{
        display: "flex",
        justifyContent: "center",
        marginTop: "16px"
      }}
    >
      <div ref={buttonRef}></div>
    </div>
  );
}
