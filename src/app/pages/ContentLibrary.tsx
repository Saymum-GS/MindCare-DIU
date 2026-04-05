import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Card } from '../components/Card';
import { Bookmark, BookOpen } from 'lucide-react';

const categories = ['All', 'Anxiety', 'Exam stress', 'Sleep', 'Low mood', 'Relationships'];
const formats = ['All formats', 'Articles', 'Audio', 'Video'];

const allContent = [
  { id: 1, title: 'Managing Academic Stress', type: 'Article', category: 'Exam stress', duration: '5 min read' },
  { id: 2, title: 'Better Sleep Habits', type: 'Article', category: 'Sleep', duration: '6 min read' },
  { id: 3, title: 'Breathing Exercises', type: 'Audio', category: 'Anxiety', duration: '8 min' },
  { id: 4, title: 'Understanding Depression', type: 'Video', category: 'Low mood', duration: '12 min' },
  { id: 5, title: 'Building Healthy Relationships', type: 'Article', category: 'Relationships', duration: '7 min read' },
  { id: 6, title: 'Mindfulness for Students', type: 'Audio', category: 'Anxiety', duration: '10 min' },
  { id: 7, title: 'Dealing with Homesickness', type: 'Article', category: 'Low mood', duration: '4 min read' },
  { id: 8, title: 'Time Management Tips', type: 'Video', category: 'Exam stress', duration: '9 min' },
  { id: 9, title: 'Progressive Muscle Relaxation', type: 'Audio', category: 'Sleep', duration: '15 min' },
];

export function ContentLibrary() {
  const navigate = useNavigate();
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedFormat, setSelectedFormat] = useState('All formats');
  const [bookmarked, setBookmarked] = useState<number[]>([]);

  const filteredContent = allContent.filter(content => {
    const categoryMatch = selectedCategory === 'All' || content.category === selectedCategory;
    const formatMatch = selectedFormat === 'All formats' || content.type === selectedFormat.slice(0, -1);
    return categoryMatch && formatMatch;
  });

  const toggleBookmark = (id: number, e: React.MouseEvent) => {
    e.stopPropagation();
    setBookmarked(prev =>
      prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
    );
  };

  const getCategoryColor = (category: string) => {
    const colors: Record<string, string> = {
      'Anxiety': 'bg-[var(--accent-primary)]',
      'Exam stress': 'bg-[var(--risk-medium)]',
      'Sleep': 'bg-[var(--crisis-accent)]',
      'Low mood': 'bg-[var(--accent-secondary)]',
      'Relationships': 'bg-[var(--risk-low)]',
    };
    return colors[category] || 'bg-[var(--accent-primary)]';
  };

  return (
    <div className="max-w-[var(--max-content-width)] mx-auto px-6 py-12">
      <div className="mb-12">
        <h1 className="serif text-4xl mb-2">Resources for you</h1>
        <p className="text-[var(--text-secondary)]">Curated for your wellbeing</p>
      </div>

      {/* Category Filter */}
      <div className="mb-4">
        <div className="flex flex-wrap gap-2">
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-4 py-2 rounded-full transition-all ${
                selectedCategory === category
                  ? 'bg-[var(--accent-primary)] text-white'
                  : 'bg-white border-2 border-[var(--accent-primary)] text-[var(--accent-primary)] hover:bg-[var(--bg-teal-tint)]'
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      </div>

      {/* Format Filter */}
      <div className="mb-8">
        <div className="flex flex-wrap gap-2">
          {formats.map(format => (
            <button
              key={format}
              onClick={() => setSelectedFormat(format)}
              className={`px-3 py-1.5 text-sm rounded-full transition-all ${
                selectedFormat === format
                  ? 'bg-[var(--accent-primary)] text-white'
                  : 'bg-white border border-[var(--accent-primary)] text-[var(--accent-primary)] hover:bg-[var(--bg-teal-tint)]'
              }`}
            >
              {format}
            </button>
          ))}
        </div>
      </div>

      {/* Content Grid */}
      {filteredContent.length > 0 ? (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredContent.map(content => (
            <Card
              key={content.id}
              className="cursor-pointer hover:shadow-xl transition-all relative group"
              onClick={() => navigate(`/content/${content.id}`)}
            >
              <div className={`h-32 ${getCategoryColor(content.category)} rounded-lg mb-4 opacity-30 relative overflow-hidden`}>
                <div className="absolute inset-0 bg-gradient-to-br from-transparent to-black/10"></div>
              </div>
              
              <div className="absolute top-6 left-6">
                <span className="text-xs px-3 py-1 rounded-full bg-white/90 text-[var(--text-primary)] backdrop-blur">
                  {content.type}
                </span>
              </div>
              
              <button
                onClick={(e) => toggleBookmark(content.id, e)}
                className="absolute top-6 right-6 w-8 h-8 rounded-full bg-white/90 backdrop-blur flex items-center justify-center hover:bg-white transition-all"
              >
                <Bookmark
                  size={16}
                  className={bookmarked.includes(content.id) ? 'fill-[var(--accent-primary)] text-[var(--accent-primary)]' : 'text-[var(--text-muted)]'}
                  strokeWidth={1.5}
                />
              </button>

              <h4 className="mb-2">{content.title}</h4>
              
              <div className="flex items-center justify-between">
                <span className="text-xs px-3 py-1 rounded-full bg-[var(--bg-teal-tint)] text-[var(--accent-primary)]">
                  {content.category}
                </span>
                <span className="text-xs text-[var(--text-muted)]">{content.duration}</span>
              </div>
            </Card>
          ))}
        </div>
      ) : (
        <Card className="text-center py-16">
          <div className="w-24 h-24 mx-auto rounded-full bg-[var(--bg-teal-tint)] flex items-center justify-center mb-6">
            <BookOpen size={40} className="text-[var(--accent-primary)]" strokeWidth={1.5} />
          </div>
          <h3 className="mb-2">No results for this filter</h3>
          <p className="text-[var(--text-secondary)] mb-6">Try another topic or format.</p>
          <button
            onClick={() => {
              setSelectedCategory('All');
              setSelectedFormat('All formats');
            }}
            className="text-[var(--accent-primary)] hover:underline"
          >
            Show all
          </button>
        </Card>
      )}
    </div>
  );
}
