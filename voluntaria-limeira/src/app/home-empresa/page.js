import style from "@/app/style/home.module.css";
import MobileWeb from "../components/opcoes";


function HomeEmpresa() {

    // Função para alternar a visibilidade do formulário usando display
    const alternarFormulario = () => {
      const empresaInfo = document.getElementById("explicacaoEmpresas");
      const botaoEmpresa = document.getElementById("btnEmpresaInfo");
      const usuarioInfo = document.getElementById("explicacaoUsuarios");
      const botaoUsuario = document.getElementById("btnUsuarioInfo");

      // Observa o estado/estilo atual da div 
      const empresaStyle = window.getComputedStyle(empresaInfo);  
      const usuarioStyle = window.getComputedStyle(usuarioInfo);  
      
      // Verifica o estado atual de visibilidade do formulário e alterna
      botaoEmpresa.addEventListener ("click", () => {

        empresaInfo.style.display = 'block';
        usuarioInfo.style.display = 'none';
      })
      
      botaoUsuario.addEventListener ("click", () => {

        empresaInfo.style.display = 'none';
        usuarioInfo.style.display = 'block';
      })

    };

  return (
    <>
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
        <div className={style.imagem}></div>
      </section>
      <section className={style.paraEmpresas}>
        <div className={style.infoEmpresaUsuario}>
          <button id="btnEmpresaInfo" className={style.btnEmpresa}>Para Empresas</button>
          <button id="btnUsuarioInfo" className={style.btnUsuario}>Para Usuários</button>
        </div>
        {/* <hr className={style.linha} /> */}

        <p id="explicacaoEmpresas" className={`${style.explicacaoEmpresas} ${style.explicacao}`}>
          No mundo atual, as empresas têm um papel fundamental na transformação
          social. Ao apoiar iniciativas voluntárias, sua empresa não só
          contribui para causas relevantes, mas também fortalece seu compromisso
          com a responsabilidade social corporativa (RSC), engaja seus
          colaboradores e melhora sua imagem perante consumidores e parceiros.
        </p>
        <p id="explicacaoUsuarios" className={`${style.explicacaoUsuarios} explicacao`}>
          No mundo atual, as empresas têm um papel fundamental na transformação
          social. Ao apoiar iniciativas voluntárias, sua empresa não só
          contribui para causas relevantes, mas também fortalece seu compromisso
          com a responsabilidade social corporativa (RSC), engaja seus
          colaboradores e melhora sua imagem perante consumidores e parceiros.
        </p>
        <MobileWeb />
      </section>
    </>
  );
}

export default HomeEmpresa;
