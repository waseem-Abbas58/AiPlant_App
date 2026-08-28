class SearchHit {
  const SearchHit({
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final void Function() onOpen;
}
