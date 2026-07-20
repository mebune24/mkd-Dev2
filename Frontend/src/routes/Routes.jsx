import { createBrowserRouter } from "react-router-dom";
import App from "../App";
import Journey from "../components/Journey/Journey";
import ProtectedRoute from "../components/ProtectedRoute";
import About from "../pages/About/About";
import Home from "../pages/Home";
import AdminLogin from "../pages/admin/AdminLogin";
import Dashboard from "../pages/admin/Dashboard";
import Blogging from "../pages/blogPage/Blogging";
import CertificationPage from "../pages/certifications/Certificate";
import Works from "../pages/works/Works";
import GitHub from "../pages/github/GitHub";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      {
        path: "/",
        element: <Home />,
      },
      {
        path: "/about",
        element: <About />,
      },
      {
        path: "/journey",
        element: <Journey />,
      },
      {
        path: "/blog",
        element: <Blogging />,
      },
      {
        path: "/project",
        element: <Works />,
      },
      {
        path: "/github",
        element: <GitHub />,
      },
      {
        path: "/certifications",
        element: <CertificationPage />,
      },
      {
        path: "/admin/login",
        element: <AdminLogin />,
      },
      {
        path: "/admin",
        element: <ProtectedRoute />,
        children: [
            {
                path: "dashboard",
                element: <Dashboard />
            }
        ]
      },
      {
        path: "*",
        element: <div>Page Not Found</div>,
      },
    ],
  },
]);

export default router;
