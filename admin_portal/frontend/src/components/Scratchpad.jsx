import React, { useState } from 'react';

export default function Scratchpad() {
  const [count, setCount] = useState(0);

  return (
    <div className="flex flex-col items-center justify-center min-h-[80vh]">
      <div className="glass-card" style={{ maxWidth: '400px', width: '100%', textAlign: 'center' }}>
        <h2 style={{ fontSize: '24px', fontWeight: '700', marginBottom: '16px' }}>Scratchpad</h2>
        <p style={{ color: 'var(--text-muted)', marginBottom: '24px' }}>
          This is an interactive component to test DOM testing setup.
        </p>
        <div style={{ marginBottom: '24px' }}>
          <p data-testid="count-display" style={{ fontSize: '32px', fontWeight: 'bold' }}>
            {count}
          </p>
        </div>
        <div style={{ display: 'flex', gap: '16px', justifyContent: 'center' }}>
          <button 
            className="btn btn-primary" 
            onClick={() => setCount(c => c - 1)}
          >
            Decrement
          </button>
          <button 
            className="btn btn-primary" 
            onClick={() => setCount(c => c + 1)}
          >
            Increment
          </button>
        </div>
      </div>
    </div>
  );
}
