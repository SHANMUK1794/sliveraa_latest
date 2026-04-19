import { useState, useEffect } from 'react';
import { X, Gift, MapPin, CreditCard, Activity, CalendarDays } from 'lucide-react';
import api from '../api';

const UserDetailModal = ({ userId, onClose }) => {
  const [details, setDetails] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const res = await api.get(`/admin/users/${userId}`);
        if (res.data.success) {
          setDetails(res.data.user);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchDetails();
  }, [userId]);

  if (loading) {
    return (
      <div className="modal-overlay">
        <div className="glass-panel" style={{ padding: '40px', background: 'var(--bg-dark)' }}>
          Loading user details...
        </div>
      </div>
    );
  }

  if (!details) return null;

  return (
    <div className="modal-overlay">
      <div className="glass-panel modal-content" style={{ maxWidth: '800px', width: '90%', maxHeight: '90vh', overflowY: 'auto', background: 'var(--bg-dark)' }}>
        <div style={{ padding: '24px', borderBottom: '1px solid var(--border-subtle)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', position: 'sticky', top: 0, background: 'var(--bg-dark)', zIndex: 10 }}>
          <h2 style={{ fontSize: '20px', display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'linear-gradient(135deg, var(--accent-gold), var(--accent-gold-dark))', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: '18px' }}>
              {details.name ? details.name.charAt(0) : '?'}
            </div>
            <div>
              <div>{details.name || 'Unnamed User'}</div>
              <div style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: 'normal' }}>{details.phoneNumber} • {details.email || 'No email'}</div>
            </div>
          </h2>
          <button onClick={onClose} className="btn-icon"><X size={20} /></button>
        </div>

        <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '32px' }}>
          
          {/* Section: Balances & Stats */}
          <section>
            <h3 style={{ fontSize: '14px', textTransform: 'uppercase', color: 'var(--text-muted)', marginBottom: '16px', letterSpacing: '1px' }}>Core Balances</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px' }}>
              <div style={{ padding: '16px', background: 'rgba(255,255,255,0.02)', borderRadius: '12px', border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>Wallet Cash</div>
                <div style={{ fontSize: '24px', fontWeight: 'bold' }}>₹{details.walletBalance.toLocaleString()}</div>
              </div>
              <div style={{ padding: '16px', background: 'rgba(200, 162, 123, 0.05)', borderRadius: '12px', border: '1px solid rgba(200, 162, 123, 0.2)' }}>
                <div style={{ fontSize: '13px', color: '#c8a27b' }}>Gold Vault</div>
                <div style={{ fontSize: '24px', fontWeight: 'bold' }}>{details.goldBalance.toFixed(4)} gm</div>
              </div>
              <div style={{ padding: '16px', background: 'rgba(226, 232, 240, 0.05)', borderRadius: '12px', border: '1px solid rgba(226, 232, 240, 0.2)' }}>
                <div style={{ fontSize: '13px', color: '#e2e8f0' }}>Silver Vault</div>
                <div style={{ fontSize: '24px', fontWeight: 'bold' }}>{details.silverBalance.toFixed(4)} gm</div>
              </div>
            </div>
          </section>

          {/* Grid Layout for remaining details */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '32px' }}>
            
            {/* Bank Accounts */}
            <section>
              <h3 style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                <CreditCard size={16} /> Bank Accounts
              </h3>
              {details.bankAccounts.length > 0 ? details.bankAccounts.map(b => (
                <div key={b.id} style={{ padding: '12px', background: 'rgba(0,0,0,0.2)', borderRadius: '8px', marginBottom: '8px', fontSize: '13px' }}>
                  <div style={{ fontWeight: 'bold' }}>{b.bankName}</div>
                  <div>Acc: ****{b.accountNumber.slice(-4)}</div>
                  <div style={{ color: 'var(--text-muted)' }}>IFSC: {b.ifsc}</div>
                </div>
              )) : <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>No attached banks.</div>}
            </section>

            {/* Addresses */}
            <section>
              <h3 style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                <MapPin size={16} /> Registered Addresses
              </h3>
              {details.addresses.length > 0 ? details.addresses.map(a => (
                <div key={a.id} style={{ padding: '12px', background: 'rgba(0,0,0,0.2)', borderRadius: '8px', marginBottom: '8px', fontSize: '13px' }}>
                  <div style={{ fontWeight: 'bold' }}>{a.label}</div>
                  <div>{a.line1}, {a.city}</div>
                  <div style={{ color: 'var(--text-muted)' }}>{a.state} - {a.pincode}</div>
                </div>
              )) : <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>No saved addresses.</div>}
            </section>

            {/* Rewards */}
            <section>
              <h3 style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                <Gift size={16} /> Earnings & Rewards
              </h3>
              {details.rewards.length > 0 ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  <div style={{ padding: '8px', background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', borderRadius: '6px', fontSize: '14px', fontWeight: 'bold' }}>
                    Total Points Gained: {details.rewards.reduce((acc, r) => acc + r.points, 0).toLocaleString()}
                  </div>
                  {details.rewards.map(r => (
                    <div key={r.id} style={{ fontSize: '12px', display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: '1px solid var(--border-subtle)' }}>
                      <span>{r.description}</span>
                      <span style={{ fontWeight: 'bold' }}>+{r.points}</span>
                    </div>
                  ))}
                </div>
              ) : <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>No rewards yet.</div>}
            </section>

            {/* SIPs */}
            <section>
              <h3 style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                <CalendarDays size={16} /> Active Auto-Saves
              </h3>
              {details.savingsPlans.length > 0 ? details.savingsPlans.map(s => (
                <div key={s.id} style={{ padding: '12px', border: `1px solid ${s.metalType === 'GOLD' ? 'rgba(200, 162, 123, 0.2)' : 'rgba(226, 232, 240, 0.2)'}`, borderRadius: '8px', marginBottom: '8px', fontSize: '13px' }}>
                  <div style={{ fontWeight: 'bold' }}>{s.metalType} • {s.frequency}</div>
                  <div>Installment: ₹{s.amount}</div>
                  <div style={{ color: 'var(--text-muted)' }}>Status: {s.status}</div>
                </div>
              )) : <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>No active SIPs.</div>}
            </section>

            {/* KYC Identity Verification */}
            <section>
              <h3 style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
                <Activity size={16} /> Identity & KYC
              </h3>
              {details.kycDetails ? (
                <div style={{ padding: '16px', background: 'rgba(0,0,0,0.2)', border: '1px solid var(--border-subtle)', borderRadius: '12px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Document Type</span>
                    <span style={{ fontWeight: 'bold', fontSize: '13px' }}>{details.kycDetails.documentType}</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Doc Number</span>
                    <span style={{ fontSize: '13px', fontFamily: 'monospace' }}>{details.kycDetails.documentNumber}</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                    <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>System Status</span>
                    <span style={{ fontSize: '13px', color: details.kycDetails.status === 'VERIFIED' ? '#10b981' : '#f59e0b' }}>{details.kycDetails.status}</span>
                  </div>
                  {details.kycDetails.verificationId && (
                     <div style={{ fontSize: '11px', color: 'var(--text-muted)', borderTop: '1px solid var(--border-subtle)', paddingTop: '8px', overflowWrap: 'break-word' }}>
                       Surepass Transaction ID: {details.kycDetails.verificationId}
                     </div>
                  )}
                </div>
              ) : (
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>No KYC documents submitted yet.</div>
              )}
            </section>
          </div>

          {/* Recent Activity */}
          <section>
            <h3 style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
              <Activity size={16} /> Recent Transactions
            </h3>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Type</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {details.transactions.map(t => (
                  <tr key={t.id}>
                    <td><span className="badge" style={{ background: 'rgba(255,255,255,0.05)' }}>{t.type} {t.metalType && `- ${t.metalType}`}</span></td>
                    <td style={{ fontWeight: 'bold' }}>₹{t.amount.toLocaleString()}</td>
                    <td>{t.status}</td>
                    <td style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>{new Date(t.createdAt).toLocaleDateString()}</td>
                  </tr>
                ))}
                {details.transactions.length === 0 && (
                  <tr><td colSpan="4" style={{ textAlign: 'center', padding: '20px', color: 'var(--text-muted)' }}>No transactions yet.</td></tr>
                )}
              </tbody>
            </table>
          </section>

        </div>
      </div>
    </div>
  );
};

export default UserDetailModal;
