"use client";
import style from "@/app/style/home.module.css";
import { Mobile, Web } from "../components/opcoes";
// import Web from "../components/opcoes";
import { useState } from "react";


function HomeEmpresa() {

  // Const para alternar a visibilidade do formulário usando display
  const [activeText, setActiveText] = useState('empresa');
  const [activeButton, setActiveButton] = useState('empresa');

  // Função para gerenciar os cliques nos botões
  const handleButtonClick = (buttonType) => {
    setActiveButton(buttonType); // Atualiza o botão ativo
    setActiveText(buttonType); // Atualiza o texto a ser mostrado
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
          <button id="btnEmpresaInfo" className={`${style.btnEmpresa}, ${activeButton === 'empresa' ? style.btnActive : ''}`} onClick={() => handleButtonClick('empresa')} >Para Usuários</button>
          <button id="btnUsuarioInfo" className={`${style.btnUsuario}, ${activeButton === 'usuario' ? style.btnActive : ''}`} onClick={() => handleButtonClick('usuario')} >Para Empresas</button>
        </div>
        {/* <hr className={style.linha} /> */}
        <div className={style.containerExplicacao}>
          <div className={style.explicacao}>
            {/* <p id="explicacaoEmpresas" className={ style.explicacao} style={{ display: activeText === 'empresa' ? 'block' : 'none' }}>
            No mundo atual, as empresas têm um papel fundamental na transformação
            social. Ao apoiar iniciativas voluntárias, sua empresa não só
            contribui para causas relevantes, mas também fortalece seu compromisso
            com a responsabilidade social corporativa (RSC), engaja seus
            colaboradores e melhora sua imagem perante consumidores e parceiros.
          </p>
          <p id="explicacaoUsuarios" className={ style.explicacao} style={{ display: activeText === 'usuario' ? 'block' : 'none' }}>
            Em um mundo cada vez mais conectado, os usuários têm a oportunidade
            de impactar positivamente a sociedade por meio de ações voluntárias
            e apoio a causas sociais. Ao se engajar em projetos que promovem o
            bem-estar coletivo, eles não apenas ajudam a criar mudanças significativas,
            mas também reforçam valores essenciais como empatia, solidariedade e cooperação.
          </p> */}
            {activeText === 'empresa' ? <Mobile /> : ''}
            {activeText === 'usuario' ? <Web /> : ''}
            {/* <Mobile style={{ display: activeText === 'empresa' ? 'block' : 'none' }}/>
        <Web style={{ display: activeText === 'usuario' ? 'block' : 'none' }}/> */}
          </div>
        </div>
      </section>
    </>
  );
}

export default HomeEmpresa;
