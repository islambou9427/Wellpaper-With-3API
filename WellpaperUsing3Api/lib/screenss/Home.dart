import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';
import 'dart:io';
import 'package:WellpaperUsing3Api/apiDataFromJson/pexelsData.dart';
import 'package:WellpaperUsing3Api/apiDataFromJson/pixabayData.dart';
import 'package:WellpaperUsing3Api/apiDataFromJson/unSplashData.dart';
import 'package:WellpaperUsing3Api/screenss/ErrourScreen.dart';
import 'package:WellpaperUsing3Api/screenss/ImageScreen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:WellpaperUsing3Api/constantsvariable.dart';
import 'package:WellpaperUsing3Api/apiKeys.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TextEditingController searchTextController;
  String searchText;

  bool showSearchBar = false;

  double categoryItemBorder = 0.0;

  List<String> source;
  int currSource;

  List<String> urlList;

  List<Future<http.Response>> httpRequestList;
  var connectivityResult, networkSubscription;

  checkConnectivity() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>Home()));
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi");
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>Home()));
    } else {
      print("Unable to connect. Please Check Internet Connection");
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => ErrorScreen()));
    }
  }

  @override
  void initState() {
    super.initState();

    checkConnectivity();
    bool isRenew = false;
    networkSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print("Connection Status has Changed\n\n$result");

      if (result == ConnectivityResult.none) {
        isRenew = true;
        Fluttertoast.showToast(
          msg: 'NO INTERNET CONNECTION',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else if ((result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi) &&
          isRenew == true) {
        isRenew = false;

        Fluttertoast.showToast(
          msg: 'INTERNET IS BACK',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });

    searchTextController = TextEditingController();
    searchText = 'wallpaper';

    currSource = 0;
    source = ['Pexels', 'UnSplash', 'Pixabay'];

    urlList = [
      'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
      //'https://api.pexels.com/v1/search?query=$searchText',
      //'https://api.unsplash.com/search/photos?query=$searchText',
      'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
      'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
    ];

    List<String> apiKeyList = [
      '563492ad6f9170000100000152591bc299184cd09df977f52b8aff88',
      'xocBhJ_Jn-XGIgJNpqyFdR6GAcm6zS-4vFhOfkSoZPs',
      '18044665-796dfc7a128c34d7db480282c',
    ];
  }

  @override
  void dispose() {
    super.dispose();

    networkSubscription.cancel();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'RESOLUTION :: size${window.physicalSize}  width${window.physicalSize.width} X height${window.physicalSize.height}');

    httpRequestList = [
      http.get(
        //'https://api.pexels.com/v1/search?query=people',
        //'https://api.pexels.com/v1/search?query=$searchText',
        urlList[0],

        // Send authorization headers to the backend.
        headers: {
          HttpHeaders.authorizationHeader: apiKeyList[0],
        },
      ),
      http.get('${urlList[1]}&client_id=${apiKeyList[1]}'),
      http.get('${urlList[2]}&key=${apiKeyList[2]}'),
    ];

    return SafeArea(
      child: Scaffold(
        drawer: buildDrawer(),
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'All Wallpaper',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Carrington',
              fontSize: 42.0,
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  showSearchBar = !showSearchBar;
                  searchTextController.clear();
                });
              },
              icon: Icon(Icons.search),
            ),
          ],
        ),
        body: Container(
          color: Colors.black87,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (showSearchBar)
                  ? Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          controller: searchTextController,
                          onSubmitted: (value) {
                            setState(() {
                              searchText = searchTextController.text
                                  .toString()
                                  .trim()
                                  .replaceAll(' ', '+');
                              urlList.replaceRange(0, urlList.length, [
                                'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                                //'https://api.pexels.com/v1/search?query=$searchText',
                                //'https://api.unsplash.com/search/photos?quer
                                // y=$searchText',
                                'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                                'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                              ]);
                              for (int i = 0;
                                  i < (isCategorySelectedList.length);
                                  i++) isCategorySelectedList[i] = false;
                              print(
                                  '$searchText  ${urlList[currSource]}  $urlList');
                            });
                          },
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                            ),
                            hintText: 'Search here..',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                setState(() {
                                  searchText = searchTextController.text
                                      .toString()
                                      .replaceAll(' ', '+');
                                  urlList.replaceRange(0, urlList.length, [
                                    'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                                    //'https://api.pexels.com/v1/search?query=$searchText',
                                    //'https://api.unsplash.com/search/photos?query=$searchText',
                                    'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                                    'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                                  ]);
                                  print(
                                      '$searchText  ${urlList[currSource]}  $urlList');
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  for (int i = 0;
                                      i < (isCategorySelectedList.length);
                                      i++) isCategorySelectedList[i] = false;
                                });
                              },
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 6.0),
                          child: Container(
                            height: 50.0,
                            width: 65.0,
                            decoration: BoxDecoration(
                              color: RandomColor().randomColor(),
                              border: Border.all(
                                color: Colors.teal,
                                width:
                                    (isCategorySelectedList[index]) ? 4.0 : 0.0,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                categoryUrlList[index],
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${categoryList[index]}',
                              style: TextStyle(
                                fontFamily: 'Carrington',
                                fontSize: 25.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              searchText = categoryList[index];
                              urlList.replaceRange(0, urlList.length, [
                                'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                                //'https://api.pexels.com/v1/search?query=$searchText',
                                //'https://api.unsplash.com/search/photos?query=$searchText',
                                'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                                'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                              ]);
                              for (int i = 0;
                                  i < (isCategorySelectedList.length);
                                  i++) isCategorySelectedList[i] = false;
                              isCategorySelectedList[index] = true;
                              searchTextController.clear();
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 10,
                child: FutureBuilder(
                  future: httpRequestList[currSource],
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (networkSubscription == ConnectivityResult.none)
                      return Image.asset('assets/no_internet_connection.jpeg');
                    else if (snap.connectionState == ConnectionState.waiting)
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black),
                        strokeWidth: 2.0,
                      ));
                    else if (snap.connectionState == ConnectionState.done)
                      return photoGrid(snap);
                    else
                      return Text('ERROR');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, top: 40.0),
            child: Text(
              'Source of Wallpaper :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Container(
                  color: (currSource == 0) ? Colors.black : Colors.transparent,
                  child: ListTile(
                    leading: Image.asset(
                      'assets/icon_pexels.png',
                      color: (currSource == 0) ? Colors.white : Colors.black,
                      width: 40.0,
                      height: 40.0,
                    ),
                    title: Text(
                      'Pexels',
                      style: TextStyle(
                        color: (currSource == 0) ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        currSource = 0;
                        searchTextController.text = '';

                        searchText = 'wallpaper';
                        urlList.replaceRange(0, urlList.length, [
                          'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                          //'https://api.pexels.com/v1/search?query=$searchText',
                          //'https://api.unsplash.com/search/photos?query=$searchText',
                          'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                          'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                        ]);

                        for (int i = 0;
                            i < (isCategorySelectedList.length);
                            i++) isCategorySelectedList[i] = false;

                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ),
                Container(
                  color: (currSource == 1) ? Colors.black : Colors.transparent,
                  child: ListTile(
                    leading: Image.asset(
                      'assets/icon_unsplash.png',
                      color: (currSource == 1) ? Colors.white : Colors.black,
                      width: 40.0,
                      height: 40.0,
                    ),
                    title: Text(
                      'Unsplash',
                      style: TextStyle(
                        color: (currSource == 1) ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        currSource = 1;
                        searchTextController.text = '';

                        searchText = 'wallpaper';
                        urlList.replaceRange(0, urlList.length, [
                          'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                          //'https://api.pexels.com/v1/search?query=$searchText',
                          //'https://api.unsplash.com/search/photos?query=$searchText',
                          'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                          'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                        ]);

                        for (int i = 0;
                            i < (isCategorySelectedList.length);
                            i++) isCategorySelectedList[i] = false;

                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ),
                Container(
                  color: (currSource == 2) ? Colors.black : Colors.transparent,
                  child: ListTile(
                      leading: Image.asset(
                        'assets/icon_pixabay.png',
                        color: (currSource == 2) ? Colors.white : Colors.black,
                        width: 40.0,
                        height: 40.0,
                      ),
                      title: Text(
                        'Pixabay',
                        style: TextStyle(
                          color:
                              (currSource == 2) ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          currSource = 2;
                          searchTextController.text = '';

                          searchText = 'wallpaper';
                          urlList.replaceRange(0, urlList.length, [
                            'https://api.pexels.com/v1/search?query=$searchText&page=1&per_page=100&order_by=popular',
                            //'https://api.pexels.com/v1/search?query=$searchText',
                            //'https://api.unsplash.com/search/photos?query=$searchText',
                            'https://api.unsplash.com/search/photos?query=$searchText&page=1&per_page=100&order_by=popular',
                            'https://pixabay.com/api/?q=$searchText&image_type=photo&pretty=true&page=1&per_page=100&order_by=popular',
                          ]);

                          // setting all Category Items as unselected
                          for (int i = 0;
                              i < (isCategorySelectedList.length);
                              i++) isCategorySelectedList[i] = false;

                          Navigator.of(context).pop();
                        });
                      }),
                ),
                Divider(
                  color: Colors.black,
                ),
                InkWell(
                  onTap: _launchURL,
                  child: ListTile(
                    leading: Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    title: Text('Rate Our Application'),
                  ),
                ),
                InkWell(
                  onTap: () {
                    share();
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.share,
                      color: Colors.yellow,
                    ),
                    title: Text('Share With Friends'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  photoGrid(AsyncSnapshot snap) {
    http.Response response = snap.data;

    print(urlList[currSource]);

    var photoUnits;
    int itemCount;
    if (currSource == 0) {
      photoUnits = pexelsUnitsFromJson(response.body.toString());
      photoUnits.photos..shuffle();
      itemCount = photoUnits.photos.length;
    } else if (currSource == 1) {
      photoUnits = unSplashUnitsFromJson(response.body.toString());
      photoUnits.results..shuffle();
      itemCount = photoUnits.results.length;
    } else if (currSource == 2) {
      photoUnits = pixabayUnitsFromJson(response.body.toString());
      photoUnits.hits..shuffle();
      itemCount = photoUnits.hits.length;
    }

    print('itemCount :: $itemCount');

    return (itemCount == 0)
        ? Center(
            child: Text(
                'No results found for ${searchTextController.text.trim()}.\nPlease try something else.'))
        : StaggeredGridView.countBuilder(
            padding: const EdgeInsets.all(8.0),
            crossAxisCount: 4,
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) => InkWell(
              onTap: () {
                var curPhoto;
                if (currSource == 0)
                  curPhoto = photoUnits.photos[index];
                else if (currSource == 1)
                  curPhoto = photoUnits.results[index];
                else if (currSource == 2) curPhoto = photoUnits.hits[index];
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ImageScreen(
                      currSource: currSource,
                      curPhoto: curPhoto,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width * 0.7,
                  color: RandomColor().randomColor(),
                  child: Image.network(
                    (currSource == 0)
                        ? photoUnits.photos[index].src.portrait
                        : (currSource == 1)
                            ? photoUnits.results[index].urls.regular
                            : photoUnits.hits[index].webformatUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          );
  }
}

_launchURL() async {
  const url =
      'https://play.google.com/store/apps/details?id=com.example.WellpaperUsing3Api';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> share() async {
  await FlutterShare.share(
      title: 'All Wallpaper App',
      text: "All Wallpaper application || Beautiful Wallpaper",
      linkUrl:
          "https://play.google.com/store/apps/details?id=com.example.WellpaperUsing3Api",
      chooserTitle: 'Where You Want To Share');
}
