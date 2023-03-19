// ignore_for_file: file_names
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sqflite_learning/grocery.dart';

class DatabaseHelper {
  // Define and implement database creation and interaction methods using the `sqflite` package

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  
  //initialize database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getPathProviderDirectory();
    print('documentsDirectory path: ${documentsDirectory.path}');
    String path = join(documentsDirectory.path, 'groceries.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<Directory> getPathProviderDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  //create database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groceries(
        id INTEGER PRIMARY KEY,
        name TEXT
    )
   ''');
  }
  //get the content in database
  Future<List<Grocery>> getGroceries() async {
    Database db = await instance.database;
    var groceries = await db.query('groceries', orderBy: 'name');
    List<Grocery> groceryList = groceries.isNotEmpty
        ? groceries.map((c) => Grocery.fromMap(c)).toList()
        : [];
    return groceryList;
  }
  //add items in app & database
  Future<int> add(Grocery grocery) async {
    Database db = await instance.database;
    return await db.insert('groceries', grocery.toMap());
  }
  //remove items from database
  Future remove(int id) async {
    Database db = await instance.database;
    return await db.delete('groceries', where: 'id = ?', whereArgs: [id]);
  }
  //update items in database
  Future<int> update(Grocery grocery) async {
    Database db = await instance.database;
    return await db.update('groceries', grocery.toMap(),
        where: 'id = ?', whereArgs: [grocery.id]);
  }
}
