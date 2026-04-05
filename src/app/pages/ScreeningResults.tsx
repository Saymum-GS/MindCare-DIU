import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { CheckCircle2, Heart, Phone } from 'lucide-react';

export function ScreeningResults() {
  const { type } = useParams<{ type: string }>();
  const navigate = useNavigate();
  const [riskLevel, setRiskLevel] = useState<'low' | 'medium' | 'high'>('low');

  useEffect(() => {
    const storedRiskLevel = localStorage.getItem('mindcare_risk_level') as 'low' | 'medium' | 'high';
    if (storedRiskLevel) {
      setRiskLevel(storedRiskLevel);
    }
  }, []);

  const contentSuggestions = [
    { id: 1, title: 'Understanding Anxiety', type: 'Article', topic: 'Anxiety' },
    { id: 2, title: 'Relaxation Techniques', type: 'Audio', topic: 'Stress relief' },
  ];

  if (riskLevel === 'low') {
    return (
      <div className="max-w-[800px] mx-auto px-6 py-12">
        <div className="text-center mb-8">
          <div className="inline-flex w-24 h-24 rounded-full bg-[var(--risk-low)] bg-opacity-20 items-center justify-center mb-6">
            <CheckCircle2 size={48} className="text-[var(--risk-low)]" strokeWidth={1.5} />
          </div>
          
          <div className="inline-flex px-4 py-1 rounded-full bg-[var(--risk-low)] text-white text-sm mb-4">
            LOW
          </div>
          
          <p className="text-sm text-[var(--text-muted)] mb-4">Your check-in is complete</p>
          
          <h1 className="serif text-4xl mb-4">You seem to be doing well.</h1>
          
          <p className="text-[var(--text-secondary)] max-w-[600px] mx-auto leading-relaxed">
            Your score suggests you're managing well right now. That can change — and we're here whenever you need us.
          </p>
        </div>

        <div className="h-px bg-[var(--border-color)] my-12" />

        <div className="mb-8">
          <h3 className="mb-6">What might help</h3>
          <div className="grid md:grid-cols-2 gap-4 mb-6">
            {contentSuggestions.map((content) => (
              <Card 
                key={content.id}
                className="cursor-pointer hover:shadow-lg transition-shadow"
                onClick={() => navigate(`/content/${content.id}`)}
              >
                <div className="h-24 bg-gradient-to-br from-[var(--accent-primary)] to-[var(--accent-secondary)] rounded-lg mb-3 opacity-30"></div>
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-xs px-2 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]">
                    {content.type}
                  </span>
                </div>
                <h4 className="text-sm mb-1">{content.title}</h4>
                <p className="text-xs text-[var(--text-muted)]">{content.topic}</p>
              </Card>
            ))}
          </div>
          <button
            onClick={() => navigate('/content')}
            className="text-[var(--accent-primary)] hover:underline"
          >
            Browse more →
          </button>
        </div>

        <Card className="bg-[var(--bg-teal-tint)]">
          <h4 className="mb-2">Want to track how you feel day to day?</h4>
          <p className="text-sm text-[var(--text-secondary)] mb-4">
            Daily mood tracking can help you notice patterns and understand what affects your wellbeing.
          </p>
          <Button variant="secondary" onClick={() => navigate('/mood')}>
            Start tracking
          </Button>
        </Card>

        <div className="text-center mt-8">
          <p className="text-sm text-[var(--text-muted)]">
            Retake in 2 weeks
          </p>
        </div>
      </div>
    );
  }

  if (riskLevel === 'medium') {
    return (
      <div className="max-w-[800px] mx-auto px-6 py-12">
        <div className="text-center mb-8">
          <div className="inline-flex w-24 h-24 rounded-full bg-[var(--risk-medium)] bg-opacity-20 items-center justify-center mb-6">
            <div className="w-16 h-16 rounded-full bg-[var(--risk-medium)] opacity-40"></div>
          </div>
          
          <div className="inline-flex px-4 py-1 rounded-full bg-[var(--risk-medium)] text-white text-sm mb-4">
            MEDIUM
          </div>
          
          <h1 className="serif text-4xl mb-4">It sounds like things have been tough.</h1>
          
          <p className="text-[var(--text-secondary)] max-w-[600px] mx-auto leading-relaxed">
            Your answers suggest you might be experiencing some anxiety or low mood. You don't have to manage this alone.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-4 mb-8">
          <Card className="text-center cursor-pointer hover:shadow-lg transition-shadow" onClick={() => navigate('/content')}>
            <div className="w-12 h-12 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-3">
              📚
            </div>
            <h4 className="text-sm mb-2">Read helpful content</h4>
            <p className="text-xs text-[var(--text-muted)]">Articles and resources</p>
          </Card>

          <Card className="text-center cursor-pointer hover:shadow-lg transition-shadow" onClick={() => navigate('/mood')}>
            <div className="w-12 h-12 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-3">
              📊
            </div>
            <h4 className="text-sm mb-2">Track your mood</h4>
            <p className="text-xs text-[var(--text-muted)]">Daily check-ins</p>
          </Card>

          <Card className="text-center cursor-pointer hover:shadow-lg transition-shadow border-2 border-[var(--accent-primary)]" onClick={() => navigate('/psychologists')}>
            <div className="w-12 h-12 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-3">
              👥
            </div>
            <h4 className="text-sm mb-2">Talk to a psychologist</h4>
            <p className="text-xs text-[var(--text-muted)]">Professional support</p>
          </Card>
        </div>

        <Card className="bg-[var(--bg-lavender-tint)]">
          <div className="flex items-start gap-3">
            <Heart size={24} className="text-[var(--crisis-accent)] flex-shrink-0 mt-1" strokeWidth={1.5} />
            <div>
              <p className="text-sm text-[var(--text-secondary)]">
                If things feel urgent, your safety plan is always here.
              </p>
              <button
                onClick={() => navigate('/crisis')}
                className="text-[var(--crisis-accent)] hover:underline text-sm mt-2"
              >
                View safety plan →
              </button>
            </div>
          </div>
        </Card>
      </div>
    );
  }

  // High risk
  return (
    <div className="max-w-[800px] mx-auto px-6 py-12">
      <div className="bg-[var(--bg-rose-tint)] rounded-[var(--radius-card)] p-8 mb-8">
        <div className="text-center mb-6">
          <div className="inline-flex w-24 h-24 rounded-full bg-[var(--crisis-accent)] bg-opacity-20 items-center justify-center mb-6">
            <Heart size={48} className="text-[var(--crisis-accent)]" strokeWidth={1.5} fill="currentColor" />
          </div>
          
          <h1 className="serif text-3xl mb-4">Thank you for being honest with yourself.</h1>
          
          <p className="text-[var(--text-secondary)] max-w-[600px] mx-auto leading-relaxed">
            Your answers suggest you may be going through something significant. You don't need to handle this alone, and reaching out is a sign of strength.
          </p>
        </div>

        <div className="space-y-3 mb-6">
          <Button 
            variant="primary" 
            fullWidth
            className="!h-14"
            onClick={() => navigate('/psychologists')}
          >
            Talk to a psychologist today
          </Button>
          
          <Button 
            variant="crisis" 
            fullWidth
            className="!h-14"
            onClick={() => navigate('/crisis')}
          >
            View your safety plan
          </Button>
        </div>
      </div>

      <Card>
        <h4 className="mb-4">Immediate support</h4>
        
        <div className="space-y-4">
          <div className="p-4 bg-[var(--bg-teal-tint)] rounded-lg">
            <h4 className="mb-2">DIU Counseling Center</h4>
            <p className="text-2xl serif text-[var(--accent-primary)] mb-3">+880 1234-567890</p>
            <p className="text-sm text-[var(--text-secondary)] mb-3">Mon-Fri, 9 AM - 5 PM</p>
            <Button variant="primary" className="w-full">
              <Phone size={18} className="mr-2" /> Call now
            </Button>
          </div>

          <div className="p-4 border-2 border-[var(--border-color)] rounded-lg">
            <h4 className="mb-2">National Mental Health Helpline</h4>
            <p className="text-2xl serif text-[var(--accent-primary)] mb-3">999 (toll-free)</p>
            <p className="text-sm text-[var(--text-secondary)] mb-3">24/7 Support Available</p>
            <Button variant="secondary" className="w-full">
              <Phone size={18} className="mr-2" /> Call now
            </Button>
          </div>
        </div>
      </Card>

      <p className="text-center text-sm text-[var(--text-muted)] mt-8">
        Your check-in result is private. Only you can see this.
      </p>
    </div>
  );
}
