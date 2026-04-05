import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ArrowLeft, Check } from 'lucide-react';
import { Button } from '../components/Button';

const anxietyQuestions = [
  'Over the past 2 weeks, how often have you felt nervous or anxious?',
  'Over the past 2 weeks, how often have you been unable to stop or control worrying?',
  'Over the past 2 weeks, how often have you worried too much about different things?',
  'Over the past 2 weeks, how often have you had trouble relaxing?',
  'Over the past 2 weeks, how often have you been so restless that it\'s hard to sit still?',
  'Over the past 2 weeks, how often have you become easily annoyed or irritable?',
  'Over the past 2 weeks, how often have you felt afraid, as if something awful might happen?',
];

const depressionQuestions = [
  'Over the past 2 weeks, how often have you had little interest or pleasure in doing things?',
  'Over the past 2 weeks, how often have you felt down, depressed, or hopeless?',
  'Over the past 2 weeks, how often have you had trouble falling or staying asleep, or sleeping too much?',
  'Over the past 2 weeks, how often have you felt tired or had little energy?',
  'Over the past 2 weeks, how often have you had a poor appetite or been overeating?',
  'Over the past 2 weeks, how often have you felt bad about yourself?',
  'Over the past 2 weeks, how often have you had trouble concentrating on things?',
  'Over the past 2 weeks, how often have you moved or spoken slowly, or been fidgety or restless?',
  'Over the past 2 weeks, how often have you had thoughts that you would be better off dead?',
];

const answerOptions = [
  { label: 'Not at all', value: 0 },
  { label: 'Several days', value: 1 },
  { label: 'More than half the days', value: 2 },
  { label: 'Nearly every day', value: 3 },
];

export function ScreeningQuestions() {
  const { type } = useParams<{ type: string }>();
  const navigate = useNavigate();
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<number[]>([]);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showContinueButton, setShowContinueButton] = useState(false);

  const questions = type === 'anxiety' ? anxietyQuestions : depressionQuestions;
  const totalQuestions = questions.length;

  useEffect(() => {
    // Reset selected answer when question changes
    setSelectedAnswer(null);
    setShowContinueButton(false);
  }, [currentQuestion]);

  const handleAnswerSelect = (value: number) => {
    setSelectedAnswer(value);
    
    // Auto-advance after 300ms
    setTimeout(() => {
      handleContinue(value);
    }, 300);
    
    // Show continue button after 1.5s as fallback
    setTimeout(() => {
      setShowContinueButton(true);
    }, 1500);
  };

  const handleContinue = (value: number) => {
    const newAnswers = [...answers, value];
    setAnswers(newAnswers);

    if (currentQuestion < totalQuestions - 1) {
      setCurrentQuestion(currentQuestion + 1);
    } else {
      // Calculate score and navigate to results
      const totalScore = newAnswers.reduce((sum, answer) => sum + answer, 0);
      calculateRiskLevel(totalScore);
    }
  };

  const calculateRiskLevel = (score: number) => {
    let riskLevel = 'low';
    
    if (type === 'anxiety') {
      if (score >= 15) riskLevel = 'high';
      else if (score >= 10) riskLevel = 'medium';
    } else {
      if (score >= 20) riskLevel = 'high';
      else if (score >= 10) riskLevel = 'medium';
    }

    // Store results
    localStorage.setItem('mindcare_risk_level', riskLevel);
    localStorage.setItem('mindcare_screening_date', new Date().toLocaleDateString());
    localStorage.setItem('mindcare_screening_score', score.toString());

    // Navigate to results
    navigate(`/screening/results/${type}`);
  };

  const handleExit = () => {
    if (confirm('Are you sure you want to exit? Your progress will be lost.')) {
      navigate('/dashboard');
    }
  };

  const progress = ((currentQuestion + 1) / totalQuestions) * 100;

  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex flex-col">
      {/* Progress Bar */}
      <div className="bg-white border-b border-[var(--border-color)]">
        <div className="max-w-[800px] mx-auto px-6 py-4">
          <div className="flex items-center justify-between mb-2">
            <button
              onClick={handleExit}
              className="text-[var(--text-secondary)] hover:text-[var(--accent-primary)] transition-colors"
            >
              <ArrowLeft size={24} strokeWidth={1.5} />
            </button>
            <span className="text-sm text-[var(--text-muted)]">
              Question {currentQuestion + 1} of {totalQuestions}
            </span>
          </div>
          <div className="w-full h-1 bg-[var(--border-color)] rounded-full overflow-hidden">
            <div
              className="h-full bg-[var(--accent-primary)] transition-all duration-300"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      </div>

      {/* Question */}
      <div className="flex-grow flex items-center justify-center px-6 py-12">
        <div className="max-w-[680px] w-full">
          <h2 className="text-2xl text-center mb-12 leading-relaxed">
            {questions[currentQuestion]}
          </h2>

          <div className="space-y-3">
            {answerOptions.map((option) => (
              <button
                key={option.value}
                onClick={() => handleAnswerSelect(option.value)}
                className={`w-full min-h-[48px] px-6 py-4 rounded-lg border-2 transition-all text-left flex items-center justify-between ${
                  selectedAnswer === option.value
                    ? 'bg-[var(--accent-primary)] border-[var(--accent-primary)] text-white'
                    : 'bg-white border-[var(--border-color)] hover:border-[var(--accent-primary)] text-[var(--text-primary)]'
                }`}
              >
                <span>{option.label}</span>
                {selectedAnswer === option.value && <Check size={20} strokeWidth={2} />}
              </button>
            ))}
          </div>

          {showContinueButton && selectedAnswer !== null && (
            <div className="mt-8 text-center">
              <Button
                variant="primary"
                onClick={() => handleContinue(selectedAnswer)}
              >
                Continue →
              </Button>
            </div>
          )}
        </div>
      </div>

      {/* Skip option */}
      <div className="text-center py-6">
        <button
          onClick={() => navigate('/dashboard')}
          className="text-xs text-[var(--text-muted)] hover:text-[var(--accent-primary)]"
        >
          I'd like to skip this check-in
        </button>
      </div>
    </div>
  );
}
