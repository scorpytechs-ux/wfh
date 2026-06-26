import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { BrowserRouter } from 'react-router-dom';
import axios from 'axios';
import Login from './Login';

vi.mock('axios');

describe('Login Component', () => {
  const renderLogin = () => {
    return render(
      <BrowserRouter>
        <Login />
      </BrowserRouter>
    );
  };

  it('renders login form correctly', () => {
    renderLogin();
    expect(screen.getByText('Admin Authentication')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('admin')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('••••••••')).toBeInTheDocument();
  });

  it('shows error on failed login', async () => {
    axios.post.mockRejectedValueOnce({
      response: { data: { error: 'Invalid admin credentials' } }
    });

    renderLogin();
    
    const usernameInput = screen.getByPlaceholderText('admin');
    const passwordInput = screen.getByPlaceholderText('••••••••');
    const submitBtn = screen.getByRole('button', { name: /secure login/i });

    fireEvent.change(usernameInput, { target: { value: 'wronguser' } });
    fireEvent.change(passwordInput, { target: { value: 'wrongpass' } });
    fireEvent.click(submitBtn);

    await waitFor(() => {
      expect(screen.getByText('Invalid admin credentials')).toBeInTheDocument();
    });
  });

  it('calls login API on valid submission', async () => {
    axios.post.mockResolvedValueOnce({
      data: { success: true, token: 'fake-token' }
    });

    renderLogin();
    
    const usernameInput = screen.getByPlaceholderText('admin');
    const passwordInput = screen.getByPlaceholderText('••••••••');
    const submitBtn = screen.getByRole('button', { name: /secure login/i });

    fireEvent.change(usernameInput, { target: { value: 'admin' } });
    fireEvent.change(passwordInput, { target: { value: 'admin' } });
    fireEvent.click(submitBtn);

    await waitFor(() => {
      expect(axios.post).toHaveBeenCalledWith('http://localhost:5000/api/admin/login', {
        username: 'admin',
        password: 'admin'
      });
    });
  });
});
