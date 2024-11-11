function Header() {
  return (
    <header>
      <nav>
        <div className="links-navegacao">
          <a href="/">Início</a>
          <a href="/incentivos">Incentivos</a>
          <a href="/projetos">Projetos</a>
        </div>
        <div className="autenticacao">
          <button type="button">
            <a href="">Entrar</a>
          </button>
          <button type="button">
            <a href="">Registrar</a>
          </button>
          <button></button>
        </div>
      </nav>
    </header>
  );
}
export default Header;
