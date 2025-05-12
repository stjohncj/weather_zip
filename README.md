# README

WeatherZip - A sample application to lookup weather by zip code

* Ruby version - 3.4.1

* System dependencies
  - This app uses the TomorrowIO API and requires a valid API key to be put in your environment (.env file etc) at TOMORROW_IO_API_KEY
  - gems:
    - rails 8.0.2
    - faraday
    - dotenv
    - vcr
    - climate_control
    - rails-controller-testing

* Configuration
  - You must add a valid TOMORROW_IO_API_KEY
  - `bundle install`
  - `bin/rails s`

* How to run the test suite
  - `bin/rails test`

* System Decomposition

  The TomorrowIO API is access through the TomorrowIoService (`app/services/tomorrow_io_service.rb`) class. This provides the application with the current temperature via an API call to the realtime data endpoint, encapsulated by `TomorrowIoService#get_weather_realtime`. The current day's high/low temperature forecast comes from another API call to the forecast data endpoint, encapsulated by `TomorrowIoService#get_weather_forecast`.

  The WeatherLookupController (`app/controllers/weather_lookup_controller.rb`) handles all requests through its `index` action.  When a zip code is provided to the action the controller passes this to the TomorrowIO API via the `TomorrowIoService`, although all calls to the service are wrapped within a `Rails.cache.fetch` block.  The cache expiration is set to 30 minutes for all cache keys.  The realtime data call is appended with the current time at cache write, which is then displayed to the user within the weather results as "last updated" time.

  I have time-boxed this development to about 3 hours.  The UI has no styling and is pure default HTML elements.  My next steps would be to add styling, perhaps a Capybara system test of the UI, and expand upon the data elemnts from the TomorrowIO API that are displayed.  A further interesting addition would be to add a weather map centered on the provided zip code via the OpenWeatherMaps API or similar.
