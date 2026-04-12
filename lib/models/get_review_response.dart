class GetReviewResponse {
  final bool? status;
  final List<ReviewData>? data;

  GetReviewResponse({
    this.status,
    this.data,
  });

  factory GetReviewResponse.fromJson(Map<String, dynamic> json) {
    return GetReviewResponse(
      status: json['status'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ReviewData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class ReviewData {
  final int? rating;
  final String? comment;
  final String? createdAt;
  final User? user;

  ReviewData({
    this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'user': user?.toJson(),
    };
  }
}

class User {
  final String? name;
  final String? profilePicture;

  User({
    this.name,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profilePicture': profilePicture,
    };
  }
}
