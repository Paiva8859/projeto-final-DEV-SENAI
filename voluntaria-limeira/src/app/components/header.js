"use client";
import Link from "next/link";
import style from "@/app/view/style/header.module.css";
import { useRouter } from "next/navigation";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "../SDK_FIREBASE";
import { useEffect, useState } from "react";
import { signOut } from "firebase/auth";
import { sair } from "../service/loginAdministrador";

function Header() {
  const router = useRouter();
  const [usuarioLogado, setUsuarioLogado] = useState(null);

   useEffect(() => {
     const unsubscribe = onAuthStateChanged(auth, (user) => {
       if (user) {
         // Se o usuário estiver logado
         console.log("Usuário logado:", user);
         setUsuarioLogado(user);
       } else {
         // Se o usuário não estiver logado
         console.log("Nenhum usuário logado");
         setUsuarioLogado(null);
       }
     });

     // Limpeza do efeito (desinscrever quando o componente for desmontado)
     return () => unsubscribe();
   }, []);

   const logout = () => {
     signOut(auth)
       .then(() => {
         console.log("Logout realizado com sucesso!");
         // Redireciona o usuário para a página de login ou página inicial
         router.push("/"); // Ajuste conforme necessário
       })
       .catch((error) => {
         console.error("Erro ao realizar logout:", error);
       });
   };

  const mudarPagina = (event) => {
    const value = event.target.value;
    if (value === "entrar") {
      router.refresh("/home-empresa");
    } else if (value === "registrar") {
      router.push("/home-empresa");
    } else if (value === "administrador-login") {
      router.push("/administrador-login");
    } else if (value === "empresa-login") {
      router.push("/empresa-login");
    } else if (value === "empresa-cadastro") {
      router.push("/empresa-cadastro");
    } else if (value === "usuario") {
      router.push("/usuario");
    }
  };

  return (
    <header className={style.header}>
      <nav className={style.nav}>
        <div className={style.linksNavegacao}>
          {/* Usando Link para navegação */}
          <Link href="/">Início</Link>
          <Link href="/incentivos">Incentivos</Link>
          <Link href="/projetos">Projetos</Link>
        </div>
        {usuarioLogado ? (
          // o que e esse fragmanto
          <>
            <p>Bem vindo {usuarioLogado.nome}</p>
            <button onClick={logout}>Sair</button>
          </>
        ) : (
          <div className={style.autenticacao}>
            {/* Select para navegação */}
            <select className={style.btnLogin} onChange={mudarPagina}>
              <option value="entrar">Entrar</option>
              <option value="empresa-login">Empresa</option>
              <option value="administrador-login">Administrador</option>
            </select>

            {/* Link para registro */}
            <select className={style.btnCadastro} onChange={mudarPagina}>
              <option value="registrar">Registrar</option>
              <option value="empresa-cadastro">Empresa</option>
              <option value="usuario">Usuário</option>
            </select>
          </div>
        )}
      </nav>
    </header>
  );
}

export default Header;
