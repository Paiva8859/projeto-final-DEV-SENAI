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


      setTitulo("");
      setDescricao("");
      setInicio("");
      setTermino("");
      setQuantidade("");
      // setMensagem("");

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
        <form id="formRecompensa" className={style.form}>
          <h2 style={{ margin: 0 }}>Cadastre Recompensa</h2>

          {mensagem && <p style={{ color: "#302f2f" }} className={style.mensagem}>{mensagem}</p>}
          <div className={style.infoForm}>
            <div className={style.containerInput}>
              <label style={{ color: '#797979', outline: '0', fontSize: '10px' }} htmlFor="titulo">Título</label>
              <input
                style={{ color: '#797979', outline: '0' }}
                type="text"
                id="tituloRecompensa"
                // placeholder="Título Recompensa"

                value={titulo}
                onChange={(e) => setTitulo(e.target.value)}
                required
              />
            </div>

            <div className={style.containerInput}>

              <label style={{ color: '#797979', outline: '0', fontSize: '10px' }} htmlFor="descricao">Descrição</label>
              <textarea
                style={{ border: '0', backgroundColor: '#f0f0f0', color: '#797979', outline: '0', fontFamily: 'Gill Sans MT' }}
                id="descricaoRecompensa"
                // placeholder="Descrição Recompensa"

                value={descricao}
                onChange={(e) => setDescricao(e.target.value)}
                required
              />
            </div>

            <div className={style.containerInput}>

              <label style={{ color: '#797979', outline: '0', fontSize: '10px' }} htmlFor="dataInicio">Início</label>
              <input
                style={{ color: '#797979', outline: '0' }}
                type="date"
                // placeholder="Início"
                value={inicio}
                onChange={(e) => { setInicio(e.target.value) }}

              // requires
              />
            </div>
            <div className={style.containerInput}>

              <label style={{ color: '#797979', outline: '0', fontSize: '10px' }} htmlFor="dataFinal">Final</label>
              <input
                style={{ color: '#797979', outline: '0' }}
                type="date"
                // title="Final"
                value={termino}
                onChange={(e) => { setTermino(e.target.value) }}

              // required
              />
            </div>
            <div className={style.containerInput}>

              <label style={{ color: '#797979', outline: '0', fontSize: '10px' }} htmlFor="qunatidade">Quantidade</label>
              <input
                style={{ color: '#797979', outline: '0' }}
                type="number"
                // placeholder="Quantidade"
                value={quantidade}
                onChange={(e) => {
                  const value = e.target.value;
                  // Verifica se o valor é um número válido
                  const numero = value ? Number(value) : 0;  // Se não for um valor válido, define como 0
                  setQuantidade(numero);
                }}

              // required
              />
            </div>


            <div className={style.containerInput}>
              <br></br>
              <button className={style.btnCadastroRecompensa} onClick={criarNova}>Cadastrar</button>
            </div>

          </div>
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
