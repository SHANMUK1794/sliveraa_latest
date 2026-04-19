import { useState, useEffect } from 'react';
import { ArrowUpRight, TrendingUp, Users, Package } from 'lucide-react';
import api from '../api';

const Overview = () => {
  const [period, setPeriod] = useState('all_time');
  const [metrics, setMetrics] = useState({
    totalUsers: 0,
    totalWalletBalance: 0,
    totalGoldInVault: 0,
    totalSilverInVault: 0,
    activeSips: 0,
    pendingDeliveries: 0,
  });

  useEffect(() => {
    api.get('/admin/metrics', { params: { period } }).then(res => {
      if (res.data.success) {
        setMetrics(res.data.metrics);
      }
    }).catch(err => {
      console.error('Failed to load metrics:', err);
    });
  }, [period]);

  return (
    <div className="animate-fade-in">
      <header style={{ marginBottom: '40px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '28px', color: 'var(--text-primary)' }}>Overview</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Welcome to the Silvra Admin Console. Here's what's happening today.</p>
        </div>
        <select 
          value={period} 
          onChange={(e) => setPeriod(e.target.value)} 
          className="input-field" 
          style={{ width: '180px', background: 'rgba(0,0,0,0.3)', padding: '10px' }}
        >
          <option value="all_time">All Time</option>
          <option value="monthly">This Month</option>
          <option value="weekly">This Week</option>
          <option value="daily">Today (24h)</option>
        </select>
      </header>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '24px', marginBottom: '40px' }}>
        <MetricCard 
          title="Total Platform Wealth" 
          value={`₹${(metrics.totalWalletBalance).toLocaleString()}`} 
          trend="Live Sync" 
          icon={<TrendingUp size={20} />} 
          glow={true}
        />
        <MetricCard 
          title="Active Users" 
          value={metrics.totalUsers.toLocaleString()} 
          trend="Live Sync" 
          icon={<Users size={20} />} 
        />
        <MetricCard 
          title="Gold in Vault" 
          value={`${metrics.totalGoldInVault.toFixed(2)} gm`} 
          trend="Secure" 
          icon={<div style={{ color: '#c8a27b' }}>●</div>} 
        />
        <MetricCard 
          title="Silver in Vault" 
          value={`${metrics.totalSilverInVault.toFixed(2)} gm`} 
          trend="Secure" 
          icon={<div style={{ color: '#e2e8f0' }}>●</div>} 
        />
      </div>

      <div className="glass-panel" style={{ padding: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
          <h3 style={{ fontSize: '18px' }}>Action Items</h3>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
          <ActionCard 
            title="Pending Deliveries" 
            count={metrics.pendingDeliveries} 
            action="Fulfill Orders" 
            icon={<Package size={24} color="var(--accent-gold)" />} 
          />
          <ActionCard 
            title="Active SIPs" 
            count={metrics.activeSips} 
            action="View Schedules" 
            icon={<TrendingUp size={24} color="#6ee7b7" />} 
          />
        </div>
      </div>
    </div>
  );
};

const MetricCard = ({ title, value, trend, icon, glow }) => (
  <div className="glass-panel" style={{ padding: '24px', position: 'relative', overflow: 'hidden' }}>
    {glow && (
      <div style={{ 
        position: 'absolute', top: '-50%', right: '-20%', width: '150px', height: '150px', 
        background: 'var(--accent-gold)', filter: 'blur(80px)', opacity: 0.15, borderRadius: '50%' 
      }} />
    )}
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--text-secondary)', fontSize: '14px', fontWeight: '500' }}>
        {icon} {title}
      </div>
    </div>
    <div style={{ fontSize: '32px', fontWeight: '800', fontFamily: 'Manrope, sans-serif', color: glow ? 'var(--accent-gold)' : 'var(--text-primary)', marginBottom: '8px' }}>
      {value}
    </div>
    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '13px', color: '#6ee7b7', fontWeight: '500' }}>
      <ArrowUpRight size={14} /> {trend}
    </div>
  </div>
);

const ActionCard = ({ title, count, action, icon }) => (
  <div style={{ background: 'rgba(0,0,0,0.2)', border: '1px solid var(--border-subtle)', borderRadius: '12px', padding: '20px', display: 'flex', alignItems: 'center', gap: '20px' }}>
    <div style={{ width: '56px', height: '56px', borderRadius: '12px', background: 'var(--bg-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center', border: '1px solid var(--border-subtle)' }}>
      {icon}
    </div>
    <div style={{ flex: 1 }}>
      <h4 style={{ fontSize: '18px', marginBottom: '4px', color: 'var(--text-primary)' }}>{count} {title}</h4>
      <p style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>Requires immediate attention</p>
    </div>
    <button className="btn-icon">
      <ArrowUpRight size={20} />
    </button>
  </div>
);

export default Overview;
