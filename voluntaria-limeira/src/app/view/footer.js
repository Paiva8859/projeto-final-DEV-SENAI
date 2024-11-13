import style from "@/app/view/style/footer.module.css";

function Footer() {
   <footer className={style.footer}>
     <div className={style.containerFooter}>
       <div className={style.informacoesFooter}>
         <div className={style.pesquise}>
           <h1>
             Voluntaria <span className={style.spp}>Limeira</span>
           </h1>
           <input type="text" placeholder="Pesquise" />
         </div>

         <div className={style.contato}>
           <h5>Contate-nos</h5>
           <p>Email: voluntarialimeira@gmail.com</p>
           <p>Telefone: (19) 99999-9999</p>
         </div>
       </div>
     </div>
   </footer>; 
}

export default Footer;