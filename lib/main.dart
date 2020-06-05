import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:start_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Code Land",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
        accentColor: Colors.white70
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  Future<List<BloodPost>> _getPosts() async {
    var bloodData = await http.get('http://10.0.2.2:8000/api/requests/bloodRequests/');

    var jsonData = json.decode(bloodData.body);

    List<BloodPost> posts = [];

    for (var b in jsonData) {

      BloodPost post = BloodPost(b['pk'], b['title'], b['slug'], b['username'], b['description'], b['bloodGroup'], b['image'], b['updatedDate']);
      posts.add(post);

    }
    print(posts.length);

    return posts;

  }

  SharedPreferences sharedPreferences;
  String name;
  String email;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Posts", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: _getPosts(),
          builder: (BuildContext conext, AsyncSnapshot snapshot){
            if (snapshot.data == null ){
              return Container(
                child: Center(
                  child: Text("Loading....."),
                ),
              );
            }else{
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int pk){

                  return ListTile(
                    leading: CircleAvatar(
                      
                    ),
                    title: Text(snapshot.data[pk].slug),
                    subtitle: Text("Author:" + ' ' + snapshot.data[pk].username + '\n' + "Updated date:" + " " + snapshot.data[pk].updatedDate
                                  + '\n' + "Blood Group:" + ' ' + snapshot.data[pk].bloodGroup
                    ),
                    
                    onTap: () {
                      Navigator.push(context, 
                        new MaterialPageRoute(builder: (context) => PostDetailPage(snapshot.data[pk]))
                      );
                    },
                  );

                },
              );
            }
          },
        ),
      ),
      drawer: Drawer(),
    );
  }
}

class PostDetailPage extends StatelessWidget {

  final BloodPost post;
  PostDetailPage(this.post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.slug),
      ),
    );
  }
}

class BloodPost {
  final int pk;
  final String title;
  final String slug;
  final String username;
  final String description;
  final String bloodGroup;
  final String updatedDate;
  final String image;

  BloodPost (this.pk, this.title, this.slug, this.username, this.description, this.bloodGroup, this.image, this.updatedDate);
}