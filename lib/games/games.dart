import 'dart:math';

class Games {
  static String getQuestion({required List<String> questionList}) {
    var randIndex = Random().nextInt(questionList.length);
    return questionList[randIndex];
  }
}
