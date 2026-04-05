import { Link, useNavigate, useLocation } from 'react-router';
import { Home, ClipboardList, BookOpen, Heart, Users, User, Menu, X } from 'lucide-react';
import { Button } from './Button';
import { useState } from 'react';

interface NavbarProps {
  isAuthenticated?: boolean;
  username?: string;
}

export function Navbar({ isAuthenticated = false, username }: NavbarProps) {
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  const navItems = [
    { label: 'Home', path: '/dashboard', icon: Home },
    { label: 'Check-in', path: '/screening', icon: ClipboardList },
    { label: 'Content', path: '/content', icon: BookOpen },
    { label: 'Mood', path: '/mood', icon: Heart },
    { label: 'Psychologists', path: '/psychologists', icon: Users },
  ];

  const isActive = (path: string) => location.pathname === path;

  if (!isAuthenticated) {
    return (
      <nav className="bg-[var(--bg-surface)] border-b border-[var(--border-color)] sticky top-0 z-50 shadow-sm">
        <div className="max-w-[var(--max-content-width)] mx-auto px-6 h-16 flex items-center justify-between">
          <Link to="/" className="flex items-center gap-2">
            <span className="serif text-2xl text-[var(--text-primary)]">MindCare</span>
            <span className="text-[var(--accent-primary)]">@DIU</span>
          </Link>
          
          <div className="hidden md:flex items-center gap-8">
            <a href="#how-it-works" className="text-[var(--text-secondary)] hover:text-[var(--accent-primary)] transition-colors">
              How it works
            </a>
            <a href="#for-students" className="text-[var(--text-secondary)] hover:text-[var(--accent-primary)] transition-colors">
              For students
            </a>
            <a href="#privacy" className="text-[var(--text-secondary)] hover:text-[var(--accent-primary)] transition-colors">
              Privacy
            </a>
            
            <div className="flex items-center gap-3">
              <Button variant="ghost" onClick={() => navigate('/signin')}>
                Sign in
              </Button>
              <Button variant="primary" onClick={() => navigate('/register')}>
                Get started
              </Button>
            </div>
          </div>

          {/* Mobile menu button */}
          <button
            className="md:hidden text-[var(--text-primary)]"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-[var(--border-color)] bg-white">
            <div className="px-6 py-4 space-y-4">
              <a href="#how-it-works" className="block text-[var(--text-secondary)] hover:text-[var(--accent-primary)]">
                How it works
              </a>
              <a href="#for-students" className="block text-[var(--text-secondary)] hover:text-[var(--accent-primary)]">
                For students
              </a>
              <a href="#privacy" className="block text-[var(--text-secondary)] hover:text-[var(--accent-primary)]">
                Privacy
              </a>
              <div className="flex flex-col gap-3 pt-4 border-t border-[var(--border-color)]">
                <Button variant="ghost" onClick={() => navigate('/signin')} fullWidth>
                  Sign in
                </Button>
                <Button variant="primary" onClick={() => navigate('/register')} fullWidth>
                  Get started
                </Button>
              </div>
            </div>
          </div>
        )}
      </nav>
    );
  }

  return (
    <nav className="bg-[var(--bg-surface)] border-b border-[var(--border-color)] sticky top-0 z-50 shadow-sm">
      <div className="max-w-[var(--max-content-width)] mx-auto px-6 h-16 flex items-center justify-between">
        <Link to="/dashboard" className="flex items-center gap-2">
          <span className="serif text-2xl text-[var(--text-primary)]">MindCare</span>
          <span className="text-[var(--accent-primary)]">@DIU</span>
        </Link>
        
        <div className="hidden md:flex items-center gap-1">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${
                isActive(item.path)
                  ? 'text-[var(--accent-primary)] bg-[var(--bg-teal-tint)]'
                  : 'text-[var(--text-secondary)] hover:text-[var(--accent-primary)] hover:bg-[var(--bg-teal-tint)]'
              }`}
            >
              <item.icon size={18} strokeWidth={1.5} />
              <span>{item.label}</span>
            </Link>
          ))}
        </div>
        
        <div className="flex items-center gap-3">
          <Button 
            variant="crisis" 
            onClick={() => navigate('/crisis')}
            className="hidden md:flex"
          >
            Need help now?
          </Button>

          {/* Mobile crisis button */}
          <button
            onClick={() => navigate('/crisis')}
            className="md:hidden w-10 h-10 rounded-full bg-[var(--crisis-accent)] text-white flex items-center justify-center"
          >
            <Heart size={20} fill="white" strokeWidth={1.5} />
          </button>
          
          <button
            onClick={() => navigate('/profile')}
            className="flex items-center gap-2 px-3 py-2 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)] hover:bg-[var(--accent-primary)] hover:text-white transition-all"
          >
            <User size={16} />
            <span className="text-sm hidden sm:inline">{username || 'User'}</span>
          </button>
        </div>
      </div>
    </nav>
  );
}