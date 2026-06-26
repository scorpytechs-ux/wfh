import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import Review from './components/Review';
import './index.css';

function App() {
  return (
    <BrowserRouter>
      <div className="app-container">
        <header className="app-header">
          <div className="header-content">
            <div className="logo-box">
              <span>A</span>
            </div>
            <h1 className="header-title">Admin Portal</h1>
          </div>
        </header>

        <main className="main-content">
          <Routes>
            <Route path="/" element={<Navigate to="/login" replace />} />
            <Route path="/login" element={<Login />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/review/:id" element={<Review />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}

export default App;
