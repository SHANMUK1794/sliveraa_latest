import { useState, useEffect } from 'react';
import api from '../api';

const Sips = () => {
  const [sips, setSips] = useState([]);

  useEffect(() => {
    const fetchSips = async () => {
      try {
        const res = await api.get('/admin/sips');
        if (res.data.success) {
          setSips(res.data.sips);
        }
      } catch (err) {
        console.error('Failed to load SIPs:', err);
      }
    };
    fetchSips();
  }, []);

  return (
    <div className="animate-fade-in">
      <header style={{ marginBottom: '40px' }}>
        <h1 style={{ fontSize: '28px', color: 'var(--text-primary)' }}>SIP & Auto-Investments</h1>
        <p style={{ color: 'var(--text-secondary)' }}>Track automated systematic investment plans.</p>
      </header>

      <div className="glass-panel" style={{ overflowX: 'auto' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Metal</th>
              <th>Investor Details</th>
              <th>Frequency</th>
              <th>Installment Amount</th>
              <th>Status</th>
              <th>Created Date</th>
            </tr>
          </thead>
          <tbody>
            {sips.map(sip => (
              <tr key={sip.id}>
                <td>
                  <span className="badge" style={{ background: sip.metalType === 'GOLD' ? 'rgba(200, 162, 123, 0.15)' : 'rgba(226, 232, 240, 0.15)', color: sip.metalType === 'GOLD' ? '#c8a27b' : '#e2e8f0' }}>
                    {sip.metalType}
                  </span>
                </td>
                <td>
                  <div style={{ fontWeight: '600' }}>{sip.user?.name || 'Unknown'}</div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{sip.user?.phoneNumber}</div>
                </td>
                <td><span className="badge" style={{ background: 'transparent', border: '1px solid var(--border-subtle)' }}>{sip.frequency}</span></td>
                <td style={{ fontWeight: 'bold' }}>₹{sip.amount.toLocaleString()}</td>
                <td>
                  <span className={`badge badge-${sip.status === 'ACTIVE' ? 'success' : 'pending'}`}>
                    {sip.status}
                  </span>
                </td>
                <td style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>
                  {new Date(sip.createdAt).toLocaleDateString()}
                </td>
              </tr>
            ))}
            {sips.length === 0 && (
              <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>No SIPs found.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Sips;
