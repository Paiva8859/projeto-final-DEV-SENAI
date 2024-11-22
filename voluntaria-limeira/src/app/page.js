import Header from "./components/header";
import Footer from "./components/footer";
import HomeEmpresa from "./home-empresa/page";
import { AuthProvider } from "./service/authContext";

export default function Home() {
  return (
    <AuthProvider>
      <Header />
      <HomeEmpresa />
      <Footer />
    </AuthProvider>
  );
}
// cadastro de usuario redirwecionar
