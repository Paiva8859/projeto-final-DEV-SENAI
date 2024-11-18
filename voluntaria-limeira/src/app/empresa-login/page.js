import style from "@/app/view/style/loginEmpresa.module.css";
import Header from "../components/header";
import Footer from "../components/footer";
function EmpresaLogin() {
  return (
    <>
      <Header />
      <div className={style.container}>
        <div className={style.containerFormulario}>
          <form className={style.formulario}>
            <div className={style.inputLogin}>
              <h3>Torne-se um Parceiro</h3>
              <input type="email" placeholder="E-mail" />
              <input type="text" placeholder="Senha" />

            </div>
            <button className={style.btnLogin}>Entrar</button>
          </form>
          <div className={style.cadastro}>
            <p>Quer se tornar um parceiro?</p>

            <button className={style.btnLogin}>Registrar</button>
          </div>
        </div>
      </div>
      <Footer />
    </>
  );
}

export default EmpresaLogin;
