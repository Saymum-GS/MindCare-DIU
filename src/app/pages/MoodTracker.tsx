import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Smile, Meh, Frown, SmilePlus, AngryIcon, Check, X } from 'lucide-react';

const moods = [
  { icon: AngryIcon, label: 'Very sad', value: 1, color: 'text-[var(--risk-high)]' },
  { icon: Frown, label: 'Sad', value: 2, color: 'text-[var(--risk-medium)]' },
  { icon: Meh, label: 'Okay', value: 3, color: 'text-[var(--text-muted)]' },
  { icon: Smile, label: 'Good', value: 4, color: 'text-[var(--risk-low)]' },
  { icon: SmilePlus, label: 'Very good', value: 5, color: 'text-[var(--accent-primary)]' },
];

const mockPastMoods = [
  { date: 'Mar 29', mood: 4 },
  { date: 'Mar 30', mood: 3 },
  { date: 'Mar 31', mood: 4 },
  { date: 'Apr 1', mood: 5 },
  { date: 'Apr 2', mood: 3 },
  { date: 'Apr 3', mood: 4 },
  { date: 'Yesterday', mood: 4 },
];

export function MoodTracker() {
  const navigate = useNavigate();
  const [selectedMood, setSelectedMood] = useState<number | null>(null);
  const [note, setNote] = useState('');
  const [hasLoggedToday, setHasLoggedToday] = useState(false);
  const [todayMood, setTodayMood] = useState<number | null>(null);
  const [showRescreenBanner, setShowRescreenBanner] = useState(true);

  const handleSave = () => {
    if (selectedMood !== null) {
      setHasLoggedToday(true);
      setTodayMood(selectedMood);
      setSelectedMood(null);
      setNote('');
      localStorage.setItem('mindcare_mood_today', selectedMood.toString());
    }
  };

  const getMoodIcon = (value: number) => {
    const mood = moods.find(m => m.value === value);
    return mood ? mood.icon : Meh;
  };

  const getMoodColor = (value: number) => {
    const mood = moods.find(m => m.value === value);
    return mood ? mood.color : 'text-[var(--text-muted)]';
  };

  return (
    <div className="max-w-[900px] mx-auto px-6 py-12">
      <div className="mb-12">
        <h1 className="serif text-4xl mb-2">Your mood journal</h1>
        <p className="text-[var(--text-secondary)]">Track how you're feeling each day</p>
      </div>

      {/* Rescreen Nudge Banner */}
      {showRescreenBanner && (
        <Card className="bg-[var(--bg-teal-tint)] mb-8">
          <div className="flex items-start justify-between gap-4">
            <div>
              <h4 className="mb-2">It's been a while</h4>
              <p className="text-sm text-[var(--text-secondary)] mb-4">
                Want to take a quick check-in? It helps us understand how to support you better.
              </p>
              <Button variant="primary" onClick={() => navigate('/screening')}>
                Yes, let's go
              </Button>
            </div>
            <button
              onClick={() => setShowRescreenBanner(false)}
              className="flex-shrink-0 text-[var(--text-muted)] hover:text-[var(--accent-primary)]"
            >
              <X size={20} strokeWidth={1.5} />
            </button>
          </div>
        </Card>
      )}

      {/* Today's Log */}
      <Card className="mb-8" padding="large">
        {!hasLoggedToday ? (
          <>
            <h2 className="text-2xl mb-8 text-center">How are you feeling today?</h2>
            
            <div className="flex items-center justify-center gap-4 mb-8">
              {moods.map((mood) => {
                const Icon = mood.icon;
                const isSelected = selectedMood === mood.value;
                
                return (
                  <button
                    key={mood.value}
                    onClick={() => setSelectedMood(mood.value)}
                    className={`flex flex-col items-center gap-3 p-4 rounded-xl transition-all ${
                      isSelected
                        ? 'bg-[var(--accent-primary)] text-white scale-110'
                        : 'hover:bg-[var(--bg-teal-tint)]'
                    }`}
                  >
                    <div
                      className={`w-16 h-16 rounded-full flex items-center justify-center transition-all ${
                        isSelected ? 'bg-white' : 'bg-[var(--bg-teal-tint)]'
                      }`}
                    >
                      <Icon
                        size={32}
                        className={isSelected ? mood.color : mood.color}
                        strokeWidth={1.5}
                      />
                    </div>
                    <span className={`text-sm ${isSelected ? 'text-white' : 'text-[var(--text-muted)]'}`}>
                      {mood.label}
                    </span>
                  </button>
                );
              })}
            </div>

            {selectedMood !== null && (
              <div className="max-w-md mx-auto">
                <label htmlFor="note" className="block text-sm mb-2">
                  Add a note (optional)
                </label>
                <textarea
                  id="note"
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  placeholder="For example: Had a great study session today..."
                  rows={3}
                  maxLength={200}
                  className="w-full px-4 py-3 border border-[var(--border-color)] rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--focus-ring)] focus:border-transparent resize-none"
                />
                <div className="flex justify-between items-center mt-2 mb-6">
                  <span className="text-xs text-[var(--text-muted)]">
                    {note.length}/200
                  </span>
                </div>

                <Button variant="primary" fullWidth onClick={handleSave}>
                  Save
                </Button>
              </div>
            )}
          </>
        ) : (
          <div className="text-center py-8">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-[var(--accent-primary)] text-white mb-4">
              <Check size={32} strokeWidth={2} />
            </div>
            <h3 className="text-[var(--accent-primary)] mb-4">Logged for today ✓</h3>
            {todayMood && (() => {
              const Icon = getMoodIcon(todayMood);
              return (
                <div className="inline-flex flex-col items-center">
                  <Icon size={48} className={getMoodColor(todayMood)} strokeWidth={1.5} />
                </div>
              );
            })()}
          </div>
        )}
      </Card>

      {/* Recent Mood History */}
      <Card>
        <h3 className="mb-6">Your recent mood</h3>
        <p className="text-sm text-[var(--text-muted)] mb-6">Last 14 days</p>
        
        <div className="flex items-end justify-between gap-3 pb-4 border-b border-[var(--border-color)] mb-4">
          {mockPastMoods.map((entry, index) => {
            const Icon = getMoodIcon(entry.mood);
            return (
              <div key={index} className="flex flex-col items-center gap-2">
                <button
                  className="w-10 h-10 rounded-full hover:bg-[var(--bg-teal-tint)] flex items-center justify-center transition-colors group relative"
                  title={entry.date}
                >
                  <Icon
                    size={24}
                    className={getMoodColor(entry.mood)}
                    strokeWidth={1.5}
                  />
                </button>
                <span className="text-xs text-[var(--text-muted)]">{entry.date}</span>
              </div>
            );
          })}
        </div>

        <p className="text-xs text-[var(--text-muted)] text-center">
          Tap any day to see your note
        </p>
      </Card>
    </div>
  );
}
