import { BarChart3, Users, Package, Settings, LogOut, FileText, Repeat } from 'lucide-react';
import { NavLink } from 'react-router-dom';

const Sidebar = ({ onLogout }) => {
  return (
    <aside style={{
      width: '260px',
      background: 'rgba(20, 23, 31, 0.8)',
      backdropFilter: 'blur(12px)',
      borderRight: '1px solid rgba(255, 255, 255, 0.05)',
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      position: 'sticky',
      top: 0
    }}>
      <div style={{ padding: '32px 24px', borderBottom: '1px solid rgba(255, 255, 255, 0.05)' }}>
        <h2 className="text-gradient-gold" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ width: '24px', height: '24px', borderRadius: '6px', background: 'linear-gradient(135deg, #c8a27b 0%, #a37c56 100%)' }}></div>
          SILVRA
        </h2>
        <div style={{ marginTop: '4px', fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '2px' }}>
          Admin Console
        </div>
      </div>

      <nav style={{ padding: '24px 16px', display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
        <NavItem to="/overview" icon={<BarChart3 size={18} />} label="Overview" />
        <NavItem to="/users" icon={<Users size={18} />} label="Users" />
        <NavItem to="/ledger" icon={<FileText size={18} />} label="Transactions" />
        <NavItem to="/sips" icon={<Repeat size={18} />} label="Auto-Saves (SIPs)" />
        <NavItem to="/deliveries" icon={<Package size={18} />} label="Deliveries" />
        <NavItem to="/settings" icon={<Settings size={18} />} label="Settings" />
      </nav>

      <div style={{ padding: '24px 16px', borderTop: '1px solid rgba(255, 255, 255, 0.05)' }}>
        <button style={{
          display: 'flex', alignItems: 'center', gap: '12px', width: '100%',
          padding: '12px 16px', background: 'rgba(255,255,255,0.02)', border: '1px solid var(--border-subtle)',
          borderRadius: '8px', color: 'var(--text-secondary)', cursor: 'pointer',
          transition: 'all 0.2s', fontSize: '14px', fontWeight: '500'
        }}
        onClick={onLogout}
        onMouseOver={e => { e.currentTarget.style.background = 'rgba(239, 68, 68, 0.1)'; e.currentTarget.style.color = '#ef4444'; e.currentTarget.style.borderColor = 'rgba(239, 68, 68, 0.2)' }}
        onMouseOut={e => { e.currentTarget.style.background = 'rgba(255,255,255,0.02)'; e.currentTarget.style.color = 'var(--text-secondary)'; e.currentTarget.style.borderColor = 'var(--border-subtle)' }}
        >
          <LogOut size={16} /> Logout
        </button>
      </div>
    </aside>
  );
};

const NavItem = ({ to, icon, label }) => {
  return (
    <NavLink
      to={to}
      style={({ isActive }) => ({
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
        padding: '12px 16px',
        borderRadius: '8px',
        textDecoration: 'none',
        fontSize: '14px',
        fontWeight: '500',
        transition: 'all 0.2s',
        color: isActive ? 'var(--accent-gold)' : 'var(--text-secondary)',
        background: isActive ? 'rgba(200, 162, 123, 0.08)' : 'transparent',
      })}
    >
      {icon} {label}
    </NavLink>
  );
};

export default Sidebar;
