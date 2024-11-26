import { db } from "../SDK_FIREBASE";
import { doc, setDoc, Timestamp } from "firebase/firestore";
// import {cadastroRecompensa} from "@/app/service/cadastroRecompensa";

async function cadastroRecompensa(titulo, descricao, dataInicio, dataFinal) {
  try {
    const projetoId = titulo;

    // Convertendo as datas para Timestamp do Firebase
    const dataInicioTimestamp = Timestamp.fromDate(new Date(dataInicio));
    const dataFinalTimestamp = Timestamp.fromDate(new Date(dataFinal));

    // Criação do documento no Firestore com a data de início e data final
    await setDoc(doc(db, "Recompensas", projetoId), {
      titulo: titulo,
      descricao: descricao,
      dataInicio: dataInicioTimestamp,
      dataFinal: dataFinalTimestamp,
      verificado: false, // Por padrão, o projeto não é verificado
    });

    console.log(`Recompensa criada com sucesso: ${titulo}`);

    return { projetoId, titulo, descricao };
  } catch (err) {
    console.error("Erro ao criar recompensa: ", err);
    throw err;
  }
}

export default cadastroRecompensa;
