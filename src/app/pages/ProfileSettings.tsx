import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { LogOut, AlertTriangle } from 'lucide-react';

export function ProfileSettings() {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [createdDate, setCreatedDate] = useState('');
  const [syncEnabled, setSyncEnabled] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  useEffect(() => {
    const storedUsername = localStorage.getItem('mindcare_username');
    if (storedUsername) {
      setUsername(storedUsername);
    }
    // Mock creation date
    setCreatedDate('March 15, 2026');
  }, []);

  const handleSignOut = () => {
    localStorage.removeItem('mindcare_authenticated');
    navigate('/');
  };

  const handleDeleteAccount = () => {
    if (confirm('Are you absolutely sure? This will permanently delete all your data and cannot be undone.')) {
      localStorage.clear();
      navigate('/');
    }
  };

  const handleDownloadData = () => {
    alert('A download link will be sent to your email address within 24 hours.');
  };

  return (
    <div className="max-w-[800px] mx-auto px-6 py-12">
      <div className="mb-12">
        <h1 className="serif text-4xl mb-2">Your account</h1>
        <p className="text-[var(--text-secondary)]">Manage your preferences and data</p>
      </div>

      {/* Account Info */}
      <Card className="mb-6">
        <h3 className="mb-6">Account information</h3>
        
        <div className="space-y-4">
          <div className="pb-4 border-b border-[var(--border-color)]">
            <p className="text-sm text-[var(--text-muted)] mb-1">Username</p>
            <p className="text-lg">{username}</p>
            <p className="text-xs text-[var(--text-muted)] mt-2">Username cannot be changed</p>
          </div>

          <div>
            <p className="text-sm text-[var(--text-muted)] mb-1">Account created</p>
            <p>{createdDate}</p>
          </div>
        </div>
      </Card>

      {/* Privacy Settings */}
      <Card className="mb-6">
        <h3 className="mb-6">Privacy & data</h3>
        
        <div className="space-y-6">
          <div className="flex items-start justify-between gap-4">
            <div className="flex-grow">
              <h4 className="mb-2">Sync mood data to server</h4>
              <p className="text-sm text-[var(--text-secondary)]">
                When enabled, your daily mood entries are backed up to our secure servers. When disabled, mood data is stored only on this device.
              </p>
            </div>
            <button
              onClick={() => setSyncEnabled(!syncEnabled)}
              className={`flex-shrink-0 w-12 h-6 rounded-full transition-colors relative ${
                syncEnabled ? 'bg-[var(--accent-primary)]' : 'bg-[var(--border-color)]'
              }`}
            >
              <div
                className={`absolute top-0.5 w-5 h-5 bg-white rounded-full transition-transform ${
                  syncEnabled ? 'translate-x-6' : 'translate-x-0.5'
                }`}
              />
            </button>
          </div>

          <div className="pt-6 border-t border-[var(--border-color)]">
            <h4 className="mb-2">Download my data</h4>
            <p className="text-sm text-[var(--text-secondary)] mb-4">
              Request a copy of all data we have stored about you. This includes your screening results, mood entries, and account information.
            </p>
            <Button variant="secondary" onClick={handleDownloadData}>
              Request data export
            </Button>
          </div>

          <div className="pt-6 border-t border-[var(--border-color)]">
            <h4 className="mb-2 text-[var(--risk-high)]">Delete my account</h4>
            <p className="text-sm text-[var(--text-secondary)] mb-4">
              This will permanently delete your account and all associated data. This action cannot be undone.
            </p>
            
            {!showDeleteConfirm ? (
              <Button
                variant="ghost"
                className="text-[var(--risk-high)] hover:bg-[var(--bg-rose-tint)]"
                onClick={() => setShowDeleteConfirm(true)}
              >
                Delete account
              </Button>
            ) : (
              <div className="bg-[var(--bg-rose-tint)] p-4 rounded-lg">
                <div className="flex items-start gap-3 mb-4">
                  <AlertTriangle size={20} className="text-[var(--risk-high)] flex-shrink-0 mt-0.5" strokeWidth={1.5} />
                  <div>
                    <p className="text-sm mb-2">
                      <strong>Are you sure?</strong> This will:
                    </p>
                    <ul className="text-sm text-[var(--text-secondary)] space-y-1 list-disc list-inside">
                      <li>Delete all your screening results</li>
                      <li>Delete all your mood entries</li>
                      <li>Remove your username and account data</li>
                      <li>Cancel any pending psychologist bookings</li>
                    </ul>
                  </div>
                </div>
                <div className="flex gap-3">
                  <Button
                    variant="primary"
                    className="bg-[var(--risk-high)] hover:opacity-90"
                    onClick={handleDeleteAccount}
                  >
                    Yes, delete my account
                  </Button>
                  <Button
                    variant="ghost"
                    onClick={() => setShowDeleteConfirm(false)}
                  >
                    Cancel
                  </Button>
                </div>
              </div>
            )}
          </div>
        </div>
      </Card>

      {/* About */}
      <Card className="mb-6">
        <h3 className="mb-6">About this app</h3>
        
        <div className="space-y-3 text-sm">
          <div className="flex justify-between py-2 border-b border-[var(--border-color)]">
            <span className="text-[var(--text-muted)]">Version</span>
            <span>1.0.0</span>
          </div>
          <div className="flex justify-between py-2 border-b border-[var(--border-color)]">
            <span className="text-[var(--text-muted)]">Privacy policy</span>
            <a href="#" className="text-[var(--accent-primary)] hover:underline">
              View policy
            </a>
          </div>
          <div className="flex justify-between py-2">
            <span className="text-[var(--text-muted)]">Contact support</span>
            <a href="mailto:support@mindcare.diu.edu" className="text-[var(--accent-primary)] hover:underline">
              support@mindcare.diu.edu
            </a>
          </div>
        </div>
      </Card>

      {/* Sign Out */}
      <div className="text-center pt-6">
        <Button
          variant="ghost"
          onClick={handleSignOut}
          className="text-[var(--text-muted)]"
        >
          <LogOut size={18} className="mr-2" strokeWidth={1.5} />
          Sign out
        </Button>
      </div>
    </div>
  );
}
