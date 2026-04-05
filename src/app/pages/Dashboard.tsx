import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { ArrowRight, Smile, Meh, Frown, SmilePlus, AngryIcon } from 'lucide-react';

export function Dashboard() {
  const navigate = useNavigate();
  const [username, setUsername] = useState('');
  const [hasCompletedScreening, setHasCompletedScreening] = useState(false);
  const [lastScreeningDate, setLastScreeningDate] = useState('');
  const [riskLevel, setRiskLevel] = useState('');

  useEffect(() => {
    const storedUsername = localStorage.getItem('mindcare_username');
    const storedRiskLevel = localStorage.getItem('mindcare_risk_level');
    const storedDate = localStorage.getItem('mindcare_screening_date');
    
    if (storedUsername) setUsername(storedUsername);
    if (storedRiskLevel) {
      setHasCompletedScreening(true);
      setRiskLevel(storedRiskLevel);
    }
    if (storedDate) setLastScreeningDate(storedDate);
  }, []);

  const getTimeOfDay = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };

  const moodEmojis = [
    { icon: AngryIcon, label: 'Very sad', color: 'text-[var(--risk-high)]' },
    { icon: Frown, label: 'Sad', color: 'text-[var(--risk-medium)]' },
    { icon: Meh, label: 'Okay', color: 'text-[var(--text-muted)]' },
    { icon: Smile, label: 'Good', color: 'text-[var(--risk-low)]' },
    { icon: SmilePlus, label: 'Very good', color: 'text-[var(--accent-primary)]' },
  ];

  const contentRecommendations = [
    {
      id: 1,
      title: 'Managing Academic Stress',
      type: 'Article',
      topic: 'Academic stress',
      duration: '5 min read',
    },
    {
      id: 2,
      title: 'Breathing Exercises',
      type: 'Audio',
      topic: 'Anxiety',
      duration: '8 min',
    },
    {
      id: 3,
      title: 'Building Resilience',
      type: 'Video',
      topic: 'Mental wellness',
      duration: '12 min',
    },
  ];

  const quickActions = [
    { label: 'Check-in', path: '/screening', icon: '📋' },
    { label: 'Find a psychologist', path: '/psychologists', icon: '👥' },
    { label: 'Safety plan', path: '/crisis', icon: '💜' },
  ];

  return (
    <div className="max-w-[var(--max-content-width)] mx-auto px-6 py-12">
      {/* Welcome Banner */}
      <div className="mb-12">
        <h1 className="serif text-4xl mb-2">{getTimeOfDay()}, {username}</h1>
        <p className="text-[var(--text-secondary)]">How can we support you today?</p>
      </div>

      {/* Main Content */}
      <div className="grid lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-8">
          {/* First Visit or Screening Card */}
          {!hasCompletedScreening ? (
            <Card className="bg-gradient-to-br from-[var(--accent-primary)] to-[var(--accent-secondary)] text-white" padding="large">
              <h2 className="serif text-3xl mb-4">Start with a check-in</h2>
              <p className="text-white/90 mb-6 leading-relaxed">
                Take a quick, confidential mental health screening to understand how you're feeling and get personalized support.
              </p>
              <Button 
                variant="secondary" 
                className="bg-white text-[var(--accent-primary)] hover:bg-white/90 border-0"
                onClick={() => navigate('/screening')}
              >
                Take the check-in <ArrowRight size={20} className="ml-2" />
              </Button>
            </Card>
          ) : (
            <Card>
              <div className="flex items-center justify-between mb-4">
                <h3>Last check-in</h3>
                <span className={`px-3 py-1 rounded-full text-sm ${
                  riskLevel === 'low' ? 'bg-[var(--risk-low)] text-white' :
                  riskLevel === 'medium' ? 'bg-[var(--risk-medium)] text-white' :
                  'bg-[var(--risk-high)] text-white'
                }`}>
                  {riskLevel.toUpperCase()}
                </span>
              </div>
              <p className="text-sm text-[var(--text-muted)] mb-4">
                Completed on {lastScreeningDate || 'March 28, 2026'}
              </p>
              <Button variant="ghost" onClick={() => navigate('/screening')}>
                Retake check-in
              </Button>
            </Card>
          )}

          {/* Mood Log */}
          <Card>
            <h3 className="mb-4">How are you feeling today?</h3>
            <div className="flex items-center justify-between gap-3 mb-6">
              {moodEmojis.map((mood, index) => (
                <button
                  key={index}
                  className="flex flex-col items-center gap-2 p-3 rounded-lg hover:bg-[var(--bg-teal-tint)] transition-colors group"
                  onClick={() => {
                    localStorage.setItem('mindcare_mood_today', mood.label);
                    navigate('/mood');
                  }}
                >
                  <mood.icon size={32} className={mood.color} strokeWidth={1.5} />
                  <span className="text-xs text-[var(--text-muted)] group-hover:text-[var(--accent-primary)]">
                    {mood.label}
                  </span>
                </button>
              ))}
            </div>
            <div className="flex gap-2 pt-4 border-t border-[var(--border-color)]">
              <div className="text-xs text-[var(--text-muted)]">Last 7 days:</div>
              {[...Array(7)].map((_, i) => (
                <div key={i} className="w-2 h-2 rounded-full bg-[var(--accent-primary)] opacity-50"></div>
              ))}
            </div>
          </Card>

          {/* Content Recommendations */}
          <div>
            <h3 className="mb-4">Suggested for you</h3>
            <div className="grid md:grid-cols-3 gap-4">
              {contentRecommendations.map((content) => (
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
                    <span className="text-xs text-[var(--text-muted)]">{content.duration}</span>
                  </div>
                  <h4 className="text-sm mb-1">{content.title}</h4>
                  <p className="text-xs text-[var(--text-muted)]">{content.topic}</p>
                </Card>
              ))}
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Quick Access */}
          <Card>
            <h4 className="mb-4">Quick access</h4>
            <div className="space-y-3">
              {quickActions.map((action) => (
                <button
                  key={action.path}
                  onClick={() => navigate(action.path)}
                  className="w-full flex items-center gap-3 p-3 rounded-lg bg-[var(--bg-teal-tint)] hover:bg-[var(--accent-primary)] hover:text-white transition-all text-left"
                >
                  <span className="text-2xl">{action.icon}</span>
                  <span>{action.label}</span>
                </button>
              ))}
            </div>
          </Card>

          {/* High Risk Alert (if applicable) */}
          {riskLevel === 'high' && (
            <Card className="bg-[var(--bg-rose-tint)]">
              <h4 className="mb-3">We're here for you</h4>
              <p className="text-sm text-[var(--text-secondary)] mb-4">
                Your last check-in flagged some concerns. Your safety plan and psychologist booking are ready whenever you are.
              </p>
              <div className="flex flex-col gap-2">
                <Button variant="primary" onClick={() => navigate('/psychologists')}>
                  Talk to a psychologist
                </Button>
                <Button variant="ghost" onClick={() => navigate('/crisis')}>
                  View safety plan
                </Button>
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}
