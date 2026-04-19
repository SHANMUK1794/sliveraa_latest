import { useState, useEffect } from 'react';
import { Truck, MapPin } from 'lucide-react';
import api from '../api';

const Deliveries = () => {
  const [deliveries, setDeliveries] = useState([]);

  useEffect(() => {
    fetchDeliveries();
  }, []);

  const fetchDeliveries = async () => {
    try {
      const res = await api.get('/admin/deliveries');
      if (res.data.success) {
        setDeliveries(res.data.deliveries);
      }
    } catch (err) {
      console.error('Failed to load deliveries:', err);
    }
  };

  const updateStatus = async (id, status, trackingId = null) => {
    try {
      const payload = { status };
      if (trackingId) payload.trackingId = trackingId;
      
      const res = await api.patch(`/admin/deliveries/${id}`, payload);
      if (res.data.success) fetchDeliveries();
    } catch (error) {
      console.error('Failed to update delivery:', error);
    }
  };

  return (
    <div className="animate-fade-in">
      <header style={{ marginBottom: '40px' }}>
        <h1 style={{ fontSize: '28px', color: 'var(--text-primary)' }}>Delivery Logistics</h1>
        <p style={{ color: 'var(--text-secondary)' }}>Manage physical metal shipments and track packages.</p>
      </header>

      <div style={{ display: 'grid', gap: '20px' }}>
        {deliveries.map(delivery => (
          <div key={delivery.id} className="glass-panel" style={{ padding: '24px', display: 'flex', gap: '24px', flexWrap: 'wrap' }}>
            <div style={{ flex: '1 1 300px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
                <Truck size={20} color={delivery.metalType === 'GOLD' ? '#c8a27b' : '#e2e8f0'} />
                <h3 style={{ fontSize: '18px' }}>{delivery.weight}gm {delivery.metalType} Coin</h3>
                <span className={`badge badge-${delivery.status === 'SHIPPED' ? 'success' : delivery.status === 'DELIVERED' ? 'success' : 'pending'}`} style={{ marginLeft: 'auto' }}>
                  {delivery.status}
                </span>
              </div>
              
              <div style={{ display: 'flex', gap: '8px', color: 'var(--text-secondary)', fontSize: '14px', marginBottom: '8px' }}>
                <MapPin size={16} /> 
                {delivery.address ? `${delivery.address.street1}, ${delivery.address.city}, ${delivery.address.state} - ${delivery.address.pincode}` : 'No Address Provided'}
              </div>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                Requested by: {delivery.user?.name} ({delivery.user?.phoneNumber})
              </div>
            </div>

            <div style={{ flex: '1 1 300px', display: 'flex', flexDirection: 'column', gap: '16px', borderLeft: '1px solid var(--border-subtle)', paddingLeft: '24px' }}>
              <div>
                <label className="input-label" style={{ fontSize: '11px' }}>Tracking Number</label>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <input 
                    type="text" 
                    className="input-field" 
                    style={{ flex: 1, padding: '8px 12px', fontSize: '14px' }} 
                    placeholder="E.g., BLUEDART-12345" 
                    defaultValue={delivery.trackingId || ''}
                    id={`track-${delivery.id}`}
                  />
                  <button 
                    className="btn-primary" 
                    style={{ padding: '8px 16px' }}
                    onClick={() => {
                      const val = document.getElementById(`track-${delivery.id}`).value;
                      updateStatus(delivery.id, 'SHIPPED', val);
                    }}
                  >
                    Ship
                  </button>
                </div>
              </div>
              
              <div style={{ display: 'flex', gap: '12px' }}>
                {delivery.status !== 'DELIVERED' && (
                  <button onClick={() => updateStatus(delivery.id, 'DELIVERED')} style={{ flex: 1, padding: '8px', background: 'transparent', border: '1px solid #10b981', color: '#10b981', borderRadius: '6px', fontSize: '13px', cursor: 'pointer' }}>
                    Mark Delivered
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
        {deliveries.length === 0 && (
          <div className="glass-panel" style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)' }}>
            No delivery requests found.
          </div>
        )}
      </div>
    </div>
  );
};

export default Deliveries;
