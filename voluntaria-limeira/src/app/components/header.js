"use client";
import Link from "next/link";
import style from "@/app/view/style/header.module.css";
import { useRouter } from "next/navigation";

function Header() {
  const router = useRouter();

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
    }else if (value === "usuario"){
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
      </nav>
    </header>
  );
}

export default Header;
