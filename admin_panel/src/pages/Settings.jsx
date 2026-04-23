import { useState } from 'react';
import { Save, Bell, Shield, Key } from 'lucide-react';

const Settings = () => {
  return (
    <div className="animate-fade-in">
      <header style={{ marginBottom: '40px' }}>
        <h1 style={{ fontSize: '28px', color: 'var(--text-primary)' }}>Admin Settings</h1>
        <p style={{ color: 'var(--text-secondary)' }}>Configure system preferences and security.</p>
      </header>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '24px', maxWidth: '800px' }}>
        <div className="glass-panel" style={{ padding: '24px' }}>
          <h2 style={{ fontSize: '18px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '24px' }}>
            <Key size={18} color="var(--accent-gold)" /> Platform Credentials
          </h2>
          
          <div className="input-group">
            <label className="input-label">Cashfree Live App ID</label>
            <input type="password" className="input-field" placeholder="••••••••••••••" disabled style={{ opacity: 0.7 }} />
            <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Configured via .env on server</span>
          </div>
          
          <div className="input-group">
            <label className="input-label">Webhook Secret Validation</label>
            <input type="password" className="input-field" placeholder="••••••••••••••" disabled style={{ opacity: 0.7 }} />
            <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Configured via .env on server</span>
          </div>
        </div>

        <div className="glass-panel" style={{ padding: '24px' }}>
          <h2 style={{ fontSize: '18px', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '24px' }}>
            <Shield size={18} color="#6ee7b7" /> Account Security
          </h2>
          <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '16px' }}>Manage administrators and session tokens.</p>
          <button className="btn-icon" style={{ background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
            Revoke All Active Sessions
          </button>
        </div>
      </div>
    </div>
  );
};

export default Settings;
