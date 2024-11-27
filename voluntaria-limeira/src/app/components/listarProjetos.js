import { db } from "../SDK_FIREBASE"; // Importa sua configuração do Firebase
import { collection, getDocs, doc, deleteDoc, updateDoc} from "firebase/firestore"; // Importa métodos do Firestore
import { AuthProvider, useAuth } from "../service/authContext"; // Hook de autenticação
import React, { useEffect, useState } from "react";
import style from "@/app/style/listarProjetos.module.css"; // Estilo CSS

function ListarProjetos() {
  // const { usuario } = useAuth() || {}; // Obtém o tipo de usuário do contexto de autenticação
  const [tipoUsuario, setTipoUsuario] = useState("Administrador"); // Estado para armazenar o tipo de usuário
  const [projetos, setProjetos] = useState([]); // Estado para armazenar os projetos
  const [carregando, setCarregando] = useState(true); // Estado para controle do carregamento

  useEffect(() => {
    // Função para buscar os projetos no Firestore
    const fetchProjetos = async () => {
      try {
        const projetosRef = collection(db, "Usuarios"); // Referência à coleção
        const querySnapshot = await getDocs(projetosRef); // Busca os documentos
        const listaProjetos = querySnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));
        setProjetos(listaProjetos);
      } catch (error) {
        console.error("Erro ao buscar projetos:", error);
      } finally {
        setCarregando(false); // Finaliza o carregamento
      }
    };

    fetchProjetos();
  }, []);

  // Função para atualizar o projeto ao aceitar
  const aceitarProjeto = async (id) => {
    try {
      const projetoAprovado = true;
      const projetoRef = doc(db, "Projetos", id);
      await updateDoc(projetoRef, {
        vaquinha: false,
      });
      // Atualiza o estado para refletir as mudanças na UI
      setProjetos((prevProjetos) =>
        prevProjetos.map((projeto) =>
          projeto.id === id
            ? {
                ...projeto,
                verificado: true,
               
              }
            : projeto
        )
      );
    } catch (error) {
      console.error("Erro ao aceitar o projeto:", error);
    }
  };

  // Função para excluir o projeto ao reprovar
  const reprovarProjeto = async (id) => {
    try {
      const projetoRef = doc(db, "Projetos", id);
      await deleteDoc(projetoRef); // Exclui o projeto da coleção
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
    <>
      <AuthProvider>
        <div className={style.container}>
          {tipoUsuario === "Administrador" || tipoUsuario === "Empresa" ? (
            <div>
              <ul className={style.projetoLista}>
                {projetos.map((projeto) => (
                  <li key={projeto.id} className={style.projetoItem}>
                    <div className={style.projetos}>
                      <div className={style.imagem}>
                        <img src="/logo.png" alt="Imagem Projeto" />
                      </div>
                      <div className={style.informacoes}>
                        <h3>{projeto.nome}</h3>
                        <p>
                          <strong>Descricao:</strong> {projeto.descricao}
                        </p>
                        <div className={style.infoUsuario}>
                          <p>Email: {projeto.email}</p>
                          <p>Telefone: {projeto.telefone}</p>
                        </div>
                        <p>
                          <strong>Categoria:</strong>
                          {projeto.tipo}
                        </p>
                        <p>
                          <strong>Local:</strong> {projeto.local}
                        </p>

                        <div className={style.acoes}>
                          <button className={style.btnRecusar} onClick={() => {reprovarProjeto(projeto.id)}}>X</button>
                          <button className={style.btnAprovar} onClick={() => {aceitarProjeto(projeto.id)}}>✓</button>
                        </div>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          ) : (
            <p className={style.notFound}>
              Acesso não autorizado ou página não encontrada.
            </p>
          )}
        </div>
      </AuthProvider>
    </>
  );
}
// confirme se é vc mesmo
export default ListarProjetos;
