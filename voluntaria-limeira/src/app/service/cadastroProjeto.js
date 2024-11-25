import { db } from "../SDK_FIREBASE";
import { doc, setDoc } from "firebase/firestore";

async function cadastroProjeto(titulo, descricao, tipo, local) {
  try {
    // Criação de um ID único para o projeto (pode ser baseado em qualquer critério que desejar)
    const projetoId = new Date().getTime().toString(); // Exemplo de ID único baseado no timestamp

    // Criação do documento do projeto sem voluntários inicialmente
    await setDoc(doc(db, "Projetos", projetoId), {
      titulo: titulo,
      descricao: descricao,
      tipo: tipo,
      local: local,
      voluntarios: [], // Inicialmente, sem voluntários
      verificado: false, // Por padrão, o projeto não é verificado
    });

    console.log(`Projeto criado com sucesso: ${titulo}`);

    return { projetoId, titulo, descricao, tipo, local };
  } catch (err) {
    console.error("Erro ao criar projeto: ", err);
    throw err;
  }
}

export default cadastroProjeto;
