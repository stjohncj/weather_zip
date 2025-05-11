class TomorrowIoService
  # This service interacts with the Tomorrow.io API to fetch weather data.
  # It requires an API key to authenticate requests.
  # The API key can be provided as an argument or set as an environment variable.

  FORECAST_URL = "https://api.tomorrow.io/v4/weather/forecast"
  REALTIME_URL = "https://api.tomorrow.io/v4/weather/realtime"

  def initialize(api_key = ENV["TOMORROW_IO_API_KEY"])
    raise "API key is required" if api_key.nil? || api_key.empty?
    @api_key = api_key
  end

  # Fetches weather data for a given location (by latitude/longitude or ZIP code).
  # The location can be specified as a string (e.g., "New York, NY") or as an array of coordinates.
  # The fields parameter specifies which weather data to retrieve (e.g., temperature, precipitation).
  # The units parameter specifies the unit system to use (e.g., "imperial" for Fahrenheit).
  # The method returns a parsed JSON response containing the weather data.
  #
  # @param location [String, Array] The location for which to fetch weather data.
  # @param fields [Array] The weather fields to retrieve (e.g., ["temperature", "precipitation"]).
  # @param units [String] The unit system to use (e.g., "imperial" or "metric").
  # @return [Hash] The parsed JSON response containing the weather data.
  # @raise [StandardError] If the API request fails or returns an error.
  #
  def get_weather_realtime(location, fields, units)
    params = {
      location: location,
      fields: fields,
      units: units,
      apikey: @api_key
    }
    response = Faraday.get(REALTIME_URL) do |req|
      req.params = params
    end
    if response.status == 200
      JSON.parse(response.body)
    else
      raise "Error fetching weather data: #{response.status} - #{response.body}"
    end
  end

  # Fetches weather data for a given location (by latitude/longitude or ZIP code).
  # The location can be specified as a string (e.g., "New York, NY") or as an array of coordinates.
  # The fields parameter specifies which weather data to retrieve (e.g., temperature, precipitation).
  # The units parameter specifies the unit system to use (e.g., "imperial" for Fahrenheit).
  # The method returns a parsed JSON response containing the weather data.
  #
  # @param location [String, Array] The location for which to fetch weather data.
  # @param fields [Array] The weather fields to retrieve (e.g., ["temperature", "precipitation"]).
  # @param units [String] The unit system to use (e.g., "imperial" or "metric").
  # @return [Hash] The parsed JSON response containing the weather data.
  # @raise [StandardError] If the API request fails or returns an error.
  #
  def get_weather_forecast(location, fields, units)
    params = {
      timesteps: "1d",
      location: location,
      fields: fields,
      units: units,
      apikey: @api_key
    }

    response = Faraday.get(FORECAST_URL) do |req|
      req.params = params
    end

    if response.status == 200
      JSON.parse(response.body)
    else
      raise "Error fetching weather data: #{response.status} - #{response.body}"
    end
  end

  # Fetches weather data by ZIP code.
  def get_weather_forecast_by_zip(zip, fields, units)
    location = zip
    get_weather_forecast(location, fields, units)
  end

  # Fetches current day temperature data by ZIP code.
  def get_weather_forecast_temperatures_by_zip(zip)
    location = zip
    data = get_weather_forecast_by_zip(location, [ "temperature" ], "imperial")
    data["timelines"]["daily"][1]
  end
end
