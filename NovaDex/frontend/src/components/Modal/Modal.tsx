import React from 'react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

const Modal: React.FC<ModalProps> = ({
  isOpen,
  onClose,
  title,
  children,
  footer,
  size = 'md'
}) => {
  if (!isOpen) return null;

  const sizeClasses = {
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-xl'
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* 遮罩层 */}
      <div 
        className="fixed inset-0 bg-black bg-opacity-50" 
        onClick={onClose}
      ></div>

      {/* 模态框 */}
      <div className={`relative bg-card rounded-xl shadow-card overflow-hidden max-h-[90vh] overflow-y-auto fade-in ${sizeClasses[size]}`}>
        {/* 模态框头部 */}
        {title && (
          <div className="p-6 border-b border-border flex justify-between items-center">
            <h2 className="text-xl font-semibold">{title}</h2>
            <button 
              className="text-text-secondary hover:text-text transition-colors" 
              onClick={onClose}
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        )}

        {/* 模态框内容 */}
        <div className="p-6">
          {children}
        </div>

        {/* 模态框底部 */}
        {footer && (
          <div className="p-6 border-t border-border flex justify-end space-x-3">
            {footer}
          </div>
        )}
      </div>
    </div>
  );
};

export default Modal;