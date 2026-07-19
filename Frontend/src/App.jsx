import { Outlet } from "react-router-dom";
import Footer from "./layouts/Footer";
import Nav from "./layouts/Nav";
import "./styles/App.css";

function App() {
  return (
    <div className="App">
      <Nav />
      <Outlet />
      <Footer />
    </div>
  );
}

export default App;
