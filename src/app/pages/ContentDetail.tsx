import { useNavigate, useParams } from 'react-router';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { ArrowLeft, Bookmark, Play, Pause } from 'lucide-react';
import { useState } from 'react';

const contentData: Record<string, any> = {
  '1': {
    title: 'Managing Academic Stress',
    type: 'Article',
    category: 'Exam stress',
    duration: '5 min read',
    content: `Academic stress is a common experience for university students. The pressure to perform well, meet deadlines, and balance multiple responsibilities can feel overwhelming at times.

Understanding Stress

Stress is your body's natural response to challenges. While some stress can be motivating, chronic stress can impact your mental and physical health. Recognizing the signs early is key to managing it effectively.

Practical Strategies

1. Break down large tasks into smaller, manageable steps
2. Create a realistic study schedule with built-in breaks
3. Practice the Pomodoro Technique: 25 minutes of focused work, followed by a 5-minute break
4. Get enough sleep - aim for 7-9 hours per night
5. Stay physically active, even a short walk can help

Remember: It's okay to ask for help. Talk to your professors, use university resources, or reach out to a counselor if stress becomes unmanageable.`,
  },
  '2': {
    title: 'Better Sleep Habits',
    type: 'Article',
    category: 'Sleep',
    duration: '6 min read',
    content: `Quality sleep is essential for mental health, academic performance, and overall wellbeing. Here's how to improve your sleep habits.

Create a Sleep-Friendly Environment

Your bedroom should be cool, quiet, and dark. Consider using blackout curtains, earplugs, or a white noise machine if needed.

Establish a Routine

Go to bed and wake up at the same time every day, even on weekends. This helps regulate your body's internal clock.

Wind Down Before Bed

Spend 30-60 minutes before bed doing calming activities: reading, gentle stretching, or meditation. Avoid screens during this time.

Watch What You Consume

Avoid caffeine after 2 PM and heavy meals close to bedtime. If you're hungry, opt for a light snack.`,
  },
  '3': {
    title: 'Breathing Exercises',
    type: 'Audio',
    category: 'Anxiety',
    duration: '8 min',
  },
};

export function ContentDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [isBookmarked, setIsBookmarked] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);

  const content = id ? contentData[id] : null;

  if (!content) {
    return (
      <div className="max-w-[var(--max-content-width)] mx-auto px-6 py-12">
        <Card className="text-center py-16">
          <h3 className="mb-4">Content not found</h3>
          <Button variant="primary" onClick={() => navigate('/content')}>
            Back to library
          </Button>
        </Card>
      </div>
    );
  }

  const relatedContent = [
    { id: 2, title: 'Better Sleep Habits', type: 'Article', category: 'Sleep' },
    { id: 3, title: 'Breathing Exercises', type: 'Audio', category: 'Anxiety' },
    { id: 4, title: 'Understanding Depression', type: 'Video', category: 'Low mood' },
  ].filter(item => item.id.toString() !== id);

  return (
    <div className="max-w-[800px] mx-auto px-6 py-12">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm text-[var(--text-muted)] mb-6">
        <button onClick={() => navigate('/content')} className="hover:text-[var(--accent-primary)]">
          Content
        </button>
        <span>→</span>
        <span>{content.category}</span>
      </div>

      {/* Back Button */}
      <button
        onClick={() => navigate('/content')}
        className="flex items-center gap-2 text-[var(--text-secondary)] hover:text-[var(--accent-primary)] mb-6 transition-colors"
      >
        <ArrowLeft size={20} strokeWidth={1.5} />
        <span>Back</span>
      </button>

      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <span className="text-sm px-3 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]">
            {content.type}
          </span>
          <span className="text-sm px-3 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]">
            {content.category}
          </span>
        </div>

        <div className="flex items-start justify-between gap-4 mb-4">
          <h1 className="serif text-4xl">{content.title}</h1>
          <button
            onClick={() => setIsBookmarked(!isBookmarked)}
            className="flex-shrink-0 w-12 h-12 rounded-full border-2 border-[var(--border-color)] flex items-center justify-center hover:border-[var(--accent-primary)] transition-colors"
          >
            <Bookmark
              size={20}
              className={isBookmarked ? 'fill-[var(--accent-primary)] text-[var(--accent-primary)]' : 'text-[var(--text-muted)]'}
              strokeWidth={1.5}
            />
          </button>
        </div>

        <p className="text-[var(--text-muted)]">{content.duration}</p>
      </div>

      {/* Content */}
      {content.type === 'Article' && (
        <div className="prose max-w-none mb-12">
          <div className="text-lg leading-relaxed whitespace-pre-line text-[var(--text-secondary)]">
            {content.content}
          </div>
        </div>
      )}

      {content.type === 'Audio' && (
        <Card className="mb-12">
          <div className="text-center py-12">
            <button
              onClick={() => setIsPlaying(!isPlaying)}
              className="w-24 h-24 mx-auto rounded-full bg-[var(--accent-primary)] text-white flex items-center justify-center hover:bg-[var(--accent-hover)] transition-all mb-6"
            >
              {isPlaying ? <Pause size={40} fill="white" /> : <Play size={40} fill="white" />}
            </button>
            
            <div className="max-w-md mx-auto">
              <div className="h-2 bg-[var(--border-color)] rounded-full mb-2">
                <div className="h-full w-1/3 bg-[var(--accent-primary)] rounded-full"></div>
              </div>
              <div className="flex justify-between text-sm text-[var(--text-muted)]">
                <span>2:45</span>
                <span>{content.duration}</span>
              </div>
            </div>
          </div>
        </Card>
      )}

      {content.type === 'Video' && (
        <Card className="mb-12" padding="none">
          <div className="aspect-video bg-[var(--accent-primary)] bg-opacity-20 rounded-t-[var(--radius-card)] flex items-center justify-center">
            <button className="w-20 h-20 rounded-full bg-[var(--accent-primary)] text-white flex items-center justify-center hover:bg-[var(--accent-hover)] transition-all">
              <Play size={32} fill="white" />
            </button>
          </div>
        </Card>
      )}

      {/* More like this */}
      <div className="mb-12">
        <h3 className="mb-6">More like this</h3>
        <div className="grid md:grid-cols-3 gap-4">
          {relatedContent.slice(0, 3).map(item => (
            <Card
              key={item.id}
              className="cursor-pointer hover:shadow-lg transition-shadow"
              onClick={() => navigate(`/content/${item.id}`)}
            >
              <div className="h-20 bg-gradient-to-br from-[var(--accent-primary)] to-[var(--accent-secondary)] rounded-lg mb-3 opacity-30"></div>
              <span className="text-xs px-2 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]">
                {item.type}
              </span>
              <h4 className="text-sm mt-2 mb-1">{item.title}</h4>
              <p className="text-xs text-[var(--text-muted)]">{item.category}</p>
            </Card>
          ))}
        </div>
      </div>

      {/* CTA Strip */}
      <Card className="bg-[var(--bg-teal-tint)] text-center">
        <p className="mb-4">Feeling like you need more support?</p>
        <Button variant="primary" onClick={() => navigate('/psychologists')}>
          Talk to a psychologist
        </Button>
      </Card>
    </div>
  );
}
