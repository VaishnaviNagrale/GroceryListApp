import 'package:flutter/material.dart';
import 'package:flutter_sqflite_learning/helpers/databaseHelper.dart';
import 'package:flutter_sqflite_learning/helpers/grocery.dart';
import 'package:flutter_sqflite_learning/themes/theme_constants.dart';
import 'package:flutter_sqflite_learning/themes/theme_manager.dart';
import 'package:intl/intl.dart';

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
        appBar: AppBar(
          title: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter here...',
              border: InputBorder.none,
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
              if (snapshot.hasError) {
                return Center(
                  child: Text('ERROR: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }
              return snapshot.data!.isEmpty
                  ? const Center(
                      child: Text('No Tasks in List.'),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Grocery grocery = snapshot.data![index];
                        return Card(
                          color: selectedId == grocery.id
                              ? Colors.amber
                              : Colors.grey.withOpacity(0.2),
                          child: ListTile(
                            title: Text(grocery.name!),
                            subtitle: Text(grocery.dateTime != null
                                ? DateFormat('dd/MM/yyyy hh:mm a')
                                    .format(grocery.dateTime!)
                                : ''),
                            trailing: IconButton(
                              tooltip: "Delete",
                              hoverColor: Colors.red,
                              highlightColor: Colors.red,
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                // setState(() {
                                //   DatabaseHelper.instance.remove(grocery.id!);
                                // });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor: Colors.white,
                                      title: const Text(
                                        'Delete Item',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this item?',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: ButtonStyle(
                                            overlayColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Color(0xFF98BEFF),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            overlayColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Colors.redAccent,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              DatabaseHelper.instance
                                                  .remove(grocery.id!);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () {
                              setState(() {
                                if (selectedId == null) {
                                  textController.text = grocery.name!;
                                  selectedId = grocery.id;
                                } else {
                                  textController.text = '';
                                  selectedId = null;
                                }
                              });
                            },
                          ),
                        );
                      },
                    );
              // Swipe To Delete
              //  ListView.builder(
              //     itemCount: snapshot.data!.length,
              //     itemBuilder: (context, index) {
              //       Grocery grocery = snapshot.data![index];
              //       return Dismissible(
              //         key: UniqueKey(),
              //         direction: DismissDirection.endToStart,
              //         onDismissed: (_) {
              //           setState(() {
              //             DatabaseHelper.instance.remove(grocery.id!);
              //           });
              //         },
              //         background: Container(
              //           alignment: Alignment.centerRight,
              //           padding: EdgeInsets.only(right: 20.0),
              //           color: Colors.red,
              //           child: Icon(
              //             Icons.delete,
              //             color: Colors.white,
              //           ),
              //         ),
              //         child: Card(
              //           color: selectedId == grocery.id
              //               ? Colors.amber
              //               : Colors.grey.withOpacity(0.2),
              //           child: ListTile(
              //             title: Text(grocery.name!),
              //             subtitle: Text(grocery.dateTime != null
              //                 ? DateFormat('dd/MM/yyyy hh:mm a')
              //                     .format(grocery.dateTime!)
              //                 : ''),
              //             splashColor: Colors.grey,
              //             onTap: () {
              //               setState(() {
              //                 if (selectedId == null) {
              //                   textController.text = grocery.name!;
              //                   selectedId = grocery.id;
              //                 } else {
              //                   textController.text = '';
              //                   selectedId = null;
              //                 }
              //               });
              //             },
              //           ),
              //         ),
              //       );
              //     },
              //   );

              // LongPress To Delete
              //  ListView(
              //     children: snapshot.data!.map(
              //       (grocery) {
              //         return Center(
              //           child: Card(
              //             color: selectedId == grocery.id
              //                 ? Colors.amber
              //                 : Colors.grey.withOpacity(0.2),
              //             child: ListTile(
              //               title: Text(grocery.name!),
              //               subtitle: Text(grocery.dateTime != null
              //                   ? DateFormat('dd/MM/yyyy hh:mm a')
              //                       .format(grocery.dateTime!)
              //                   : ''),
              //               splashColor: Colors.grey,
              //               onTap: () {
              //                 setState(() {
              //                   if (selectedId == null) {
              //                     textController.text = grocery.name!;
              //                     selectedId = grocery.id;
              //                   } else {
              //                     textController.text = '';
              //                     selectedId = null;
              //                   }
              //                 });
              //               },
              //               onLongPress: () {
              //                 setState(() {
              //                   DatabaseHelper.instance.remove(grocery.id!);
              //                 });
              //               },
              //             ),
              //           ),
              //         );
              //       },
              //     ).toList(),
              //   );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          tooltip: 'Save list',
          onPressed: () async {
            if (textController.text.isNotEmpty) {
              final dateTime = DateTime.now();
              final grocery = selectedId != null
                  ? await DatabaseHelper.instance.update(
                      Grocery(
                        id: selectedId,
                        name: textController.text,
                        dateTime: dateTime,
                      ),
                    )
                  : await DatabaseHelper.instance.add(
                      Grocery(
                        name: textController.text,
                        dateTime: dateTime,
                      ),
                    );
              setState(() {
                textController.clear();
                selectedId = null;
              });
            }
          },
          splashColor: Colors.green,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.save,
                size: 30,
              ),
              Text(
                'Save',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
