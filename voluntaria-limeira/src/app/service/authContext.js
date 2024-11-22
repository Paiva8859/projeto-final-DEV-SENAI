"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "../SDK_FIREBASE";

// criar o contexto
const authContext = createContext();

// crie um hook personalizado para acessar o contexto com facilidade
export function useAuth() {
  return useContext(authContext);
}

export function AuthProvider({ children }) {
  const [usuarioLogado, setUsuarioLogado] = useState(null);
  const [tipoUsuario, setTipoUsuario] = useState("");

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        console.log("Usuário logado:", user); // Verifique se o usuário está logado
        setUsuarioLogado(user);

        try {
          const refEmpresa = doc(db, "Empresa", user.uid);
          const docEmpresa = await getDoc(refEmpresa);

          if (docEmpresa.exists()) {
            console.log("Esse usuário é uma empresa.");
            setTipoUsuario("Empresa");
            return;
          }

          const refAdministrador = doc(db, "Administradores", user.uid);
          const docAdministrador = await getDoc(refAdministrador);

          if (docAdministrador.exists()) {
            console.log("Esse usuário é um administrador");
            setTipoUsuario("Administrador");
          } else {
            console.log("Nenhum dado encontrado para usuário.");
            setTipoUsuario("");
          }
        } catch (err) {
          console.error(`Houve um erro ao buscar o usuário: ${err}`);
        }
      } else {
        console.log("Nenhum usuário logado");
        setUsuarioLogado(null);
        setTipoUsuario("");
      }
    });

    return () => unsubscribe();
  }, []);

  console.log("Tipo de usuário:", tipoUsuario); // Verifique se tipoUsuario é atualizado corretamente

  const value = {
    usuarioLogado,
    tipoUsuario,
  };

  return <authContext.Provider value={value}>{children}</authContext.Provider>;
}
