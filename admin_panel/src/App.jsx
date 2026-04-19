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
import { Menu, X } from 'lucide-react';

function App() {
  const [authenticated, setAuthenticated] = useState(!!localStorage.getItem('admin_token'));
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // Protected Route wrapper
  const ProtectedRoute = ({ children }) => {
    if (!authenticated) return <Navigate to="/login" replace />;
    return (
      <div className="app-container">
        {/* Mobile Header */}
        <div className="mobile-header">
          <h2 className="text-gradient-gold" style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '20px', margin: 0 }}>
            <div style={{ width: '20px', height: '20px', borderRadius: '4px', background: 'linear-gradient(135deg, #c8a27b 0%, #a37c56 100%)' }}></div>
            SILVRA
          </h2>
          <button className="btn-icon" onClick={() => setSidebarOpen(true)}>
            <Menu size={20} />
          </button>
        </div>

        {/* Mobile Overlay for Sidebar */}
        {sidebarOpen && (
          <div 
            className="mobile-overlay animate-fade-in" 
            style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', zIndex: 90 }}
            onClick={() => setSidebarOpen(false)}
          ></div>
        )}

        <Sidebar 
          isOpen={sidebarOpen} 
          onClose={() => setSidebarOpen(false)}
          onLogout={() => {
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_role');
            setAuthenticated(false);
          }} 
        />
        
        <main className="main-content" style={{ flex: 1, padding: '40px', overflowY: 'auto' }}>
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
