import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Users, UserPlus, ShieldAlert, ShieldCheck, ChevronRight } from 'lucide-react';

export default function Dashboard() {
  const [candidates, setCandidates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const navigate = useNavigate();

  // New Candidate Form State
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  useEffect(() => {
    if (!localStorage.getItem('adminToken')) {
      navigate('/login');
      return;
    }
    fetchCandidates();
  }, [navigate]);

  const fetchCandidates = async () => {
    try {
      const res = await axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates`);
      setCandidates(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleBlock = async (id, currentStatus) => {
    try {
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/${id}/block`, {
        isBlocked: !currentStatus
      });
      fetchCandidates();
    } catch (err) {
      console.error(err);
    }
  };

  const handleCreateCandidate = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates`, {
        name, email, username, password
      });
      setShowModal(false);
      setName(''); setEmail(''); setUsername(''); setPassword('');
      fetchCandidates();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create candidate.');
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
          <p style={{ color: 'var(--text-muted)' }}>Manage user access and review submissions</p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}>
          <UserPlus size={18} />
          Add Candidate
        </button>
      </div>

      <div className="glass-card" style={{ padding: '0', overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>CANDIDATE</th>
              <th>USERNAME</th>
              <th>EMAIL</th>
              <th>EARNINGS</th>
              <th>STATUS</th>
              <th style={{ textAlign: 'right' }}>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {candidates.map(candidate => (
              <tr key={candidate.id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: 'rgba(59, 130, 246, 0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <Users size={20} color="var(--primary)" />
                    </div>
                    <span style={{ fontWeight: '600' }}>{candidate.name}</span>
                  </div>
                </td>
                <td style={{ color: 'var(--text-muted)' }}>@{candidate.username}</td>
                <td style={{ color: 'var(--text-muted)' }}>{candidate.email}</td>
                <td style={{ color: '#4ade80', fontWeight: '600' }}>${(candidate.earnings || 0).toFixed(2)}</td>
                <td>
                  <span className={`badge ${candidate.isBlocked ? 'badge-blocked' : 'badge-active'}`}>
                    {candidate.isBlocked ? 'BLOCKED' : 'ACTIVE'}
                  </span>
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
            ))}
            {candidates.length === 0 && (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '48px', color: 'var(--text-muted)' }}>
                  No candidates found in the database.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

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
                <button type="button" className="btn btn-outline" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">Create Account</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
