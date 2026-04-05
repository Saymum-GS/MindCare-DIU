import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';

export function SignInPage() {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (username.trim()) {
      localStorage.setItem('mindcare_username', username);
      localStorage.setItem('mindcare_authenticated', 'true');
      navigate('/dashboard');
    }
  };

  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center p-6">
      <div className="w-full max-w-[480px]">
        <Card>
          <h1 className="serif text-4xl text-center mb-6">Welcome back</h1>

          <form onSubmit={handleSubmit}>
            <div className="mb-6">
              <label htmlFor="username" className="block mb-2 text-sm">
                Username or Student ID
              </label>
              <input
                type="text"
                id="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full px-4 py-3 border border-[var(--border-color)] rounded-[var(--radius-input)] focus:outline-none focus:ring-2 focus:ring-[var(--focus-ring)] focus:border-transparent"
                placeholder="Enter your username"
                required
              />
            </div>

            <Button type="submit" variant="primary" fullWidth>
              Sign in
            </Button>
          </form>

          <div className="text-center mt-6">
            <button className="text-sm text-[var(--text-muted)] hover:text-[var(--accent-primary)]">
              Forgot your username? Contact support
            </button>
          </div>
        </Card>
      </div>
    </div>
  );
}
