"use client";
import { useState } from "react";
import style from "@/app/style/recompensa.module.css";
import { cadastroRecompensa } from "../service/cadastroRecompensa";
import { useRouter } from "next/navigation";

function Recompensa() {
  const [titulo, setTitulo] = useState("");
  const [descricao, setDescricao] = useState("");
  const [inicio, setInicio] = useState("");
  const [termino, setTermino] = useState("");
  const [quantidade, setQuantidade] = useState("");
  const [mensagem, setMensagem] = useState("");
  const router = useRouter()
  const criarNova = async (e) => {
    e.preventDefault();

    try {
      // await verificarRecompensasExpiradas(); // Verifica recompensas expiradas antes de cadastrar
      await cadastroRecompensa(titulo, descricao, inicio, termino, quantidade); // Cadastra nova recompensa
      setMensagem("Recompensa cadastrada com sucesso!");
    } catch (err) {
      router.push("/empresa-login")
      console.error("Erro ao criar recompensa: ", err);
      setMensagem("Erro ao cadastrar recompensa.");
    }
  };


  // Função para alternar a visibilidade do formulário usando display
  const alternarFormulario = () => {
    const formulario = document.getElementById("formRecompensa");
    const botao = document.getElementById("botaoAlternar");

    // Observa o estado/estilo atual da div
    const estiloForm = window.getComputedStyle(formulario);

    // Verifica o estado atual de visibilidade do formulário e alterna
    if (estiloForm.display === "none") {
      formulario.style.display = "flex";
      botao.textContent = "x";
    } else {
      formulario.style.display = "none";
      botao.textContent = "+";
    }
  };


  return (
    <>
      <div className={style.sectionRecompensa}>
        <h2>Cadastre uma Recompensa</h2>
        <form id="formRecompensa" className={style.form}>
          <div>
            <label htmlFor="tituloRecompensa">Título da Recompensa</label>
            <input
              type="text"
              id="tituloRecompensa"
              value={titulo}
              onChange={(e) => setTitulo(e.target.value)}
              required
            />
          </div>

          <div>
            <label htmlFor="descricaoRecompensa">Descrição da Recompensa</label>
            <textarea
              id="descricaoRecompensa"
              value={descricao}
              onChange={(e) => setDescricao(e.target.value)}
              required
            />
          </div>

          <div>
            <label htmlFor="dataInicio">Data Início</label>
            <input
              type="date"
              placeholder="Início"
              value={inicio}
              onChange={(e) => { setInicio(e.target.value, 0) }}
            // requires
            />
          </div>
          <div>
            <label htmlFor="dataFinal">Data Final</label>
            <input
              type="date"
              placeholder="Final"
              value={termino}
              onChange={(e) => { setTermino(e.target.value, 0) }}
            // required
            />
          </div>
          <div>
            <label htmlFor="quantidade">Quantidade</label>
            <input
              type="number"
              placeholder="Quantidade"
              value={quantidade}
              onChange={(e) => { setQuantidade(e.target.value, 0) }}
            // required
            />
          </div>

          {mensagem && <p className={style.mensagem}>{mensagem}</p>}

          <button className={style.btnCadastroRecompensa} onClick={criarNova}>Cadastrar</button>
        </form>
      </div>

      {/* Botão com id para alternar o formulário */}
      <button id="botaoAlternar" className={style.buttonCadastrarRecompensa} onClick={alternarFormulario}>
        +
      </button>
    </>
  );
}

export default Recompensa;
