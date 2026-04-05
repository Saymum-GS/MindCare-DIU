import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Brain, Heart, Clock } from 'lucide-react';

export function ScreeningSelector() {
  const navigate = useNavigate();

  const screenings = [
    {
      id: 'anxiety',
      title: 'Anxiety check-in',
      subtitle: 'GAD-7',
      description: 'Understand how anxiety may be affecting you',
      duration: '~2 minutes',
      icon: Brain,
    },
    {
      id: 'depression',
      title: 'Mood & depression check-in',
      subtitle: 'PHQ-9',
      description: 'Check in with your overall mood and wellbeing',
      duration: '~3 minutes',
      icon: Heart,
    },
  ];

  return (
    <div className="max-w-[800px] mx-auto px-6 py-12">
      <div className="text-center mb-12">
        <h1 className="serif text-4xl mb-4">Which check-in would you like to take?</h1>
        <p className="text-[var(--text-secondary)]">
          These screenings are confidential and help us understand how to support you better.
        </p>
      </div>

      <div className="grid md:grid-cols-2 gap-6 mb-8">
        {screenings.map((screening) => (
          <Card key={screening.id} className="hover:shadow-xl transition-shadow cursor-pointer" padding="large">
            <div className="flex flex-col h-full">
              <div className="w-16 h-16 rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-4">
                <screening.icon size={28} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
              </div>
              
              <h3 className="mb-1">{screening.title}</h3>
              <p className="text-sm text-[var(--text-muted)] mb-3">{screening.subtitle}</p>
              <p className="text-[var(--text-secondary)] mb-4 flex-grow">
                {screening.description}
              </p>
              
              <div className="flex items-center gap-2 text-sm text-[var(--text-muted)] mb-4">
                <Clock size={16} strokeWidth={1.5} />
                <span>{screening.duration}</span>
              </div>
              
              <Button 
                variant="primary" 
                fullWidth
                onClick={() => navigate(`/screening/${screening.id}`)}
              >
                Start
              </Button>
            </div>
          </Card>
        ))}
      </div>

      <div className="text-center space-y-4">
        <p className="text-sm text-[var(--text-secondary)]">
          Not sure? Start with anxiety.
        </p>
        <button
          onClick={() => navigate('/screening/anxiety')}
          className="text-[var(--accent-primary)] hover:underline text-sm"
        >
          Take both
        </button>
      </div>
    </div>
  );
}
