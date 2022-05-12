import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flixr/main.dart';
import 'package:flixr/model/model.dart';
import 'package:flixr/network/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

Color bgContrast = const Color(0xFFF0F0F0);
Color bg = const Color(0xFFFFFFFF);
Color fg = const Color(0xFF232323);

late List<Movie> movieRes;
late Movie indexedMovie;

class Home extends StatefulWidget {
  Home(this.stream, {Key? key}) : super(key: key);

  final Stream<int> stream;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool contentOpacity = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.stream.listen((index) {
      setMyState(index);
    });
  }

  void setMyState(int index) {
    List options = [false, true];
    setState(() {
      contentOpacity = options[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 55, left: 20, right: 20),
          child: Column(
            children: contentOpacity == true ? [
              _searchBar("Enter movie title", context),
              _futureBar(context)
            ] : [
              _searchBar("Enter movie title", context),
              SizedBox(height: 15,),
              Text("Now Playing", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -1)),
              _homeContent(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar(String placeholder, context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      width: MediaQuery.of(context).size.width * 0.9,
      height: 47,
      decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          color: bgContrast,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 13.5,
              cornerSmoothing: 0.9,
            ),
          )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Image.asset(
              'lib/icons/search.png',
              color: Colors.grey,
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 10.0),
              width: MediaQuery.of(context).size.width * 0.9 - 70,
              child: TextField(
                onSubmitted: (String value) {
                  if (value.isNotEmpty) {
                    _getGlobalResults(value);
                  }
                },
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4),
                decoration: InputDecoration(
                  // suffixIcon: Icon(Icons.cancel_rounded, color: fg,),
                    border: InputBorder.none,
                    focusColor: Colors.transparent,
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4
                    )),
              )),
        ],
      ),
    );
  }

  Widget _futureBar(context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 800,
      width: double.infinity,
      child: ListView.builder(
        itemCount: movieRes.length,
        itemBuilder: (context, int index) {
          return movieCard(movieRes[index]);
        }
      ),
    );
  }

  // import 'dart:math';

  Random rnd = Random();
// Define min and max value
  int min = 0, max = 3;

  Widget movieCard(Movie data) {
    List<String> assetLoader = ["green", "red", "yellow"];
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      // height: 410,
      decoration: ShapeDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: data.poster != null ? NetworkImage("https://image.tmdb.org/t/p/original${data.poster}") : AssetImage('lib/assets/${assetLoader[min + rnd.nextInt(max - min)]}.png') as ImageProvider,
        ),
          shadows: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          color: bgContrast,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 30,
              cornerSmoothing: 0.9,
            ),
          )),
      child: Column(
        children: [
          const SizedBox(height: 185),
          SizedBox(
            // height: 225,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${data.title}", overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.left, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23, letterSpacing: -1, color: Colors.white)),
                    const SizedBox(height: 5),
                    Text(
                      "${data.overview}",
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 5,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 15,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              "${data.release}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  fontSize: 17
                              ),
                            ),
                            Text("${data.vote} / 10", style: const TextStyle(fontSize: 18, color: Colors.white, letterSpacing: -1),)
                          ],
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.only(right: 10, bottom: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              print("elevatedbutton: ${data.movieId}");
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Details(mid: data.movieId)
                              ));
                            },
                            child: FaIcon(FontAwesomeIcons.angleRight, color: Colors.white.withOpacity(0.8), size: 18,),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.1)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                    )
                                ),
                                elevation: MaterialStateProperty.all<double>(0)
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                    )
                ),
              ),
          ))
        ],
      ),
    );
  }

  _homeContent(BuildContext context) {
    return Container(
      height: 800,
      padding: EdgeInsets.only(bottom: 40, top: 10),
      child: FutureBuilder(
        future: _getNowPlaying(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data)
            return _nowPlayingList(snapshot.data);
          }
          return const Center(child: CupertinoActivityIndicator());
        },
      ),
    );
  }

  Widget _nowPlayingList(data) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, int index) {
        return movieCard(data[index]);
      },
    );
  }
}

void _getGlobalResults(String value) {
  Future response = Network().searchGlobal(value);

  response.then((res) {
    movieRes = res;
    streamController.add(1);
  });
}

dynamic _getMovie(int mid) {
  Future response = Network().indexMovie(mid);

  response.then((res) {
    print(res);
  });

  return response;
}

dynamic _getCast(int movieId) {
  Future response = Network().getCast(movieId);

  return response;
}

dynamic _getNowPlaying() {
  Future response = Network().getNowPlaying();

  return response;
}

class Details extends StatefulWidget {
  final int mid;
  const Details({Key? key, required this.mid}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: SingleChildScrollView(
         child: Container(
           padding: const EdgeInsets.only(top: 55, left: 20, right: 20),
           child: FutureBuilder(
            future: _getMovie(widget.mid),
            builder: (context, AsyncSnapshot<Movie> snapshot) {
              if (snapshot.hasData) {
                return moviePage(snapshot.data);
              }
              return const Center(child: CupertinoActivityIndicator());
            }
      ),
         ),
       ),
    );
  }

  Widget _backButton() {
    return Container(
      height: 50,
      width: 50,
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey.withOpacity(0.1)
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: FaIcon(FontAwesomeIcons.angleLeft, color: Colors.black.withOpacity(0.4), size: 18,),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.1)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                )
            ),
            elevation: MaterialStateProperty.all<double>(0)
        ),
      ),
    );
  }
  
  Widget moviePage(Movie? data) {
    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      // height: 1000,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _backButton(),
                      const SizedBox(width: 4),
                      Text(
                        data!.title.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: -1,
                          height: 0.45,
                          overflow: TextOverflow.ellipsis
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 520,
                  decoration: ShapeDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: data.poster != null ? NetworkImage("https://image.tmdb.org/t/p/original${data.poster}") : const AssetImage('lib/assets/green.png') as ImageProvider,
                      ),
                      shadows: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: bgContrast,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 30,
                          cornerSmoothing: 0.9,
                        ),
                      )),
                  ),
                  Positioned(
                    right: 18,
                    top: 35,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 5, right: 3),
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(100)
                      ),
                      child: Text("${data.vote}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.overview.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        letterSpacing: -0.7,
                        color: Colors.black.withOpacity(0.6)
                      ),
                    ),
                    Divider(color: Colors.black.withOpacity(0.3), height: 30, thickness: 1),
                    Text("Runtime: ${data.runtime} min", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                    const SizedBox(height: 3,),
                    const Text("Genres: Action, Adventure, Sci-Fi", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                    const SizedBox(height: 3,),
                    Text("Released: ${data.release}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                    const SizedBox(height: 3,),
                    Text("Earnings: ${data.revenue}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                    const SizedBox(height: 3,),
                    Text("Budget: ${data.budget}", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                    const SizedBox(height: 3,),
                    Divider(color: Colors.black.withOpacity(0.3), height: 30, thickness: 1),
                    const Text('Cast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -1.2),),
                    const SizedBox(height: 6,),
                    const SizedBox(height: 3,),
                    _cast(data.movieId, context)
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

  Widget _cast(int mid, context) {
    return Container(
      height: 260,
      child: FutureBuilder(
        future: _getCast(mid),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data);
            return _createCastList(snapshot.data, context);
          }

          return const CupertinoActivityIndicator();
        }
    ),
    );
  }

  Widget _createCastList(List<Actor> data, context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      itemBuilder: (context, int index) {
        return _castCard(data[index]);
      }
    );
  }

  Widget _castCard(Actor data) {
    return GestureDetector(
      onTap: () {
        print(data.id);
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        // padding: EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 15),
        width: 200,
        height: 280,
        // alignment: Alignment.center,
        decoration: ShapeDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 20.5,
                cornerSmoothing: 1,
              ),
            ), image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage("https://image.tmdb.org/t/p/original${data.pic}")
          )),
        child: Column(
          children: [
            const SizedBox(height: 200),
            Container(
              height: 60,
              child: ClipRRect(
                child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        margin: const EdgeInsets.only(bottom: 4),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 6, right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.name.toString(), style: const TextStyle(overflow: TextOverflow.ellipsis, color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17), maxLines: 1,),
                            Text(data.role.toString(), style: TextStyle(overflow: TextOverflow.ellipsis, color: Colors.white.withOpacity(0.56)), maxLines: 1,)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActorsPage extends StatefulWidget {
  final int actorId;
  const ActorsPage({Key? key, required this.actorId}) : super(key: key);

  @override
  State<ActorsPage> createState() => _ActorsPageState();
}

class _ActorsPageState extends State<ActorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
