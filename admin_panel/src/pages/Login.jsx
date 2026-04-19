import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

const Login = ({ setAuthenticated }) => {
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // Configured for live environment
      const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';
      const res = await axios.post(`${baseURL}/auth/login`, {
        phone,
        password
      });

      if (res.data.success) {
        localStorage.setItem('admin_token', res.data.token);
        setAuthenticated(true);
        navigate('/overview');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Ensure you have Admin credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', width: '100vw' }}>
      <div className="glass-panel" style={{ padding: '40px', width: '400px', maxWidth: '90%' }}>
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <h2 className="text-gradient-gold" style={{ fontSize: '28px', marginBottom: '8px' }}>Silvra Admin</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Enter your administrator credentials</p>
        </div>

        {error && (
          <div style={{ padding: '12px', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.3)', borderRadius: '8px', color: '#fca5a5', fontSize: '14px', marginBottom: '24px', textAlign: 'center' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleLogin}>
          <div className="input-group">
            <label className="input-label">Phone or Email</label>
            <input 
              type="text" 
              className="input-field" 
              value={phone}
              onChange={e => setPhone(e.target.value)}
              placeholder="+91 9876543210"
              required 
            />
          </div>
          
          <div className="input-group">
            <label className="input-label">Password</label>
            <input 
              type="password" 
              className="input-field" 
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="••••••••"
              required 
            />
          </div>

          <button 
            type="submit" 
            className="btn-primary" 
            style={{ width: '100%', marginTop: '16px', padding: '14px', fontSize: '16px' }}
            disabled={loading}
          >
            {loading ? 'Authenticating...' : 'Secure Login'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
