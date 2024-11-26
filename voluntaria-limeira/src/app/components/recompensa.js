"use client";
import { useState } from "react";
import style from "@/app/style/recompensa.module.css";
import cadastroRecompensa from "../service/cadastroRecompensa";

function Recompensa() {
  const [tituloRecompensa, setTitulo] = useState("");
  const [descricaoRecompensa, setDescricao] = useState("");
  // const [duracaoRecompensa, setDuracao] = useState("");
  const [dataInicio, setInicio] = useState(0);
  const [dataFinal, setFinal] = useState(0);
  const [mensagem, setMensagem] = useState(""); // Para mostrar mensagens de erro ou sucesso

  // Função para validar os campos
  const validarCampos = () => {
    if (!tituloRecompensa || !descricaoRecompensa || !dataInicio|| !dataFinal) {
      return "Todos os campos são obrigatórios.";
    }
    return ""; // Se todos os campos estão válidos
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

  const criarNova = async (e) => {
    e.preventDefault();
    cadastroRecompensa(tituloRecompensa, descricaoRecompensa, dataInicio, dataFinal);
  }

  return (
    <>
      <div>
        <form id="formRecompensa" className={style.form}>
          <div>
            <label htmlFor="tituloRecompensa">Título da Recompensa</label>
            <input
              type="text"
              id="tituloRecompensa"
              value={tituloRecompensa}
              onChange={(e) => setTitulo(e.target.value)}
              required
            />
          </div>

          <div>
            <label htmlFor="descricaoRecompensa">Descrição da Recompensa</label>
            <textarea
              id="descricaoRecompensa"
              value={descricaoRecompensa}
              onChange={(e) => setDescricao(e.target.value)}
              required
            />
          </div>

          <div>
            <label htmlFor="dataInicio">Data Início</label>
            <input
              type="date"
              placeholder="Início"
              value={dataInicio}
              onChange={(e) => { setInicio(e.target.value, 0) }}
              // requires
            />
          </div>
          <div>
            <label htmlFor="dataFinal">Data Final</label>
            <input
              type="date"
              placeholder="Final"
              value={dataFinal}
              onChange={(e) => { setFinal(e.target.value, 0) }}
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
