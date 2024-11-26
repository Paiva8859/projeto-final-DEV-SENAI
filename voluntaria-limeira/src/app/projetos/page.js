"use client";

import Footer from "../components/footer";
import Header from "../components/header";
import style from "@/app/style/projetos.module.css";
import { useAuth } from "../service/authContext";
import ListarProjetos from "../components/listarProjetos";

function Projetos() {
  const { tipoUsuario } = useAuth() || {};
console.log("Tipo de usuário atual:", tipoUsuario);
  return (
    <>
      <Header />
      <div className={style.container}>
      <ListarProjetos/>
        <hr />
      </div>
      <Footer />
    </>
  );
}

export default Projetos;
