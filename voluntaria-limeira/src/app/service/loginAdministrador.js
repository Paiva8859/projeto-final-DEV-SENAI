import { auth } from "../SDK_FIREBASE"; // Firebase Auth importado do SDK
import { signInWithEmailAndPassword } from "firebase/auth"; // Função para autenticar
import { doc, getDoc } from "firebase/firestore"; // Para trabalhar com Firestore
import { db } from "../SDK_FIREBASE"; // Referência ao Firestore

// Função para login do administrador
async function loginAdministrador(email, senha) {
  try {
    // Realizar o login com o Firebase Authentication
    const usuarioDados = await signInWithEmailAndPassword(auth, email, senha);
    console.log("Usuário autenticado:", usuarioDados);

    // Verificar se o usuário logado é um administrador
    const usuarioLogado = usuarioDados.user;
    const emailExiste = await verificarEmail(usuarioLogado.uid); // Agora usando o UID para verificar

    if (!emailExiste) {
      throw new Error(
        "O usuário autenticado não está registrado como administrador."
      );
    }

    // Retorna o usuário autenticado
    return usuarioLogado;
  } catch (err) {
    console.error(`Houve um erro ao realizar o login: ${err.message}`);
    throw err; // Lança o erro para ser tratado onde a função for chamada
  }
}

// Função para verificar se o email pertence a um administrador no Firestore
async function verificarEmail(uid) {
  const docRef = doc(db, "Administradores", uid); // Buscando pelo UID do usuário autenticado
  const docSnap = await getDoc(docRef); // Obtém os dados do documento

  if (!docSnap.exists()) {
    console.log("Dados encontrados:", docSnap.data());
    return true; // UID encontrado no Firestore como administrador
  } else {
    console.error("Nenhum dado foi encontrado.");
    return false; // Não encontrado como administrador
  }
}

export default loginAdministrador;
