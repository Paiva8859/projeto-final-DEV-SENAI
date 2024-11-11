import Header from "./header";
import style from "@/app/view/style/home.module.css"

function HomeEmpresa(){
  return (
    <>
      <Header />
      <section className={style.apresentacao}>
        <article>
          <div className="introducao">
            <h1>
              De ajuda em ajuda o mundo se torna{" "}
              <p className="destaque">melhor.</p>{" "}
            </h1>
            <p className="objetivo">
              Nosso objetivo é criar uma rede de voluntários engajados,
              oferecendo oportunidades diversas para quem quer contribuir com
              seu tempo e habilidades em benefício de quem mais precisa.
            </p>
          </div>

          <img src="../imagem-principal.png" alt="Imagem família" />
        </article>
      </section>
    </>
  );
}

export default HomeEmpresa;