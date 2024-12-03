import React, { createContext, useContext, useEffect, useState } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "../SDK_FIREBASE";
import { definirTipoUsuario } from "./definirTipoUsuario";

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [tipoUsuario, setTipoUsuario] = useState(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (usuarioFirebase) => {
      if (usuarioFirebase) {
        setUser(usuarioFirebase);
        const tipo = await definirTipoUsuario(usuarioFirebase.email);
        setTipoUsuario(tipo);
      } else {
        setUser(null);
        setTipoUsuario(null);
      }
    });

    return () => unsubscribe();
  }, []);

  return (
    <AuthContext.Provider value={{ user, tipoUsuario }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
