import Header from "./components/header";
import Footer from "./components/footer";
import HomeEmpresa from "./home-empresa/page";
import  useAuth, { AuthProvider }  from "./service/authContext";

export default function Home() {

  console.log("Função",AuthProvider);
  return (
    <AuthProvider >
      <Header />
      <HomeEmpresa />
      <Footer />
    </AuthProvider>
  );
}
// cadastro de usuario redirwecionar
