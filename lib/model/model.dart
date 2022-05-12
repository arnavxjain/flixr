class Movie {
  final bool? adult;
  final String? title;
  final String? overview;
  final String? release;
  final int? budget;
  final int movieId;
  // final List<String> genres = [];
  final int? revenue;
  final int? runtime;
  final String? studio;
  final String? poster;
  final List? actors;
  final dynamic vote;

  Movie({
      this.adult,
      this.title,
      this.overview,
      this.release,
      this.budget,
      required this.movieId,
      this.revenue,
      this.runtime,
      this.studio,
      this.poster,
      this.actors,
      this.vote
  });
}

class Actor {
  final String? role;
  final String? name;
  final String? pic;
  final int? id;

  Actor({this.role, this.name, this.pic, this.id});

}