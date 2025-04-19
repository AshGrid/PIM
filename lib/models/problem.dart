class Problem {
  final String problem;



  Problem({
    required this.problem,

  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      problem: json['problem'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem': problem,


    };
  }
}
