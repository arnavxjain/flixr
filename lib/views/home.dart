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

Color bgContrast = const Color(0xFFF0F0F0);
Color bg = const Color(0xFFFFFFFF);
Color fg = const Color(0xFF232323);

late List<Movie> movieRes;
late List<Actor> actorsRes;
late List<TVShow> showsRes;

late Movie indexedMovie;

class Home extends StatefulWidget {
  const Home(this.stream, {Key? key}) : super(key: key);

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
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
          // height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 100),
          child: Column(
            children: contentOpacity == true ? [
              _searchBar("Search for a movie, actor, or tv show", context),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        FaIcon(FontAwesomeIcons.box, size: 20,),
                        SizedBox(width: 3,),
                        Text(" Results", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -1)),
                      ],
                    ),
                    GestureDetector(
                      child: Icon(Icons.cancel_rounded, size: 23, color: Colors.grey.withOpacity(0.4),),
                      onTap: () {
                        streamController.add(0);
                      },
                    )
                  ],
                ),
              ),
              _futureMovieBar(context),
            ] : [
              _searchBar("Search for a movie, actor or TV show", context),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    FaIcon(FontAwesomeIcons.film, size: 20,),
                    SizedBox(width: 3,),
                    Text(" Now Playing", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -1)),
                  ],
                ),
              ),
              const SizedBox(height: 6,),
              _homeContent(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar(String placeholder, context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14),
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

  Widget _futureMovieBar(context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: SizedBox(
          height: double.infinity,
          child: ListView(
            physics: const ScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: [
              _futureActorBar(context),
              _futureShowBar(context),
              const SizedBox(height: 20,),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: movieRes.length,
                itemBuilder: (context, int index) {
                  return movieCard(movieRes[index]);
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _futureActorBar(BuildContext context) => actorsRes.isNotEmpty ? Container(
      height: 315,
      margin: const EdgeInsets.only(top: 14),
      decoration: ShapeDecoration(
          color: Colors.grey.withOpacity(0.2),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20.5,
              cornerSmoothing: 1,
            ),
          )),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SizedBox(width: 6,),
              FaIcon(FontAwesomeIcons.solidCircleUser, size: 18,),
              Text(" Actors", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1, fontSize: 20),),
            ],
          ),
          const SizedBox(height: 6,),
          _createCastList(actorsRes, context),
        ],
      )
  ) : const SizedBox.shrink();

  Widget _futureShowBar(BuildContext context) => showsRes.isNotEmpty ? Container(
      height: 315,
      margin: const EdgeInsets.only(top: 14),
      decoration: ShapeDecoration(
          color: Colors.grey.withOpacity(0.2),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20.5,
              cornerSmoothing: 1,
            ),
          )),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SizedBox(width: 8,),
              FaIcon(FontAwesomeIcons.tv, size: 16,),
              Text(" TV Shows", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1, fontSize: 20),),
              SizedBox(width: 2,),
            ],
          ),
          const SizedBox(height: 6,),
          _createShowList(showsRes, context),
        ],
      )
  ) : const SizedBox.shrink();

  Random rnd = Random();
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
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(bottom: 40, top: 10),
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
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, int index) {
          return movieCard(data[index]);
        },
      ),
    );
  }

  Widget _createCastList(List<Actor> data, context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: data.length,
          itemBuilder: (context, int index) {
            return _castCard(data[index]);
          }
      ),
    );
  }

  Widget _castCard(Actor data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ActorsPage(actorId: data.id)
        ));
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
            image: data.pic != null ? NetworkImage("https://image.tmdb.org/t/p/original${data.pic}") : AssetImage('lib/assets/yellow.png') as ImageProvider,
        )),
        child: Column(
          children: [
            const SizedBox(height: 200),
            SizedBox(
              height: 60,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 125, child: Text(data.name.toString(), style: const TextStyle(overflow: TextOverflow.ellipsis, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.7), overflow: TextOverflow.fade, maxLines: 1, softWrap: false)),
                            Container(child: const FaIcon(FontAwesomeIcons.angleRight, color: Colors.blueAccent,), margin: const EdgeInsets.only(right: 6),)
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

  _createShowList(List<TVShow> actorsRes, BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actorsRes.length,
        itemBuilder: (context, int index) {
          return TVCard(actorsRes[index]);
        }
    ),
    );
  }

  Widget TVCard(TVShow data) {
    return GestureDetector(
      onTap: () {},
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
            image: data.poster != null ? NetworkImage("https://image.tmdb.org/t/p/original${data.poster}") : AssetImage('lib/assets/red.png') as ImageProvider,
        )),
        child: Column(
          children: [
            const SizedBox(height: 200),
            SizedBox(
              height: 60,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 125, child: Text(data.title.toString(), style: const TextStyle(overflow: TextOverflow.ellipsis, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.7), overflow: TextOverflow.fade, maxLines: 1, softWrap: false)),
                            Container(child: const FaIcon(FontAwesomeIcons.angleRight, color: Colors.blueAccent,), margin: const EdgeInsets.only(right: 6),)
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
    return CupertinoButton(
      onPressed: () {
        Navigator.pop(context);
      },
      padding: EdgeInsets.zero,
      // onTap: () {
      //   Navigator.pop(context);
      // },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.angleLeft, color: Colors.blueAccent,),
          Container(child: const FaIcon(FontAwesomeIcons.box, size: 19, color: Colors.blueAccent,), margin: const EdgeInsets.only(bottom: 1, left: 2),)
        ],
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
              const SizedBox(height: 2,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _backButton(),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          data!.title.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: -1,
                            // height: 0.45,
                          ),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7,),
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
    return SizedBox(
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
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ActorsPage(actorId: data.id)
        ));
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
            SizedBox(
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
                            Text(data.role.toString(), style: TextStyle(overflow: TextOverflow.ellipsis, color: Colors.white.withOpacity(0.8)), maxLines: 1,)
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
  final int? actorId;
  const ActorsPage({Key? key, required this.actorId}) : super(key: key);

  @override
  State<ActorsPage> createState() => _ActorsPageState();
}

class _ActorsPageState extends State<ActorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 55, left: 20, right: 20, bottom: 40),
          child: FutureBuilder(
            future: _getActorDetails(widget.actorId),
            builder: (context, AsyncSnapshot<Actor> snapshot) {
              if (snapshot.hasData) {
                return actorExtra(snapshot.data);
              }
              return const Center(child: CupertinoActivityIndicator());
            }),
          ),
      )
      );
  }

  Widget _backButton() {
    return CupertinoButton(
      onPressed: () {
        Navigator.pop(context);
      },
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.angleLeft, color: Colors.blueAccent,),
          const SizedBox(width: 2,),
          Container(child: const FaIcon(FontAwesomeIcons.solidCircleUser, size: 19, color: Colors.blueAccent,), margin: const EdgeInsets.only(bottom: 1),)
        ],
      ),
    );
  }

  Widget actorExtra(Actor? data) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _backButton(),
                  const SizedBox(width: 4),
                  Text(
                    data!.name.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -1,
                        height: 1,
                        overflow: TextOverflow.ellipsis
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              // Container(padding: EdgeInsets.only(right: 10), margin: EdgeInsets.only(bottom: 6)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          height: 520,
          decoration: ShapeDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: data.pic != null ? NetworkImage("https://image.tmdb.org/t/p/original${data.pic}") : const AssetImage('lib/assets/green.png') as ImageProvider,
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
        Text(
          data.about.toString(),
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 17,
              letterSpacing: -0.7,
              color: Colors.black.withOpacity(0.6)
          ),
        ),
      ],
    );
  }
}

void _getGlobalResults(String value) {
  Future response = Network().searchGlobal(value);

  // print(response);
  response.then((res) {
    movieRes = res[0];
    showsRes = res[1];
    actorsRes = res[2];

    streamController.add(1);
  });
}

dynamic _getMovie(int mid) {
  Future response = Network().indexMovie(mid);

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

dynamic _getActorDetails(int? id) {
  Future response = Network().getActorDetails(id);

  return response;
}