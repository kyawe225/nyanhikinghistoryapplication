import 'package:hiking_app_one/database/database_config.dart';

import 'database.dart';
import 'database_table_column_names.dart';
import 'dart:io';

var dbHelper = DatabaseHelper();

bool isDatabaseExists(){
  return File(Configs.databaseConnectionString).existsSync();
}

void createTables(){
  // Use constants for table/column names to avoid duplication/errors
  String createHikeTables = """
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

  String createObservationTable = """
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
void migrateObservationColumns() {
  try {
    // Try adding observation_text
    dbHelper.execute("ALTER TABLE ${ObservationTable.tableName} ADD COLUMN ${ObservationTable.observationText} TEXT;");
  } catch (_) {
    // ignore - column probably exists
  }
  try {
    // Try adding observation_path
    dbHelper.execute("ALTER TABLE ${ObservationTable.tableName} ADD COLUMN ${ObservationTable.observationPath} TEXT;");
  } catch (_) {
    // ignore - column probably exists
  }
  try {
    // Ensure observation_type exists (if older schema used 'observation' only)
    dbHelper.execute("ALTER TABLE ${ObservationTable.tableName} ADD COLUMN ${ObservationTable.observationType} varchar(100) NOT NULL DEFAULT 'Text';");
  } catch (_) {
    // ignore
  }
  // Do not close the dbHelper here if other callers will use it; close to be safe
  try { dbHelper.close(); } catch (_){}
}