import { useState, useEffect } from 'react';
import { useParams, useLocation, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { ArrowLeft, Save, FileText, CheckCircle2 } from 'lucide-react';

export default function Review() {
  const { id } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const [candidate, setCandidate] = useState(location.state?.candidate || null);
  const [forms, setForms] = useState([]);
  const [earnings, setEarnings] = useState(candidate?.earnings || 0);
  const [dailyTarget, setDailyTarget] = useState(candidate?.dailyTarget || 0);
  const [monthlyTarget, setMonthlyTarget] = useState(candidate?.monthlyTarget || 0);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [adminScores, setAdminScores] = useState({});
  const [bulkScore, setBulkScore] = useState('');
  const [bulking, setBulking] = useState(false);

  useEffect(() => {
    if (!localStorage.getItem('adminToken')) {
      navigate('/login');
      return;
    }
    
    // Always fetch latest to ensure data is fresh
    axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates`).then(res => {
      const found = res.data.find(c => c.id === id);
      if (found) {
        setCandidate(found);
        // Only update targets/earnings if they are initially 0 (to not overwrite if admin is typing)
        // or actually, it's safe to overwrite on mount
        setEarnings(found.earnings || 0);
        setDailyTarget(found.dailyTarget || 0);
        setMonthlyTarget(found.monthlyTarget || 0);
      }
    });

    axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/${id}/forms`)
      .then(res => setForms(res.data))
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  }, [id, navigate]);

  const handleEvaluate = async (formId) => {
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/forms/${formId}/evaluate`);
      setForms(forms.map(f => f.id === formId ? { ...f, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));
    } catch (err) {
      alert('Evaluation failed');
    }
  };

  const handleAdminScore = async (formId) => {
    const targetScore = adminScores[formId];
    if (targetScore === undefined || targetScore === '') {
      alert('Please enter a target score.');
      return;
    }
    
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/forms/${formId}/admin-score`, { targetScore: parseFloat(targetScore) });
      setForms(forms.map(f => f.id === formId ? { ...f, ...res.data.updatedFields, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));
      alert('Admin score applied and mistakes injected!');
    } catch (err) {
      alert('Admin override failed');
    }
  };

  const handleSend = async (formId) => {
    try {
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/forms/${formId}/send`);
      setForms(forms.map(f => f.id === formId ? { ...f, status: 'sent' } : f));
      alert('Score sent to candidate successfully!');
    } catch (err) {
      alert('Failed to send score');
    }
  };

  const handleBulkScore = async () => {
    if (bulkScore === '' || bulkScore === undefined) {
      alert('Please enter a target score.');
      return;
    }
    setBulking(true);
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/${id}/bulk-score`, { targetScore: parseFloat(bulkScore) });
      setForms(res.data.forms);
      alert('Bulk score applied and mistakes injected for all pending forms!');
    } catch (err) {
      alert('Bulk override failed');
    } finally {
      setBulking(false);
    }
  };

  const renderField = (form, key, label, value) => {
    const isMistake = form.mistakes?.includes(key);
    return (
      <div style={{ marginBottom: '8px' }}>
        <span style={{ color: 'var(--text-muted)' }}>{label}:</span>{' '}
        <span style={{ 
          color: isMistake ? '#ef4444' : 'inherit', 
          fontWeight: isMistake ? 'bold' : 'normal', 
          backgroundColor: isMistake ? 'rgba(239, 68, 68, 0.1)' : 'transparent', 
          padding: isMistake ? '2px 4px' : '0', 
          borderRadius: '4px' 
        }}>
          {value || 'N/A'}
        </span>
      </div>
    );
  };

  const handleSaveEarnings = async () => {
    setSaving(true);
    try {
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/${id}/earnings`, { earnings: parseFloat(earnings) });
      alert('Earnings saved successfully!');
    } catch (err) {
      alert('Failed to save earnings');
    } finally {
      setSaving(false);
    }
  };

  const handleSaveTargets = async () => {
    setSaving(true);
    try {
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/${id}/targets`, { 
        dailyTarget: parseInt(dailyTarget, 10),
        monthlyTarget: parseInt(monthlyTarget, 10)
      });
      alert('Targets saved successfully!');
    } catch (err) {
      alert('Failed to save targets');
    } finally {
      setSaving(false);
    }
  };

  if (loading || !candidate) {
    return <div style={{ textAlign: 'center', marginTop: '100px' }}>Loading Data...</div>;
  }

  return (
    <div>
      <button 
        className="btn btn-outline" 
        onClick={() => navigate('/dashboard')}
        style={{ marginBottom: '24px', padding: '8px 16px' }}
      >
        <ArrowLeft size={16} /> Back to Dashboard
      </button>

      <div style={{ display: 'grid', gridTemplateColumns: '300px 1fr', gap: '32px' }}>
        
        {/* Left Sidebar: Profile & Earnings */}
        <div>
          <div className="glass-card" style={{ position: 'sticky', top: '100px' }}>
            <h3 style={{ fontSize: '20px', fontWeight: 'bold', marginBottom: '24px', borderBottom: '1px solid rgba(255,255,255,0.1)', paddingBottom: '16px' }}>
              Candidate Overview
            </h3>
            
            <div style={{ marginBottom: '32px' }}>
              <div style={{ marginBottom: '16px' }}>
                <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)' }}>Name</span>
                <span style={{ fontWeight: '600', fontSize: '16px' }}>{candidate.name}</span>
              </div>
              <div style={{ marginBottom: '16px' }}>
                <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)' }}>Username</span>
                <span style={{ fontWeight: '600', fontSize: '16px' }}>@{candidate.username}</span>
              </div>
              <div style={{ marginBottom: '16px' }}>
                <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)' }}>Email</span>
                <span style={{ fontWeight: '600', fontSize: '16px' }}>{candidate.email}</span>
              </div>
              <div style={{ marginBottom: '16px' }}>
                <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)' }}>Last OTP (Backup)</span>
                <span style={{ fontWeight: '600', fontSize: '16px', color: '#3b82f6', letterSpacing: '2px' }}>
                  {candidate.lastOtp || 'None'}
                </span>
              </div>
              <div>
                <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>Status</span>
                <span className={`badge ${candidate.isBlocked ? 'badge-blocked' : 'badge-active'}`}>
                  {candidate.isBlocked ? 'BLOCKED' : 'ACTIVE'}
                </span>
              </div>
            </div>

            <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '16px' }}>Set Earnings</h3>
            <div className="input-group">
              <input 
                type="number" 
                step="0.01"
                className="input-field" 
                value={earnings}
                onChange={e => setEarnings(e.target.value)}
                style={{ fontSize: '24px', fontWeight: 'bold', color: '#4ade80', marginBottom: '8px' }}
              />
            </div>
            
            <button 
              className="btn btn-success" 
              style={{ width: '100%', marginBottom: '24px' }}
              onClick={handleSaveEarnings}
              disabled={saving}
            >
              <Save size={18} />
              {saving ? 'Saving...' : 'Save Earnings'}
            </button>

            <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '16px', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '16px' }}>Set Form Targets</h3>
            <div className="input-group" style={{ marginBottom: '12px' }}>
              <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>Daily Target</span>
              <input 
                type="number" 
                className="input-field" 
                value={dailyTarget}
                onChange={e => setDailyTarget(e.target.value)}
              />
            </div>
            <div className="input-group" style={{ marginBottom: '16px' }}>
              <span style={{ display: 'block', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>Monthly Target</span>
              <input 
                type="number" 
                className="input-field" 
                value={monthlyTarget}
                onChange={e => setMonthlyTarget(e.target.value)}
              />
            </div>
            
            <button 
              className="btn btn-primary" 
              style={{ width: '100%' }}
              onClick={handleSaveTargets}
              disabled={saving}
            >
              <Save size={18} />
              {saving ? 'Saving...' : 'Save Targets'}
            </button>
          </div>
        </div>

        {/* Right Content: Forms List */}
        <div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <FileText size={28} color="var(--primary)" />
              <h2 style={{ fontSize: '28px', fontWeight: 'bold' }}>Submitted Forms ({forms.filter(f => f.status !== 'archived').length})</h2>
            </div>
            
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'rgba(255,255,255,0.05)', padding: '8px 12px', borderRadius: '8px' }}>
              <span style={{ fontSize: '14px', fontWeight: 'bold', color: 'var(--text-muted)' }}>Bulk Action:</span>
              <input 
                type="number" 
                placeholder="Score %" 
                style={{ width: '80px', padding: '6px', borderRadius: '4px', border: '1px solid rgba(255,255,255,0.1)', background: 'rgba(0,0,0,0.2)', color: 'white' }} 
                value={bulkScore}
                onChange={(e) => setBulkScore(e.target.value)}
              />
              <button className="btn btn-primary" style={{ padding: '6px 12px', fontSize: '14px', background: '#eab308', color: 'black' }} onClick={handleBulkScore} disabled={bulking}>
                {bulking ? 'Applying...' : 'Set Score for All'}
              </button>
            </div>
          </div>

          {forms.filter(f => f.status !== 'archived').length === 0 ? (
            <div className="glass-card" style={{ textAlign: 'center', padding: '64px', color: 'var(--text-muted)' }}>
              This candidate has no active forms.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {forms.filter(f => f.status !== 'archived').map((form, index) => (
                <details key={index} className="glass-card" style={{ padding: '24px', cursor: 'pointer' }}>
                  <summary style={{ outline: 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <CheckCircle2 color="var(--success)" size={20} />
                      <span style={{ fontSize: '18px', fontWeight: '600' }}>
                        Serial No: {form.serialNo}
                      </span>
                    </div>
                    <span style={{ color: 'var(--text-muted)' }}>
                      {form.dateOfIssue}
                    </span>
                  </summary>
                  
                  <div style={{ marginTop: '24px', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '24px' }}>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
                      <div>
                        {renderField(form, 'title', 'Title', form.title)}
                        {renderField(form, 'firstName', 'First Name', form.firstName)}
                        {renderField(form, 'lastName', 'Last Name', form.lastName)}
                        {renderField(form, 'email', 'Email', form.email)}
                        {renderField(form, 'simNo', 'Phone (Sim No)', form.simNo)}
                        {renderField(form, 'mailingCity', 'Mailing City', form.mailingCity)}
                        {renderField(form, 'mailingCountry', 'Mailing Country', form.mailingCountry)}
                      </div>
                      <div>
                        {renderField(form, 'contractValue', 'Contract Value', form.contractValue)}
                        {renderField(form, 'accountNo', 'Account No', form.accountNo)}
                        {renderField(form, 'amountPaid', 'Amount Paid', form.amountPaid)}
                        {renderField(form, 'installment', 'Installment', form.installment)}
                        {renderField(form, 'remarks', 'Remarks', form.remarks)}
                      </div>
                    </div>
                    
                    <div style={{ marginTop: '24px', paddingTop: '16px', borderTop: '1px dashed rgba(255,255,255,0.1)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div>
                        {form.status === 'pending' || !form.status ? (
                          <span style={{ color: 'var(--text-muted)' }}>Not yet evaluated</span>
                        ) : (
                          <div>
                            <span style={{ fontSize: '18px', fontWeight: 'bold', color: form.score > 80 ? 'var(--success)' : '#ef4444' }}>
                              Accuracy Score: {form.score?.toFixed(1)}%
                            </span>
                            <span style={{ marginLeft: '12px', fontSize: '12px', padding: '4px 8px', borderRadius: '4px', backgroundColor: 'rgba(255,255,255,0.1)' }}>
                              Status: {form.status.toUpperCase()}
                            </span>
                          </div>
                        )}
                      </div>
                      
                      <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                        {(!form.status || form.status === 'pending') && (
                          <button className="btn btn-outline" onClick={() => handleEvaluate(form.id)}>
                            Run Auto-Evaluator
                          </button>
                        )}
                        
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'rgba(255,255,255,0.05)', padding: '4px 8px', borderRadius: '8px' }}>
                          <input 
                            type="number" 
                            placeholder="Score %" 
                            style={{ width: '80px', padding: '6px', borderRadius: '4px', border: '1px solid rgba(255,255,255,0.1)', background: 'rgba(0,0,0,0.2)', color: 'white' }} 
                            value={adminScores[form.id] || ''}
                            onChange={(e) => setAdminScores({...adminScores, [form.id]: e.target.value})}
                          />
                          <button className="btn btn-primary" style={{ padding: '6px 12px', fontSize: '14px', background: '#eab308', color: 'black' }} onClick={() => handleAdminScore(form.id)}>
                            Set Admin Score
                          </button>
                        </div>

                        {form.status === 'evaluated' && (
                          <button className="btn btn-success" onClick={() => handleSend(form.id)}>
                            Send to Candidate
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                </details>
              ))}
            </div>
          )}

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '24px', marginTop: '48px' }}>
            <FileText size={28} color="var(--text-muted)" />
            <h2 style={{ fontSize: '28px', fontWeight: 'bold', color: 'var(--text-muted)' }}>History / Archived Forms ({forms.filter(f => f.status === 'archived').length})</h2>
          </div>
          
          {forms.filter(f => f.status === 'archived').length === 0 ? (
            <div className="glass-card" style={{ textAlign: 'center', padding: '64px', color: 'var(--text-muted)' }}>
              No history found for this candidate.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', opacity: 0.7 }}>
              {forms.filter(f => f.status === 'archived').map((form, index) => (
                <details key={index} className="glass-card" style={{ padding: '24px', cursor: 'pointer', background: 'rgba(255, 255, 255, 0.02)' }}>
                  <summary style={{ outline: 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <CheckCircle2 color="var(--text-muted)" size={20} />
                      <span style={{ fontSize: '18px', fontWeight: '600', color: 'var(--text-muted)' }}>
                        Serial No: {form.serialNo}
                      </span>
                    </div>
                    <span style={{ color: 'var(--text-muted)' }}>
                      {form.dateOfIssue}
                    </span>
                  </summary>
                  
                  <div style={{ marginTop: '24px', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '24px' }}>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
                      <div>
                        {renderField(form, 'title', 'Title', form.title)}
                        {renderField(form, 'firstName', 'First Name', form.firstName)}
                        {renderField(form, 'lastName', 'Last Name', form.lastName)}
                        {renderField(form, 'email', 'Email', form.email)}
                        {renderField(form, 'simNo', 'Phone (Sim No)', form.simNo)}
                        {renderField(form, 'mailingCity', 'Mailing City', form.mailingCity)}
                        {renderField(form, 'mailingCountry', 'Mailing Country', form.mailingCountry)}
                      </div>
                      <div>
                        {renderField(form, 'contractValue', 'Contract Value', form.contractValue)}
                        {renderField(form, 'accountNo', 'Account No', form.accountNo)}
                        {renderField(form, 'amountPaid', 'Amount Paid', form.amountPaid)}
                        {renderField(form, 'dateOfIssue', 'Date Of Issue', form.dateOfIssue)}
                        {renderField(form, 'dateOfRenewal', 'Date Of Renewal', form.dateOfRenewal)}
                      </div>
                    </div>
                    
                    <div style={{ marginTop: '24px', padding: '16px', background: 'rgba(0,0,0,0.2)', borderRadius: '8px' }}>
                      <h4 style={{ fontWeight: 'bold', marginBottom: '8px', color: 'var(--text-muted)' }}>Evaluation Results</h4>
                      <p style={{ margin: 0, color: 'var(--text-muted)' }}>Score: {form.score !== undefined ? form.score : 'N/A'}</p>
                    </div>
                  </div>
                </details>
              ))}
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
