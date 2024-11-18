import style from "@/app/view/style/administradorLogin.module.css";
import Header from "../components/header";
import Footer from "../components/footer";
function AdministradorLogin(){

    return(
        <>
        <Header/>
        
        <div className={style.container}>
            <div className={style.containerFormulario}>
                <form className={style.formulario}>
                    <div className={style.imagem}>
                        <img src="/loginAdm.png" alt="Imagem de tela de login do administrador"/>
                    </div>
                    <div className={style.containerFormulario}>

                    <h4 className={style.titulo}>Login</h4>
                    <input className={style.inputAdm} type="text" placeholder="CPF"/>
                    <input className={style.inputAdm} type="password" placeholder="SENHA"/>
                    <p className={style.recuperarSenha} /*onClick={recuperarSenha}*/>Esqueceu sua senha?</p>
                <button className={style.btnLogin} type="submit">Entrar</button>
                    </div>

                </form>
            </div>
        </div>

        <Footer/>
        </>
    );
}

export default AdministradorLogin;