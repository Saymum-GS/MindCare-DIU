import { ReactNode, ButtonHTMLAttributes } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'crisis';
  fullWidth?: boolean;
  children: ReactNode;
}

export function Button({ 
  variant = 'primary', 
  fullWidth = false, 
  children, 
  className = '',
  disabled,
  ...props 
}: ButtonProps) {
  const baseStyles = "min-h-[48px] px-8 transition-all duration-200 cursor-pointer disabled:cursor-not-allowed disabled:opacity-50";
  
  const variantStyles = {
    primary: `bg-[var(--accent-primary)] text-white hover:bg-[var(--accent-hover)] rounded-[var(--radius-pill)] ${disabled ? 'bg-[var(--disabled-state)]' : ''}`,
    secondary: `border-2 border-[var(--accent-primary)] text-[var(--accent-primary)] hover:bg-[var(--bg-teal-tint)] rounded-[var(--radius-pill)] bg-transparent`,
    ghost: `text-[var(--accent-primary)] hover:bg-[var(--bg-teal-tint)] rounded-[var(--radius-pill)] bg-transparent`,
    crisis: `bg-[var(--crisis-accent)] text-white hover:opacity-90 rounded-[var(--radius-pill)]`,
  };
  
  const widthStyle = fullWidth ? 'w-full' : '';
  
  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${widthStyle} ${className}`}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
}
