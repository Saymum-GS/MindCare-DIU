import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { Phone, ChevronDown, ChevronUp, Heart, Wind, Lightbulb } from 'lucide-react';

const copingStrategies = [
  {
    id: 1,
    title: 'Breathing exercise',
    icon: Wind,
    content: `1. Find a comfortable seated position
2. Close your eyes or soften your gaze
3. Breathe in slowly through your nose for 4 counts
4. Hold your breath for 4 counts
5. Exhale slowly through your mouth for 6 counts
6. Repeat 5-10 times

Notice how your body feels with each breath.`,
  },
  {
    id: 2,
    title: 'Grounding technique (5-4-3-2-1)',
    icon: Lightbulb,
    content: `This helps bring you back to the present moment:

5 things you can SEE around you
4 things you can TOUCH
3 things you can HEAR
2 things you can SMELL
1 thing you can TASTE

Take your time with each sense.`,
  },
  {
    id: 3,
    title: 'Distraction strategy',
    icon: Heart,
    content: `When feelings become overwhelming, try:

• Take a short walk outside
• Listen to your favorite music
• Call or text a friend
• Watch a comforting show or video
• Do a simple task (organize a drawer, make tea)
• Write or journal your thoughts
• Engage in a hobby

The goal is to shift your focus temporarily.`,
  },
  {
    id: 4,
    title: 'Self-compassion prompt',
    icon: Heart,
    content: `Speak to yourself with kindness:

"This is a difficult moment, but it will pass."
"I'm doing the best I can right now."
"I deserve care and support."
"It's okay to struggle sometimes."

Place your hand on your heart and breathe as you repeat these.`,
  },
];

export function CrisisKit() {
  const navigate = useNavigate();
  const [expandedStrategy, setExpandedStrategy] = useState<number | null>(null);

  const toggleStrategy = (id: number) => {
    setExpandedStrategy(expandedStrategy === id ? null : id);
  };

  return (
    <div className="min-h-screen bg-[var(--bg-lavender-tint)]">
      {/* Header */}
      <div className="bg-[var(--crisis-accent)] text-white py-12">
        <div className="max-w-[900px] mx-auto px-6 text-center">
          <h1 className="serif text-4xl mb-2">You reached out. That matters.</h1>
          <p className="text-white/90">Help and support are always available to you.</p>
        </div>
      </div>

      <div className="max-w-[900px] mx-auto px-6 py-12">
        {/* Section 1: Right now, you can */}
        <div className="mb-12">
          <h2 className="text-2xl mb-6">Right now, you can</h2>
          <div className="grid md:grid-cols-3 gap-4">
            <Card className="text-center cursor-pointer hover:shadow-lg transition-shadow">
              <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-lavender-tint)] flex items-center justify-center mb-4">
                <Wind size={28} className="text-[var(--crisis-accent)]" strokeWidth={1.5} />
              </div>
              <h4 className="mb-2">Take a slow breath</h4>
              <p className="text-sm text-[var(--text-secondary)] mb-4">
                A short guided breathing exercise
              </p>
              <button
                onClick={() => setExpandedStrategy(1)}
                className="text-[var(--crisis-accent)] hover:underline text-sm"
              >
                Start breathing exercise
              </button>
            </Card>

            <Card className="text-center cursor-pointer hover:shadow-lg transition-shadow">
              <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-lavender-tint)] flex items-center justify-center mb-4">
                <Lightbulb size={28} className="text-[var(--crisis-accent)]" strokeWidth={1.5} />
              </div>
              <h4 className="mb-2">Read coping strategies</h4>
              <p className="text-sm text-[var(--text-secondary)] mb-4">
                Techniques to help you feel grounded
              </p>
              <a
                href="#coping-strategies"
                className="text-[var(--crisis-accent)] hover:underline text-sm"
              >
                View strategies
              </a>
            </Card>

            <Card className="text-center cursor-pointer hover:shadow-lg transition-shadow">
              <div className="w-16 h-16 mx-auto rounded-full bg-[var(--bg-lavender-tint)] flex items-center justify-center mb-4">
                <Phone size={28} className="text-[var(--crisis-accent)]" strokeWidth={1.5} />
              </div>
              <h4 className="mb-2">Call for support</h4>
              <p className="text-sm text-[var(--text-secondary)] mb-4">
                Talk to someone who can help
              </p>
              <a
                href="#support-contacts"
                className="text-[var(--crisis-accent)] hover:underline text-sm"
              >
                View contacts
              </a>
            </Card>
          </div>
        </div>

        {/* Section 2: Signs */}
        <Card className="mb-12">
          <h2 className="text-2xl mb-4">Signs that things are getting harder</h2>
          <p className="text-[var(--text-secondary)] mb-6">
            These are common experiences when you're going through a difficult time. If you notice several of these, reaching out for support can help.
          </p>
          <ul className="space-y-3">
            <li className="flex items-start gap-3">
              <span className="w-2 h-2 rounded-full bg-[var(--crisis-accent)] mt-2 flex-shrink-0"></span>
              <p className="text-[var(--text-secondary)]">Feeling overwhelmed most days, like things are out of control</p>
            </li>
            <li className="flex items-start gap-3">
              <span className="w-2 h-2 rounded-full bg-[var(--crisis-accent)] mt-2 flex-shrink-0"></span>
              <p className="text-[var(--text-secondary)]">Withdrawing from friends, family, or activities you used to enjoy</p>
            </li>
            <li className="flex items-start gap-3">
              <span className="w-2 h-2 rounded-full bg-[var(--crisis-accent)] mt-2 flex-shrink-0"></span>
              <p className="text-[var(--text-secondary)]">Trouble sleeping, eating, or concentrating on daily tasks</p>
            </li>
            <li className="flex items-start gap-3">
              <span className="w-2 h-2 rounded-full bg-[var(--crisis-accent)] mt-2 flex-shrink-0"></span>
              <p className="text-[var(--text-secondary)]">Physical symptoms like headaches, stomach issues, or fatigue without a clear cause</p>
            </li>
            <li className="flex items-start gap-3">
              <span className="w-2 h-2 rounded-full bg-[var(--crisis-accent)] mt-2 flex-shrink-0"></span>
              <p className="text-[var(--text-secondary)]">Feeling hopeless or like things won't get better</p>
            </li>
            <li className="flex items-start gap-3">
              <span className="w-2 h-2 rounded-full bg-[var(--crisis-accent)] mt-2 flex-shrink-0"></span>
              <p className="text-[var(--text-secondary)]">Thoughts of hurting yourself or not wanting to be alive</p>
            </li>
          </ul>
        </Card>

        {/* Section 3: Immediate Support */}
        <div id="support-contacts" className="mb-12">
          <h2 className="text-2xl mb-6">Immediate support contacts</h2>
          
          <div className="space-y-4">
            <Card className="bg-[var(--bg-teal-tint)]" padding="large">
              <h3 className="mb-3">DIU Counseling Center</h3>
              <p className="serif text-4xl text-[var(--accent-primary)] mb-4">+880 1234-567890</p>
              <p className="text-[var(--text-secondary)] mb-4">Monday to Friday, 9 AM - 5 PM</p>
              <Button variant="primary" className="w-full md:w-auto">
                <Phone size={18} className="mr-2" /> Call now
              </Button>
            </Card>

            <Card padding="large">
              <h3 className="mb-3">National Mental Health Helpline</h3>
              <p className="serif text-4xl text-[var(--accent-primary)] mb-4">999 (toll-free)</p>
              <p className="text-[var(--text-secondary)] mb-4">24/7 Support Available</p>
              <Button variant="secondary" className="w-full md:w-auto">
                <Phone size={18} className="mr-2" /> Call now
              </Button>
            </Card>
          </div>
        </div>

        {/* Section 4: Coping Strategies */}
        <div id="coping-strategies" className="mb-12">
          <h2 className="text-2xl mb-6">Coping strategies</h2>
          
          <div className="space-y-3">
            {copingStrategies.map((strategy) => {
              const Icon = strategy.icon;
              const isExpanded = expandedStrategy === strategy.id;
              
              return (
                <Card
                  key={strategy.id}
                  className="cursor-pointer hover:shadow-lg transition-shadow"
                  onClick={() => toggleStrategy(strategy.id)}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-[var(--bg-lavender-tint)] flex items-center justify-center">
                        <Icon size={20} className="text-[var(--crisis-accent)]" strokeWidth={1.5} />
                      </div>
                      <h4>{strategy.title}</h4>
                    </div>
                    {isExpanded ? (
                      <ChevronUp size={20} className="text-[var(--text-muted)]" strokeWidth={1.5} />
                    ) : (
                      <ChevronDown size={20} className="text-[var(--text-muted)]" strokeWidth={1.5} />
                    )}
                  </div>
                  
                  {isExpanded && (
                    <div className="mt-4 pt-4 border-t border-[var(--border-color)]">
                      <p className="text-[var(--text-secondary)] whitespace-pre-line leading-relaxed">
                        {strategy.content}
                      </p>
                    </div>
                  )}
                </Card>
              );
            })}
          </div>
        </div>

        {/* Footer Message */}
        <Card className="bg-[var(--bg-lavender-tint)] text-center">
          <p className="text-[var(--text-secondary)]">
            This page is always here for you. You don't have to be in crisis to use it.
          </p>
        </Card>
      </div>
    </div>
  );
}
