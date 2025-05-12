class WeatherLookupController < ApplicationController
  CACHE_EXPIRATION = 30.minutes
  before_action :set_cache_headers, only: [ :index ]
  before_action :set_cache_expiration, only: [ :index ]

  # GET /weather_lookup
  def index
    @zip_code = weather_params[:zip_code]
    @weather_data = nil
    @error_message = nil

    if @zip_code.blank?
      @error_message = "Please enter a valid ZIP code."
    elsif @zip_code.match?(/\A\d{5}\z/)
      # Fetch weather data for the given ZIP code
      begin
        # Combine forecast and real-time data
        @weather_data = {
          last_updated: weather_realtime_data["last_updated"],
          temperature: weather_realtime_data["temperature"],
          temperature_max: weather_forecast_data["temperatureMax"],
          temperature_min: weather_forecast_data["temperatureMin"]
        }
      rescue StandardError => e
        @error_message = "Error fetching weather data: #{e.message}"
      end
    else
      @error_message = "Invalid ZIP code format. Please enter a 5-digit ZIP code."
    end
    # Render the index view with the weather data or error message
    render :index
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "public, max-age=#{CACHE_EXPIRATION.to_i}"
  end

  def set_cache_expiration
    expires_in CACHE_EXPIRATION, public: true
  end

  def weather_params
    params.permit(:zip_code)
  end

  def weather_realtime_data
    @weather_realtime_data ||= Rails.cache.fetch("weather_realtime_data/#{@zip_code}", expires_in: CACHE_EXPIRATION) do
      TomorrowIoService.new.get_weather_realtime(@zip_code, [ "temperature", "precipitation" ], "imperial").merge!(
        "last_updated" => Time.now.strftime("%Y-%m-%d %H:%M:%S") # Add the last_updated field
      )
    end
  end
  def weather_forecast_data
    @weather_forecast_data ||= Rails.cache.fetch("weather_forecast_data/#{@zip_code}", expires_in: CACHE_EXPIRATION) do
      TomorrowIoService.new.get_weather_forecast(@zip_code, [ "temperature", "precipitation" ], "imperial")
    end
  end
end
