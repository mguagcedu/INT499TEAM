import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "./AuthContext";

const Login = () => {
  const { isAuthenticated, loginWithGoogle } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (isAuthenticated) navigate("/");
  }, [isAuthenticated, navigate]);

  return (
    <div style={{ padding: "2rem" }}>
      <h1>Login to EZTechMovie</h1>
      <button onClick={loginWithGoogle}>Sign in with Google</button>
    </div>
  );
};

export default Login;
