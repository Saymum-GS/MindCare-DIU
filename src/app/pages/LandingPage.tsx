import { useNavigate } from 'react-router';
import { Navbar } from '../components/Navbar';
import { Button } from '../components/Button';
import { CheckCircle2, Lock, BookOpen, Heart, Users } from 'lucide-react';
import { Card } from '../components/Card';

export function LandingPage() {
  const navigate = useNavigate();

  const steps = [
    {
      number: '1',
      icon: CheckCircle2,
      title: 'Answer a few questions',
      description: 'Take a brief, confidential check-in about how you\'ve been feeling.',
    },
    {
      number: '2',
      icon: Heart,
      title: 'Understand how you\'re feeling',
      description: 'Get personalized insights and resources based on your responses.',
    },
    {
      number: '3',
      icon: Users,
      title: 'Access support that fits you',
      description: 'Connect with university psychologists and helpful content when you need it.',
    },
  ];

  const contentPreviews = [
    {
      title: 'Managing Exam Stress',
      type: 'Article',
      topic: 'Academic stress',
      duration: '5 min read',
    },
    {
      title: 'Sleep Better Tonight',
      type: 'Audio',
      topic: 'Sleep',
      duration: '10 min',
    },
    {
      title: 'Dealing with Anxiety',
      type: 'Video',
      topic: 'Anxiety',
      duration: '8 min',
    },
  ];

  return (
    <div className="min-h-screen bg-[var(--bg-primary)]">
      <Navbar isAuthenticated={false} />

      {/* Hero Section */}
      <section className="max-w-[var(--max-content-width)] mx-auto px-6 pt-12 md:pt-20 pb-16 md:pb-24">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <div>
            <h1 className="serif text-4xl md:text-5xl lg:text-6xl mb-6">
              Your mental wellbeing, your space.
            </h1>
            <p className="text-base md:text-lg text-[var(--text-secondary)] mb-8 leading-relaxed">
              A safe, private platform for Daffodil International University students to check in with themselves, 
              access support, and prioritize their mental health—completely anonymously.
            </p>
            <div className="flex flex-col sm:flex-row gap-4">
              <Button variant="primary" onClick={() => navigate('/register')}>
                Take the free check-in
              </Button>
              <Button variant="ghost" onClick={() => {
                document.getElementById('how-it-works')?.scrollIntoView({ behavior: 'smooth' });
              }}>
                Learn how it works
              </Button>
            </div>
          </div>

          {/* Abstract illustration */}
          <div className="relative h-64 md:h-96">
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="relative w-full h-full">
                <div className="absolute top-20 left-10 w-48 h-48 rounded-full bg-[var(--accent-primary)] opacity-20 blur-2xl"></div>
                <div className="absolute bottom-20 right-10 w-56 h-56 rounded-full bg-[var(--risk-low)] opacity-20 blur-2xl"></div>
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-40 h-40 rounded-full bg-[var(--accent-secondary)] opacity-25 blur-xl"></div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* How it works */}
      <section id="how-it-works" className="bg-white py-20">
        <div className="max-w-[var(--max-content-width)] mx-auto px-6">
          <h2 className="serif text-4xl text-center mb-16">How it works</h2>
          
          <div className="grid md:grid-cols-3 gap-12">
            {steps.map((step) => (
              <div key={step.number} className="relative">
                <div className="serif text-6xl text-[var(--accent-primary)] opacity-20 mb-4">
                  {step.number}
                </div>
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-12 h-12 rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center">
                    <step.icon size={24} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
                  </div>
                  <h3 className="text-xl">{step.title}</h3>
                </div>
                <p className="text-[var(--text-secondary)] leading-relaxed">
                  {step.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Privacy Promise */}
      <section className="bg-[var(--bg-teal-tint)] py-8">
        <div className="max-w-[var(--max-content-width)] mx-auto px-6">
          <div className="flex items-center justify-center gap-4">
            <Lock size={28} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
            <p className="text-lg">
              <strong>No name required. No judgment. Your data stays yours.</strong>
            </p>
          </div>
        </div>
      </section>

      {/* Resource Preview */}
      <section id="for-students" className="py-20">
        <div className="max-w-[var(--max-content-width)] mx-auto px-6">
          <h2 className="serif text-4xl text-center mb-4">Resources that support you</h2>
          <p className="text-center text-[var(--text-secondary)] mb-12">
            Access curated content designed for student wellbeing
          </p>
          
          <div className="grid md:grid-cols-3 gap-6">
            {contentPreviews.map((content) => (
              <Card key={content.title}>
                <div className="h-32 bg-gradient-to-br from-[var(--accent-primary)] to-[var(--accent-secondary)] rounded-lg mb-4 opacity-30"></div>
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-xs px-3 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]">
                    {content.type}
                  </span>
                  <span className="text-xs text-[var(--text-muted)]">{content.duration}</span>
                </div>
                <h4 className="mb-2">{content.title}</h4>
                <p className="text-sm text-[var(--text-muted)]">{content.topic}</p>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer id="privacy" className="bg-white border-t border-[var(--border-color)] py-12">
        <div className="max-w-[var(--max-content-width)] mx-auto px-6">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="flex items-center gap-2">
              <span className="serif text-xl text-[var(--text-primary)]">MindCare</span>
              <span className="text-[var(--accent-primary)]">@DIU</span>
            </div>
            
            <div className="flex flex-wrap items-center justify-center gap-6 text-sm text-[var(--text-secondary)]">
              <a href="#" className="hover:text-[var(--accent-primary)] transition-colors">Privacy Policy</a>
              <a href="mailto:support@mindcare.diu.edu" className="hover:text-[var(--accent-primary)] transition-colors">
                support@mindcare.diu.edu
              </a>
            </div>
            
            <p className="text-sm text-[var(--text-muted)]">
              A service by Daffodil International University
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}