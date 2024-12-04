import { db } from "../SDK_FIREBASE"; // Importa sua configuração do Firebase
import {
  collection,
  getDocs,
  getDoc,
  doc,
  deleteDoc,
  updateDoc,
} from "firebase/firestore";
import { getAuth, onAuthStateChanged } from "firebase/auth";
import React, { useEffect, useState } from "react";
import style from "@/app/style/listarRecompensas.module.css";

function ListarRecompensas() {
  const [recompensas, setRecompensas] = useState([]);
  const [carregando, setCarregando] = useState(true);
    const [tipoUsuario, setTipoUsuario] = useState("");


  useEffect(() => {
    const fetchRecompensas = async () => {
      try {
        const recompensasRef = collection(db, "Recompensa");
        const recompensasSnapshot = await getDocs(recompensasRef);

        const listaRecompensas = recompensasSnapshot.docs
          .map((doc) => ({
            id: doc.id,
            ...doc.data(),
          }))
          .filter((rec) => !rec.verificado); // Filtra apenas as recompensas não verificadas

        setRecompensas(listaRecompensas);
      } catch (error) {
        console.error("Erro ao buscar recompensas:", error);
      } finally {
        setCarregando(false);
      }
    };

    fetchRecompensas();
  }, [tipoUsuario]);

  const verificarEmail = async (email) => {
    const docRefAdministrador = doc(db, "Administradores", email); // Buscando pelo email do usuário na coleção Administradores
    const docSnapAdministrador = await getDoc(docRefAdministrador); // Obtém os dados do documento dos Administradores

    const docRefEmpresa = doc(db, "Empresa", email); // Buscando pelo email do usuário na coleção Empresa
    const docSnapEmpresa = await getDoc(docRefEmpresa); // Obtém os dados do documento da Empresa

    if (docSnapAdministrador.exists()) {
      console.log("Dados encontrados:", docSnapAdministrador.data());
      setTipoUsuario("Administrador"); // Se encontrado na coleção Administradores, define como "Administrador"
      return;
    }

    if (docSnapEmpresa.exists()) {
      console.log("Dados encontrados:", docSnapEmpresa.data());
      setTipoUsuario("Empresa"); // Se encontrado na coleção Empresa, define como "Empresa"
      return;
    }

    console.log("Tipo de usuário:", tipoUsuario);
    setTipoUsuario("Indefinido"); // Caso não encontre nenhum dos dois, define como "Indefinido"
  };

  // Função para pegar o usuário logado
  useEffect(() => {
    const auth = getAuth();
    onAuthStateChanged(auth, async (user) => {
      if (user) {
        // O usuário está logado
        console.log("Usuário logado:", user.email);
        if (user.email) {
          await verificarEmail(user.email); // Chama a função para verificar o tipo
        }
      } else {
        // Nenhum usuário logado
        console.log("Nenhum usuário logado.");
      }
    });
  }, []); // Use apenas uma vez ao carregar o componente
  // Função para aceitar uma recompensa
  const handleAceitar = async (id) => {
    try {
      const recompensaRef = doc(db, "Recompensa", id);
      await updateDoc(recompensaRef, { verificado: true }); // Atualiza o campo 'verificado' para true
      alert("Recompensa aceita com sucesso!");
      setRecompensas((prev) => prev.filter((rec) => rec.id !== id)); // Remove do estado
    } catch (error) {
      console.error("Erro ao aceitar recompensa:", error);
    }
  };

  // Função para recusar (excluir) uma recompensa
  const handleRecusar = async (id) => {
    try {
      const recompensaRef = doc(db, "Recompensa", id);
      await deleteDoc(recompensaRef); // Exclui o documento do Firestore
      alert("Recompensa recusada e excluída com sucesso!");
      setRecompensas((prev) => prev.filter((rec) => rec.id !== id)); // Remove do estado
    } catch (error) {
      console.error("Erro ao excluir recompensa:", error);
    }
  };

  if (carregando) {
    return <div>Carregando recompensas...</div>;
  }

  return (
    <div className={style.container}>
      <h2>Lista de Recompensas Não Aprovadas</h2>
      {recompensas.length != 0 && tipoUsuario === "Administrador" ? (
        <ul className={style.listaRecompensas}>
          {recompensas.map((recompensa) => (
            <li key={recompensa.id} className={style.itemRecompensa}>
              <h3>{recompensa.titulo}</h3>
              <p>
                <strong>Descrição:</strong> {recompensa.descricao}
              </p>
              <p>
                <strong>Quantidade:</strong>{" "}
                {recompensa.quantidade ?? "Indefinido"}
              </p>
              <p>
                <strong>Data Início:</strong>{" "}
                {new Date(recompensa.dataInicio).toLocaleDateString("pt-BR")}
              </p>
              <p>
                <strong>Data Expiração:</strong>{" "}
                {new Date(recompensa.dataExpiracao).toLocaleDateString("pt-BR")}
              </p>
              <div className={style.botoes}>
                <button
                  className={style.btnRecusar}
                  onClick={() => handleAceitar(recompensa.id)}
                >
                  Aceitar
                </button>
                <button
                  className={style.btnAprovar}
                  onClick={() => handleRecusar(recompensa.id)}
                >
                  Recusar
                </button>
              </div>
            </li>
          ))}
        </ul>
      ) : (
        <p>Nenhuma recompensa pendente.</p>
      )}
    </div>
  );
}

export default ListarRecompensas;
