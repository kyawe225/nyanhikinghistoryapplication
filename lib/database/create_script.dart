import 'package:hiking_app_one/database/database_config.dart';
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'database_table_column_names.dart';
import 'dart:io';

Future<bool> isDatabaseExists() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final path = '${documentsDirectory.path}/${Configs.databaseConnectionString}';
  return File(path).existsSync();
}

void createTables() async {
  final db = await DatabaseHelper.init();
  final dbHelper = DatabaseHelper(db);
  // Use constants for table/column names to avoid duplication/errors
  String createHikeTables =
      """
  CREATE TABLE IF NOT EXISTS ${HikehistoryTable.tableName}(
    ${HikehistoryTable.id} varchar(36) PRIMARY KEY,
    ${HikehistoryTable.name} varchar(225),
    ${HikehistoryTable.location} varchar(225),
    ${HikehistoryTable.hikedDate} date,
    ${HikehistoryTable.parkingAvailable} varchar(10) default 'No',
    ${HikehistoryTable.lengthOfHike} varchar(50),
    ${HikehistoryTable.difficultyLevel} varchar(50),
    ${HikehistoryTable.description} TEXT,
    ${HikehistoryTable.freeParking} tinyint default 0,
    ${HikehistoryTable.isFavourite} tinyint default 0,
    ${HikehistoryTable.createdAt} DATETIME DEFAULT CURRENT_TIMESTAMP
    );""";

  String createObservationTable =
      """
  CREATE TABLE IF NOT EXISTS ${ObservationTable.tableName}(
    ${ObservationTable.id} varchar(36) PRIMARY KEY NOT NULL,
    ${ObservationTable.hikingHistoryId} varchar(36) NOT NULL,
    ${ObservationTable.observationDate} datetime NOT NULL,
    ${ObservationTable.additionalComments} TEXT,
    ${ObservationTable.observationText} TEXT,        -- text content (when observation_type = 'Text')
    ${ObservationTable.observationPath} TEXT,        -- file path or URL or base64 (when observation_type = 'Image')
    ${ObservationTable.observationType} varchar(100) NOT NULL, -- 'Text' or 'Image'
    ${ObservationTable.createdAt} DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (${ObservationTable.hikingHistoryId}) REFERENCES ${HikehistoryTable.tableName}(${HikehistoryTable.id})
    );""";

  dbHelper.execute(createHikeTables);
  dbHelper.execute(createObservationTable);

  dbHelper.close();
}

// New migration helper: adds columns if they're missing (safe - errors ignored)
