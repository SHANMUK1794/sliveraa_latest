import { useState, useEffect } from 'react';
import { Search, Filter, Download } from 'lucide-react';
import api from '../api';

const Ledger = () => {
  const [transactions, setTransactions] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchTransactions();
  }, []);

  const fetchTransactions = async () => {
    try {
      const res = await api.get('/admin/transactions');
      if (res.data.success) {
        setTransactions(res.data.transactions);
      }
    } catch (err) {
      console.error('Failed to load transactions:', err);
    }
  };

  const filtered = transactions.filter(t => 
    t.razorpayOrderId?.toLowerCase().includes(searchTerm.toLowerCase()) || 
    t.user?.phoneNumber.includes(searchTerm)
  );

  return (
    <div className="animate-fade-in">
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
        <div>
          <h1 style={{ fontSize: '28px', color: 'var(--text-primary)' }}>Transaction Ledger</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Master ledger of all system transactions.</p>
        </div>
        <button className="btn-primary" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Download size={16} /> Export CSV
        </button>
      </header>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <div style={{ padding: '20px 24px', borderBottom: '1px solid var(--border-subtle)', display: 'flex', gap: '16px', alignItems: 'center' }}>
          <div style={{ position: 'relative', flex: 1, maxWidth: '400px' }}>
            <Search size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
            <input 
              type="text" 
              placeholder="Search Order ID or Phone..." 
              className="input-field" 
              style={{ width: '100%', paddingLeft: '44px', background: 'rgba(0,0,0,0.3)', border: 'none' }}
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
            />
          </div>
          <button className="btn-icon"><Filter size={18} /></button>
        </div>

        <div style={{ overflowX: 'auto' }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Transaction ID</th>
                <th>User / Phone</th>
                <th>Type</th>
                <th>Amount / Metal</th>
                <th>Status</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(t => (
                <tr key={t.id}>
                  <td style={{ fontFamily: 'monospace', fontSize: '12px' }}>{t.razorpayOrderId || t.id.slice(0, 12)}</td>
                  <td>
                    <div style={{ fontWeight: '600' }}>{t.user?.name || 'Unknown'}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{t.user?.phoneNumber}</div>
                  </td>
                  <td>
                    <span className="badge" style={{ background: 'rgba(255,255,255,0.05)' }}>
                      {t.type} {t.metalType && `- ${t.metalType}`}
                    </span>
                  </td>
                  <td>
                    <div style={{ fontWeight: 'bold' }}>₹{t.amount.toLocaleString()}</div>
                    {t.weight && <div style={{ fontSize: '12px', color: t.metalType === 'GOLD' ? '#c8a27b' : '#e2e8f0' }}>{t.weight.toFixed(4)} gm</div>}
                  </td>
                  <td>
                    <span className={`badge badge-${t.status === 'COMPLETED' ? 'success' : t.status === 'PENDING' ? 'pending' : 'failed'}`}>
                      {t.status}
                    </span>
                  </td>
                  <td style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>
                    {new Date(t.createdAt).toLocaleString()}
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>No transactions found.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Ledger;
