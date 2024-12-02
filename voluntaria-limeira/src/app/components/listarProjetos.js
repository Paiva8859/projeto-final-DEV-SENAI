import { db } from "../SDK_FIREBASE"; // Importa sua configuração do Firebase
import { collection, getDocs } from "firebase/firestore"; // Importa métodos do Firestore
import React, { useEffect, useState } from "react";

function ListarProjetos() {
  const [projetos, setProjetos] = useState([]); // Estado para armazenar projetos
  const [carregando, setCarregando] = useState(true); // Estado para controle de carregamento

  useEffect(() => {
    // Função para buscar os projetos no Firestore
    const fetchProjetos = async () => {
      try {
        // Referência para a coleção "Projetos"
        const projetosRef = collection(db, "Projetos");

        // Consulta para obter todos os documentos da coleção "Projetos"
        const querySnapshot = await getDocs(projetosRef);

        // Mapeia os dados e coloca no estado
        const listaProjetos = querySnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));

        setProjetos(listaProjetos);
        setCarregando(false);
      } catch (error) {
        console.error("Erro ao buscar projetos: ", error);
        setCarregando(false);
      }
    };

    fetchProjetos();
  }, []);

  // Renderiza uma mensagem de carregamento enquanto busca os projetos
  if (carregando) {
    return <div>Carregando projetos...</div>;
  }

  // Renderiza a lista de projetos
  return (
    <div>
      <h2>Lista de Projetos</h2>
      <ul>
        {projetos.map((projeto) => (
          <li key={projeto.id}>
            <h3>{projeto.titulo}</h3>
            <p>{projeto.descricao}</p>
            <p>
              <strong>Tipo:</strong> {projeto.tipo}
            </p>
            <p>
              <strong>Local:</strong> {projeto.local}
            </p>
            <p>
              <strong>Verificado:</strong> {projeto.verificado ? "Sim" : "Não"}
            </p>
            {projeto.Voluntarios && (
              <div>
                <strong>Voluntários:</strong>
                <ul>
                  {projeto.Voluntarios.map((voluntario, index) => (
                    <li key={index}>{voluntario}</li>
                  ))}
                </ul>
              </div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default ListarProjetos;
