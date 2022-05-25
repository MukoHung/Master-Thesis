dotnet ef migrations script --project DAL --context OpenWeatherDbContext --startup-project OpenWeather --output  $(build.artifactstagingdirectory)/db_migrations.sql --idempotent
