import React, { useState, useRef } from 'react';
import { X, Camera, Upload, RotateCw, Check } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ProfilePictureChangerProps {
  isOpen: boolean;
  onClose: () => void;
  currentAvatar: string;
  onSave: (newAvatar: string) => void;
}

export function ProfilePictureChanger({ isOpen, onClose, currentAvatar, onSave }: ProfilePictureChangerProps) {
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [rotation, setRotation] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setSelectedImage(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSave = () => {
    if (selectedImage) {
      onSave(selectedImage);
    }
    onClose();
    setSelectedImage(null);
    setRotation(0);
  };

  const handleCancel = () => {
    onClose();
    setSelectedImage(null);
    setRotation(0);
  };

  const triggerFileInput = () => {
    fileInputRef.current?.click();
  };

  const rotateImage = () => {
    setRotation((prev) => (prev + 90) % 360);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">
      <div className="bg-white rounded-2xl p-6 m-4 w-full max-w-md">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Change Profile Picture</h3>
          <button 
            onClick={handleCancel}
            className="p-1 rounded-full hover:bg-gray-100 transition-colors"
          >
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Current/Preview Image */}
        <div className="flex justify-center mb-6">
          <div className="w-32 h-32 rounded-full overflow-hidden bg-gray-100">
            {selectedImage ? (
              <img
                src={selectedImage}
                alt="Preview"
                className="w-full h-full object-cover"
                style={{ transform: `rotate(${rotation}deg)` }}
              />
            ) : (
              <ImageWithFallback
                src={currentAvatar}
                alt="Current profile"
                className="w-full h-full object-cover"
              />
            )}
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3 mb-6">
          {/* Upload New Photo */}
          <button
            onClick={triggerFileInput}
            className="w-full flex items-center justify-center space-x-3 p-4 bg-orange-50 hover:bg-orange-100 rounded-xl transition-colors"
          >
            <Upload size={20} className="text-orange-600" />
            <span className="font-medium text-orange-600">Upload New Photo</span>
          </button>

          {/* Take Photo (Camera) */}
          <button
            onClick={triggerFileInput}
            className="w-full flex items-center justify-center space-x-3 p-4 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors"
          >
            <Camera size={20} className="text-gray-600" />
            <span className="font-medium text-gray-600">Take Photo</span>
          </button>

          {/* Rotate Image (only show if image is selected) */}
          {selectedImage && (
            <button
              onClick={rotateImage}
              className="w-full flex items-center justify-center space-x-3 p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors"
            >
              <RotateCw size={20} className="text-blue-600" />
              <span className="font-medium text-blue-600">Rotate Image</span>
            </button>
          )}
        </div>

        {/* Save/Cancel Buttons */}
        <div className="flex space-x-3">
          <button
            onClick={handleCancel}
            className="flex-1 py-3 px-4 rounded-xl font-medium bg-gray-100 text-gray-700 hover:bg-gray-200 transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={!selectedImage}
            className={`flex-1 py-3 px-4 rounded-xl font-medium flex items-center justify-center space-x-2 transition-colors ${
              selectedImage
                ? 'bg-orange-400 text-white hover:bg-orange-500'
                : 'bg-gray-200 text-gray-400 cursor-not-allowed'
            }`}
          >
            <Check size={16} />
            <span>Save</span>
          </button>
        </div>

        {/* Hidden File Input */}
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileSelect}
          className="hidden"
        />

        {/* Tips */}
        <div className="mt-4 p-3 bg-gray-50 rounded-lg">
          <p className="text-xs text-gray-600 text-center">
            💡 For best results, use a high-quality square image
          </p>
        </div>
      </div>
    </div>
  );
}