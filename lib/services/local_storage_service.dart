import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../add_pills_form.dart';

class LocalStorageService {
  static Database? _database;
  static const String tableName = 'medications';
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medications.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            amount INTEGER NOT NULL,
            duration INTEGER NOT NULL,
            timeHour INTEGER NOT NULL,
            timeMinute INTEGER NOT NULL,
            startDate INTEGER NOT NULL,
            frequency TEXT NOT NULL,
            frequencyValue INTEGER NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            syncStatus INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Save medication locally
  // syncStatus: 0 = needs sync (local changes), 1 = synced (from Firebase)
  Future<void> saveMedication(PillData pill, {int syncStatus = 0}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = pill.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Check if medication already exists to preserve createdAt
    final existing = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    final createdAt = existing.isNotEmpty 
        ? existing.first['createdAt'] as int 
        : now;
    
    await db.insert(
      tableName,
      {
        'id': id,
        'name': pill.name,
        'type': pill.type,
        'amount': pill.amount,
        'duration': pill.duration,
        'timeHour': pill.time.hour,
        'timeMinute': pill.time.minute,
        'startDate': pill.startDate.millisecondsSinceEpoch,
        'frequency': pill.frequency,
        'frequencyValue': pill.frequencyValue,
        'isActive': 1,
        'createdAt': createdAt,
        'updatedAt': now,
        'syncStatus': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update medication locally
  Future<void> updateMedication(PillData pill) async {
    if (pill.id == null) return;
    
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.update(
      tableName,
      {
        'name': pill.name,
        'type': pill.type,
        'amount': pill.amount,
        'duration': pill.duration,
        'timeHour': pill.time.hour,
        'timeMinute': pill.time.minute,
        'startDate': pill.startDate.millisecondsSinceEpoch,
        'frequency': pill.frequency,
        'frequencyValue': pill.frequencyValue,
        'updatedAt': now,
        'syncStatus': 0, // Mark as needs sync
      },
      where: 'id = ?',
      whereArgs: [pill.id],
    );
  }

  // Get all active medications from local storage
  Future<List<PillData>> getMedications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) {
      return PillData(
        id: map['id'] as String,
        name: map['name'] as String,
        type: map['type'] as String,
        amount: map['amount'] as int,
        duration: map['duration'] as int,
        time: TimeOfDay(
          hour: map['timeHour'] as int,
          minute: map['timeMinute'] as int,
        ),
        startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
        frequency: map['frequency'] as String,
        frequencyValue: map['frequencyValue'] as int,
      );
    }).toList();
  }

  // Delete medication (soft delete)
  Future<void> deleteMedication(String medicationId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.update(
      tableName,
      {
        'isActive': 0,
        'updatedAt': now,
        'syncStatus': 0, // Mark as needs sync
      },
      where: 'id = ?',
      whereArgs: [medicationId],
    );
  }

  // Get medications that need to be synced
  Future<List<Map<String, dynamic>>> getUnsyncedMedications() async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'syncStatus = ?',
      whereArgs: [0],
    );
  }

  // Mark medication as synced
  Future<void> markAsSynced(String medicationId) async {
    final db = await database;
    await db.update(
      tableName,
      {'syncStatus': 1},
      where: 'id = ?',
      whereArgs: [medicationId],
    );
  }

  // Clear all local data
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableName);
  }

  // Batch save medications (for syncing from server)
  Future<void> batchSaveMedications(List<Map<String, dynamic>> medications) async {
    final db = await database;
    final batch = db.batch();
    
    for (var med in medications) {
      batch.insert(
        tableName,
        {
          ...med,
          'syncStatus': 1, // Already synced from server
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
}
