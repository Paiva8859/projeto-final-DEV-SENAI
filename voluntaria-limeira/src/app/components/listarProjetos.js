import { db } from "../SDK_FIREBASE"; // Importa sua configuração do Firebase
import {
  collection,
  getDocs,
  doc,
  updateDoc,
  deleteDoc,
} from "firebase/firestore"; // Importa métodos do Firestore
import React, { useEffect, useState } from "react";
import style from "@/app/style/listarProjetos.module.css"; // Estilo CSS
import { AuthProvider, useAuth } from "../service/authContext";

function ListarProjetos() {
  const [projetos, setProjetos] = useState([]); // Estado para armazenar os projetos
  const [carregando, setCarregando] = useState(true); // Estado para controle do carregamento
  const {tipoUsuario} = useAuth() || {};
  const [usuario, setTipoUsuario] = useState(null);

  useEffect(() => {
    // Função para buscar os projetos no Firestore
    
    const fetchProjetos = async () => {
      try {
        const usuariosRef = collection(db, "Usuarios"); // Referência à coleção de usuários
        const usuariosSnapshot = await getDocs(usuariosRef); // Busca todos os usuários

        let todosProjetos = []; // Lista para armazenar todos os projetos
        for (const usuarioDoc of usuariosSnapshot.docs) {
          const projetosRef = collection(
            db,
            `Usuarios/${usuarioDoc.id}/Projetos`
          ); // Referência à subcoleção `Projetos`
          const projetosSnapshot = await getDocs(projetosRef);

          // Mapeia os projetos dessa subcoleção e adiciona na lista geral
          
          todosProjetos = [
            ...todosProjetos,
            ...projetosSnapshot.docs.map((projetoDoc) => ({
              id: projetoDoc.id,
              ...projetoDoc.data(),
              usuarioId: usuarioDoc.id, // Adiciona o ID do usuário relacionado
            })).filter((projeto)=>projeto.verificado === false),
          ];

          setProjetos(todosProjetos)
        }

        setProjetos(todosProjetos); // Atualiza o estado com todos os projetos
      } catch (error) {
        console.error("Erro ao buscar projetos:", error);
      } finally {
        setCarregando(false); // Finaliza o carregamento
      }
    };

    fetchProjetos();
  }, []);

  const aceitarProjeto = async (id) => {
    try {
      const projetoRef = doc(
        db,
        `Usuarios/${projetos.find((p) => p.id === id).usuarioId}/Projetos`,
        id
      );
const valor = prompt("Digite o valor que os usuários vão receber")
console.log(valor);
      // Atualiza o projeto no Firestore
      await updateDoc(projetoRef, {
        verificado: true,
        recompensa: Number(valor) // Atualiza os campos necessários
      });

      // Atualiza o estado local
      setProjetos(
        (prevProjetos) => prevProjetos.filter((projeto) => projeto.id !== id) // Remove o projeto da lista
      );

      console.log("Projeto aprovado e removido da lista!");
    } catch (error) {
      console.error("Erro ao aceitar o projeto:", error);
    }
  };


  // Função para excluir o projeto ao reprovar
  const reprovarProjeto = async (id) => {
    try {
      const projetoRef = doc(
        db,
        `Usuarios/${projetos.find((p) => p.id === id).usuarioId}/Projetos`,
        id
      ); // Corrige o caminho do documento
      await deleteDoc(projetoRef); // Exclui o projeto da subcoleção

      // Atualiza o estado para remover o projeto da lista
      setProjetos(
        (prevProjetos) => prevProjetos.filter((projeto) => projeto.id !== id) // Remove o projeto da lista local
      );
    } catch (error) {
      console.error("Erro ao reprovar e excluir o projeto:", error);
    }
  };

  // Exibe mensagem de carregamento
  if (carregando) {
    return <div>Carregando projetos...</div>;
  }

  // Exibe a lista de projetos ou mensagem de erro
  return (
    <AuthProvider>
      <div className={style.container}>
        {tipoUsuario === "Administrador" ? (
          <ul className={style.projetoLista}>
            {projetos.map((projeto) => (
              <li key={projeto.id} className={style.projetoItem}>
                <div className={style.projetos}>
                  <div className={style.imagem}>
                    <img src="/logo.png" alt="Imagem Projeto"></img>
                  </div>
                  <div className={style.informacoes}>
                    <h3>{projeto.nome}</h3>
                    <p>
                      <strong>Descrição:</strong> {projeto.descricao}
                    </p>
                    <p>
                      <strong>Local ou Valor:</strong> {projeto.localOuValor}
                    </p>
                    <div className={style.acoes}>
                      <button
                        className={style.btnRecusar}
                        onClick={() => {
                          reprovarProjeto(projeto.id);
                        }}
                      >
                        X
                      </button>
                      <button
                        className={style.btnAprovar}
                        onClick={() => {
                          aceitarProjeto(projeto.id);
                        }}
                      >
                        ✓
                      </button>
                    </div>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <p>404 not found!</p>
        )}
      </div>
    </AuthProvider>
  );
}

export default ListarProjetos;
