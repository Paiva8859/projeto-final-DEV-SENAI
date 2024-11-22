import style from "@/app/style/cadastroProjeto.module.css";
function CadastroProjeto() {
  return (
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
  );
}

export default CadastroProjeto;
