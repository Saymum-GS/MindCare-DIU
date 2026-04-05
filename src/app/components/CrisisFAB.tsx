import { useNavigate } from 'react-router';
import { Heart } from 'lucide-react';

interface CrisisFABProps {
  highRisk?: boolean;
}

export function CrisisFAB({ highRisk = false }: CrisisFABProps) {
  const navigate = useNavigate();

  return (
    <button
      onClick={() => navigate('/crisis')}
      className={`fixed bottom-6 right-6 z-50 bg-[var(--crisis-accent)] text-white px-6 py-3 rounded-full shadow-lg hover:opacity-90 transition-all flex items-center gap-2 ${
        highRisk ? 'pulse-subtle' : ''
      }`}
    >
      <Heart size={20} fill="white" strokeWidth={1.5} />
      <span className="hidden md:inline">Need help now?</span>
    </button>
  );
}
