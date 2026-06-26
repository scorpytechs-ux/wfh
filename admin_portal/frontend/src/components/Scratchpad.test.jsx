import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import Scratchpad from './Scratchpad';

describe('Scratchpad Component', () => {
  it('renders correctly', () => {
    render(<Scratchpad />);
    expect(screen.getByText('Scratchpad')).toBeInTheDocument();
    expect(screen.getByTestId('count-display')).toHaveTextContent('0');
  });

  it('increments the count when the Increment button is clicked', () => {
    render(<Scratchpad />);
    const incrementButton = screen.getByText('Increment');
    fireEvent.click(incrementButton);
    expect(screen.getByTestId('count-display')).toHaveTextContent('1');
  });

  it('decrements the count when the Decrement button is clicked', () => {
    render(<Scratchpad />);
    const decrementButton = screen.getByText('Decrement');
    fireEvent.click(decrementButton);
    expect(screen.getByTestId('count-display')).toHaveTextContent('-1');
  });
});
