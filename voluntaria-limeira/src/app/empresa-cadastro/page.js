// EmpresaCadastro.js

"use client";

import style from "@/app/style/cadastroEmpresa.module.css";
import Header from "../components/header";
import Footer from "../components/footer";
import { useState } from "react";
import criarUsuario from "../service/criarUsuarioEmpresa";

// Expressão Regular para validar o formato do CNPJ
const cnpjRegex = /^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$/;
const senhaRegex = /^.{8,}$/;

function EmpresaCadastro() {
  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [cnpj, setCnpj] = useState("");
  const [senha, setSenha] = useState("");
  const [mensagem, setMensagem] = useState("");
  const [erroMensagem, setErroMensagem] = useState("");

  const enviarDados = async (e) => {
    e.preventDefault();

    // Verifica se o CNPJ está no formato correto
    if (!cnpjRegex.test(cnpj)) {
      setErroMensagem("CNPJ inválido. Ex: xx.xxx.xxx/xxxx-xx");
      return;
    }

    if (!senhaRegex.test(senha)) {
      setErroMensagem("Senha inválida, minimo 8 caracteres")
    }

    try {
      // Chamada da função criarUsuario para cadastrar e armazenar dados no Firestore
      await criarUsuario(nome, email, cnpj, senha);
      setMensagem(`Usuário criado com sucesso: ${email}`);
      setErroCnpj(""); // Limpa o erro do CNPJ caso a criação seja bem-sucedida
      setNome("");
      setEmail("");
      setCnpj("");
      setSenha("");
    } catch (err) {
      setErroMensagem("");
    }
  };

  return (
    <>
      <Header />
      <div className={style.container}>
        <div className={style.containerFormulario}>
          <div className={style.login}>
            <p>Já criou sua conta?</p>
            <button className={style.btnLogin}>Entrar</button>
            <p style={{ fontSize: '10px', textAlign: 'center' }} className={style.mensagem} >{mensagem}</p>
          </div>
          <form className={style.formulario} onSubmit={enviarDados}>
            <div className={style.inputCadastro}>
              <h3>Torne-se um Parceiro</h3>
              {erroMensagem && <p style={{ color: "red", fontSize: "8px" }}>{erroMensagem}</p>}{" "}
              <input
                type="text"
                value={nome}
                onChange={(e) => setNome(e.target.value)}
                required
                placeholder="Nome"
              />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="E-mail"
              />
              <input
                type="text"
                value={cnpj}
                onChange={(e) => {
                  setCnpj(e.target.value);
                  setErroMensagem(erroMensagem); // Limpa o erro de CNPJ ao digitar novamente
                }}
                required
                placeholder="CNPJ"
              />
              {/* Exibe a mensagem de erro do CNPJ */}
              <input
                type="password"
                value={senha}
                onChange={(e) => {
                  setSenha(e.target.value)
                  setErroMensagem(erroMensagem);
                }
                }
                required
                placeholder="Senha"
              />
            </div>
            <button className={style.btnCadastro} type="submit">
              Cadastrar
            </button>
          </form>
        </div>
      </div>
      <Footer />
    </>
  );
}

export default EmpresaCadastro;