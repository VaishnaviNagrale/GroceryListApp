import 'package:flutter/material.dart';
import 'package:flutter_sqflite_learning/databaseHelper.dart';
import 'package:flutter_sqflite_learning/grocery.dart';
import 'package:flutter_sqflite_learning/themes/theme_constants.dart';
import 'package:flutter_sqflite_learning/themes/theme_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? selectedId;
  final textController = TextEditingController();
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GroceryListApp",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      home: Scaffold(
        // backgroundColor: Colors.green,
        appBar: AppBar(
          // backgroundColor: Colors.orange,
          title: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Enter here...',
              border: InputBorder.none,
              // hintStyle: TextStyle(color: Colors.amber[50]),
            ),
            style: const TextStyle(fontWeight: FontWeight.w400),
            cursorColor: Colors.black,
            cursorHeight: 30,
          ),
          actions: [
            Switch(
              activeColor: Colors.black,
              value: _themeManager.themeMode == ThemeMode.dark,
              onChanged: (newValue) {
                _themeManager.toggleTheme(newValue);
              },
            ),
          ],
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
                                  ? Colors.amber
                                  : Colors.grey.withOpacity(0.2),
                              child: ListTile(
                                title: Text(grocery.name),
                                splashColor: Colors.grey,
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
          //backgroundColor: Colors.orange,
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
