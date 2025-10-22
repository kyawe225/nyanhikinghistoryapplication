import 'package:hiking_app_one/database/database_config.dart';

import 'database.dart';
import 'dart:io';

var dbHelper = DatabaseHelper();

bool isDatabaseExists(){
  return File(Configs.databaseConnectionString).existsSync();
}

void createTables(){
  String createHikeTables="""
  CREATE TABLE IF NOT EXISTS hiking_history(
    id varchar(36) PRIMARY KEY,
    name varchar(225),
    location varchar(225),
    hiked_date date,
    parking_available varchar(10) default 'No',
    length_of_hike varchar(50),
    difficulty_level varchar(50),
    description TEXT,
    free_parking tinyint default 0,
    is_favourite tinyint default 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );""";
  String createObservationTable="""
  CREATE TABLE IF NOT EXISTS observations(
    id varchar(36) PRIMARY KEY NOT NULL,
    hiking_history_id varchar(36) NOT NULL,
    observation_date datetime NOT NULL,
    additional_comments TEXT,
    observation_text TEXT,        -- text content (when observation_type = 'Text')
    observation_path TEXT,        -- file path or URL or base64 (when observation_type = 'Image')
    observation_type varchar(100) NOT NULL, -- 'Text' or 'Image'
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hiking_history_id) REFERENCES hiking_history(id)
    );""";

    dbHelper.execute(createHikeTables);
    dbHelper.execute(createObservationTable);

    dbHelper.close();
}

// New migration helper: adds columns if they're missing (safe - errors ignored)
void migrateObservationColumns() {
  try {
    // Try adding observation_text
    dbHelper.execute("ALTER TABLE observations ADD COLUMN observation_text TEXT;");
  } catch (_) {
    // ignore - column probably exists
  }
  try {
    // Try adding observation_path
    dbHelper.execute("ALTER TABLE observations ADD COLUMN observation_path TEXT;");
  } catch (_) {
    // ignore - column probably exists
  }
  try {
    // Ensure observation_type exists (if older schema used 'observation' only)
    dbHelper.execute("ALTER TABLE observations ADD COLUMN observation_type varchar(100) NOT NULL DEFAULT 'Text';");
  } catch (_) {
    // ignore
  }
  // Do not close the dbHelper here if other callers will use it; close to be safe
  try { dbHelper.close(); } catch (_){}
}