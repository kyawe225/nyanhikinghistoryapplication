import 'package:hiking_app_one/database/databaseConfig.dart';

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
    id varchar(36) PRIMARY KEY,
    hiking_history_id varchar(36),
    observation_date datetime,
    additional_comments TEXT,
    observation TEXT,
    observation_type varchar(100), -- file or text this would effect to observation column
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hiking_history_id) REFERENCES hiking_history(id)
    );""";

    dbHelper.execute(createHikeTables);
    dbHelper.execute(createObservationTable);

    dbHelper.close();
}