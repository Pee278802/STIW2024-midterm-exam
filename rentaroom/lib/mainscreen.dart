import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'data/room.dart';
import 'package:rent_a_room/detailscreen.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late double screenHeight;
  late double screenWidth;
  late double resWidth;
  late ScrollController _scrollController;
  int scrollCount = 10;
  int rowCount = 2;
  int roomNumber = 0;
  List roomList = [];
  String title = "Loading...";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowCount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RentARoom',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: roomList.isEmpty
          ? Center(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)))
          : Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: rowCount,
                    controller: _scrollController,
                    children: List.generate(scrollCount, (index) {
                      return Card(
                          child: InkWell(
                        onTap: () => {_roomDetails(index)},
                        child: Column(
                          children: [
                            Flexible(
                              flex: 6,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: screenWidth,
                                imageUrl:
                                    "https://slumberjer.com/rentaroom/images/" +
                                        roomList[index]['roomid'] +
                                        "_1.jpg",
                              ),
                            ),
                            Flexible(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      Text(
                                          truncate(roomList[index]['title']
                                              .toString()),
                                          style: TextStyle(
                                            fontSize: resWidth * 0.045,
                                          )),
                                      Text(
                                          "RM " +
                                              double.parse(
                                                      roomList[index]['price'])
                                                  .toStringAsFixed(2) +
                                              " per month  ",
                                          style: TextStyle(
                                            fontSize: resWidth * 0.03,
                                          )),
                                      Text(
                                          "Deposit: RM" +
                                              roomList[index]['deposit'],
                                          style: TextStyle(
                                            fontSize: resWidth * 0.03,
                                          )),
                                      Text(roomList[index]['area'],
                                          style: TextStyle(
                                            fontSize: resWidth * 0.03,
                                          )),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ));
                    }),
                  ),
                ),
              ],
            ),
    );
  }

  void _loadRooms() {
    http.post(Uri.parse("https://slumberjer.com/rentaroom/php/load_rooms.php"),
        body: {}).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        print(response.body);
        var extractdata = data['data'];
        setState(() {
          roomList = extractdata["rooms"];
          roomNumber = roomList.length;
          if (scrollCount >= roomList.length) {
            scrollCount = roomList.length;
          }
        });
      } else {
        setState(() {
          title = "No Data";
        });
      }
    });
  }

  _roomDetails(int index) {
    Room room = Room(
        roomid: roomList[index]['roomid'],
        contact: roomList[index]['contact'],
        title: roomList[index]['title'],
        desc: roomList[index]['description'],
        price: roomList[index]['price'],
        deposit: roomList[index]['deposit'],
        state: roomList[index]['state'],
        area: roomList[index]['area'],
        date: roomList[index]['date_created'],
        latitude: roomList[index]['latitude'],
        longitude: roomList[index]['longitude']);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => DetailScreen(
                  room: room,
                )));
  }

  String truncate(String str) {
    if (str.length > 15) {
      str = str.substring(0, 15);
      return str + "...";
    } else {
      return str;
    }
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        if (roomList.length > scrollCount) {
          scrollCount = scrollCount + 10;
          if (scrollCount >= roomList.length) {
            scrollCount = roomList.length;
          }
        }
      });
    }
  }
}
