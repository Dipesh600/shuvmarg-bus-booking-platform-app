class GetReviewResponse {
  final bool? status;
  final List<ReviewData>? data;
  final ReviewStats? stats;

  GetReviewResponse({
    this.status,
    this.data,
    this.stats,
  });

  factory GetReviewResponse.fromJson(Map<String, dynamic> json) {
    return GetReviewResponse(
      status: json['status'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ReviewData.fromJson(item))
          .toList(),
      stats: json['stats'] != null
          ? ReviewStats.fromJson(json['stats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((item) => item.toJson()).toList(),
      'stats': stats?.toJson(),
    };
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution; // {1: count, 2: count, ...5: count}

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final rawDist = json['distribution'] as Map<String, dynamic>? ?? {};
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = (rawDist[i.toString()] ?? 0) as int;
    }
    return ReviewStats(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      distribution: distribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'distribution': distribution.map((k, v) => MapEntry(k.toString(), v)),
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
