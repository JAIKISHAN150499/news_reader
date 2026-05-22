class ReadTimeEstimator {
  ReadTimeEstimator._();

  static const int _wordsPerMinute = 200;


  static String estimate(String? content) {
    if (content == null || content.trim().isEmpty) return '1 min read';

    final wordCount = _countWords(content);
    if (wordCount == 0) return '1 min read';

    final minutes = (wordCount / _wordsPerMinute).ceil();
    final clampedMinutes = minutes.clamp(1, 60);

    return '$clampedMinutes min read';
  }

  static int countWords(String? content) {
    if (content == null || content.trim().isEmpty) return 0;
    return _countWords(content);
  }

  static int _countWords(String text) {

    return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
}