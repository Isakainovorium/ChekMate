import React from 'react';
import { ArrowLeft, HelpCircle, ChevronRight, Mail, Phone, MapPin, Globe, FileText, Share2, LogOut } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import exampleImage from 'figma:asset/c4705b1f451123afdca76f3e602499c1d2aa7237.png';

interface SettingsPageProps {
  onBack: () => void;
}

export function SettingsPage({ onBack }: SettingsPageProps) {
  const settingsItems = [
    {
      id: 'username',
      icon: null,
      label: '@reallygreatsite',
      subtitle: 'Username',
      hasArrow: true
    },
    {
      id: 'email',
      icon: Mail,
      label: 'hello@reallygreatsite.com',
      subtitle: 'E-mail Address',
      hasArrow: true
    },
    {
      id: 'password',
      icon: Phone,
      label: 'Change Password',
      subtitle: null,
      hasArrow: true
    },
    {
      id: 'address',
      icon: MapPin,
      label: '123 Anywhere St., Any City, ST 12345',
      subtitle: 'Address',
      hasArrow: true
    }
  ];

  const appSettings = [
    {
      id: 'language',
      icon: Globe,
      label: 'English',
      subtitle: 'Language',
      hasArrow: true
    },
    {
      id: 'privacy',
      icon: null,
      label: 'Privacy Policy',
      subtitle: null,
      hasArrow: false
    },
    {
      id: 'terms',
      icon: null,
      label: 'Terms of Use',
      subtitle: null,
      hasArrow: false
    },
    {
      id: 'conditions',
      icon: FileText,
      label: 'Terms & Conditions',
      subtitle: null,
      hasArrow: true
    },
    {
      id: 'share',
      icon: Share2,
      label: 'Share this app',
      subtitle: null,
      hasArrow: true
    }
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-4 border-b border-gray-100">
        <button onClick={onBack} className="flex items-center space-x-2">
          <div className="p-2 bg-gray-800 rounded-lg">
            <ArrowLeft size={20} className="text-white" />
          </div>
          <span className="font-medium text-gray-900">Back</span>
        </button>
        
        <button className="p-2 bg-gray-800 rounded-lg">
          <HelpCircle size={20} className="text-white" />
        </button>
      </div>

      {/* Profile Section */}
      <div className="px-4 py-6 border-b border-gray-100">
        <div className="flex items-center space-x-4">
          <ImageWithFallback
            src={exampleImage}
            alt="Simone Gabrielle"
            className="w-16 h-16 rounded-full object-cover"
          />
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Simone Gabrielle</h2>
            <p className="text-gray-600">Settings & Privacy</p>
          </div>
        </div>
      </div>

      {/* General Settings */}
      <div className="px-4 py-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-6">General Settings</h3>
        
        <div className="space-y-1">
          {settingsItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                className="w-full flex items-center space-x-4 py-4 border-b border-gray-100 last:border-b-0"
              >
                {Icon ? (
                  <Icon size={20} className="text-gray-600 flex-shrink-0" />
                ) : (
                  <div className="w-5 h-5 flex-shrink-0" />
                )}
                
                <div className="flex-1 text-left">
                  <p className="text-gray-900">{item.label}</p>
                  {item.subtitle && (
                    <p className="text-sm text-gray-600">{item.subtitle}</p>
                  )}
                </div>
                
                {item.hasArrow && (
                  <div className="p-1 bg-gray-800 rounded-md">
                    <ChevronRight size={16} className="text-white" />
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* Settings */}
      <div className="px-4 py-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-6">Settings</h3>
        
        <div className="space-y-1">
          {appSettings.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                className="w-full flex items-center space-x-4 py-4 border-b border-gray-100 last:border-b-0"
              >
                {Icon ? (
                  <Icon size={20} className="text-gray-600 flex-shrink-0" />
                ) : (
                  <div className="w-5 h-5 flex-shrink-0" />
                )}
                
                <div className="flex-1 text-left">
                  <p className="text-gray-900">{item.label}</p>
                  {item.subtitle && (
                    <p className="text-sm text-gray-600">{item.subtitle}</p>
                  )}
                </div>
                
                {item.hasArrow && (
                  <div className="p-1 bg-gray-800 rounded-md">
                    <ChevronRight size={16} className="text-white" />
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* Sign Out */}
      <div className="px-4 py-6 border-t border-gray-100">
        <div className="flex items-center justify-between">
          <button className="flex items-center space-x-3 text-gray-900">
            <LogOut size={20} className="text-gray-600" />
            <span className="font-medium">Sign Out</span>
          </button>
          
          <button className="text-sm text-gray-600">
            Privacy & Policy
          </button>
        </div>
      </div>
    </div>
  );
}