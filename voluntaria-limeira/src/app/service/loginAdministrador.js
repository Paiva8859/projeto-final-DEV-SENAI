import { auth } from "../SDK_FIREBASE"; // Firebase Auth importado do SDK
import { signInWithEmailAndPassword, signOut } from "firebase/auth"; // Função para autenticar
import { doc, getDoc } from "firebase/firestore"; // Para trabalhar com Firestore
import { db } from "../SDK_FIREBASE"; // Referência ao Firestore

// Função para login do administrador
async function loginAdministrador(email, senha) {
  try {
    // Verificar se o email está registrado como administrador
    const emailExiste = await verificarEmail(email);

    if (!emailExiste) {
      throw new Error(
        "O email fornecido não está registrado como administrador."
      );
    }

    // Realizar o login com o Firebase Authentication
    const usuarioDados = await signInWithEmailAndPassword(auth, email, senha);
    console.log("Usuário autenticado:", usuarioDados);

    // Atualiza o estado de login (porém a função logado não é necessária aqui)
    // A autenticação já é tratada diretamente pelo Firebase Auth
    return usuarioDados.user; // Retorna o usuário autenticado
  } catch (err) {
    console.error(`Houve um erro ao realizar o login: ${err.message}`);
    throw err; // Lança o erro para ser tratado onde a função for chamada
  }
}

// Função para verificar se o email pertence a um administrador no Firestore
async function verificarEmail(email) {
  const docRef = doc(db, "Administradores", email); // Referência ao documento do administrador
  const docSnap = await getDoc(docRef); // Obtém os dados do documento

  if (docSnap.exists()) {
    console.log("Dados encontrados:", docSnap.data());
    return true; // Email encontrado no Firestore como administrador
  } else {
    console.error("Nenhum dado foi encontrado.");
    return false; // Email não encontrado como administrador
  }
}

// Função para verificar se o usuário está logado
async function logado(user) {
  if (user) {
    return true; // Se o usuário estiver logado, retorna true
  } else {
    return false; // Caso contrário, retorna false
  }
}


export { loginAdministrador, logado  };
