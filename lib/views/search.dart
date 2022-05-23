import 'package:chat_app_message/helper/constants.dart';
import 'package:chat_app_message/services/database.dart';
import 'package:chat_app_message/views/conversation_screen.dart';
import 'package:chat_app_message/widget/widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController searchtextEditingController = TextEditingController();

  dynamic searchSnapshot;

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return searchTile(
                userName: searchSnapshot.docs[index].data()["name"],
                userEmail: searchSnapshot.docs[index].data()['email'],
              );
            })
        : Container();
  }

  initiateSearch() {
    databaseMethods
        .getUserByUsername(searchtextEditingController.text)
        .then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

//create chatroom , send user to conversation screen,pushreplacement
  createChatroomAndStartConversation({String? userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName!, Constants.myName);

      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> charRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };

      DatabaseMethods().createCharRoom(chatRoomId, charRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                    chatRoomId: chatRoomId,
                  )));
    } else {
      // ignore: avoid_print
      print("you cannot send message to yourself");
    }
  }

  Widget searchTile({String? userName, String? userEmail}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName!,
                style: mediumTextStyle(),
              ),
              Text(
                userEmail!,
                style: mediumTextStyle(),
              )
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              createChatroomAndStartConversation(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Message",
                style: mediumTextStyle(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: appBarMain(context)),
      body: Column(
        children: [
          Container(
            color: const Color(0X54FFFFFF),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: searchtextEditingController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      hintText: "search username...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none),
                )),
                GestureDetector(
                  onTap: () {
                    initiateSearch();
                  },
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0x36FFFFFF),
                            Color(0x0FFFFFFF)
                          ]),
                          borderRadius: BorderRadius.circular(40)),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset("assets/images/search_white.png")),
                )
              ],
            ),
          ),
          searchList()
        ],
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
