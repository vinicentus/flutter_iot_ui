String convertDateTimeToString(DateTime datetime) =>
    datetime.toUtc().toIso8601String().split('.')[0] + 'Z';
