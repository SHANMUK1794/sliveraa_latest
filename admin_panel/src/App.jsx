import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Overview from './pages/Overview';
import Users from './pages/Users';
import Deliveries from './pages/Deliveries';
import Ledger from './pages/Ledger';
import Sips from './pages/Sips';
import Settings from './pages/Settings';
import Login from './pages/Login';
import { useState, useEffect } from 'react';

function App() {
  const [authenticated, setAuthenticated] = useState(!!localStorage.getItem('admin_token'));

  // Protected Route wrapper
  const ProtectedRoute = ({ children }) => {
    if (!authenticated) return <Navigate to="/login" replace />;
    return (
      <div className="app-container">
        <Sidebar onLogout={() => {
          localStorage.removeItem('admin_token');
          setAuthenticated(false);
        }} />
        <main style={{ flex: 1, padding: '40px', overflowY: 'auto' }}>
          {children}
        </main>
      </div>
    );
  };

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={authenticated ? <Navigate to="/overview" /> : <Login setAuthenticated={setAuthenticated} />} />
        
        {/* Protected Routes */}
        <Route path="/" element={<ProtectedRoute><Navigate to="/overview" /></ProtectedRoute>} />
        <Route path="/overview" element={<ProtectedRoute><Overview /></ProtectedRoute>} />
        <Route path="/users" element={<ProtectedRoute><Users /></ProtectedRoute>} />
        <Route path="/deliveries" element={<ProtectedRoute><Deliveries /></ProtectedRoute>} />
        <Route path="/ledger" element={<ProtectedRoute><Ledger /></ProtectedRoute>} />
        <Route path="/sips" element={<ProtectedRoute><Sips /></ProtectedRoute>} />
        <Route path="/settings" element={<ProtectedRoute><Settings /></ProtectedRoute>} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
