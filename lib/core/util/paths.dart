// Specific to IoT device, points to the local sqlite db
String dbPathIotDevice =
    '/home/pi/git-repos/IoT-Microservice/app/oracle/sensor_data.db';
// Same as above but used when when a separate device that doesn not generate data wishes to display it form a local sqlite db
String dbPathSeparateDevice =
    'C:/Users/langstvi/OneDrive - Arcada/Documents/sensor_data.db';

// A path where a temporary sqlite db is downloaded from storj to dislay data from
String tempDbPath = 'C:/Users/langstvi/OneDrive - Arcada/Documents/temp.db';

// Needed on any platform that wishes to display data rom a local sqlite db.
// That couldbe an Iot device wishing to display it own data, or a a debug device that has  obtained a copy of a db
String configPathIotDevice =
    '/home/pi/git-repos/IoT-Microservice/app/resources/device_settings.yaml';

// Needed on any platform, see uplink_storj library for more info
String libuplinkcDllPath =
    'C:/Users/langstvi/OneDrive - Arcada/Documents/libuplinkc.so';

// Only needed on windows, sqlite3 is loaded dynamically on linux when it is installed correctly in a common install location
String sqliteDllPath =
    'C:/Users/langstvi/OneDrive - Arcada/Documents/sqlite-dll-win64-x64-3360000/sqlite3.dll';
