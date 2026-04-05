import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { CheckCircle2, BookOpen, Heart, Users, TrendingUp, Heart as HeartIcon } from 'lucide-react';

export function OnboardingFlow() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [consentChecked, setConsentChecked] = useState(false);

  const handleNext = () => {
    if (step < 3) {
      setStep(step + 1);
    } else {
      navigate('/dashboard');
    }
  };

  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center p-6">
      <div className="w-full max-w-[680px]">
        {/* Step Indicators */}
        <div className="flex justify-center gap-2 mb-8">
          {[1, 2, 3].map((i) => (
            <div
              key={i}
              className={`w-3 h-3 rounded-full transition-all ${
                i === step ? 'bg-[var(--accent-primary)] w-8' : 'bg-[var(--border-color)]'
              }`}
            />
          ))}
        </div>

        <Card>
          {step === 1 && (
            <>
              <div className="text-center mb-8">
                <div className="inline-flex w-24 h-24 rounded-full bg-[var(--bg-teal-tint)] items-center justify-center mb-6">
                  <div className="relative">
                    <div className="w-16 h-16 rounded-full border-4 border-[var(--accent-primary)] opacity-30"></div>
                    <div className="absolute inset-0 flex items-center justify-center">
                      <HeartIcon size={32} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
                    </div>
                  </div>
                </div>
                <h2 className="serif text-3xl mb-4">Before we begin</h2>
              </div>

              <div className="space-y-4 mb-8">
                <div className="flex gap-3">
                  <CheckCircle2 size={24} className="text-[var(--accent-primary)] flex-shrink-0 mt-1" strokeWidth={1.5} />
                  <p className="text-[var(--text-secondary)]">
                    <strong className="text-[var(--text-primary)]">What this app does:</strong> Helps you check in with your mental health and connects you with support resources.
                  </p>
                </div>
                <div className="flex gap-3">
                  <CheckCircle2 size={24} className="text-[var(--accent-primary)] flex-shrink-0 mt-1" strokeWidth={1.5} />
                  <p className="text-[var(--text-secondary)]">
                    <strong className="text-[var(--text-primary)]">What it doesn't do:</strong> This is not a clinical diagnosis or emergency service.
                  </p>
                </div>
                <div className="flex gap-3">
                  <CheckCircle2 size={24} className="text-[var(--accent-primary)] flex-shrink-0 mt-1" strokeWidth={1.5} />
                  <p className="text-[var(--text-secondary)]">
                    <strong className="text-[var(--text-primary)]">Your data:</strong> We store only your username and responses. Everything is encrypted and private.
                  </p>
                </div>
                <div className="flex gap-3">
                  <CheckCircle2 size={24} className="text-[var(--accent-primary)] flex-shrink-0 mt-1" strokeWidth={1.5} />
                  <p className="text-[var(--text-secondary)]">
                    <strong className="text-[var(--text-primary)]">Deleting your account:</strong> You can delete all your data anytime from settings.
                  </p>
                </div>
              </div>

              <label className="flex items-start gap-3 mb-8 cursor-pointer">
                <input
                  type="checkbox"
                  checked={consentChecked}
                  onChange={(e) => setConsentChecked(e.target.checked)}
                  className="mt-1 w-5 h-5 rounded border-[var(--border-color)] text-[var(--accent-primary)] focus:ring-2 focus:ring-[var(--focus-ring)]"
                />
                <span className="text-[var(--text-secondary)]">I understand and agree</span>
              </label>

              <Button
                variant="primary"
                fullWidth
                disabled={!consentChecked}
                onClick={handleNext}
              >
                I understand, let's continue
              </Button>
            </>
          )}

          {step === 2 && (
            <>
              <h2 className="serif text-3xl text-center mb-8">Here's what MindCare offers</h2>

              <div className="grid grid-cols-2 gap-6 mb-8">
                <div className="text-center p-6">
                  <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-4">
                    <CheckCircle2 size={28} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
                  </div>
                  <h4 className="mb-2">Check-in</h4>
                  <p className="text-sm text-[var(--text-secondary)]">Quick mental health screenings</p>
                </div>

                <div className="text-center p-6">
                  <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-4">
                    <BookOpen size={28} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
                  </div>
                  <h4 className="mb-2">Content Library</h4>
                  <p className="text-sm text-[var(--text-secondary)]">Articles, audio, and videos</p>
                </div>

                <div className="text-center p-6">
                  <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-4">
                    <TrendingUp size={28} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
                  </div>
                  <h4 className="mb-2">Mood Tracking</h4>
                  <p className="text-sm text-[var(--text-secondary)]">Track how you feel daily</p>
                </div>

                <div className="text-center p-6">
                  <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-4">
                    <Users size={28} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
                  </div>
                  <h4 className="mb-2">Psychologist Support</h4>
                  <p className="text-sm text-[var(--text-secondary)]">Book sessions with professionals</p>
                </div>
              </div>

              <Button variant="primary" fullWidth onClick={handleNext}>
                Looks good
              </Button>
            </>
          )}

          {step === 3 && (
            <>
              <h2 className="serif text-3xl text-center mb-4">One thing before you start</h2>
              <p className="text-center text-[var(--text-secondary)] mb-8">
                If you're ever in distress, help is always one tap away — no matter where you are in the app.
              </p>

              <div className="bg-[var(--bg-lavender-tint)] rounded-[var(--radius-card)] p-6 mb-8 text-center">
                <div className="inline-flex items-center gap-2 bg-[var(--crisis-accent)] text-white px-6 py-3 rounded-full mb-6">
                  <Heart size={20} fill="white" strokeWidth={1.5} />
                  <span>Need help now?</span>
                </div>
                <p className="text-sm text-[var(--text-secondary)]">
                  This button will always be visible in the bottom-right corner
                </p>
              </div>

              <div className="space-y-4 mb-8">
                <div className="p-4 border border-[var(--border-color)] rounded-lg">
                  <h4 className="mb-1">DIU Counseling Center</h4>
                  <p className="text-sm text-[var(--text-secondary)] mb-2">Available Mon-Fri, 9 AM - 5 PM</p>
                  <p className="text-[var(--accent-primary)]">+880 1234-567890</p>
                </div>

                <div className="p-4 border border-[var(--border-color)] rounded-lg">
                  <h4 className="mb-1">National Mental Health Helpline</h4>
                  <p className="text-sm text-[var(--text-secondary)] mb-2">24/7 Support Available</p>
                  <p className="text-[var(--accent-primary)]">999 (toll-free)</p>
                </div>
              </div>

              <Button variant="primary" fullWidth onClick={handleNext}>
                Take me to my dashboard
              </Button>
            </>
          )}
        </Card>
      </div>
    </div>
  );
}
