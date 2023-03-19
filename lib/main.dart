import 'package:flutter/material.dart';
import 'package:flutter_sqflite_learning/databaseHelper.dart';
import 'package:flutter_sqflite_learning/grocery.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? selectedId;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          //title: TextField(controller: textController),
          title: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter here...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.amber[50]),
            ),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            cursorColor: Colors.black,
            cursorHeight: 30,
          ),
        ),
        body: Center(
          child: FutureBuilder<List<Grocery>>(
            future: DatabaseHelper.instance.getGroceries(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Grocery>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }
              return snapshot.data!.isEmpty
                  ? const Center(
                      child: Text('No Groceries in List.'),
                    )
                  : ListView(
                      children: snapshot.data!.map(
                        (grocery) {
                          return Center(
                            child: Card(
                              color: selectedId == grocery.id
                                  ? Colors.amber[300]
                                  : Colors.white,
                              child: ListTile(
                                title: Text(grocery.name),
                                onTap: () {
                                  setState(() {
                                    if (selectedId == null) {
                                      textController.text = grocery.name;
                                      selectedId = grocery.id;
                                    } else {
                                      textController.text = '';
                                      selectedId = null;
                                    }
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    DatabaseHelper.instance.remove(grocery.id!);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          tooltip: 'save list',
          onPressed: () async {
            selectedId != null
                ? await DatabaseHelper.instance.update(
                    Grocery(id: selectedId, name: textController.text),
                  )
                : await DatabaseHelper.instance.add(
                    Grocery(name: textController.text),
                  );
            setState(() {
              textController.clear();
              selectedId = null;
            });
          },
          child: const Icon(
            Icons.save,
            size: 30,
          ),
        ),
      ),
    );
  }
}
