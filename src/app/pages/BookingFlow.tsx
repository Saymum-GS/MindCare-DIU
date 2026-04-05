import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Check, CheckCircle2 } from 'lucide-react';

const psychologists: Record<string, any> = {
  '1': { name: 'Dr. Ayesha Rahman', initials: 'AR' },
  '2': { name: 'Dr. Kamal Hossain', initials: 'KH' },
  '3': { name: 'Dr. Nusrat Islam', initials: 'NI' },
  '4': { name: 'Dr. Rashed Ahmed', initials: 'RA' },
};

const weekDays = [
  { day: 'Mon', date: 'Apr 7', slots: ['10:00 AM', '2:00 PM', '4:00 PM'] },
  { day: 'Tue', date: 'Apr 8', slots: ['10:00 AM', '11:00 AM'] },
  { day: 'Wed', date: 'Apr 9', slots: ['2:00 PM', '3:00 PM', '4:00 PM'] },
  { day: 'Thu', date: 'Apr 10', slots: ['10:00 AM', '2:00 PM'] },
  { day: 'Fri', date: 'Apr 11', slots: ['11:00 AM', '3:00 PM'] },
  { day: 'Sat', date: 'Apr 12', slots: [] },
  { day: 'Sun', date: 'Apr 13', slots: [] },
];

export function BookingFlow() {
  const { psychologistId } = useParams<{ psychologistId: string }>();
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [selectedDay, setSelectedDay] = useState<string | null>(null);
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const [message, setMessage] = useState('');

  const psychologist = psychologistId ? psychologists[psychologistId] : null;

  if (!psychologist) {
    return null;
  }

  const handleSlotSelect = (day: string, slot: string) => {
    setSelectedDay(day);
    setSelectedSlot(slot);
  };

  const handleSubmit = () => {
    // In a real app, this would send the booking request
    setStep(3);
  };

  if (step === 1) {
    return (
      <div className="max-w-[900px] mx-auto px-6 py-12">
        <div className="mb-8">
          <h1 className="serif text-4xl mb-2">Select a time slot</h1>
          <p className="text-[var(--text-secondary)]">Choose a convenient time for your session</p>
        </div>

        {selectedDay && selectedSlot && (
          <Card className="bg-[var(--bg-teal-tint)] mb-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-[var(--text-muted)] mb-1">Selected time</p>
                <p className="text-lg">
                  <strong>{selectedDay}</strong> at {selectedSlot}
                </p>
              </div>
              <Check size={24} className="text-[var(--accent-primary)]" strokeWidth={2} />
            </div>
          </Card>
        )}

        <div className="grid grid-cols-7 gap-3 mb-8">
          {weekDays.map((dayData) => (
            <div key={dayData.day}>
              <div className="text-center mb-3">
                <div className="text-sm text-[var(--text-secondary)]">{dayData.day}</div>
                <div className="text-xs text-[var(--text-muted)]">{dayData.date}</div>
              </div>
              <div className="space-y-2">
                {dayData.slots.length > 0 ? (
                  dayData.slots.map((slot) => (
                    <button
                      key={slot}
                      onClick={() => handleSlotSelect(`${dayData.day}, ${dayData.date}`, slot)}
                      className={`w-full px-2 py-2 rounded-lg text-xs transition-all ${
                        selectedDay === `${dayData.day}, ${dayData.date}` && selectedSlot === slot
                          ? 'bg-[var(--accent-primary)] text-white'
                          : 'bg-white border border-[var(--border-color)] hover:border-[var(--accent-primary)] text-[var(--text-primary)]'
                      }`}
                    >
                      {slot}
                    </button>
                  ))
                ) : (
                  <div className="text-xs text-[var(--text-muted)] text-center py-2">—</div>
                )}
              </div>
            </div>
          ))}
        </div>

        <div className="flex justify-end">
          <Button
            variant="primary"
            onClick={() => setStep(2)}
            disabled={!selectedDay || !selectedSlot}
          >
            Choose this time →
          </Button>
        </div>
      </div>
    );
  }

  if (step === 2) {
    return (
      <div className="max-w-[680px] mx-auto px-6 py-12">
        <div className="mb-8">
          <h1 className="serif text-4xl mb-4">Anything you'd like them to know beforehand?</h1>
          <p className="text-[var(--text-secondary)]">
            This is optional and shared only with your psychologist.
          </p>
        </div>

        <Card className="mb-6">
          <label htmlFor="message" className="block text-sm mb-2">
            Message (optional)
          </label>
          <textarea
            id="message"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="For example: I've been feeling anxious about exams lately."
            rows={4}
            maxLength={500}
            className="w-full px-4 py-3 border border-[var(--border-color)] rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--focus-ring)] focus:border-transparent resize-none"
          />
          <div className="flex justify-end mt-2">
            <span className="text-xs text-[var(--text-muted)]">{message.length}/500</span>
          </div>
        </Card>

        <div className="flex flex-col gap-3">
          <Button variant="primary" fullWidth onClick={handleSubmit}>
            Send my request
          </Button>
          <button
            onClick={handleSubmit}
            className="text-[var(--accent-primary)] hover:underline text-sm text-center"
          >
            Skip and send without a message
          </button>
        </div>
      </div>
    );
  }

  // Step 3: Confirmation
  return (
    <div className="max-w-[680px] mx-auto px-6 py-12">
      <div className="text-center mb-8">
        <div className="inline-flex w-24 h-24 rounded-full bg-[var(--risk-low)] bg-opacity-20 items-center justify-center mb-6">
          <CheckCircle2 size={48} className="text-[var(--risk-low)]" strokeWidth={1.5} />
        </div>

        <h1 className="serif text-4xl mb-4">Your request has been sent.</h1>
        <p className="text-[var(--text-secondary)] max-w-md mx-auto">
          Your psychologist will confirm your session by email. This usually takes 1–2 business days.
        </p>
      </div>

      <Card className="mb-8">
        <h4 className="mb-4">Booking summary</h4>
        
        <div className="space-y-3">
          <div className="flex items-center gap-3 pb-3 border-b border-[var(--border-color)]">
            <div className="w-12 h-12 rounded-full bg-[var(--accent-primary)] text-white flex items-center justify-center">
              {psychologist.initials}
            </div>
            <div>
              <p className="text-sm text-[var(--text-muted)]">Psychologist</p>
              <p>{psychologist.name}</p>
            </div>
          </div>

          <div className="pb-3 border-b border-[var(--border-color)]">
            <p className="text-sm text-[var(--text-muted)] mb-1">Requested time</p>
            <p>{selectedDay} at {selectedSlot}</p>
          </div>

          {message && (
            <div>
              <p className="text-sm text-[var(--text-muted)] mb-1">Your message</p>
              <p className="text-sm text-[var(--text-secondary)]">{message}</p>
            </div>
          )}
        </div>
      </Card>

      <div className="flex flex-col sm:flex-row gap-3">
        <Button variant="primary" fullWidth onClick={() => navigate('/dashboard')}>
          Back to home
        </Button>
        <Button variant="ghost" fullWidth onClick={() => navigate('/content')}>
          Browse resources while you wait
        </Button>
      </div>
    </div>
  );
}
