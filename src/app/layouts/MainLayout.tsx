import { Outlet } from 'react-router';
import { Navbar } from '../components/Navbar';
import { CrisisFAB } from '../components/CrisisFAB';
import { MobileNav } from '../components/MobileNav';
import { useState, useEffect } from 'react';

export function MainLayout() {
  // Mock authentication state - in real app, this would come from auth context
  const [username, setUsername] = useState<string>('');
  const [highRisk, setHighRisk] = useState(false);

  useEffect(() => {
    // Check local storage for user data
    const storedUsername = localStorage.getItem('mindcare_username');
    const storedRiskLevel = localStorage.getItem('mindcare_risk_level');
    
    if (storedUsername) {
      setUsername(storedUsername);
    }
    
    if (storedRiskLevel === 'high') {
      setHighRisk(true);
    }
  }, []);

  return (
    <div className="min-h-screen bg-[var(--bg-primary)]">
      <Navbar isAuthenticated={true} username={username} />
      <main className="pb-20 md:pb-0">
        <Outlet />
      </main>
      <MobileNav />
      <CrisisFAB highRisk={highRisk} />
    </div>
  );
}