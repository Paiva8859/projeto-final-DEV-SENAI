import { db } from "../SDK_FIREBASE";

import {
  doc,
  setDoc,
  Timestamp,
  collection,
  getDocs,
  deleteDoc,
} from "firebase/firestore";


async function cadastroRecompensa(titulo, descricao, inicio, termino) {
  try {
    // Construa as datas manualmente para evitar erros
    const [diaInicio, mesInicio, anoInicio] = inicio.split("/").map(Number);
    const [diaTermino, mesTermino, anoTermino] = termino.split("/").map(Number);

    // Cria a data no formato ano, mês (base 0), dia
    const dataInicio = new Date(anoInicio, mesInicio - 1, diaInicio);
    const dataExpiracao = new Date(anoTermino, mesTermino - 1, diaTermino);

    // Formata as datas para o formato "dd/MM/yyyy"
    const dataInicioFormatada = `${Number(diaInicio).padStart(2, "0")}/${Number(
      mesInicio
    ).padStart(2, "0")}/${anoInicio}`;
    const dataExpiracaoFormatada = `${Number(diaTermino).padStart(
      2,
      "0"
    )}/${String(mesTermino).padStart(2, "0")}/${anoTermino}`;


    // Somando 1 dia (24 horas) à data
    dataInicio.setTime(dataInicio.getTime() + 24 * 60 * 60 * 1000);
    dataExpiracao.setTime(dataExpiracao.getTime() + 24 * 60 * 60 * 1000);

    await setDoc(doc(db, "Recompensas", titulo), {
      titulo: titulo,
      descricao: descricao,
      dataInicio: Number(dataInicioFormatada),
      dataExpiracao: dataExpiracaoFormatada,
      verificado: false,
    });

    console.log(`Recompensa criada com sucesso: ${titulo}`);
    return {
      titulo,
      descricao,
      dataInicio: dataInicioFormatada,
      dataExpiracao: dataExpiracaoFormatada,
    };
  } catch (err) {
    console.error("Erro ao criar recompensa: ", err);
    throw err;
  }
}



async function verificarRecompensasExpiradas() {
  try {
    const colecaoRecompensas = collection(db, "Recompensas");
    const snapshot = await getDocs(colecaoRecompensas);

    snapshot.forEach(async (documento) => {
      const dados = documento.data();

      if (dados.dataExpiracao && dados.dataExpiracao.toDate() > new Date()) {
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

