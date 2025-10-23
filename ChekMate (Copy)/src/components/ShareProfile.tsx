import React, { useState, useRef } from 'react';
import { X, Copy, Share2, MessageCircle, Mail, Download, QrCode, Check, ExternalLink, Instagram, Twitter, Facebook } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ShareProfileProps {
  isOpen: boolean;
  onClose: () => void;
  username: string;
  bio: string;
  avatar: string;
  profileStats?: {
    followers?: number;
    following?: number;
    posts?: number;
  };
}

export function ShareProfile({ 
  isOpen, 
  onClose, 
  username, 
  bio, 
  avatar,
  profileStats = { followers: 1234, following: 567, posts: 89 }
}: ShareProfileProps) {
  const [copied, setCopied] = useState(false);
  const [showQR, setShowQR] = useState(false);
  const [shareSuccess, setShareSuccess] = useState('');
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Generate profile URL
  const profileUrl = `https://chekmate.app/profile/${username}`;
  
  // Generate QR code data (mock for now)
  const generateQRCode = () => {
    // In a real app, you would use a QR code library like qrcode
    // For now, we'll show a placeholder
    return `data:image/svg+xml;base64,${btoa(`
      <svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
        <rect width="200" height="200" fill="white"/>
        <rect x="20" y="20" width="160" height="160" fill="black"/>
        <rect x="40" y="40" width="120" height="120" fill="white"/>
        <text x="100" y="105" text-anchor="middle" font-family="Arial" font-size="12" fill="black">QR Code</text>
        <text x="100" y="125" text-anchor="middle" font-family="Arial" font-size="8" fill="black">@${username}</text>
      </svg>
    `)}`;
  };

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(profileUrl);
      setCopied(true);
      setShareSuccess('Profile link copied to clipboard!');
      setTimeout(() => {
        setCopied(false);
        setShareSuccess('');
      }, 3000);
    } catch (err) {
      console.error('Failed to copy: ', err);
      setShareSuccess('Failed to copy link');
    }
  };

  const shareViaWebShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `Check out ${username}'s ChekMate profile!`,
          text: bio.length > 100 ? `${bio.substring(0, 100)}...` : bio,
          url: profileUrl,
        });
        setShareSuccess('Profile shared successfully!');
        setTimeout(() => setShareSuccess(''), 3000);
      } catch (err) {
        console.error('Error sharing:', err);
      }
    } else {
      // Fallback to copy link
      copyToClipboard();
    }
  };

  const shareToSocialMedia = (platform: string) => {
    const text = `Check out my ChekMate dating profile! ${bio.length > 50 ? bio.substring(0, 50) + '...' : bio}`;
    const url = profileUrl;
    
    let shareUrl = '';
    
    switch (platform) {
      case 'twitter':
        shareUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`;
        break;
      case 'facebook':
        shareUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}&quote=${encodeURIComponent(text)}`;
        break;
      case 'instagram':
        // Instagram doesn't support direct web sharing, so we copy the link
        copyToClipboard();
        setShareSuccess('Link copied! Paste it in your Instagram story or bio');
        return;
      case 'whatsapp':
        shareUrl = `https://wa.me/?text=${encodeURIComponent(`${text} ${url}`)}`;
        break;
      case 'sms':
        shareUrl = `sms:?body=${encodeURIComponent(`${text} ${url}`)}`;
        break;
      case 'email':
        shareUrl = `mailto:?subject=${encodeURIComponent(`Check out ${username}'s ChekMate profile`)}&body=${encodeURIComponent(`${text}\n\n${url}`)}`;
        break;
    }
    
    if (shareUrl) {
      window.open(shareUrl, '_blank');
      setShareSuccess(`Shared to ${platform}!`);
      setTimeout(() => setShareSuccess(''), 3000);
    }
  };

  const generateProfileCard = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Set canvas size
    canvas.width = 400;
    canvas.height = 600;

    // Background gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, 600);
    gradient.addColorStop(0, '#f97316');
    gradient.addColorStop(1, '#ea580c');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 400, 600);

    // Add profile content (simplified)
    ctx.fillStyle = 'white';
    ctx.font = 'bold 24px Arial';
    ctx.textAlign = 'center';
    ctx.fillText('ChekMate Profile', 200, 60);
    
    ctx.font = '18px Arial';
    ctx.fillText(`@${username}`, 200, 200);
    
    ctx.font = '14px Arial';
    const words = bio.split(' ');
    let line = '';
    let y = 240;
    
    for (let n = 0; n < words.length; n++) {
      const testLine = line + words[n] + ' ';
      const metrics = ctx.measureText(testLine);
      const testWidth = metrics.width;
      
      if (testWidth > 350 && n > 0) {
        ctx.fillText(line, 200, y);
        line = words[n] + ' ';
        y += 25;
      } else {
        line = testLine;
      }
    }
    ctx.fillText(line, 200, y);

    // Add QR code placeholder
    ctx.fillStyle = 'white';
    ctx.fillRect(150, 400, 100, 100);
    ctx.fillStyle = 'black';
    ctx.font = '12px Arial';
    ctx.fillText('QR Code', 200, 455);

    // Add app branding
    ctx.fillStyle = 'white';
    ctx.font = 'bold 16px Arial';
    ctx.fillText('chekmate.app', 200, 550);
  };

  const downloadProfileCard = () => {
    generateProfileCard();
    const canvas = canvasRef.current;
    if (!canvas) return;

    const link = document.createElement('a');
    link.download = `${username}-chekmate-profile.png`;
    link.href = canvas.toDataURL();
    link.click();
    
    setShareSuccess('Profile card downloaded!');
    setTimeout(() => setShareSuccess(''), 3000);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl w-full max-w-md max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-100">
          <h2 className="text-xl font-bold text-gray-900">Share Profile</h2>
          <button 
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Profile Preview */}
          <div className="bg-gradient-to-r from-orange-400 to-pink-500 rounded-2xl p-6 text-white text-center">
            <ImageWithFallback
              src={avatar}
              alt="Profile"
              className="w-20 h-20 rounded-full object-cover mx-auto mb-4 border-4 border-white"
            />
            <h3 className="text-xl font-bold mb-1">@{username}</h3>
            <p className="text-orange-100 text-sm mb-4 leading-relaxed">{bio}</p>
            
            <div className="flex justify-center space-x-6 text-sm">
              <div>
                <div className="font-bold">{profileStats.followers?.toLocaleString()}</div>
                <div className="text-orange-100">Followers</div>
              </div>
              <div>
                <div className="font-bold">{profileStats.following?.toLocaleString()}</div>
                <div className="text-orange-100">Following</div>
              </div>
              <div>
                <div className="font-bold">{profileStats.posts}</div>
                <div className="text-orange-100">Posts</div>
              </div>
            </div>
          </div>

          {/* Profile URL */}
          <div className="space-y-3">
            <h4 className="font-semibold text-gray-900">Profile Link</h4>
            <div className="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg">
              <ExternalLink size={16} className="text-gray-500 flex-shrink-0" />
              <span className="text-sm text-gray-600 flex-1 truncate">{profileUrl}</span>
              <button
                onClick={copyToClipboard}
                className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
                  copied 
                    ? 'bg-green-100 text-green-700' 
                    : 'bg-orange-100 text-orange-700 hover:bg-orange-200'
                }`}
              >
                {copied ? <Check size={14} /> : <Copy size={14} />}
              </button>
            </div>
          </div>

          {/* Quick Share Options */}
          <div className="space-y-3">
            <h4 className="font-semibold text-gray-900">Quick Share</h4>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={shareViaWebShare}
                className="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <Share2 size={18} className="text-orange-500" />
                <span className="text-sm font-medium">Share</span>
              </button>
              
              <button
                onClick={() => setShowQR(!showQR)}
                className="flex items-center space-x-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <QrCode size={18} className="text-orange-500" />
                <span className="text-sm font-medium">QR Code</span>
              </button>
            </div>
          </div>

          {/* QR Code Section */}
          {showQR && (
            <div className="space-y-3 bg-gray-50 rounded-lg p-4">
              <div className="flex items-center justify-between">
                <h4 className="font-semibold text-gray-900">QR Code</h4>
                <button
                  onClick={downloadProfileCard}
                  className="text-orange-600 hover:text-orange-700 text-sm font-medium"
                >
                  Download Card
                </button>
              </div>
              <div className="flex justify-center">
                <img 
                  src={generateQRCode()} 
                  alt="QR Code" 
                  className="w-32 h-32 border border-gray-200 rounded-lg"
                />
              </div>
              <p className="text-xs text-gray-600 text-center">
                Others can scan this QR code to view your profile
              </p>
            </div>
          )}

          {/* Social Media Sharing */}
          <div className="space-y-3">
            <h4 className="font-semibold text-gray-900">Share to Social Media</h4>
            <div className="grid grid-cols-3 gap-3">
              <button
                onClick={() => shareToSocialMedia('twitter')}
                className="flex flex-col items-center space-y-2 p-3 border border-gray-200 rounded-lg hover:bg-blue-50 hover:border-blue-200 transition-colors"
              >
                <Twitter size={20} className="text-blue-500" />
                <span className="text-xs font-medium">Twitter</span>
              </button>
              
              <button
                onClick={() => shareToSocialMedia('instagram')}
                className="flex flex-col items-center space-y-2 p-3 border border-gray-200 rounded-lg hover:bg-pink-50 hover:border-pink-200 transition-colors"
              >
                <Instagram size={20} className="text-pink-500" />
                <span className="text-xs font-medium">Instagram</span>
              </button>
              
              <button
                onClick={() => shareToSocialMedia('facebook')}
                className="flex flex-col items-center space-y-2 p-3 border border-gray-200 rounded-lg hover:bg-blue-50 hover:border-blue-200 transition-colors"
              >
                <Facebook size={20} className="text-blue-600" />
                <span className="text-xs font-medium">Facebook</span>
              </button>
            </div>
          </div>

          {/* Messaging Options */}
          <div className="space-y-3">
            <h4 className="font-semibold text-gray-900">Send Directly</h4>
            <div className="grid grid-cols-3 gap-3">
              <button
                onClick={() => shareToSocialMedia('whatsapp')}
                className="flex flex-col items-center space-y-2 p-3 border border-gray-200 rounded-lg hover:bg-green-50 hover:border-green-200 transition-colors"
              >
                <MessageCircle size={20} className="text-green-500" />
                <span className="text-xs font-medium">WhatsApp</span>
              </button>
              
              <button
                onClick={() => shareToSocialMedia('sms')}
                className="flex flex-col items-center space-y-2 p-3 border border-gray-200 rounded-lg hover:bg-blue-50 hover:border-blue-200 transition-colors"
              >
                <MessageCircle size={20} className="text-blue-500" />
                <span className="text-xs font-medium">SMS</span>
              </button>
              
              <button
                onClick={() => shareToSocialMedia('email')}
                className="flex flex-col items-center space-y-2 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 hover:border-gray-300 transition-colors"
              >
                <Mail size={20} className="text-gray-600" />
                <span className="text-xs font-medium">Email</span>
              </button>
            </div>
          </div>

          {/* Profile Card Download */}
          <div className="space-y-3">
            <h4 className="font-semibold text-gray-900">Profile Card</h4>
            <button
              onClick={downloadProfileCard}
              className="w-full flex items-center justify-center space-x-2 p-3 bg-orange-100 text-orange-700 rounded-lg hover:bg-orange-200 transition-colors"
            >
              <Download size={18} />
              <span className="font-medium">Download Profile Card</span>
            </button>
            <p className="text-xs text-gray-600 text-center">
              Download a shareable image of your profile
            </p>
          </div>

          {/* Privacy Notice */}
          <div className="bg-blue-50 rounded-lg p-4">
            <h4 className="text-sm font-medium text-blue-800 mb-1">Privacy & Safety</h4>
            <p className="text-xs text-blue-700">
              Your profile link is public and can be viewed by anyone. Only share with people you trust. 
              You can disable public profile viewing in Settings anytime.
            </p>
          </div>

          {/* Success Message */}
          {shareSuccess && (
            <div className="bg-green-50 border border-green-200 rounded-lg p-3">
              <div className="flex items-center space-x-2">
                <Check size={16} className="text-green-600" />
                <span className="text-sm text-green-700 font-medium">{shareSuccess}</span>
              </div>
            </div>
          )}
        </div>

        {/* Hidden Canvas for Profile Card Generation */}
        <canvas ref={canvasRef} style={{ display: 'none' }} />
      </div>
    </div>
  );
}