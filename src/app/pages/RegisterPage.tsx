import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Lock } from 'lucide-react';
import { Card } from '../components/Card';
import { Button } from '../components/Button';

export function RegisterPage() {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [useStudentId, setUseStudentId] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (username.trim()) {
      localStorage.setItem('mindcare_username', username);
      localStorage.setItem('mindcare_authenticated', 'true');
      navigate('/onboarding');
    }
  };

  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center p-6">
      <div className="w-full max-w-[480px]">
        <Card>
          <div className="flex flex-col items-center text-center mb-8">
            <div className="w-12 h-12 rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-3">
              <Lock size={20} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
            </div>
            <p className="text-sm text-[var(--text-muted)]">Your identity is protected</p>
          </div>

          <h1 className="serif text-4xl text-center mb-4">Create your private space</h1>
          <p className="text-center text-[var(--text-secondary)] text-sm mb-8">
            We don't need your name. Just choose a username you'll remember.
          </p>

          <form onSubmit={handleSubmit}>
            <div className="mb-6">
              <label htmlFor="username" className="block mb-2 text-sm">
                {useStudentId ? 'Student ID' : 'Choose a username'}
              </label>
              <input
                type={useStudentId ? 'password' : 'text'}
                id="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full px-4 py-3 border border-[var(--border-color)] rounded-[var(--radius-input)] focus:outline-none focus:ring-2 focus:ring-[var(--focus-ring)] focus:border-transparent"
                placeholder={useStudentId ? 'Enter your student ID' : 'e.g., ocean_breeze'}
                required
              />
              <p className="text-xs text-[var(--text-muted)] mt-2">
                {useStudentId 
                  ? 'Your ID is encrypted and never stored in plain text.' 
                  : 'This is the only identifier we store.'}
              </p>
            </div>

            <button
              type="button"
              onClick={() => setUseStudentId(!useStudentId)}
              className="text-sm text-[var(--accent-primary)] hover:underline mb-6 block"
            >
              {useStudentId ? 'Use a username instead' : 'Or continue with your Student ID'}
            </button>

            <Button type="submit" variant="primary" fullWidth>
              Create my account
            </Button>
          </form>

          <div className="text-center mt-6">
            <p className="text-sm text-[var(--text-secondary)]">
              Already have an account?{' '}
              <button
                onClick={() => navigate('/signin')}
                className="text-[var(--accent-primary)] hover:underline"
              >
                Sign in
              </button>
            </p>
          </div>

          <div className="mt-8 pt-6 border-t border-[var(--border-color)] text-center">
            <a href="#" className="text-sm text-[var(--text-muted)] hover:text-[var(--accent-primary)]">
              Read our privacy policy
            </a>
          </div>
        </Card>
      </div>
    </div>
  );
}
