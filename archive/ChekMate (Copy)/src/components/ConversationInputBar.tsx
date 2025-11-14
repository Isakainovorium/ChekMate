import React, { useState, useRef } from 'react';
import { Send, Smile, Camera, Mic, Paperclip, Image, Plus } from 'lucide-react';

interface ConversationInputBarProps {
  onSendMessage: (message: string) => void;
  placeholder?: string;
  disabled?: boolean;
  showAttachments?: boolean;
  showCamera?: boolean;
  showMicrophone?: boolean;
  showEmoji?: boolean;
}

export function ConversationInputBar({
  onSendMessage,
  placeholder = "Type a message...",
  disabled = false,
  showAttachments = true,
  showCamera = true,
  showMicrophone = true,
  showEmoji = true
}: ConversationInputBarProps) {
  const [message, setMessage] = useState('');
  const [showAttachmentMenu, setShowAttachmentMenu] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleSend = () => {
    if (message.trim() && !disabled) {
      onSendMessage(message.trim());
      setMessage('');
      inputRef.current?.focus();
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const attachmentOptions = [
    { icon: Camera, label: 'Camera', color: 'bg-green-500' },
    { icon: Image, label: 'Gallery', color: 'bg-blue-500' },
    { icon: Paperclip, label: 'Document', color: 'bg-purple-500' },
    { icon: Mic, label: 'Audio', color: 'bg-red-500' }
  ];

  return (
    <div className="relative">
      {/* Attachment Menu */}
      {showAttachmentMenu && showAttachments && (
        <div className="absolute bottom-full left-4 mb-2 bg-white rounded-2xl shadow-lg border border-gray-200 p-3">
          <div className="grid grid-cols-2 gap-3">
            {attachmentOptions.map((option, index) => {
              const Icon = option.icon;
              return (
                <button
                  key={index}
                  onClick={() => setShowAttachmentMenu(false)}
                  className="flex flex-col items-center p-3 rounded-xl hover:bg-gray-50 transition-colors"
                >
                  <div className={`w-12 h-12 ${option.color} rounded-full flex items-center justify-center mb-2`}>
                    <Icon size={20} className="text-white" />
                  </div>
                  <span className="text-xs text-gray-700">{option.label}</span>
                </button>
              );
            })}
          </div>
        </div>
      )}

      {/* Input Bar */}
      <div className="bg-white border-t border-gray-200 p-4">
        <div className="flex items-center space-x-3">
          {/* Attachment Button */}
          {showAttachments && (
            <button
              onClick={() => setShowAttachmentMenu(!showAttachmentMenu)}
              className="p-2 text-gray-600 hover:text-orange-400 transition-colors"
            >
              <Plus size={20} />
            </button>
          )}

          {/* Emoji Button */}
          {showEmoji && (
            <button className="p-2 text-gray-600 hover:text-orange-400 transition-colors">
              <Smile size={20} />
            </button>
          )}

          {/* Text Input */}
          <div className="flex-1 relative">
            <input
              ref={inputRef}
              type="text"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder={placeholder}
              disabled={disabled}
              className={`w-full px-4 py-3 bg-gray-100 rounded-full border-none outline-none transition-all duration-200 ${
                disabled 
                  ? 'opacity-50 cursor-not-allowed' 
                  : 'focus:ring-2 focus:ring-orange-200 focus:bg-white'
              }`}
            />
            
            {/* Character count (optional) */}
            {message.length > 100 && (
              <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                <span className={`text-xs ${
                  message.length > 280 ? 'text-red-500' : 'text-gray-400'
                }`}>
                  {message.length}/280
                </span>
              </div>
            )}
          </div>

          {/* Camera Button */}
          {showCamera && (
            <button className="p-2 text-gray-600 hover:text-orange-400 transition-colors">
              <Camera size={20} />
            </button>
          )}

          {/* Microphone Button */}
          {showMicrophone && !message.trim() && (
            <button className="p-2 text-gray-600 hover:text-orange-400 transition-colors">
              <Mic size={20} />
            </button>
          )}

          {/* Send Button */}
          <button
            onClick={handleSend}
            disabled={!message.trim() || disabled}
            className={`p-3 rounded-full transition-all duration-200 ${
              message.trim() && !disabled
                ? 'bg-orange-400 text-white hover:bg-orange-500 transform hover:scale-105'
                : 'bg-gray-100 text-gray-400 cursor-not-allowed'
            }`}
          >
            <Send size={18} />
          </button>
        </div>

        {/* Typing Indicator (optional) */}
        {message.length > 0 && (
          <div className="mt-2 px-4">
            <div className="flex items-center space-x-2 text-xs text-gray-500">
              <div className="flex space-x-1">
                <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce"></div>
                <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                <div className="w-1 h-1 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
              </div>
              <span>Typing...</span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}