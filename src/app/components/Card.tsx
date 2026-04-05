import { ReactNode } from 'react';

interface CardProps {
  children: ReactNode;
  className?: string;
  padding?: 'default' | 'large' | 'none';
}

export function Card({ children, className = '', padding = 'default' }: CardProps) {
  const paddingStyles = {
    default: 'p-[var(--spacing-card)]',
    large: 'p-[var(--spacing-section)]',
    none: '',
  };
  
  return (
    <div className={`bg-[var(--bg-surface)] rounded-[var(--radius-card)] shadow-[var(--shadow-soft)] border border-[var(--border-color)] ${paddingStyles[padding]} ${className}`}>
      {children}
    </div>
  );
}
