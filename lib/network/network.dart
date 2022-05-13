import 'dart:convert';

import 'package:flixr/model/model.dart';
import 'package:http/http.dart';

const apiKey = "a47fb0ba038702bdab7994999dce820b";

class Network {
  Future<List<Movie>> searchGlobal(String term) async {
    Response response = await get(Uri.parse(Uri.encodeFull("http://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$term")));

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      List<Movie> listOfResults = [];
      int lengthOfRes = res["results"].length;

      for (int x = 0; x < lengthOfRes; x++) {
        final dataindex = res["results"][x];
        Movie newMovieX = Movie(
          title: dataindex["title"],
          adult: dataindex["adult"],
          overview: dataindex["overview"],
          release: dataindex["release_date"],
          poster: dataindex["poster_path"],
          movieId: dataindex["id"],
          vote: dataindex["vote_average"]
        );
        listOfResults.add(newMovieX);
      }

      return listOfResults;
    }

    return [Movie(movieId: 0)];
  }

  Future<Movie> indexMovie(int mid) async {
    late Movie newMovieX;
    Response response = await get(Uri.parse(Uri.encodeFull("http://api.themoviedb.org/3/movie/$mid?api_key=$apiKey&language=en-US")));

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      // print(res);
      // print("network.dart: ${res["title"]}");

      newMovieX = Movie(
          title: res["title"],
          adult: res["adult"],
          overview: res["overview"],
          release: res["release_date"],
          poster: res["poster_path"],
          movieId: res["id"],
          vote: res["vote_average"],
          budget: res["budget"],
          revenue: res["revenue"],
          runtime: res["runtime"],
          // studio: res["production_companies"][0]["name"]
      );
    }
    return newMovieX;
    // return Movie();
  }

  Future<List<Actor>> getCast(int mid) async {
    List<Actor> actors = [];
    Response response = await get(Uri.parse(Uri.encodeFull("http://api.themoviedb.org/3/movie/$mid/credits?api_key=$apiKey")));

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      // print(res);
      for (int x = 0; x < 12; x++) {
        // print(res[x])
        Actor newActor = Actor(
          name: res["cast"][x]["name"],
          pic: res["cast"][x]["profile_path"],
          role: res["cast"][x]["character"],
          id: res["cast"][x]["id"]
        );

        actors.add(newActor);
      }
    }

    return actors;
  }

  Future<List<Movie>> getNowPlaying() async {
    List<Movie> listOfResults = [];
    Response response = await get(Uri.parse(Uri.encodeFull("http://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey")));

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      int lengthOfRes = res["results"].length;

      for (int x = 0; x < lengthOfRes; x++) {
        final dataindex = res["results"][x];
        Movie newMovieX = Movie(
            title: dataindex["title"],
            adult: dataindex["adult"],
            overview: dataindex["overview"],
            release: dataindex["release_date"],
            poster: dataindex["poster_path"],
            movieId: dataindex["id"],
            vote: dataindex["vote_average"]
        );
        listOfResults.add(newMovieX);
      }
    }

    return listOfResults;
  }

  Future<Actor> getActorDetails(int? id) async {
    Actor detailedActor = Actor();
    Response response = await get(Uri.parse(Uri.encodeFull("https://api.themoviedb.org/3/person/$id?api_key=$apiKey")));

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      detailedActor = Actor(
        name: res["name"],
        about: res["biography"],
        birthday: res["birthday"],
        birthplace: res["place_of_birth"],
        pic: res["profile_path"]
      );
    }

    return detailedActor;
  }

  }