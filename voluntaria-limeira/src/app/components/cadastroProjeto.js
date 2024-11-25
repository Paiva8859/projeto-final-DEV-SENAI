import React, { useState } from "react";
import style from "@/app/style/cadastroProjeto.module.css";
import cadastroProjeto from "../service/cadastroProjeto"; // Importa a função para cadastrar o projeto

function CadastroProjeto() {
  // Estados para armazenar os valores dos inputs
  const [titulo, setTitulo] = useState("");
  const [descricao, setDescricao] = useState("");
  const [tipo, setTipo] = useState("");
  const [local, setLocal] = useState("");

  // Função para lidar com o clique no botão "Criar"
  const handleCriarProjeto = async () => {
    try {
      // Chama a função de cadastro com os valores dos estados
      await cadastroProjeto(titulo, descricao, tipo, local);
      alert("Projeto criado com sucesso!");

      // Limpa os campos após a criação do projeto
      setTitulo("");
      setDescricao("");
      setTipo("");
      setLocal("");
    } catch (err) {
      console.error("Erro ao criar projeto:", err);
      alert("Erro ao criar projeto, tente novamente.");
    }
  };

  return (
    <div className={style.criarProjeto}>
      <div className={style.adicionarImagem}></div>
      <form
        className={style.formularioProjeto}
        onSubmit={(e) => e.preventDefault()} // Evita o comportamento padrão do formulário
      >
        <input
          className={style.inputFormulario}
          placeholder="Titulo"
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
        />
        <input
          className={style.inputFormulario}
          placeholder="Descricao"
          value={descricao}
          onChange={(e) => setDescricao(e.target.value)}
        />
        <input
          className={style.inputFormulario}
          placeholder="Tipo"
          value={tipo}
          onChange={(e) => setTipo(e.target.value)}
        />
        <input
          className={style.inputFormulario}
          placeholder="Local"
          value={local}
          onChange={(e) => setLocal(e.target.value)}
        />
        <button
          className={style.btnCriarProjeto}
          type="button"
          onClick={handleCriarProjeto}
        >
          Criar
        </button>
      </form>
    </div>
  );
}

export default CadastroProjeto;
