import { useState, useEffect } from 'react';
import { useParams, useLocation, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { ArrowLeft, Save, FileText, CheckCircle2 } from 'lucide-react';

export default function Review() {
  const { id } = useParams();
  const location = useLocation();
  const navigate = useNavigate();
  const [candidate, setCandidate] = useState(location.state?.candidate || null);
  const [activeForms, setActiveForms] = useState([]);
  const [archivedForms, setArchivedForms] = useState([]);
  const [overallScore, setOverallScore] = useState(candidate?.stats?.overallScore || 0);
  const [activeCount, setActiveCount] = useState(candidate?.stats?.activeCount || 0);
  const [archivedCount, setArchivedCount] = useState(candidate?.stats?.archivedCount || 0);
  const [earnings, setEarnings] = useState(candidate?.earnings || 0);
  const [dailyTarget, setDailyTarget] = useState(candidate?.dailyTarget || 0);
  const [monthlyTarget, setMonthlyTarget] = useState(candidate?.monthlyTarget || 0);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [adminScores, setAdminScores] = useState({});
  const [bulkScore, setBulkScore] = useState('');
  const [bulking, setBulking] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [archivedPage, setArchivedPage] = useState(1);
  const formsPerPage = 50;

  useEffect(() => {
    if (!localStorage.getItem('adminToken')) {
      navigate('/login');
      return;
    }
    
    // Always fetch latest to ensure data is fresh
    // Fetch active forms
    const fetchActive = () => {
      setLoading(true);
      axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/forms?page=${currentPage}&limit=${formsPerPage}&status=active`)
        .then(res => {
          setActiveForms(res.data.forms);
          if (res.data.stats) {
            setOverallScore(res.data.stats.overallScore);
            setActiveCount(res.data.stats.activeCount);
            setArchivedCount(res.data.stats.archivedCount);
          }
        })
        .finally(() => setLoading(false));
    };

    const fetchArchived = () => {
      axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/forms?page=${archivedPage}&limit=${formsPerPage}&status=archived`)
        .then(res => setArchivedForms(res.data.forms));
    };

    fetchActive();
    fetchArchived();
  }, [id, navigate, currentPage, archivedPage]);

  const fetchActiveRef = async () => {
      const res = await axios.get(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/forms?page=${currentPage}&limit=${formsPerPage}&status=active`);
      setActiveForms(res.data.forms);
      if (res.data.stats) {
        setOverallScore(res.data.stats.overallScore);
        setActiveCount(res.data.stats.activeCount);
        setArchivedCount(res.data.stats.archivedCount);
      }
  };

  const handleEvaluate = async (formId) => {
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/forms/${formId}/evaluate`);
      setActiveForms(activeForms.map(f => f.id === formId ? { ...f, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));
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
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/forms/${formId}/admin-score`, { targetScore: parseFloat(targetScore) });
      setActiveForms(activeForms.map(f => f.id === formId ? { ...f, ...res.data.updatedFields, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));
      alert('Admin score applied and mistakes injected!');
    } catch (err) {
      alert('Admin override failed');
    }
  };

  const handleSend = async (formId) => {
    try {
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/forms/${formId}/send`);
      setActiveForms(activeForms.map(f => f.id === formId ? { ...f, status: 'sent' } : f));
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
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/bulk-score`, { targetScore: parseFloat(bulkScore) });
      await fetchActiveRef();
      alert('Bulk score applied and mistakes injected for all pending forms!');
    } catch (err) {
      alert('Bulk override failed');
    } finally {
      setBulking(false);
    }
  };

  const handleBulkEvaluate = async () => {
    setBulking(true);
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/bulk-evaluate`);
      await fetchActiveRef();
      alert('Bulk auto-evaluation completed!');
    } catch (err) {
      alert('Bulk auto-evaluation failed');
    } finally {
      setBulking(false);
    }
  };

  const handleBulkSend = async () => {
    setBulking(true);
    try {
      const res = await axios.post(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/bulk-send`);
      await fetchActiveRef();
      alert('Bulk send completed!');
    } catch (err) {
      alert('Bulk send failed');
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
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/earnings`, { earnings: parseFloat(earnings) });
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
      await axios.put(`${import.meta.env.VITE_API_URL || 'https://wfh-2.onrender.com'}/api/candidates/${id}/targets`, { 
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

  const formFields = [
    { key: 'serialNo', label: 'Serial No' },
    { key: 'title', label: 'Title' },
    { key: 'firstName', label: 'First Name' },
    { key: 'lastName', label: 'Last Name' },
    { key: 'initial', label: 'Initial' },
    { key: 'email', label: 'Email' },
    { key: 'fatherName', label: 'Father Name' },
    { key: 'dob', label: 'DOB' },
    { key: 'gender', label: 'Gender' },
    { key: 'profession', label: 'Profession' },
    { key: 'mailingStreet', label: 'Mailing Street' },
    { key: 'mailingCity', label: 'Mailing City' },
    { key: 'mailingPostal', label: 'Mailing Postal Code' },
    { key: 'mailingCountry', label: 'Mailing Country' },
    { key: 'serviceProvider', label: 'Service Provider' },
    { key: 'fileNo', label: 'File No' },
    { key: 'referenceNo', label: 'Reference No' },
    { key: 'simNo', label: 'Sim No' },
    { key: 'typeOfNetwork', label: 'Type Of Network' },
    { key: 'cellModelNo', label: 'Cell Model No' },
    { key: 'imsi1', label: 'IMSI 1' },
    { key: 'imsi2', label: 'IMSI 2' },
    { key: 'typeOfPlan', label: 'Type Of Plan' },
    { key: 'creditCardType', label: 'Credit Card Type' },
    { key: 'contractValue', label: 'Contract Value' },
    { key: 'dateOfIssue', label: 'Date Of Issue' },
    { key: 'dateOfRenewal', label: 'Date Of Renewal' },
    { key: 'installment', label: 'Installment' },
    { key: 'amountInWords', label: 'Amount In Words' },
    { key: 'remarks', label: 'Remarks' }
  ];

  if (loading || !candidate) {
    return <div style={{ textAlign: 'center', marginTop: '100px' }}>Loading Data...</div>;
  }

  
  

  const currentForms = activeForms;
  const totalPages = Math.ceil(activeCount / formsPerPage);

  
  const indexOfLastArchived = archivedPage * formsPerPage;
  const indexOfFirstArchived = indexOfLastArchived - formsPerPage;
  const currentArchivedForms = archivedForms.slice(indexOfFirstArchived, indexOfLastArchived);
  const totalArchivedPages = Math.ceil(archivedForms.length / formsPerPage);

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

            <h3 style={{ fontSize: '16px', fontWeight: 'bold', marginBottom: '16px', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '16px' }}>Set Form Target</h3>
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
              {saving ? 'Saving...' : 'Save Target'}
            </button>
          </div>
        </div>

        {/* Right Content: Forms List */}
        <div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <FileText size={28} color="var(--primary)" />
              <h2 style={{ fontSize: '28px', fontWeight: 'bold' }}>Submitted Forms ({activeCount})</h2>
            </div>
            
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'rgba(255,255,255,0.05)', padding: '8px 12px', borderRadius: '8px', flexWrap: 'wrap' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginRight: '16px', borderRight: '1px solid rgba(255,255,255,0.1)', paddingRight: '16px' }}>
                <span style={{ fontSize: '14px', fontWeight: 'bold', color: 'var(--text-muted)' }}>Project Score:</span>
                <span style={{ fontSize: '20px', fontWeight: 'bold', color: parseFloat(overallScore) >= 80 ? '#4ade80' : '#ef4444' }}>{overallScore}%</span>
              </div>
              <span style={{ fontSize: '14px', fontWeight: 'bold', color: 'var(--text-muted)' }}>Bulk Action:</span>
              
              <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '14px' }} onClick={handleBulkEvaluate} disabled={bulking}>
                Auto Evaluate All
              </button>

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

              <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '14px' }} onClick={handleBulkSend} disabled={bulking}>
                Send All to Candidate
              </button>
            </div>
          </div>

          {activeForms.length === 0 ? (
            <div className="glass-card" style={{ textAlign: 'center', padding: '64px', color: 'var(--text-muted)' }}>
              This candidate has no active forms.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {currentForms.map((form, index) => (
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
                        {formFields.slice(0, 15).map(field => (
                          <div key={field.key}>
                            {renderField(form, field.key, field.label, form[field.key])}
                          </div>
                        ))}
                      </div>
                      <div>
                        {formFields.slice(15).map(field => (
                          <div key={field.key}>
                            {renderField(form, field.key, field.label, form[field.key])}
                          </div>
                        ))}
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
              
              {totalPages > 1 && (
                <div style={{ display: 'flex', justifyContent: 'center', gap: '16px', marginTop: '24px', alignItems: 'center' }}>
                  <button 
                    className="btn btn-outline" 
                    onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                  >
                    Previous
                  </button>
                  <span>
                    Page {currentPage} of {totalPages}
                  </span>
                  <button 
                    className="btn btn-outline" 
                    onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                    disabled={currentPage === totalPages}
                  >
                    Next
                  </button>
                </div>
              )}
            </div>
          )}

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '24px', marginTop: '48px' }}>
            <FileText size={28} color="var(--text-muted)" />
            <h2 style={{ fontSize: '28px', fontWeight: 'bold', color: 'var(--text-muted)' }}>History / Archived Forms ({archivedForms.length})</h2>
          </div>
          
          {archivedForms.length === 0 ? (
            <div className="glass-card" style={{ textAlign: 'center', padding: '64px', color: 'var(--text-muted)' }}>
              No history found for this candidate.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', opacity: 0.7 }}>
              {currentArchivedForms.map((form, index) => (
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
                        {formFields.slice(0, 15).map(field => (
                          <div key={field.key}>
                            {renderField(form, field.key, field.label, form[field.key])}
                          </div>
                        ))}
                      </div>
                      <div>
                        {formFields.slice(15).map(field => (
                          <div key={field.key}>
                            {renderField(form, field.key, field.label, form[field.key])}
                          </div>
                        ))}
                      </div>
                    </div>
                    
                    <div style={{ marginTop: '24px', padding: '16px', background: 'rgba(0,0,0,0.2)', borderRadius: '8px' }}>
                      <h4 style={{ fontWeight: 'bold', marginBottom: '8px', color: 'var(--text-muted)' }}>Evaluation Results</h4>
                      <p style={{ margin: 0, color: 'var(--text-muted)' }}>Score: {form.score !== undefined ? form.score : 'N/A'}</p>
                    </div>
                  </div>
                </details>
              ))}
              
              {totalArchivedPages > 1 && (
                <div style={{ display: 'flex', justifyContent: 'center', gap: '16px', marginTop: '24px', alignItems: 'center' }}>
                  <button 
                    className="btn btn-outline" 
                    onClick={() => setArchivedPage(p => Math.max(1, p - 1))}
                    disabled={archivedPage === 1}
                  >
                    Previous
                  </button>
                  <span>
                    Page {archivedPage} of {totalArchivedPages}
                  </span>
                  <button 
                    className="btn btn-outline" 
                    onClick={() => setArchivedPage(p => Math.min(totalArchivedPages, p + 1))}
                    disabled={archivedPage === totalArchivedPages}
                  >
                    Next
                  </button>
                </div>
              )}
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
