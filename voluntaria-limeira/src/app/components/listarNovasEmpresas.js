"use client";
import React, { useEffect, useState } from "react";
import { getAuth, onAuthStateChanged } from "firebase/auth";
import {
  collection,
  getDocs,
  getDoc,
  doc,
  deleteDoc,
  updateDoc,
} from "firebase/firestore";
import { db } from "../SDK_FIREBASE"; // Certifique-se de ajustar o caminho se necessário
import style from "@/app/style/listarRecompensas.module.css";

function ListarNovasEmpresas() {
  const [empresas, setEmpresas] = useState([]);
  const [carregando, setCarregando] = useState(true);
  const [tipoUsuario, setTipoUsuario] = useState("");

  // Função para buscar empresas não verificadas no Firestore
  const fetchEmpresas = async () => {
    try {
      const empresaRef = collection(db, "Empresa");
      const empresaSnapshot = await getDocs(empresaRef);

      const listaEmpresas = empresaSnapshot.docs
        .map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }))
        .filter((empresa) => empresa.verificado === false);

      setEmpresas(listaEmpresas);
    } catch (error) {
      console.error("Erro ao buscar empresas:", error);
    } finally {
      setCarregando(false);
    }
  };

  // Função para verificar o tipo de usuário no Firestore
  const verificarEmail = async (email) => {
    const docRefAdministrador = doc(db, "Administradores", email);
    const docSnapAdministrador = await getDoc(docRefAdministrador);

    const docRefEmpresa = doc(db, "Empresa", email);
    const docSnapEmpresa = await getDoc(docRefEmpresa);

    if (docSnapAdministrador.exists()) {
      setTipoUsuario("Administrador");
      return;
    }

    if (docSnapEmpresa.exists()) {
      setTipoUsuario("Empresa");
      return;
    }

    setTipoUsuario("Indefinido");
  };

  // useEffect para buscar empresas quando o componente é montado
  useEffect(() => {
    fetchEmpresas();
  }, []);

  // useEffect para verificar o tipo de usuário autenticado
  useEffect(() => {
    const auth = getAuth();
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user && user.email) {
        await verificarEmail(user.email);
      }
    });
    return () => unsubscribe();
  }, []);

  // Função para aceitar empresa
  const handleAceitar = async (id) => {
    try {
      const empresaRef = doc(db, "Empresa", id);
      await updateDoc(empresaRef, { verificado: true });
      alert("Empresa aceita com sucesso!");
      setEmpresas((prev) => prev.filter((empresa) => empresa.id !== id));
    } catch (error) {
      console.error("Erro ao aceitar empresa:", error);
    }
  };

  // Função para recusar e excluir empresa
  const handleRecusar = async (id) => {
    try {
      const empresaRef = doc(db, "Empresa", id);
      await deleteDoc(empresaRef);
      alert("Empresa recusada e excluída com sucesso!");
      setEmpresas((prev) => prev.filter((empresa) => empresa.id !== id));
    } catch (error) {
      console.error("Erro ao excluir empresa:", error);
    }
  };

  if (carregando) {
    return <div>Carregando empresas...</div>;
  }

  return (
    <div className={style.container}>
      <h2>Lista de Empresas Não Aprovadas</h2>
      {empresas.length !== 0 && tipoUsuario === "Administrador" ? (
        <ul className={style.listaEmpresa}>
          {empresas.map((empresa) => (
            <li key={empresa.id} className={style.itemEmpresa}>
              <h3>{empresa.nome}</h3>
              <p>
                <strong>Email:</strong> {empresa.email}
              </p>
              <div className={style.botoes}>
                <button
                  className={style.btnRecusar}
                  onClick={() => handleAceitar(empresa.id)}
                >
                  Aceitar
                </button>
                <button
                  className={style.btnAprovar}
                  onClick={() => handleRecusar(empresa.id)}
                >
                  Recusar
                </button>
              </div>
            </li>
          ))}
        </ul>
      ) : (
        <p>Nenhuma empresa pendente.</p>
      )}
    </div>
  );
}

export default ListarNovasEmpresas;
