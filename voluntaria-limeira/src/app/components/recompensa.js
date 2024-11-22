"use client";
import { useState } from "react";
import style from "@/app/view/style/components/recompensas.module.css";

function Recompensa() {
  const [tituloRecompensa, setTitulo] = useState("");
  const [descricaoRecompensa, setDescricao] = useState("");
  const [duracaoRecompensa, setDuracao] = useState("");
  const [mensagem, setMensagem] = useState(""); // Para mostrar mensagens de erro ou sucesso

  // Função para validar os campos
  const validarCampos = () => {

    if (!tituloRecompensa || !descricaoRecompensa || !duracaoRecompensa) {
      return "Todos os campos são obrigatórios.";
    }
    if (isNaN(duracaoRecompensa) || duracaoRecompensa <= 0) {
      return "A duração deve ser um número positivo.";
    }
    return ""; // Se todos os campos estão válidos
  };

  const enviarDadosRecompensas = async (e) => {
    e.preventDefault();

    // Validação dos campos
    const erro = validarCampos();
    if (erro) {
      setMensagem(erro);
      return;
    }

    try {
      // Chamada da função criarUsuario para cadastrar e armazenar dados no Firestore
      await criarUsuario(tituloRecompensa, descricaoRecompensa, duracaoRecompensa);
      setMensagem(`Recompensa criada com sucesso: ${tituloRecompensa}`);
    } catch (err) {
      setMensagem(`Erro ao criar Recompensa: ${err.message}`);
    }
  };

  return (
    <div>
      <form onSubmit={enviarDadosRecompensas} className={style.form}>
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
          <label htmlFor="duracaoRecompensa">Duração (em dias)</label>
          <input
            type="number"
            id="duracaoRecompensa"
            value={duracaoRecompensa}
            onChange={(e) => setDuracao(e.target.value)}
            required
          />
        </div>

        {mensagem && <p className={style.mensagem}>{mensagem}</p>}

        <button type="submit">Criar Recompensa</button>
      </form>
    </div>
  );
}

export default Recompensa;
