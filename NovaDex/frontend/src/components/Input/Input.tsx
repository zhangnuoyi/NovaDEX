import React from 'react';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  suffix?: React.ReactNode;
  prefix?: React.ReactNode;
}

const Input: React.FC<InputProps> = ({
  label,
  error,
  suffix,
  prefix,
  className = '',
  type = 'text',
  disabled = false,
  ...props
}) => {
  return (
    <div className="w-full">
      {label && (
        <label className="block text-sm font-medium text-text-secondary mb-1">
          {label}
        </label>
      )}
      <div className="relative">
        {prefix && (
          <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-text-secondary">
            {prefix}
          </div>
        )}
        <input
          type={type}
          disabled={disabled}
          className={`
            w-full bg-background border border-border rounded-lg px-4 py-3 text-white focus:outline-none focus:ring-2 focus:ring-secondary
            ${prefix ? 'pl-10' : ''}
            ${suffix ? 'pr-10' : ''}
            ${disabled ? 'opacity-50 cursor-not-allowed' : ''}
            ${error ? 'border-error' : ''}
            ${className}
          `}
          {...props}
        />
        {suffix && (
          <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
            {suffix}
          </div>
        )}
      </div>
      {error && (
        <p className="text-sm text-error mt-1">{error}</p>
      )}
    </div>
  );
};

export default Input;