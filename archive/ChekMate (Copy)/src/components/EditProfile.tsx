import React, { useState, useEffect } from 'react';
import { X, Check, User, FileText, AlertCircle } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface EditProfileProps {
  isOpen: boolean;
  onClose: () => void;
  currentUsername: string;
  currentBio: string;
  userAvatar: string;
  onSave: (username: string, bio: string) => void;
}

export function EditProfile({ 
  isOpen, 
  onClose, 
  currentUsername, 
  currentBio, 
  userAvatar, 
  onSave 
}: EditProfileProps) {
  const [username, setUsername] = useState(currentUsername);
  const [bio, setBio] = useState(currentBio);
  const [usernameError, setUsernameError] = useState('');
  const [isUsernameValid, setIsUsernameValid] = useState(true);
  const [hasChanges, setHasChanges] = useState(false);

  const maxBioLength = 150;
  const maxUsernameLength = 30;
  const minUsernameLength = 3;

  useEffect(() => {
    if (isOpen) {
      setUsername(currentUsername);
      setBio(currentBio);
      setUsernameError('');
      setIsUsernameValid(true);
      setHasChanges(false);
    }
  }, [isOpen, currentUsername, currentBio]);

  useEffect(() => {
    setHasChanges(username !== currentUsername || bio !== currentBio);
  }, [username, bio, currentUsername, currentBio]);

  const validateUsername = (value: string) => {
    if (value.length < minUsernameLength) {
      setUsernameError(`Username must be at least ${minUsernameLength} characters`);
      setIsUsernameValid(false);
      return false;
    }
    
    if (value.length > maxUsernameLength) {
      setUsernameError(`Username must be ${maxUsernameLength} characters or less`);
      setIsUsernameValid(false);
      return false;
    }
    
    if (!/^[a-zA-Z0-9_]+$/.test(value)) {
      setUsernameError('Username can only contain letters, numbers, and underscores');
      setIsUsernameValid(false);
      return false;
    }
    
    if (value.startsWith('_') || value.endsWith('_')) {
      setUsernameError('Username cannot start or end with underscore');
      setIsUsernameValid(false);
      return false;
    }
    
    setUsernameError('');
    setIsUsernameValid(true);
    return true;
  };

  const handleUsernameChange = (value: string) => {
    setUsername(value);
    validateUsername(value);
  };

  const handleSave = () => {
    if (!isUsernameValid || !hasChanges) return;
    
    const finalValidation = validateUsername(username);
    if (finalValidation) {
      onSave(username.trim(), bio.trim());
      onClose();
    }
  };

  const handleCancel = () => {
    if (hasChanges) {
      const confirmDiscard = window.confirm('You have unsaved changes. Are you sure you want to discard them?');
      if (!confirmDiscard) return;
    }
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl w-full max-w-md max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-100">
          <h2 className="text-xl font-bold text-gray-900">Edit Profile</h2>
          <button 
            onClick={handleCancel}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Profile Picture Preview */}
          <div className="flex flex-col items-center space-y-3">
            <ImageWithFallback
              src={userAvatar}
              alt="Profile preview"
              className="w-20 h-20 rounded-full object-cover border-4 border-orange-100"
            />
            <p className="text-sm text-gray-600">Profile picture can be changed from settings</p>
          </div>

          {/* Username Field */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-gray-700">
              <User size={16} />
              <span>Username</span>
            </label>
            <div className="relative">
              <input
                type="text"
                value={username}
                onChange={(e) => handleUsernameChange(e.target.value)}
                placeholder="Enter your username"
                maxLength={maxUsernameLength}
                className={`w-full px-4 py-3 border rounded-lg transition-colors ${
                  usernameError 
                    ? 'border-red-300 focus:ring-red-200 focus:border-red-400' 
                    : 'border-gray-200 focus:ring-orange-200 focus:border-orange-400'
                } focus:outline-none focus:ring-2`}
              />
              {isUsernameValid && username && (
                <Check size={16} className="absolute right-3 top-1/2 transform -translate-y-1/2 text-green-500" />
              )}
              {usernameError && (
                <AlertCircle size={16} className="absolute right-3 top-1/2 transform -translate-y-1/2 text-red-500" />
              )}
            </div>
            <div className="flex justify-between items-center">
              <div>
                {usernameError && (
                  <p className="text-red-500 text-xs">{usernameError}</p>
                )}
                {!usernameError && username && (
                  <p className="text-green-600 text-xs">Username is available!</p>
                )}
              </div>
              <span className="text-xs text-gray-500">
                {username.length}/{maxUsernameLength}
              </span>
            </div>
          </div>

          {/* Bio Field */}
          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-sm font-medium text-gray-700">
              <FileText size={16} />
              <span>Bio</span>
            </label>
            <textarea
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              placeholder="Tell us about yourself..."
              maxLength={maxBioLength}
              rows={4}
              className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-colors resize-none"
            />
            <div className="flex justify-between items-center">
              <p className="text-xs text-gray-500">
                Share your interests, what you're looking for, or fun facts about yourself
              </p>
              <span className={`text-xs ${
                bio.length > maxBioLength * 0.9 ? 'text-orange-500' : 'text-gray-500'
              }`}>
                {bio.length}/{maxBioLength}
              </span>
            </div>
          </div>

          {/* Preview Section */}
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="text-sm font-medium text-gray-700 mb-3">Preview</h3>
            <div className="flex items-start space-x-3">
              <ImageWithFallback
                src={userAvatar}
                alt="Profile preview"
                className="w-12 h-12 rounded-full object-cover"
              />
              <div className="flex-1">
                <h4 className="font-semibold text-gray-900">{username || 'Username'}</h4>
                <p className="text-gray-600 text-sm mt-1">
                  {bio || 'Your bio will appear here...'}
                </p>
              </div>
            </div>
          </div>

          {/* Character Guidelines */}
          <div className="bg-blue-50 rounded-lg p-4">
            <h4 className="text-sm font-medium text-blue-800 mb-2">Profile Tips</h4>
            <ul className="text-xs text-blue-700 space-y-1">
              <li>• Use a clear, friendly username that represents you</li>
              <li>• Write a bio that shows your personality and interests</li>
              <li>• Mention what you're looking for in a relationship</li>
              <li>• Keep it positive and authentic</li>
            </ul>
          </div>
        </div>

        {/* Actions */}
        <div className="border-t border-gray-100 p-6">
          <div className="flex space-x-3">
            <button
              onClick={handleCancel}
              className="flex-1 py-3 px-4 border border-gray-200 text-gray-700 rounded-lg font-medium hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={!hasChanges || !isUsernameValid || !username.trim()}
              className={`flex-1 py-3 px-4 rounded-lg font-medium transition-colors ${
                hasChanges && isUsernameValid && username.trim()
                  ? 'bg-orange-500 text-white hover:bg-orange-600'
                  : 'bg-gray-200 text-gray-400 cursor-not-allowed'
              }`}
            >
              Save Changes
            </button>
          </div>
          
          {hasChanges && (
            <p className="text-center text-xs text-gray-500 mt-3">
              Changes will be saved to your profile
            </p>
          )}
        </div>
      </div>
    </div>
  );
}