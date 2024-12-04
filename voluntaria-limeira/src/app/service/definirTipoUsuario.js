import { doc, getDoc } from "firebase/firestore";
import { db } from "../SDK_FIREBASE"; // Configuração do Firestore

export async function definirTipoUsuario(email) {
  try {
    console.log("Iniciando verificação do tipo de usuário para:", email);

    // Verifica na coleção Administradores
    const adminRef = doc(db, "Administradores", email);
    const adminDoc = await getDoc(adminRef);

    if (adminDoc.exists()) {
      console.log("Usuário encontrado na coleção Administradores.");
      return "admin"; // Tipo definido como administrador
    }

    // Verifica na coleção Empresa
    const empresaRef = doc(db, "Empresa", email);
    const empresaDoc = await getDoc(empresaRef);

    if (empresaDoc.exists()) {
      console.log("Usuário encontrado na coleção Empresa.");
      return "empresa"; // Tipo definido como empresa
    }

    // Email não encontrado em nenhuma das coleções
    console.log(
      "Email não encontrado nas coleções. Definindo como usuário padrão."
    );
    return "usuario"; // Tipo padrão
  } catch (error) {
    console.error("Erro ao definir tipo de usuário:", error);
    throw new Error("Não foi possível determinar o tipo de usuário.");
  }
}

export default definirTipoUsuario;
