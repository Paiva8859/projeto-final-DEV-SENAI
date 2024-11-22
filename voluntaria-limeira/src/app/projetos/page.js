import Footer from "../components/footer";
import Header from "../components/header";
import style from "@/app/view/style/projetos.module.css";

function Projetos() {
  return (
    <>
      <Header />
      <div className={style.container}>
        <div className={style.criarProjeto}>
          <div className={style.adicionarImagem}></div>
          <form className={style.formularioProjeto}>
            <input className={style.inputFormulario} placeholder="Titulo" />
            <input className={style.inputFormulario} placeholder="Descricao" />
            <input className={style.inputFormulario} placeholder="Tipo" />
            <input className={style.inputFormulario} placeholder="Local" />
            <button className={style.btnCriarProjeto} type="button">
              Criar
            </button>
          </form>
        </div>
        <hr />
        <div className={style.containerProjetos}>
          <div className={style.projetos}>
            <div className={style.imagemProjeto}>
              <img src="" alt="" />
            </div>
            <div className={style.informacoes}>
              <h4 className={style.titulo}></h4>
              <p className={style.descricao}></p>
              <div className={style.infoUsuario}>
                <p className={style.email}></p>
                <p className={style.telefone}></p>
              </div>
              <p className={style.endereco}></p>

              <div className={style.aprovacao}>
                <p className={style.categoria}></p>
                <div className={style.acoes}>
                  <button className={style.reprovar}>X</button>
                  <button className={style.aprovar}>✓</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <Footer/>
    </>
  );
}

export default Projetos;
