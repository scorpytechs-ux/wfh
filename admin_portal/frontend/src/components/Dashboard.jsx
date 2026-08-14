import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Users, UserPlus, ShieldAlert, ShieldCheck, ChevronRight, Smartphone, AlertTriangle, Trash2 } from 'lucide-react';

export default function Dashboard() {
  const [candidates, setCandidates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [selectedCandidateDevices, setSelectedCandidateDevices] = useState(null);
  const navigate = useNavigate();

  // New Candidate Form State
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (!localStorage.getItem('adminToken')) {
      navigate('/login');
      return;
    }
    fetchCandidates();
  }, [navigate]);

  const fetchCandidates = async () => {
    try {
      const res = await axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates`);
      setCandidates(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleBlock = async (id, currentStatus) => {
    try {
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/block`, {
        isBlocked: !currentStatus,
        clearDevices: true
      });
      fetchCandidates();
      if (selectedCandidateDevices && selectedCandidateDevices.id === id) {
        setSelectedCandidateDevices(null);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleClearDevices = async (id) => {
    try {
      await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/clear-devices`);
      alert('Active device sessions cleared successfully.');
      fetchCandidates();
      if (selectedCandidateDevices && selectedCandidateDevices.id === id) {
        setSelectedCandidateDevices(prev => prev ? { ...prev, activeDevices: [], deviceCount: 0 } : null);
      }
    } catch (err) {
      console.error(err);
      alert('Failed to clear device sessions.');
    }
  };

  const handleCreateCandidate = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates`, {
        name, email, username, password
      });
      setShowModal(false);
      setName(''); setEmail(''); setUsername(''); setPassword('');
      alert('Candidate created successfully');
      fetchCandidates();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create candidate.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading) {
    return <div style={{ textAlign: 'center', marginTop: '100px' }}>Loading Data...</div>;
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <div>
          <h2 style={{ fontSize: '28px', fontWeight: 'bold' }}>Candidate Management</h2>
          <p style={{ color: 'var(--text-muted)' }}>Manage user access, device logins, and review submissions</p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}>
          <UserPlus size={18} />
          Add Candidate
        </button>
      </div>

      <div className="glass-card" style={{ padding: '0', overflowX: 'auto' }}>
        <table className="data-table" style={{ minWidth: '1100px' }}>
          <thead>
            <tr>
              <th>CANDIDATE</th>
              <th>USERNAME</th>
              <th>EMAIL</th>
              <th>DEVICES</th>
              <th>EARNINGS</th>
              <th>STATUS</th>
              <th style={{ textAlign: 'right' }}>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {candidates.map(candidate => {
              const activeDevices = Array.isArray(candidate.activeDevices) ? candidate.activeDevices : [];
              const deviceCount = candidate.deviceCount != null ? candidate.deviceCount : activeDevices.length;
              const isMultiDeviceBlocked = Boolean(candidate.isBlocked) && (deviceCount >= 2 || Boolean(candidate.blockReason && candidate.blockReason.toLowerCase().includes('device')));

              return (
                <tr key={candidate.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'rgba(59, 130, 246, 0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Users size={20} color="var(--primary)" />
                      </div>
                      <div>
                        <span style={{ fontWeight: '600', display: 'block' }}>{candidate.name}</span>
                        {candidate.blockReason ? (
                          <span style={{ fontSize: '11px', color: '#f87171', display: 'block', marginTop: '2px' }}>
                            {candidate.blockReason}
                          </span>
                        ) : null}
                      </div>
                    </div>
                  </td>
                  <td style={{ color: 'var(--text-muted)' }}>@{candidate.username}</td>
                  <td style={{ color: 'var(--text-muted)' }}>{candidate.email}</td>
                  <td>
                    <button
                      className="btn btn-outline"
                      style={{
                        padding: '4px 10px',
                        fontSize: '12px',
                        borderColor: isMultiDeviceBlocked ? '#ef4444' : (deviceCount > 0 ? '#3b82f6' : 'var(--border)'),
                        color: isMultiDeviceBlocked ? '#f87171' : (deviceCount > 0 ? '#60a5fa' : 'var(--text-muted)')
                      }}
                      onClick={() => setSelectedCandidateDevices(candidate)}
                    >
                      <Smartphone size={14} style={{ marginRight: '4px' }} />
                      {deviceCount} {deviceCount === 1 ? 'Device' : 'Devices'}
                    </button>
                  </td>
                  <td style={{ color: '#4ade80', fontWeight: '600' }}>${(candidate.earnings || 0).toFixed(2)}</td>
                  <td>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', alignItems: 'flex-start' }}>
                      <span className={`badge ${candidate.isBlocked ? 'badge-blocked' : 'badge-active'}`}>
                        {candidate.isBlocked ? 'BLOCKED' : 'ACTIVE'}
                      </span>
                      {isMultiDeviceBlocked ? (
                        <span className="badge" style={{ background: 'rgba(239, 68, 68, 0.2)', color: '#f87171', border: '1px solid rgba(239, 68, 68, 0.4)', fontSize: '10px' }}>
                          <AlertTriangle size={10} style={{ marginRight: '3px', verticalAlign: 'middle' }} /> MULTI-DEVICE
                        </span>
                      ) : null}
                    </div>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                      <button 
                        className={`btn ${candidate.isBlocked ? 'btn-success' : 'btn-danger'}`}
                        style={{ padding: '8px 16px', fontSize: '12px' }}
                        onClick={() => toggleBlock(candidate.id, candidate.isBlocked)}
                      >
                        {candidate.isBlocked ? <ShieldCheck size={16} /> : <ShieldAlert size={16} />}
                        {candidate.isBlocked ? 'Reactivate' : 'Block ID'}
                      </button>
                      <button 
                        className="btn btn-outline"
                        style={{ padding: '8px 16px', fontSize: '12px' }}
                        onClick={() => navigate(`/review/${candidate.id}`, { state: { candidate } })}
                      >
                        Review Forms <ChevronRight size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
            {candidates.length === 0 && (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '48px', color: 'var(--text-muted)' }}>
                  No candidates found in the database.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Create Candidate Modal */}
      {showModal && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(4px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="glass-card" style={{ width: '100%', maxWidth: '500px', background: 'rgba(15, 23, 42, 0.95)' }}>
            <h3 style={{ fontSize: '20px', fontWeight: 'bold', marginBottom: '24px' }}>Create New Candidate</h3>
            <form onSubmit={handleCreateCandidate}>
              <div className="input-group">
                <label>Full Name</label>
                <input type="text" className="input-field" value={name} onChange={e => setName(e.target.value)} required />
              </div>
              <div className="input-group">
                <label>Email Address</label>
                <input type="email" className="input-field" value={email} onChange={e => setEmail(e.target.value)} required />
              </div>
              <div className="input-group">
                <label>Username</label>
                <input type="text" className="input-field" value={username} onChange={e => setUsername(e.target.value)} required />
              </div>
              <div className="input-group" style={{ marginBottom: '32px' }}>
                <label>Password</label>
                <input type="password" className="input-field" value={password} onChange={e => setPassword(e.target.value)} required />
              </div>
              
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-outline" onClick={() => setShowModal(false)} disabled={isSubmitting}>Cancel</button>
                <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                  {isSubmitting ? 'Creating...' : 'Create Account'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* View & Manage Active Devices Modal */}
      {selectedCandidateDevices && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(4px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="glass-card" style={{ width: '100%', maxWidth: '550px', background: 'rgba(15, 23, 42, 0.95)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <div>
                <h3 style={{ fontSize: '20px', fontWeight: 'bold' }}>Active Devices</h3>
                <p style={{ color: 'var(--text-muted)', fontSize: '13px' }}>Candidate: <strong>{selectedCandidateDevices.name}</strong> (@{selectedCandidateDevices.username})</p>
              </div>
              <button className="btn btn-outline" style={{ padding: '4px 8px' }} onClick={() => setSelectedCandidateDevices(null)}>✕</button>
            </div>

            {selectedCandidateDevices.isBlocked === 1 && (
              <div style={{ background: 'rgba(239, 68, 68, 0.15)', border: '1px solid rgba(239, 68, 68, 0.4)', borderRadius: '8px', padding: '12px', marginBottom: '16px', color: '#f87171', fontSize: '13px' }}>
                <AlertTriangle size={16} style={{ verticalAlign: 'middle', marginRight: '6px' }} />
                <strong>Candidate Account Blocked:</strong> {selectedCandidateDevices.blockReason || 'Blocked due to multi-device login.'}
              </div>
            )}

            <div style={{ maxHeight: '250px', overflowY: 'auto', marginBottom: '24px' }}>
              {Array.isArray(selectedCandidateDevices.activeDevices) && selectedCandidateDevices.activeDevices.length > 0 ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  {selectedCandidateDevices.activeDevices.map((device, idx) => (
                    <div key={device.deviceId || idx} style={{ background: 'rgba(255, 255, 255, 0.05)', borderRadius: '8px', padding: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <Smartphone size={20} color="#60a5fa" />
                        <div>
                          <div style={{ fontWeight: '600', fontSize: '14px' }}>{device.deviceName || 'Device ' + (idx + 1)}</div>
                          <div style={{ color: 'var(--text-muted)', fontSize: '12px' }}>ID: {device.deviceId}</div>
                          <div style={{ color: 'var(--text-muted)', fontSize: '11px' }}>IP: {device.ipAddress || 'Unknown'} | Last Active: {device.lastActive ? new Date(device.lastActive).toLocaleString() : 'N/A'}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div style={{ textAlign: 'center', padding: '24px', color: 'var(--text-muted)' }}>
                  No active device sessions registered.
                </div>
              )}
            </div>

            <div style={{ display: 'flex', gap: '12px', justifyContent: 'space-between' }}>
              <button
                type="button"
                className="btn btn-danger"
                style={{ padding: '8px 16px', fontSize: '13px' }}
                onClick={() => handleClearDevices(selectedCandidateDevices.id)}
              >
                <Trash2 size={16} style={{ marginRight: '6px' }} />
                Clear Device Sessions
              </button>
              <div style={{ display: 'flex', gap: '8px' }}>
                {selectedCandidateDevices.isBlocked === 1 && (
                  <button
                    type="button"
                    className="btn btn-success"
                    style={{ padding: '8px 16px', fontSize: '13px' }}
                    onClick={() => toggleBlock(selectedCandidateDevices.id, true)}
                  >
                    Unblock Candidate
                  </button>
                )}
                <button type="button" className="btn btn-outline" onClick={() => setSelectedCandidateDevices(null)}>Close</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

