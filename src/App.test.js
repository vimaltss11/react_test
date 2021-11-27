import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Todo app', () => {
  render(<App />);
  const linkElement = screen.getByText(/Todo app/i);
  expect(linkElement).toBeInTheDocument();
});
