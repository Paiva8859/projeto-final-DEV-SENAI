"use client";
import style from "@/app/view/style/header.module.css";
import { useRouter } from "next/navigation";

function Header() {
const router = useRouter();

  const mudarPagina = (event)=>{
    const value = event.target.value;
if (value === "entrar") {
router.push("/");
}else if(value === "empresa"){
  router.push("/empresa-login");
}else if(value === "administrador"){
  router.push("administrador-login")
}
  };
  return (
    <header className={style.header}>
      <nav className={style.nav}>
        <div className={style.linksNavegacao}>
          <a href="/">Início</a>
          <a href="/incentivos">Incentivos</a>
          <a href="/projetos">Projetos</a>
        </div>

        <div className={style.autenticacao}>
          
            <select className={style.btnLogin} onChange={mudarPagina}>
              <option value="entrar">Entrar</option>
              <option value="empresa">Empresa</option>
              <option value="administrador">Administrador</option>
            </select>
          
            <a className={style.btnCadastro} href="/cadastro">Registrar</a>
        </div>
      </nav>
    </header>
  );
}

export default Header;
