import { db } from "../SDK_FIREBASE";
import {
  doc,
  setDoc,
  Timestamp,
  deleteDoc,
  collection,
  getDocs,
} from "firebase/firestore";

// Função para converter string "dd/MM/yyyy" para Date
function stringParaData(dataString) {
  const [dia, mes, ano] = dataString.split("/").map(Number);
  return new Date(ano, mes - 1, dia); // Mês é zero-indexado (0 = Janeiro)
}

// Função para converter Date para string "dd/MM/yyyy"
function dataParaString(data) {
  const dia = String(data.getDate()).padStart(2, "0");
  const mes = String(data.getMonth() + 1).padStart(2, "0"); // Mês é zero-indexado
  const ano = data.getFullYear();
  return `${dia}/${mes}/${ano}`;
}

// Função para cadastrar recompensa
async function cadastroRecompensa(titulo, descricao, inicio, termino) {
  try {
    // Converte as strings de data para objetos Date
    const dataInicio = stringParaData(inicio);
    const dataExpiracao = stringParaData(termino);

    // Verificar se as datas fornecidas são válidas
    if (isNaN(dataInicio.getTime()) || isNaN(dataExpiracao.getTime())) {
      throw new Error("Data de início ou data de expiração inválida.");
    }

    await setDoc(doc(db, "Recompensas", titulo), {
      titulo: titulo,
      descricao: descricao,
      valor: 0.0,
      dataInicio: Timestamp.fromDate(dataInicio),
      dataExpiracao: Timestamp.fromDate(dataExpiracao),
      verificado: false,
    });

    console.log(`Recompensa criada com sucesso: ${titulo}`);
    return { titulo, descricao, dataInicio, dataExpiracao };
  } catch (err) {
    console.error("Erro ao criar recompensa: ", err);
    throw err;
  }
}

// Função para verificar recompensas expiradas
async function verificarRecompensasExpiradas(documento) {
  try {
    // Verificar se o documento é válido
    if (!documento || typeof documento.data !== "function") {
      throw new Error("Documento inválido ou não encontrado.");
    }

    const dados = documento.data();

    if (dados.dataExpiracao) {
      // Verifique se dataExpiracao é um Timestamp do Firestore
      const dataExpiracao =
        typeof dados.dataExpiracao.toDate === "function"
          ? dados.dataExpiracao.toDate()
          : new Date(dados.dataExpiracao);

      // Verifique se a data de expiração já passou
      if (dataExpiracao < new Date()) {
        await deleteDoc(documento.ref);
        console.log(`Recompensa ${documento.id} deletada por expiração.`);
      }
    } else {
      console.log("Nenhuma data de expiração encontrada.");
    }
  } catch (error) {
    console.error(`Erro ao verificar a data de expiração: ${error}`);
  }
}

// Função para verificar todas as recompensas e apagar as expiradas
async function verificarTodasRecompensas() {
  try {
    const colecaoRecompensas = collection(db, "Recompensas");
    const snapshot = await getDocs(colecaoRecompensas);

    // Iterar por cada documento na coleção
    snapshot.forEach((documento) => {
      // Passe cada documento para a função de verificação
      verificarRecompensasExpiradas(documento);
    });
  } catch (error) {
    console.error("Erro ao buscar recompensas:", error);
  }
}

export {
  cadastroRecompensa,
  verificarRecompensasExpiradas,
  verificarTodasRecompensas,
};
