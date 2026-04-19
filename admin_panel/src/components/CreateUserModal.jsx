import { useState } from 'react';
import { X, UserPlus } from 'lucide-react';
import api from '../api';

const CreateUserModal = ({ onClose, onSuccess }) => {
  const [formData, setFormData] = useState({
    name: '',
    phoneNumber: '',
    password: '',
    role: 'ADMIN' // Default to admin creation since this is admin tool
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const res = await api.post('/admin/users', formData);
      if (res.data.success) {
        onSuccess();
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="glass-panel modal-content" style={{ width: '400px', maxWidth: '90%' }}>
        <div style={{ padding: '20px 24px', borderBottom: '1px solid var(--border-subtle)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2 style={{ fontSize: '18px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <UserPlus size={20} className="text-gradient-gold" />
            Create System User
          </h2>
          <button onClick={onClose} className="btn-icon"><X size={18} /></button>
        </div>

        {error && (
          <div style={{ margin: '20px 24px 0', padding: '12px', background: 'rgba(239,68,68,0.1)', border: '1px solid rgba(239,68,68,0.3)', borderRadius: '8px', color: '#fca5a5', fontSize: '13px' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ padding: '24px' }}>
          <div className="input-group">
            <label className="input-label">Full Name</label>
            <input type="text" className="input-field" required value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} placeholder="e.g., John Doe" />
          </div>

          <div className="input-group">
            <label className="input-label">Phone Number</label>
            <input type="text" className="input-field" required value={formData.phoneNumber} onChange={e => setFormData({...formData, phoneNumber: e.target.value})} placeholder="+91 XXXXX XXXXX" />
          </div>

          <div className="input-group">
            <label className="input-label">Initial Password</label>
            <input type="text" className="input-field" required value={formData.password} onChange={e => setFormData({...formData, password: e.target.value})} placeholder="SecurePassword123" />
          </div>

          <div className="input-group">
            <label className="input-label">Access Level</label>
            <select className="input-field" value={formData.role} onChange={e => setFormData({...formData, role: e.target.value})}>
              <option value="USER">App User (Customer)</option>
              <option value="ADMIN">Administrator</option>
              <option value="SUPER_ADMIN">Super Administrator</option>
            </select>
          </div>

          <button type="submit" className="btn-primary" style={{ width: '100%', marginTop: '16px' }} disabled={loading}>
            {loading ? 'Processing...' : 'Create Account'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default CreateUserModal;
