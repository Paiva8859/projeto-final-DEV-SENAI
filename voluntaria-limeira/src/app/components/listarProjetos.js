import { db } from "../SDK_FIREBASE"; // Configuração do Firebase
import {
  collection,
  getDocs,
  getDoc,
  doc,
  updateDoc,
  deleteDoc,
} from "firebase/firestore"; // Métodos do Firestore
import { getAuth, onAuthStateChanged } from "firebase/auth";
import React, { useEffect, useState } from "react";
import style from "@/app/style/listarProjetos.module.css"; // Estilo CSS

function ListarProjetos() {
  const [projetos, setProjetos] = useState([]); // Estado para armazenar os projetos
  const [carregando, setCarregando] = useState(true); // Estado para controle do carregamento
  const [mensagem, setMensagem] = useState("");
  const [tipoUsuario, setTipoUsuario] = useState("");

  useEffect(() => {
    const fetchProjetos = async () => {
      try {
        const usuariosRef = collection(db, "Usuarios"); // Referência à coleção de usuários
        const usuariosSnapshot = await getDocs(usuariosRef); // Busca todos os usuários

        let todosProjetos = []; // Lista para armazenar todos os projetos
        for (const usuarioDoc of usuariosSnapshot.docs) {
          const usuarioData = usuarioDoc.data(); // Dados do usuário
          const projetosRef = collection(
            db,
            `Usuarios/${usuarioDoc.id}/Projetos`
          ); // Referência à subcoleção `Projetos`
          const projetosSnapshot = await getDocs(projetosRef);

          todosProjetos = [
            ...todosProjetos,
            ...projetosSnapshot.docs.map((projetoDoc) => ({
              id: projetoDoc.id,
              ...projetoDoc.data(),
              usuario: { id: usuarioDoc.id, ...usuarioData }, // Adiciona dados do usuário relacionado
            })),
          ];
        }

        setProjetos(todosProjetos); // Atualiza o estado com todos os projetos
      } catch (error) {
        console.error("Erro ao buscar projetos:", error);
      } finally {
        setCarregando(false); // Finaliza o carregamento
      }
    };

    fetchProjetos();
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

  const aceitarProjeto = async (id) => {
    try {
      const projeto = projetos.find((p) => p.id === id);
      const projetoRef = doc(db, `Usuarios/${projeto.usuario.id}/Projetos`, id);
      const valor = prompt("Digite o valor que os usuários vão receber");
      if (!valor) return;

      await updateDoc(projetoRef, {
        verificado: true,
        recompensa: Number(valor),
      });

      setProjetos((prevProjetos) =>
        prevProjetos.filter((projeto) => projeto.id !== id)
      );

      alert("Projeto aprovado com sucesso!");
    } catch (error) {
      console.error("Erro ao aceitar o projeto:", error);
    }
  };

  const reprovarProjeto = async (id) => {
    try {
      const projeto = projetos.find((p) => p.id === id);
      const projetoRef = doc(db, `Usuarios/${projeto.usuario.id}/Projetos`, id);
      await deleteDoc(projetoRef);

      setProjetos((prevProjetos) =>
        prevProjetos.filter((projeto) => projeto.id !== id)
      );

      alert("Projeto recusado e excluído com sucesso!");
    } catch (error) {
      console.error("Erro ao excluir o projeto:", error);
    }
  };

  const copiarTexto = (texto) => {
    const textarea = document.createElement("textarea");
    textarea.value = texto;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand("copy");
    document.body.removeChild(textarea);
    setMensagem("Texto copiado para a área de transferência!");
  };

  if (carregando) {
    return <div>Carregando projetos...</div>;
  }

  return (
    <div className={style.container}>
      {projetos.length === 0 ? (
        <p>Nenhum projeto encontrado.</p>
      ) : (
        <ul className={style.projetoLista}>
          {projetos.map((projeto) => (
            <li key={projeto.id} className={style.projetoItem}>
              <div className={style.projetos}>
                <div className={style.imagem}>
                  <img src="/logo.png" alt="Imagem do Projeto" />
                </div>
                <div className={style.informacoes}>
                  <h3>{projeto.nome}</h3>
                  <p>
                    <strong>Descrição:</strong> {projeto.descricao}
                  </p>
                  <p>
                    <strong>Local ou Valor:</strong> {projeto.localOuValor}
                  </p>
                  <div className={style.infoUsuario}>
                    <p>
                      <strong>Usuário:</strong> {projeto.usuario.email}
                      <button
                        title={mensagem}
                        onClick={() => copiarTexto(projeto.usuario.email)}
                        className={style.btnCopiar}
                      >
                        <img src="/copiar.png" />
                      </button>
                    </p>
                    <p>
                      <strong>Telefone:</strong> {projeto.usuario.telefone}
                      <button
                        title={mensagem}
                        onClick={() => copiarTexto(projeto.usuario.email)}
                        className={style.btnCopiar}
                      >
                        <img src="/copiar.png" />
                      </button>
                    </p>
                  </div>
                  <div>
                    {projeto.vaquinha ? (
                      <p>
                        <strong>R$:</strong> {projeto.localOuValor}
                      </p>
                    ) : (
                      <p>
                        <strong>Local:</strong> {projeto.localOuValor}
                      </p>
                    )}
                  </div>
                  {tipoUsuario === "Administrador" && ( // Exibe botões apenas se o usuário for administrador
                    <div className={style.acoes}>
                      <button
                        className={style.btnRecusar}
                        onClick={() => reprovarProjeto(projeto.id)}
                      >
                        Recusar
                      </button>
                      <button
                        className={style.btnAprovar}
                        onClick={() => aceitarProjeto(projeto.id)}
                      >
                        Aceitar
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default ListarProjetos;
