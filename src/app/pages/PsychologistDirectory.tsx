import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Lock, X } from 'lucide-react';

const psychologists = [
  {
    id: 1,
    name: 'Dr. Ayesha Rahman',
    initials: 'AR',
    specializations: ['Anxiety', 'Academic stress', 'Depression'],
    bio: 'Dr. Rahman has 8 years of experience working with university students. She specializes in cognitive behavioral therapy and mindfulness-based approaches. Her warm, non-judgmental style helps students feel comfortable opening up about their challenges.',
    available: true,
    nextAvailable: 'This week',
  },
  {
    id: 2,
    name: 'Dr. Kamal Hossain',
    initials: 'KH',
    specializations: ['Depression', 'Grief', 'Relationships'],
    bio: 'Dr. Hossain brings a compassionate approach to supporting students through difficult transitions. With 10 years of clinical experience, he helps students develop coping strategies and build resilience. His areas of focus include mood disorders and interpersonal challenges.',
    available: true,
    nextAvailable: 'This week',
  },
  {
    id: 3,
    name: 'Dr. Nusrat Islam',
    initials: 'NI',
    specializations: ['Academic stress', 'Self-esteem', 'Life transitions'],
    bio: 'Dr. Islam specializes in helping students navigate the challenges of university life. She uses evidence-based therapies to address perfectionism, imposter syndrome, and adjustment difficulties. Her collaborative approach empowers students to discover their own strengths.',
    available: false,
    nextAvailable: 'April 12',
  },
  {
    id: 4,
    name: 'Dr. Rashed Ahmed',
    initials: 'RA',
    specializations: ['Anxiety', 'Trauma', 'Sleep issues'],
    bio: 'Dr. Ahmed has extensive training in treating anxiety disorders and trauma. He creates a safe, supportive environment where students can work through difficult experiences. His integrative approach combines traditional therapy with relaxation techniques.',
    available: true,
    nextAvailable: 'This week',
  },
];

export function PsychologistDirectory() {
  const navigate = useNavigate();
  const [selectedPsychologist, setSelectedPsychologist] = useState<number | null>(null);

  const selected = selectedPsychologist
    ? psychologists.find(p => p.id === selectedPsychologist)
    : null;

  return (
    <div className="max-w-[var(--max-content-width)] mx-auto px-6 py-12">
      <div className="mb-8">
        <h1 className="serif text-4xl mb-2">Find support</h1>
        <p className="text-[var(--text-secondary)]">Our university psychologists are here for you</p>
      </div>

      {/* Callout Strip */}
      <Card className="bg-[var(--bg-teal-tint)] mb-8">
        <div className="flex items-center gap-3">
          <Lock size={24} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
          <p className="text-[var(--text-secondary)]">
            <strong className="text-[var(--text-primary)]">Sessions are confidential.</strong> Booking is just a request — no commitment.
          </p>
        </div>
      </Card>

      {/* Psychologist Cards */}
      <div className="grid md:grid-cols-2 gap-6">
        {psychologists.map((psych) => (
          <Card
            key={psych.id}
            className="cursor-pointer hover:shadow-xl transition-all"
            onClick={() => setSelectedPsychologist(psych.id)}
          >
            <div className="flex gap-4 mb-4">
              <div className="w-16 h-16 rounded-full bg-[var(--accent-primary)] text-white flex items-center justify-center text-xl flex-shrink-0">
                {psych.initials}
              </div>
              <div className="flex-grow">
                <h3 className="mb-1">{psych.name}</h3>
                <div className="flex flex-wrap gap-2">
                  {psych.specializations.map((spec) => (
                    <span
                      key={spec}
                      className="text-xs px-2 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]"
                    >
                      {spec}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            <p className="text-sm text-[var(--text-secondary)] mb-4 line-clamp-2">
              {psych.bio}
            </p>

            <div className="flex items-center justify-between">
              <span
                className={`text-sm ${
                  psych.available ? 'text-[var(--risk-low)]' : 'text-[var(--text-muted)]'
                }`}
              >
                {psych.available ? `Available ${psych.nextAvailable}` : `Next available ${psych.nextAvailable}`}
              </span>
              <Button variant="secondary" onClick={() => setSelectedPsychologist(psych.id)}>
                View details
              </Button>
            </div>
          </Card>
        ))}
      </div>

      {/* Detail Panel (Modal-like overlay) */}
      {selected && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-6" onClick={() => setSelectedPsychologist(null)}>
          <div className="bg-white rounded-[var(--radius-card)] max-w-2xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-[var(--border-color)] p-6 flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-16 h-16 rounded-full bg-[var(--accent-primary)] text-white flex items-center justify-center text-xl">
                  {selected.initials}
                </div>
                <div>
                  <h2 className="text-2xl">{selected.name}</h2>
                  <span className={`text-sm ${selected.available ? 'text-[var(--risk-low)]' : 'text-[var(--text-muted)]'}`}>
                    {selected.available ? `Available ${selected.nextAvailable}` : `Next available ${selected.nextAvailable}`}
                  </span>
                </div>
              </div>
              <button
                onClick={() => setSelectedPsychologist(null)}
                className="text-[var(--text-muted)] hover:text-[var(--accent-primary)]"
              >
                <X size={24} strokeWidth={1.5} />
              </button>
            </div>

            <div className="p-6">
              <div className="mb-6">
                <h4 className="mb-3">Specializations</h4>
                <div className="flex flex-wrap gap-2">
                  {selected.specializations.map((spec) => (
                    <span
                      key={spec}
                      className="px-3 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]"
                    >
                      {spec}
                    </span>
                  ))}
                </div>
              </div>

              <div className="mb-8">
                <h4 className="mb-3">About</h4>
                <p className="text-[var(--text-secondary)] leading-relaxed">{selected.bio}</p>
              </div>

              <div className="mb-6">
                <h4 className="mb-3">Available times</h4>
                <div className="grid grid-cols-7 gap-2 mb-4">
                  {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day, index) => (
                    <div key={day} className="text-center">
                      <div className="text-xs text-[var(--text-muted)] mb-2">{day}</div>
                      <button
                        className={`w-full px-2 py-2 rounded-lg text-xs ${
                          index < 5
                            ? 'bg-[var(--accent-primary)] text-white hover:bg-[var(--accent-hover)]'
                            : 'bg-[var(--border-color)] text-[var(--text-muted)] cursor-not-allowed'
                        }`}
                        disabled={index >= 5}
                      >
                        {index < 5 ? '10 AM' : '—'}
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              <Button
                variant="primary"
                fullWidth
                onClick={() => navigate(`/booking/${selected.id}`)}
              >
                Request a session
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
