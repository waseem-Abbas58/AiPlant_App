class ProfileNotifyItem {
  const ProfileNotifyItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class ProfileNotifyGroup {
  const ProfileNotifyGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ProfileNotifyItem> items;
}

class ProfileNotifications {
  ProfileNotifications._();

  static const groups = [
    ProfileNotifyGroup(
      title: 'Garden reminders',
      items: [
        ProfileNotifyItem(
          id: 'water',
          title: 'Water',
          subtitle: 'When a plant needs water',
        ),
        ProfileNotifyItem(
          id: 'mist',
          title: 'Mist',
          subtitle: 'When a plant needs misting',
        ),
        ProfileNotifyItem(
          id: 'fertilizer',
          title: 'Fertilizer',
          subtitle: 'When it is time to fertilize',
        ),
        ProfileNotifyItem(
          id: 'rotate',
          title: 'Rotate',
          subtitle: 'When to turn the pot for even light',
        ),
        ProfileNotifyItem(
          id: 'cut',
          title: 'Cut',
          subtitle: 'When it is time to prune',
        ),
      ],
    ),
    ProfileNotifyGroup(
      title: 'Subscription',
      items: [
        ProfileNotifyItem(
          id: 'plan_ending',
          title: 'Plan ending',
          subtitle: 'Before a trial or plan runs out',
        ),
        ProfileNotifyItem(
          id: 'plan_active',
          title: 'Plan updates',
          subtitle: 'When a plan starts or renews',
        ),
      ],
    ),
    ProfileNotifyGroup(
      title: 'Home',
      items: [
        ProfileNotifyItem(
          id: 'tips',
          title: 'Care tips',
          subtitle: 'Seasonal and weekly plant tips',
        ),
        ProfileNotifyItem(
          id: 'quiz',
          title: 'Weekly quiz',
          subtitle: 'Reminder when a new quiz is ready',
        ),
      ],
    ),
    ProfileNotifyGroup(
      title: 'Scan and chat',
      items: [
        ProfileNotifyItem(
          id: 'scan',
          title: 'Scan results',
          subtitle: 'When identify or disease scan is ready',
        ),
        ProfileNotifyItem(
          id: 'botanist',
          title: 'Botanist replies',
          subtitle: 'When Ask Botanist answers you',
        ),
      ],
    ),
  ];

  static List<String> get ids => [
        for (final group in groups)
          for (final item in group.items) item.id,
      ];
}
