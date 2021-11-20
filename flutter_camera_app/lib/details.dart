import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Result> createAlbum(String image) async {
  final response = await http.post(
    Uri.parse('http://7efe-37-225-75-16.ngrok.io/api/predict'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'image': image,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Result.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
   return Result(confidence: 0,label: 'Not Found');
  }
}

Future<Resp> searchNewonceA(String image) async {
  var result = await createAlbum(image);
  var searchN = await searchNewonce(result);
  //
  // searchN.items[0].title =
  return Resp(searchN, result.label);
}
class Resp {
  final Newonce elem;
  final String plyta;

  Resp(this.elem, this.plyta);
}
Future<Newonce> searchNewonce(Result result) async {
  var author = NewonceAuthor(name: '');
  List<NewonceData>  lst = List<NewonceData>.generate(1, (int index) => NewonceData(title: "Not found",slug: '',image: ''));

  if(result == null  || result.label == 'Not Found'){
    return Newonce(items: lst);
  }

  Map<String, String> queryParams = {
    'search_query': result.label,
    'page': '1',
    'per_page': '10'
  };

  String queryString = Uri(queryParameters: queryParams).query;

  var requestUrl = 'https://newonce-api.herokuapp.com/related/articles' + '?' + queryString;

  final response = await http
      .get(Uri.parse(requestUrl));

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Newonce.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    return Newonce(items: lst);
  }
}

class Result {
  final double confidence;
  final String label;

  Result({required this.confidence, required this.label});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      confidence: json['confidence'],
      label: json['label'],
    );
  }
}

class Newonce {
  final List<NewonceData> items;

  Newonce({required this.items});

  factory Newonce.fromJson(Map<String, dynamic> json) {
    return Newonce(
        items:        json['items'] != null
        ? json['items']
        .map<NewonceData>((json) => NewonceData.fromJson(json))
        .toList()
        : null,
    );
  }
}

class NewonceData {
  final String title;
  final String slug;
  final String image;
  //final NewonceAuthor author;

  NewonceData({required this.title, required this.slug,required this.image});

  factory NewonceData.fromJson(Map<String, dynamic> json) {
    return NewonceData(
        title: json['title'],
        slug: json['slug'],
        image: json['image']
    );
  }
}

class NewonceAuthor {
  final String name;

  NewonceAuthor({required this.name});

  factory NewonceAuthor.fromJson(Map<String, dynamic> json) {
    return NewonceAuthor(
      name: json['name']
    );
  }
}

class details extends StatelessWidget {
  final String baseImg;
  const details({Key? key, required this.baseImg}) : super(key: key);


  @override
  Widget  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wynik'),
      ),
      body: Center(
      child: FutureBuilder<Resp>(
          future: searchNewonceA(baseImg),
          builder: (context, AsyncSnapshot<Resp> snapshot) {
            if(snapshot.hasData){


              //return Text("Płyta:" + snapshot.data!.plyta + "       Pierwszy artykuł z newonce: " + snapshot.data!.elem.items[0].title);

              return
                Center(
                  child:
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child:
                    Text("Płyta:" + snapshot.data!.plyta,style: TextStyle(fontSize: 16))),
                    Center(
                      child:
                    Text("Znalezione artykuły w newonce:",style: TextStyle(fontSize: 14))),
                Expanded(child: ListView.builder(
                  itemCount: snapshot.data!.elem.items.length,
                  itemBuilder: (context, index) {
                  final item = snapshot.data!.elem.items[index];
                    return ListTile(
                    title: Text(item.title, style: TextStyle(fontSize: 12)),
                  //subtitle: Text(item.slug),
                          );
                },
    ),
                    ),
],
                    ),
                );
            }
            else{
              return CircularProgressIndicator();
            }
          }
      ),
    ),
    );
  }
}