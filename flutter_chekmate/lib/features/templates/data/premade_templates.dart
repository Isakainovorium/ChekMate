import '../models/story_template_model.dart';

/// Service providing pre-made story templates
class PremadeTemplates {
  /// Get all pre-made templates for post creation
  static List<StoryTemplate> getAllTemplates() {
    return [
      _firstDateRedFlags,
      _ghostingRecovery,
      _successStories,
      _patternRecognition,
      _longDistanceDating,
      _polyamorousDating,
      _postDivorceDating,
    ];
  }

  /// Get template by predefined identifier
  static StoryTemplate? getTemplateById(String id) {
    return getAllTemplates().firstWhere(
      (template) => template.id == id,
      orElse: () => throw Exception('Template not found: $id'),
    );
  }

  /// First Date Red Flags template
  static final StoryTemplate _firstDateRedFlags = StoryTemplate(
    id: 'first_date_red_flags',
    title: 'First Date Red Flags',
    description: 'Document red flags you noticed on a first date',
    category: StoryTemplateCategory.firstDate,
    icon: 'flag',
    color: '#FF6B6B', // Red for warnings
    difficulty: 'Beginner',
    estimatedMinutes: 15,
    sections: const [
      StoryTemplateSection(
        id: 'venue',
        title: 'Venue & Arrival',
        description: 'What was the atmosphere like?',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Taken to sketchy area',
          'Way too fancy for budget',
          'Talked about exes immediately',
          'Late without apology',
        ],
        helpText: 'Select any behaviors that felt off',
      ),
      StoryTemplateSection(
        id: 'conversation',
        title: 'Conversation Red Flags',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Interrupted me constantly',
          'Only talked about appearance',
          'Pushed personal boundaries',
          'Made inappropriate jokes',
          'Bad-mouthed exes',
        ],
        helpText: 'Check all that apply',
      ),
      StoryTemplateSection(
        id: 'body_language',
        title: 'Body Language & Energy',
        type: StoryTemplateSectionType.multipleChoice,
        required: false,
        options: [
          'Avoided eye contact',
          'Watched phone constantly',
          'Seemed disinterested or bored',
          'Too intense or aggressive',
          'Invaded personal space',
        ],
        helpText: 'How did you feel their energy?',
      ),
      StoryTemplateSection(
        id: 'deal_breaker',
        title: 'Main Deal Breaker',
        description: 'What was the biggest red flag?',
        type: StoryTemplateSectionType.textInput,
        required: true,
        placeholder: 'The thing that made me realize this wouldn\'t work...',
        helpText: 'Describe what ultimately ended this date',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const ['first date', 'warning signs', 'safety', 'red flags'],
    usageCount: 1250,
    averageRating: 0.0,
  );

  /// Ghosting Recovery template
  static final StoryTemplate _ghostingRecovery = StoryTemplate(
    id: 'ghosting_recovery',
    title: 'Ghosting Recovery',
    description: 'Process your experience with being ghosted',
    category: StoryTemplateCategory.ghostingRecovery,
    icon: 'ghost',
    color: '#F5A623', // Orange for healing
    difficulty: 'Intermediate',
    estimatedMinutes: 20,
    sections: const [
      StoryTemplateSection(
        id: 'timeline',
        title: 'The Timeline',
        description: 'How long did it last?',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'One date, ghosted after',
          'Multiple dates, ghosting after commitment talk',
          'Long-term relationship, ghosted out of nowhere',
          'Friends with benefits arrangement ended',
        ],
        helpText: 'When did the ghosting happen?',
      ),
      StoryTemplateSection(
        id: 'emotional_impact',
        title: 'Emotional Impact',
        type: StoryTemplateSectionType.rating,
        required: true,
        ratingScale: RatingScale(
          min: 1,
          max: 10,
          labels: {
            '1': 'Not bothered at all',
            '5': 'Mildly disappointed',
            '10': 'Devastated and heartbroken',
          },
        ),
        helpText: 'Rate how much it affected you on a scale of 1-10',
      ),
      StoryTemplateSection(
        id: 'lessons',
        title: 'Lessons Learned',
        description: 'What did you take away?',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Trust people\'s actions, not words',
          'Pay attention to red flags I ignored',
          'I deserve better treatment',
          'Dating is a numbers game',
          'Better to be single than invisible',
        ],
        helpText: 'Check all lessons that resonated',
      ),
      StoryTemplateSection(
        id: 'self_care',
        title: 'Self-Care Actions',
        type: StoryTemplateSectionType.multipleChoice,
        required: false,
        options: [
          'Treated myself to something nice',
          'Spent time with supportive friends',
          'Focused on personal goals',
          'Journaled the experience',
          'Deleted social media for a while',
        ],
        helpText: 'How are you taking care of yourself?',
      ),
      StoryTemplateSection(
        id: 'dating_resume',
        title: 'Dating Resume Update',
        description: 'What did you add to your deal-breakers list?',
        type: StoryTemplateSectionType.textInput,
        required: false,
        placeholder: 'I now require...\nI will not tolerate...',
        helpText: 'Update your dating standards',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const ['ghosting', 'breakup', 'healing', 'boundaries'],
    usageCount: 890,
    averageRating: 0.0,
  );

  /// Success Stories template
  static final StoryTemplate _successStories = StoryTemplate(
    id: 'success_stories',
    title: 'Success Stories',
    description: 'Celebrate a great dating experience',
    category: StoryTemplateCategory.successStories,
    icon: 'celebration',
    color: '#38A169', // Green for positive experiences
    difficulty: 'Beginner',
    estimatedMinutes: 25,
    sections: const [
      StoryTemplateSection(
        id: 'what_worked',
        title: 'What Made It Great',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Excellent communication',
          'Mutual respect and boundaries',
          'Shared values and interests',
          'Emotional intelligence shown',
          'Physical chemistry was amazing',
          'Fun and easy conversation flowed naturally',
        ],
        helpText: 'Check all the positive qualities',
      ),
      StoryTemplateSection(
        id: 'compatibility',
        title: 'Compatibility Score',
        description: 'How well did your personalities mesh?',
        type: StoryTemplateSectionType.rating,
        required: true,
        ratingScale: RatingScale(
          min: 1,
          max: 10,
          labels: {
            '1': 'Complete opposites',
            '5': 'Decent match',
            '10': 'Soulmates',
          },
        ),
      ),
      StoryTemplateSection(
        id: 'deal_makers',
        title: 'Future Deal Makers',
        description: 'What would you want in future relationships?',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Someone as kind and thoughtful',
          'Good communication skills',
          'Similar sense of humor',
          'Emotional maturity level',
          'Physical attraction balance',
          'Future goals alignment',
        ],
        helpText: 'What to look for again',
      ),
      StoryTemplateSection(
        id: 'proud_moment',
        title: 'Proudest Moment',
        description: 'Your favorite part of the experience',
        type: StoryTemplateSectionType.textInput,
        required: true,
        placeholder: 'The moment I felt most happy was...',
        helpText: 'Celebrate what went right',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const ['success', 'positive', 'celebrate', 'compatibility'],
    usageCount: 1450,
    averageRating: 0.0,
  );

  /// Pattern Recognition template
  static final StoryTemplate _patternRecognition = StoryTemplate(
    id: 'pattern_recognition',
    title: 'Pattern Recognition',
    description: 'Identify repeated behaviors in relationships',
    category: StoryTemplateCategory.patternRecognition,
    icon: 'analytics',
    color: '#1E3A8A', // Navy for analysis
    difficulty: 'Advanced',
    estimatedMinutes: 30,
    sections: const [
      StoryTemplateSection(
        id: 'recurring_themes',
        title: 'Recurring Themes',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Ghosting after emotional investment',
          'Love bombing followed by withdrawal',
          'Always choosing unavailable partners',
          'Ignoring red flags due to chemistry',
          'Staying too long in unhealthy situations',
          'Attracting similar personality types painfully',
        ],
        helpText: 'Which patterns do you keep seeing?',
      ),
      StoryTemplateSection(
        id: 'root_cause',
        title: 'Possible Root Causes',
        type: StoryTemplateSectionType.multipleChoice,
        required: false,
        options: [
          'Fear of loneliness drives choices',
          'Low self-esteem attracts toxic dynamics',
          'Childhood attachment patterns repeating',
          'Societal pressure to be in a relationship',
          'Comfortable with unhealthy familiarity',
          'Still healing from past betrayals',
        ],
        helpText: 'What might be driving these patterns?',
      ),
      StoryTemplateSection(
        id: 'broken_pattern',
        title: 'Breaking the Pattern',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'I deleted dating apps for self-reflection',
          'Started therapy for attachment issues',
          'Built meaningful life outside of dating',
          'Learned to sit with being single',
          'Journal daily about relationship wants',
          'Seeking friends\' input on dates',
        ],
        helpText: 'What are you doing differently?',
      ),
      StoryTemplateSection(
        id: 'pattern_insight',
        title: 'Biggest Insight',
        description: 'What revelation helped break the pattern?',
        type: StoryTemplateSectionType.textInput,
        required: true,
        placeholder: 'I finally realized that...',
        helpText: 'The aha moment that changed everything',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const ['patterns', 'growth', 'reflection', 'healing'],
    usageCount: 675,
    averageRating: 0.0,
  );

  /// Long Distance Dating template
  static final StoryTemplate _longDistanceDating = StoryTemplate(
    id: 'long_distance_dating',
    title: 'Long Distance Journey',
    description: 'Document your long-distance dating story',
    category: StoryTemplateCategory.longDistance,
    icon: 'flight',
    color: '#F5A623', // Golden for journeys
    difficulty: 'Intermediate',
    estimatedMinutes: 20,
    sections: const [
      StoryTemplateSection(
        id: 'distance_and_time',
        title: 'Distance & Timeline',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Same country, ~500 miles apart',
          'International (same continent)',
          'Intercontinental relationship',
          'Met online, never in person yet',
          'Friends first, then long distance',
        ],
        helpText: 'How far apart are/were you?',
      ),
      StoryTemplateSection(
        id: 'communication_style',
        title: 'Communication Rhythm',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Daily calls + texts throughout day',
          'Daily check-ins, separate activities',
          'Every other day deep conversations',
          'Weekend-long video calls only',
          'Text-based relationship primarily',
        ],
        helpText: 'How often did you connect?',
      ),
      StoryTemplateSection(
        id: 'ld_challenges',
        title: 'Long Distance Challenges',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Trust building difficulties',
          'Different social lives causing jealousy',
          'Physical intimacy missing affected us',
          'Miscommunications via text',
          'Different time zones complicated things',
          'Family/friends not supportive',
        ],
        helpText: 'What made long distance hard?',
      ),
      StoryTemplateSection(
        id: 'ld_successes',
        title: 'What Made It Successful',
        type: StoryTemplateSectionType.multipleChoice,
        required: false,
        options: [
          'Strong emotional connection from start',
          'Clear communication about expectations',
          'Regular visits despite distance',
          'Shared virtual activities together',
          'Trust and respect were never issues',
          'Had realistic timelines for moving',
        ],
        helpText: 'Celebrate what worked',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const ['long distance', 'relationships', 'travel', 'communication'],
    usageCount: 920,
    averageRating: 0.0,
  );

  /// Polyamorous Dating template
  static final StoryTemplate _polyamorousDating = StoryTemplate(
    id: 'polyamorous_dating',
    title: 'Polyamory Experience',
    description: 'Share your polyamorous relationship experiences',
    category: StoryTemplateCategory.polyamorous,
    icon: 'group',
    color: '#8B5CF6', // Purple for alternative relationships
    difficulty: 'Intermediate',
    estimatedMinutes: 25,
    sections: const [
      StoryTemplateSection(
        id: 'relationship_structure',
        title: 'Relationship Structure',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Three-person throuple/triad',
          'One committed relationship, casual others',
          'Multiple committed relationships',
          'Hinge/polyamory (non-hierarchical)',
          'Solo polyamory (independent relationships)',
          'Relationship anarchy (no hierarchy/ownership)',
        ],
        helpText: 'How was your poly structure defined?',
      ),
      StoryTemplateSection(
        id: 'communication_challenge',
        title: 'Communication Style',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Highly communicative about all feelings',
          'Open but not constant check-ins',
          'Expected emotional independence',
          'Struggled with expressing needs',
          'Over-communicated and got overwhelmed',
          'Used calendars/schedules for coordination',
        ],
        helpText: 'How did you all communicate?',
      ),
      StoryTemplateSection(
        id: 'jealousy_experience',
        title: 'Jealousy & Compersion',
        type: StoryTemplateSectionType.rating,
        required: true,
        ratingScale: RatingScale(
          min: 1,
          max: 10,
          labels: {
            '1': 'Managed jealousy perfectly',
            '5': 'Had jealous moments but processed them',
            '10': 'Jealousy destroyed the connection',
          },
        ),
      ),
      StoryTemplateSection(
        id: 'poly_lessons',
        title: 'Polyamory Lessons Learned',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Communication is non-negotiable',
          'Jealousy is normal and processable',
          'Different people need different things',
          'Compersion takes effort and time',
          'Not everyone is poly-compatible',
          'Time management gets complex',
        ],
        helpText: 'What wisdom did you gain?',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const [
      'polyamory',
      'alternative relationships',
      'communication',
      'jealousy'
    ],
    usageCount: 320,
    averageRating: 0.0,
  );

  /// Post-Divorce Dating template
  static final StoryTemplate _postDivorceDating = StoryTemplate(
    id: 'post_divorce_dating',
    title: 'Post-Divorce Dating',
    description: 'Your experience dating after divorce',
    category: StoryTemplateCategory.postDivorce,
    icon: 'phoenix',
    color: '#F5A623', // Golden for rebirth
    difficulty: 'Intermediate',
    estimatedMinutes: 20,
    sections: const [
      StoryTemplateSection(
        id: 'divorce_timeline',
        title: 'Time Since Divorce',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Less than 1 year',
          '1-2 years',
          '2-5 years',
          '5-10 years',
          'More than 10 years',
          'Divorce recently finalized',
        ],
        helpText: 'How long ago was your divorce?',
      ),
      StoryTemplateSection(
        id: 'dating_hesitations',
        title: 'Biggest Hesitations',
        type: StoryTemplateSectionType.multipleChoice,
        required: true,
        options: [
          'Trust issues from betrayal',
          'Emotional baggage getting in the way',
          'Fear of another heartbreak',
          'Kids making things complicated',
          'Financial concerns after divorce',
          'Comparing everyone to my ex',
        ],
        helpText: 'What scared you about dating again?',
      ),
      StoryTemplateSection(
        id: 'healing_journey',
        title: 'Healing & Growth',
        type: StoryTemplateSectionType.multipleChoice,
        required: false,
        options: [
          'Therapy helped immensely',
          'Focused on myself first',
          'Journaling processed emotions',
          'Friends provided support',
          'Travel/experiences built confidence',
          'Still actively healing',
        ],
        helpText: 'How are you healing?',
      ),
      StoryTemplateSection(
        id: 'post_divorce_wisdom',
        title: 'Post-Divorce Wisdom',
        type: StoryTemplateSectionType.multipleChoice,
        required: false,
        options: [
          'Communication is everything',
          'Never ignore red flags again',
          'Emotional maturity matters most',
          'Children deserve stability first',
          'Love after loss is beautiful',
          'Trust can be rebuilt with the right person',
        ],
        helpText: 'What insights help you now?',
      ),
      StoryTemplateSection(
        id: 'dating_experience',
        title: 'Your Dating Experience So Far',
        description: 'Share any recent dating story briefly',
        type: StoryTemplateSectionType.textInput,
        required: false,
        placeholder: 'Something surprising I learned...',
        helpText: 'Optional recent experience summary',
      ),
    ],
    version: '1.0',
    isActive: true,
    createdAt: DateTime.now(),
    tags: const ['divorce', 'healing', 'second chances', 'growth'],
    usageCount: 580,
    averageRating: 0.0,
  );
}
