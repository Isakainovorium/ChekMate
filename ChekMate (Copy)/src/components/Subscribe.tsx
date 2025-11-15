import React, { useState } from 'react';
import { Check, X, Crown, Heart, Star, Shield, Zap, Users, MessageCircle, Video, Gift, Sparkles } from 'lucide-react';

const subscriptionPlans = [
  {
    id: 'free',
    name: 'Free',
    price: '$0',
    period: 'forever',
    description: 'Get started with basic ChekMate features',
    color: 'gray',
    features: [
      { name: 'Basic profile creation', included: true },
      { name: 'Limited daily swipes (10)', included: true },
      { name: 'Basic matching algorithm', included: true },
      { name: 'Standard post creation', included: true },
      { name: 'View stories', included: true },
      { name: 'Advanced filters', included: false },
      { name: 'Unlimited swipes', included: false },
      { name: 'Priority matching', included: false },
      { name: 'Ad-free experience', included: false },
      { name: 'Read receipts', included: false },
      { name: 'Profile boost', included: false },
      { name: 'Video calling', included: false }
    ]
  },
  {
    id: 'premium',
    name: 'Premium',
    price: '$9.99',
    period: 'per month',
    description: 'Enhanced dating experience with premium features',
    color: 'orange',
    popular: true,
    features: [
      { name: 'Everything in Free', included: true },
      { name: 'Unlimited daily swipes', included: true },
      { name: 'Advanced matching algorithm', included: true },
      { name: 'Advanced filters (age, location, interests)', included: true },
      { name: 'Ad-free experience', included: true },
      { name: 'Read receipts', included: true },
      { name: 'Priority customer support', included: true },
      { name: 'Monthly profile boost', included: true },
      { name: 'Video calling', included: false },
      { name: 'VIP badge', included: false },
      { name: 'Exclusive premium content', included: false },
      { name: 'Advanced analytics', included: false }
    ]
  },
  {
    id: 'pro',
    name: 'Pro',
    price: '$19.99',
    period: 'per month',
    description: 'Ultimate dating experience for serious daters',
    color: 'purple',
    features: [
      { name: 'Everything in Premium', included: true },
      { name: 'Video calling & voice messages', included: true },
      { name: 'VIP profile badge', included: true },
      { name: 'Exclusive premium content access', included: true },
      { name: 'Advanced dating analytics', included: true },
      { name: 'Weekly profile boosts', included: true },
      { name: 'Priority matching algorithm', included: true },
      { name: 'Relationship coaching access', included: true },
      { name: 'Custom profile themes', included: true },
      { name: 'Early access to new features', included: true },
      { name: 'Verified profile badge', included: true },
      { name: 'Premium dating events invites', included: true }
    ]
  }
];

const premiumFeatures = [
  {
    icon: Heart,
    title: 'Smart Matching',
    description: 'Advanced AI algorithm finds your perfect match based on compatibility',
    color: 'text-pink-500'
  },
  {
    icon: Shield,
    title: 'Verified Profiles',
    description: 'Date with confidence knowing profiles are verified and authentic',
    color: 'text-blue-500'
  },
  {
    icon: Zap,
    title: 'Profile Boosts',
    description: 'Get 10x more visibility with priority placement in potential matches',
    color: 'text-yellow-500'
  },
  {
    icon: Video,
    title: 'Video Dating',
    description: 'Connect face-to-face with secure in-app video calls',
    color: 'text-green-500'
  },
  {
    icon: Users,
    title: 'Exclusive Events',
    description: 'Access to premium dating events and meetups in your area',
    color: 'text-purple-500'
  },
  {
    icon: Sparkles,
    title: 'Ad-Free Experience',
    description: 'Enjoy uninterrupted browsing without any advertisements',
    color: 'text-orange-500'
  }
];

interface SubscribeProps {
  currentPlan?: string;
}

export function Subscribe({ currentPlan = 'free' }: SubscribeProps) {
  const [selectedPlan, setSelectedPlan] = useState(currentPlan);
  const [billingCycle, setBillingCycle] = useState<'monthly' | 'yearly'>('monthly');
  const [showPaymentModal, setShowPaymentModal] = useState(false);

  const getDiscountedPrice = (price: string) => {
    if (billingCycle === 'yearly' && price !== '$0') {
      const monthlyPrice = parseFloat(price.replace('$', ''));
      const yearlyPrice = monthlyPrice * 12 * 0.8; // 20% discount
      return `$${yearlyPrice.toFixed(2)}`;
    }
    return price;
  };

  const PlanCard = ({ plan }: { plan: typeof subscriptionPlans[0] }) => {
    const isSelected = selectedPlan === plan.id;
    const isCurrentPlan = currentPlan === plan.id;
    
    return (
      <div className={`relative bg-white rounded-2xl p-6 border-2 transition-all duration-200 ${
        isSelected 
          ? plan.color === 'orange' 
            ? 'border-orange-400 shadow-lg transform scale-105' 
            : plan.color === 'purple'
            ? 'border-purple-400 shadow-lg transform scale-105'
            : 'border-gray-400 shadow-lg transform scale-105'
          : 'border-gray-200 hover:border-gray-300'
      }`}>
        {plan.popular && (
          <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
            <span className="bg-orange-400 text-white px-4 py-1 rounded-full text-sm font-medium">
              Most Popular
            </span>
          </div>
        )}
        
        {isCurrentPlan && (
          <div className="absolute -top-3 right-4">
            <span className="bg-green-500 text-white px-3 py-1 rounded-full text-xs font-medium">
              Current Plan
            </span>
          </div>
        )}

        <div className="text-center mb-6">
          <h3 className="text-xl font-bold text-gray-900 mb-2">{plan.name}</h3>
          <div className="mb-2">
            <span className="text-3xl font-bold text-gray-900">
              {billingCycle === 'yearly' && plan.price !== '$0' 
                ? getDiscountedPrice(plan.price)
                : plan.price
              }
            </span>
            {plan.price !== '$0' && (
              <span className="text-gray-600 text-sm ml-1">
                /{billingCycle === 'yearly' ? 'year' : 'month'}
              </span>
            )}
          </div>
          {billingCycle === 'yearly' && plan.price !== '$0' && (
            <div className="text-green-600 text-sm font-medium">
              Save 20% annually
            </div>
          )}
          <p className="text-gray-600 text-sm">{plan.description}</p>
        </div>

        <div className="space-y-3 mb-6">
          {plan.features.map((feature, index) => (
            <div key={index} className="flex items-center space-x-3">
              {feature.included ? (
                <Check size={16} className="text-green-500 flex-shrink-0" />
              ) : (
                <X size={16} className="text-gray-300 flex-shrink-0" />
              )}
              <span className={`text-sm ${
                feature.included ? 'text-gray-900' : 'text-gray-400'
              }`}>
                {feature.name}
              </span>
            </div>
          ))}
        </div>

        <button
          onClick={() => {
            setSelectedPlan(plan.id);
            if (plan.id !== 'free' && !isCurrentPlan) {
              setShowPaymentModal(true);
            }
          }}
          disabled={isCurrentPlan}
          className={`w-full py-3 rounded-lg font-medium transition-colors ${
            isCurrentPlan
              ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
              : plan.color === 'orange'
              ? 'bg-orange-400 text-white hover:bg-orange-500'
              : plan.color === 'purple'
              ? 'bg-purple-500 text-white hover:bg-purple-600'
              : 'bg-gray-800 text-white hover:bg-gray-900'
          }`}
        >
          {isCurrentPlan ? 'Current Plan' : plan.price === '$0' ? 'Get Started' : 'Upgrade Now'}
        </button>
      </div>
    );
  };

  const PaymentModal = () => {
    if (!showPaymentModal) return null;

    const selectedPlanData = subscriptionPlans.find(p => p.id === selectedPlan);

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl w-full max-w-md max-h-[90vh] overflow-y-auto">
          <div className="p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-bold text-gray-900">Complete Payment</h2>
              <button onClick={() => setShowPaymentModal(false)} className="text-gray-500">
                <X size={24} />
              </button>
            </div>

            {/* Plan Summary */}
            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="flex items-center justify-between mb-2">
                <span className="font-semibold text-gray-900">{selectedPlanData?.name} Plan</span>
                <span className="font-bold text-gray-900">
                  {billingCycle === 'yearly' 
                    ? getDiscountedPrice(selectedPlanData?.price || '$0')
                    : selectedPlanData?.price
                  }
                </span>
              </div>
              <div className="text-sm text-gray-600">
                Billed {billingCycle === 'yearly' ? 'annually' : 'monthly'}
              </div>
              {billingCycle === 'yearly' && (
                <div className="text-sm text-green-600 font-medium">
                  You save 20% with annual billing
                </div>
              )}
            </div>

            {/* Payment Form */}
            <form className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Card Number
                </label>
                <input
                  type="text"
                  placeholder="1234 5678 9012 3456"
                  className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Expiry Date
                  </label>
                  <input
                    type="text"
                    placeholder="MM/YY"
                    className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    CVC
                  </label>
                  <input
                    type="text"
                    placeholder="123"
                    className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cardholder Name
                </label>
                <input
                  type="text"
                  placeholder="John Doe"
                  className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400"
                />
              </div>
            </form>

            {/* Terms */}
            <div className="mt-6 p-4 bg-gray-50 rounded-lg">
              <p className="text-xs text-gray-600">
                By subscribing, you agree to our Terms of Service and Privacy Policy. 
                Your subscription will auto-renew unless cancelled.
              </p>
            </div>

            {/* Payment Button */}
            <button
              onClick={() => {
                // Simulate payment processing
                setTimeout(() => {
                  setShowPaymentModal(false);
                  alert('Payment successful! Welcome to ' + selectedPlanData?.name + '!');
                }, 1000);
              }}
              className="w-full mt-6 py-3 bg-orange-400 text-white rounded-lg font-medium hover:bg-orange-500 transition-colors"
            >
              Subscribe Now
            </button>
          </div>
        </div>
      </div>
    );
  };

  return (
    <>
      <PaymentModal />
      
      <div className="pb-16">
        {/* Hero Section */}
        <div className="bg-gradient-to-br from-orange-400 to-pink-500 text-white p-8 text-center">
          <Crown size={48} className="mx-auto mb-4 text-yellow-300" />
          <h1 className="text-3xl font-bold mb-2">Upgrade Your Dating Game</h1>
          <p className="text-orange-100 max-w-md mx-auto">
            Unlock premium features and find meaningful connections faster with ChekMate Premium
          </p>
        </div>

        {/* Billing Toggle */}
        <div className="bg-white border-b border-gray-100 px-4 py-4">
          <div className="flex items-center justify-center">
            <div className="bg-gray-100 rounded-full p-1 flex">
              <button
                onClick={() => setBillingCycle('monthly')}
                className={`px-6 py-2 rounded-full font-medium transition-colors ${
                  billingCycle === 'monthly'
                    ? 'bg-white text-gray-900 shadow-sm'
                    : 'text-gray-600'
                }`}
              >
                Monthly
              </button>
              <button
                onClick={() => setBillingCycle('yearly')}
                className={`px-6 py-2 rounded-full font-medium transition-colors relative ${
                  billingCycle === 'yearly'
                    ? 'bg-white text-gray-900 shadow-sm'
                    : 'text-gray-600'
                }`}
              >
                Yearly
                <span className="absolute -top-1 -right-1 bg-green-500 text-white text-xs px-1 rounded">
                  20% OFF
                </span>
              </button>
            </div>
          </div>
        </div>

        {/* Subscription Plans */}
        <div className="p-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            {subscriptionPlans.map((plan) => (
              <PlanCard key={plan.id} plan={plan} />
            ))}
          </div>
        </div>

        {/* Premium Features */}
        <div className="bg-white m-4 rounded-2xl p-6">
          <h2 className="text-xl font-bold text-gray-900 text-center mb-6">
            Why Choose ChekMate Premium?
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {premiumFeatures.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div key={index} className="flex items-start space-x-4">
                  <div className={`p-3 rounded-lg bg-gray-50`}>
                    <Icon size={24} className={feature.color} />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-1">{feature.title}</h3>
                    <p className="text-gray-600 text-sm">{feature.description}</p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Current Plan Status */}
        <div className="bg-white m-4 rounded-2xl p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Your Subscription</h2>
          
          <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
            <div>
              <h3 className="font-semibold text-gray-900 capitalize">{currentPlan} Plan</h3>
              <p className="text-gray-600 text-sm">
                {currentPlan === 'free' ? 'Free forever' : 'Next billing: January 15, 2025'}
              </p>
            </div>
            
            {currentPlan !== 'free' && (
              <button className="text-orange-400 font-medium hover:text-orange-500 transition-colors">
                Manage Subscription
              </button>
            )}
          </div>

          {currentPlan !== 'free' && (
            <div className="mt-4 p-4 bg-green-50 rounded-lg">
              <div className="flex items-center space-x-2 text-green-700">
                <Check size={16} />
                <span className="font-medium">Premium features active</span>
              </div>
              <p className="text-green-600 text-sm mt-1">
                Enjoying unlimited swipes, ad-free experience, and priority matching
              </p>
            </div>
          )}
        </div>

        {/* FAQ Section */}
        <div className="bg-white m-4 rounded-2xl p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Frequently Asked Questions</h2>
          
          <div className="space-y-4">
            <div>
              <h3 className="font-semibold text-gray-900 mb-1">Can I cancel anytime?</h3>
              <p className="text-gray-600 text-sm">
                Yes, you can cancel your subscription at any time. You'll continue to have access to premium features until your current billing period ends.
              </p>
            </div>
            
            <div>
              <h3 className="font-semibold text-gray-900 mb-1">What payment methods do you accept?</h3>
              <p className="text-gray-600 text-sm">
                We accept all major credit cards, PayPal, and Apple Pay for your convenience.
              </p>
            </div>
            
            <div>
              <h3 className="font-semibold text-gray-900 mb-1">Is my data secure?</h3>
              <p className="text-gray-600 text-sm">
                Absolutely. We use bank-level encryption to protect your personal and payment information.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}