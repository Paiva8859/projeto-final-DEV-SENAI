import { auth } from "../SDK_FIREBASE"; // Firebase Auth importado do SDK
import {signInWithEmailAndPassword} from "firebase/auth";
import { doc, getDoc } from "firebase/firestore"; // Para trabalhar com Firestore
import { db } from "../SDK_FIREBASE"; // Referência ao Firestore


// Função para criar um novo usuário
async function loginUsuario(email, senha) {
  try {
    // Verificar se o email está na coleção de administradores antes de criar o usuário
    const isAdmin = await verificarEmailAdmin(email);

    if (isAdmin) {
      throw new Error("O email fornecido está registrado como administrador. Não é possível criar usuário.");
    }else{

    // Criação do usuário autenticado no Firebase Authentication
    const usuarioDados = await signInWithEmailAndPassword(auth, email, senha);

    if (usuarioDados != null) {
    

      console.log(`Usuário criado com sucesso: ${email}`);
      return usuarioDados.user;
    }
  }
  } catch (err) {
    console.error("Erro ao criar usuário: ", err);

    // Resetar dados de autenticação se houver um erro
    signOut(auth).catch(signOutError => {
      console.error("Erro ao realizar logout:", signOutError);
    });

    throw err;
  }
}

// Função para verificar se o email pertence a um administrador no Firestore
async function verificarEmailAdmin(email) {
  const docRef = doc(db, "Administradores", email); // Buscando pelo email do usuário autenticado
  const docSnap = await getDoc(docRef); // Obtém os dados do documento

  if (docSnap.exists()) {
    console.log("Dados encontrados:", docSnap.data());
    return true; // Email encontrado no Firestore como administrador
  } else {
    console.error("Nenhum dado foi encontrado.");
    return false; // Não encontrado como administrador
  }
}

export default loginUsuario;
