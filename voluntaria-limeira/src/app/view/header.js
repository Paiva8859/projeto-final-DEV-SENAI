import style from "@/app/view/style/header.module.css";

function Header() {
  return (
    <header className={style.header}>
      <nav className={style.nav}>
        <div className={style.linksNavegacao}>
          <a href="/">Início</a>
          <a href="/incentivos">Incentivos</a>
          <a href="/projetos">Projetos</a>
        </div>
        <div className={style.autenticacao}>
          
            <a className={style.btnLogin} href="/login">
              Entrar
            </a>
          
            <a className={style.btnCadastro} href="/cadastro">Registrar</a>
        </div>
      </nav>
    </header>
  );
}

export default Header;
