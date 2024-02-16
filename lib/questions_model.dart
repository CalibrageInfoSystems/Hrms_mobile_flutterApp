class questionmodel {
  final int questionid;
  final String question;

  questionmodel({
    required this.questionid,
    required this.question,
  });

  factory questionmodel.fromJson(Map<String, dynamic> json) {
    return questionmodel(
      questionid: json['questionId'],
      question: json['question'],
    );
  }
}
