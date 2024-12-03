import style from "@/app/style/opcoes.module.css";

function Mobile() {
  return (
    <div className={style.opcoes}>
      <div className={style.publico}>
        <div className={style.apresentacao}>
          <img
            src="/app.png"
            className={style.imagem}
            alt="Voluntaria Limeira App"
          />
          <div className={style.informacoes}>
            <h1 className={style.titulo}>Baixe o Aplicativo !</h1>
            <p className={style.explicacao}>
              O Aplicativo <span className={style.app}>Voluntaria Limeira</span>
              , te dará uma experiência intuitiva e simples para ajudar o
              próximo, possibilitando o ganho de recompendsas.
              <br></br>
              <br></br>
              <small>Em um mundo cada vez mais conectado, os usuários têm a oportunidade
            de impactar positivamente a sociedade por meio de ações voluntárias
            e apoio a causas sociais.</small>
            </p>
          </div>
        </div>
      </div>
      <div className={style.empresas}></div>
    </div>
  );
}
function Web() {
  return (
    <div className={style.opcoes}>
      <div className={style.publico}>
        <div className={style.apresentacao}>
          <div className={style.informacoes}>
            <h1 className={style.titulo}>Seja Nosso Parceiro !</h1>
            <p className={style.explicacao}>
              No mundo atual, <span className={style.app}>as empresas têm um papel fundamental na transformação
                social.</span>
                <small>
                  <br></br>
                  <br></br>
              Ao apoiar iniciativas voluntárias, sua empresa não só
              contribui para causas relevantes, mas também fortalece seu compromisso
              com a responsabilidade social corporativa (RSC), engaja seus
              colaboradores e melhora sua imagem perante consumidores e parceiros.
              </small>
            </p>
          </div>
          <img
            src="/web.png"
            className={style.imagem}
            alt="Voluntaria Limeira App"
          />
        </div>
      </div>
      <div className={style.empresas}></div>
    </div>
  );
}

export { Mobile, Web };
