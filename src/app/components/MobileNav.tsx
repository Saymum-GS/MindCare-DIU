import { Link, useLocation } from 'react-router';
import { Home, ClipboardList, BookOpen, Heart, Users } from 'lucide-react';

export function MobileNav() {
  const location = useLocation();

  const navItems = [
    { label: 'Home', path: '/dashboard', icon: Home },
    { label: 'Check-in', path: '/screening', icon: ClipboardList },
    { label: 'Content', path: '/content', icon: BookOpen },
    { label: 'Mood', path: '/mood', icon: Heart },
    { label: 'Psychologists', path: '/psychologists', icon: Users },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-[var(--border-color)] z-40 safe-area-inset-bottom">
      <div className="flex items-center justify-around px-2 py-2">
        {navItems.map((item) => (
          <Link
            key={item.path}
            to={item.path}
            className={`flex flex-col items-center gap-1 px-3 py-2 rounded-lg transition-colors ${
              isActive(item.path)
                ? 'text-[var(--accent-primary)]'
                : 'text-[var(--text-muted)]'
            }`}
          >
            <item.icon 
              size={22} 
              strokeWidth={isActive(item.path) ? 2 : 1.5} 
            />
            <span className="text-xs">{item.label}</span>
            {isActive(item.path) && (
              <div className="absolute bottom-0 w-12 h-1 bg-[var(--accent-primary)] rounded-t-full" />
            )}
          </Link>
        ))}
      </div>
    </nav>
  );
}
