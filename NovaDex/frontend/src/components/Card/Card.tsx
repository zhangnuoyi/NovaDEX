import React from 'react';

interface CardProps {
  children: React.ReactNode;
  title?: string;
  className?: string;
  footer?: React.ReactNode;
}

const Card: React.FC<CardProps> = ({
  children,
  title,
  className = '',
  footer
}) => {
  return (
    <div className={`bg-card rounded-xl shadow-card overflow-hidden transition-all duration-300 card ${className}`}>
      {title && (
        <div className="p-6 border-b border-border">
          <h2 className="text-xl font-semibold">{title}</h2>
        </div>
      )}
      <div className="p-6">
        {children}
      </div>
      {footer && (
        <div className="p-6 border-t border-border">
          {footer}
        </div>
      )}
    </div>
  );
};

export default Card;