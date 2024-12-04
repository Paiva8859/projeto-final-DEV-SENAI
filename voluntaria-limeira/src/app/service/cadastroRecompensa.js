import { db } from "../SDK_FIREBASE";

import {
  doc,
  setDoc,
  Timestamp,
} from "firebase/firestore";


// Função para cadastro de recompensa
async function cadastroRecompensa( titulo, descricao, inicio, termino, quantidade, preco = 0, verificado = false) {

  try {
    const dataInicio = new Date(inicio);
    const dataExpiracao = new Date(termino);


    // console.log("Dados a serem cadastrados:", { titulo, descricao, dataInicio, dataExpiracao, quantidade });

    // Somando 1 dia (24 horas) à data
    dataInicio.setTime(dataInicio.getTime() + 24 * 60 * 60 * 1000);
    dataExpiracao.setTime(dataExpiracao.getTime() + 24 * 60 * 60 * 1000);

    // Gerar um ID único para cada recompensa. Aqui usamos o título + timestamp para evitar sobreposição de dados.
    const recompensaId = `${titulo}-${new Date().getTime()}`;

    // Salvar a recompensa no Firestore com um ID único baseado no título e timestamp
    await setDoc(doc(db, "Recompensa", recompensaId), {

      titulo: titulo,
      descricao: descricao,
      dataInicio: Timestamp.fromDate(dataInicio),
      dataExpiracao: Timestamp.fromDate(dataExpiracao),
      quantidade: Number(quantidade),
      preco: Number(preco),
      verificado: verificado,
    });

    console.log(`Recompensa criada com sucesso: ${titulo}`);
    return { titulo, descricao, dataInicio, dataExpiracao, quantidade, preco, verificado };


  } catch (err) {
    console.error("Erro ao criar recompensa: ", err);
    throw err;
  }
}

export { cadastroRecompensa };

