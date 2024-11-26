import { db } from "../SDK_FIREBASE";
import {
  doc,
  setDoc,
  Timestamp,
  collection,
  getDocs,
  deleteDoc,
} from "firebase/firestore";

// Função para converter Date para string "dd/MM/yyyy"
function dataParaString(data) {
  const dia = String(data.getDate()).padStart(2, "0");
  const mes = String(data.getMonth() + 1).padStart(2, "0"); // Mês é zero-indexado
  const ano = data.getFullYear();
  return `${dia}/${mes}/${ano}`;
}

// Função para converter string "dd/MM/yyyy" para Date
function stringParaData(dataString) {
  const [dia, mes, ano] = dataString.split("/").map(Number);
  return new Date(ano, mes - 1, dia); // Mês é zero-indexado (0 = Janeiro)
}

// Função para cadastrar recompensa
async function cadastroRecompensa(titulo, descricao, inicio, termino) {
  try {
    // Converte a data recebida para Date
    const dataInicio = stringParaData(inicio);
    const dataExpiracao = stringParaData(termino);

    // Verificar se as datas fornecidas são válidas
    if (isNaN(dataInicio.getTime()) || isNaN(dataExpiracao.getTime())) {
      throw new Error("Data de início ou data de expiração inválida.");
    }

    // Converte as datas para strings no formato "dd/MM/yyyy"
    const dataInicioFormatada = dataParaString(dataInicio);
    const dataExpiracaoFormatada = dataParaString(dataExpiracao);

    // Salva a recompensa no Firestore com datas no formato string e Timestamp
    await setDoc(doc(db, "Recompensas", titulo), {
      titulo: titulo,
      descricao: descricao,
      valor: 0,
      dataInicio: {
        timestamp: Timestamp.fromDate(dataInicio),
        formatada: dataInicioFormatada,
      },
      dataExpiracao: {
        timestamp: Timestamp.fromDate(dataExpiracao),
        formatada: dataExpiracaoFormatada,
      },
      verificado: false,
    });

    console.log(`Recompensa criada com sucesso: ${titulo}`);
    return { titulo, descricao, dataInicioFormatada, dataExpiracaoFormatada };
  } catch (err) {
    console.error("Erro ao criar recompensa: ", err);
    throw err;
  }
}

// Função para verificar recompensas expiradas
async function verificarRecompensasExpiradas() {
  try {
    const colecaoRecompensas = collection(db, "Recompensas");
    const snapshot = await getDocs(colecaoRecompensas);

    snapshot.forEach(async (documento) => {
      const dados = documento.data();

      if (
        dados.dataExpiracao &&
        dados.dataExpiracao.timestamp.toDate() < new Date()
      ) {
        await deleteDoc(documento.ref);
        console.log(`Recompensa ${documento.id} deletada por expiração.`);
      }
    });
  } catch (err) {
    console.error("Erro ao verificar recompensas expiradas: ", err);
    throw err;
  }
}

export { cadastroRecompensa, verificarRecompensasExpiradas };
