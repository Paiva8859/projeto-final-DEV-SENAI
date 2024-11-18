import style from "@/app/view/style/cadastroEmpresa.module.css";
import Header from "../components/header";
import Footer from "../components/footer";
function EmpresaCadastro() {
  return (
    <>
    <Header/>
      <div className={style.container}>
        <div className={style.containerFormulario}>
          <form className={style.formulario}>
            <div className={style.inputCadastro}>
              <h3>Torne-se um Parceiro</h3>
              <input type="text" placeholder="Nome" />
              <input type="email" placeholder="E-mail" />
              <input type="text" placeholder="CNPJ" />
              <input type="text" placeholder="Senha" />
            </div>
            <button className={style.btnCadastro}>Cadastrar</button>
          </form>
          <div className={style.login}>
            <p>Já criou sua conta?</p>
            <p>Então faça seu login</p>

            <button className={style.btnLogin}>Entrar</button>
          </div>
        </div>
      </div>
      <Footer/>
    </>
  );
}

export default EmpresaCadastro;
