import { useState, useEffect } from 'react';
import { Search, Filter, ShieldCheck, ShieldAlert, AlertCircle } from 'lucide-react';
import api from '../api';
import UserDetailModal from '../components/UserDetailModal';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUserId, setSelectedUserId] = useState(null);
  const [period, setPeriod] = useState('all_time');

  useEffect(() => {
    fetchUsers();
  }, [period]);

  const fetchUsers = async () => {
    try {
      const res = await api.get('/admin/users', { params: { period } });
      if (res.data.success) {
        setUsers(res.data.users);
      }
    } catch (err) {
      console.error('Failed to load users:', err);
    }
  };

  const handleKycStatus = async (id, status) => {
    try {
      const res = await api.patch(`/admin/kyc/${id}`, { status });
      if (res.data.success) {
        fetchUsers();
      }
    } catch (err) {
      console.error('Failed to update KYC:', err);
    }
  };

  const filteredUsers = users.filter(u => 
    u.name?.toLowerCase().includes(searchTerm.toLowerCase()) || 
    u.phoneNumber.includes(searchTerm)
  );

  return (
    <div className="animate-fade-in">
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
        <div>
          <h1 style={{ fontSize: '28px', color: 'var(--text-primary)' }}>User Management</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Manage accounts, view balances, and approve KYC.</p>
        </div>
        <button className="btn-primary">Add User</button>
      </header>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <div style={{ padding: '20px 24px', borderBottom: '1px solid var(--border-subtle)', display: 'flex', gap: '16px', alignItems: 'center' }}>
          <div style={{ position: 'relative', flex: 1, maxWidth: '400px' }}>
            <Search size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
            <input 
              type="text" 
              placeholder="Search users by name or phone..." 
              className="input-field" 
              style={{ width: '100%', paddingLeft: '44px', background: 'rgba(0,0,0,0.3)', border: 'none' }}
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
            />
          </div>
          
          <div style={{ position: 'relative' }}>
            <select 
              value={period} 
              onChange={(e) => setPeriod(e.target.value)} 
              className="input-field" 
              style={{ width: '180px', background: 'rgba(0,0,0,0.3)', padding: '10px' }}
            >
              <option value="all_time">Joined: All Time</option>
              <option value="monthly">Joined: This Month</option>
              <option value="weekly">Joined: This Week</option>
              <option value="daily">Joined: Today</option>
            </select>
          </div>
        </div>

        <div style={{ overflowX: 'auto' }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>User Details</th>
                <th>KYC Status</th>
                <th>Wallet Balance</th>
                <th>Vault Balance</th>
                <th>Joined Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map(user => (
                <tr key={user.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'linear-gradient(135deg, var(--bg-dark), rgba(255,255,255,0.05))', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', color: 'var(--accent-gold)' }}>
                        {user.name ? user.name.charAt(0) : '?'}
                      </div>
                      <div>
                        <div style={{ fontWeight: '600', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                          {user.name || 'Unknown User'} 
                          {user.role === 'ADMIN' && <span className="badge badge-admin" style={{ padding: '2px 6px', fontSize: '10px' }}>Admin</span>}
                        </div>
                        <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{user.phoneNumber}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <KycBadge status={user.kycStatus} />
                  </td>
                  <td style={{ fontWeight: '600', color: 'var(--text-primary)' }}>
                    ₹{user.walletBalance.toLocaleString()}
                  </td>
                  <td>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                      <span style={{ fontSize: '12px', color: '#c8a27b', fontWeight: '600' }}>{user.goldBalance.toFixed(3)}g GOLD</span>
                      <span style={{ fontSize: '12px', color: '#e2e8f0', fontWeight: '600' }}>{user.silverBalance.toFixed(3)}g SILVER</span>
                    </div>
                  </td>
                  <td style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>
                    {new Date(user.createdAt).toLocaleDateString()}
                  </td>
                  <td>
                    {user.kycStatus === 'PENDING' ? (
                      <div style={{ display: 'flex', gap: '8px' }}>
                        <button onClick={() => handleKycStatus(user.id, 'VERIFIED')} style={{ padding: '6px 12px', background: 'rgba(16, 185, 129, 0.2)', border: '1px solid #10b981', color: '#6ee7b7', borderRadius: '6px', fontSize: '12px', cursor: 'pointer' }}>Approve</button>
                        <button onClick={() => handleKycStatus(user.id, 'REJECTED')} style={{ padding: '6px 12px', background: 'rgba(239, 68, 68, 0.2)', border: '1px solid #ef4444', color: '#fca5a5', borderRadius: '6px', fontSize: '12px', cursor: 'pointer' }}>Reject</button>
                      </div>
                    ) : (
                      <button onClick={() => setSelectedUserId(user.id)} className="btn-icon" style={{ color: 'var(--accent-gold)' }}>View</button>
                    )}
                  </td>
                </tr>
              ))}
              {filteredUsers.length === 0 && (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
                    No users found matching your search.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      {selectedUserId && (
        <UserDetailModal 
          userId={selectedUserId} 
          onClose={() => setSelectedUserId(null)} 
        />
      )}
    </div>
  );
};

const KycBadge = ({ status }) => {
  if (status === 'VERIFIED') return <span className="badge badge-success"><ShieldCheck size={12} style={{ marginRight: '4px' }} /> Verified</span>;
  if (status === 'PENDING') return <span className="badge badge-pending"><AlertCircle size={12} style={{ marginRight: '4px' }} /> Pending</span>;
  return <span className="badge" style={{ background: 'rgba(255,255,255,0.05)', color: 'var(--text-secondary)', border: '1px solid var(--border-subtle)' }}><ShieldAlert size={12} style={{ marginRight: '4px' }} /> Not Started</span>;
};

export default Users;
