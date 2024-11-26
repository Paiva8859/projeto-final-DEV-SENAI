import Header from "./components/header";
import Footer from "./components/footer";
import HomeEmpresa from "./home-empresa/page";
import Recompensa from "./components/recompensa";
import {AuthProvider} from "./service/authContext";

export default function Home() {
  console.log("Função", AuthProvider);
  return (
    <AuthProvider>
      <Header />
      <HomeEmpresa />
      <Recompensa />
      <Footer />
    </AuthProvider>
  );
}
// cadastro de usuario redirwecionar
