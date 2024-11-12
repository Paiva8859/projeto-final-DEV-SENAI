import Header from "@/app/view/header";
import style from "@/app/view/style/home.module.css";

function HomeEmpresa() {
  return (
    <>
      <Header />
      <div className="container">
        <section className={style.apresentacao}>
          <article>
            <div className={style.introducao}>
              <h1 className={style.titulo}>
                <p>
                  De ajuda em ajuda o mundo se torna
                  <span className={style.destaque}>melhor.</span>
                </p>
              </h1>
              <p className={style.objetivo}>
                Nosso objetivo é criar uma rede de voluntários engajados,
                oferecendo oportunidades diversas para quem quer contribuir com
                seu tempo e habilidades em benefício de quem mais precisa.
              </p>
            </div>
          </article>
          <div className={style.imagem}>
            {/* <img src="../imagem-principal.png" alt="Imagem família" /> */}
          </div>
        </section>
        <section className={style.empresas}>
          <h1>Para empresas</h1>
          <hr className={style.linha}/>
          <p>
            No mundo atual, as empresas têm um papel fundamental na
            transformação social. Ao apoiar iniciativas voluntárias, sua empresa
            não só contribui para causas relevantes, mas também fortalece seu
            compromisso com a responsabilidade social corporativa (RSC), engaja
            seus colaboradores e melhora sua imagem perante consumidores e
            parceiros.
          </p>
        </section>
      </div>
    </>
  );
}

export default HomeEmpresa;
