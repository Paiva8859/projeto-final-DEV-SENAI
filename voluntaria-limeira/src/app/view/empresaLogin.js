function EmpresaLogin(){
return (
  <div className="container">
    <div className="containerFormulario">
      <form className="formulario">
        <h3>Torne-se um Parceiro</h3>
        <input type="text" placeholder="Nome" />
        <input type="email" placeholder="E-mail" />
        <input type="text" placeholder="CNPJ" />
        <input type="text" placeholder="Senha" />

        <button>Cadastrar</button>
      </form>
      <div className="login">
        <p>Já criou sua conta?</p>
        <p>Então faça seu login</p>

        <button>Entrar</button>
      </div>
    </div>
  </div>
);
}

export default EmpresaLogin;