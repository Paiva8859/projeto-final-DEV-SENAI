import style from "@/app/style/footer.module.css";

function Footer() {
  return (
    <footer className={style.footer}>
      <div className={style.containerFooter}>
        <div className={style.informacoesFooter}>
          <div className={style.pesquise}>
            <h1>
              Voluntaria <span className={style.app}>Limeira</span>
            </h1>
            <input className={style.searchBox} type="text" placeholder="Pesquise" />
          </div>
        </div>
        <div className={style.subContainer}>
          <div className={style.logo}>
            <div className={style.contato}>
              <h4>Contate-nos</h4>
        
              <small>Email: voluntarialimeira@gmail.com</small>
              <br></br>
              <small>Telefone: (19) 99999-9999</small>
            </div>
            <img src="/logo.png" alt="Logo Voluntaria Limeira" />
          </div>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
