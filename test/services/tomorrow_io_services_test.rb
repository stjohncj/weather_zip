require "test_helper"

class TomorrowIoServiceTest < ActiveSupport::TestCase
  def setup
    @api_key = ENV["TOMORROW_IO_API_KEY"]
    @service = TomorrowIoService.new(@api_key)
  end

  test "should raise error if API key is not provided or in environment" do
    ClimateControl.modify TOMORROW_IO_API_KEY: nil do
      assert_raises(RuntimeError) do
        TomorrowIoService.new(nil)
      end
    end
  end

  test "should fetch realtime weather data by location" do
    VCR.use_cassette("tomorrow_io_service/get_weather_realtime") do
      location = "New York"
      fields = [ "temperature", "precipitation" ]
      units = "imperial"
      response = @service.get_weather_realtime(location, fields, units)
      assert response.is_a?(Hash)
      assert response["data"].is_a?(Hash)
      assert response["data"]["values"].is_a?(Hash)
      assert response["data"]["values"]["temperature"].is_a?(Numeric)
      assert response["data"]["values"]["humidity"].is_a?(Numeric)
    end
  end

  test "should fetch forecast weather data by location" do
    VCR.use_cassette("tomorrow_io_service/get_weather_forecast") do
      location = "New York"
      fields = [ "temperature", "precipitation" ]
      units = "imperial"
      response = @service.get_weather_forecast(location, fields, units)
      assert response.is_a?(Hash)
      assert response["timelines"].is_a?(Hash)
      assert response["timelines"]["daily"].is_a?(Array)
      assert response["timelines"]["daily"].any?
      assert response["timelines"]["daily"][0].is_a?(Hash)
      assert response["timelines"]["daily"][0]["time"].is_a?(String)
      assert response["timelines"]["daily"][0]["values"].is_a?(Hash)
      assert response["timelines"]["daily"][0]["values"]["temperatureMax"].is_a?(Numeric)
      assert response["timelines"]["daily"][0]["values"]["temperatureAvg"].is_a?(Numeric)
    end
  end

  test "should fetch weather forecast data by zip code" do
    VCR.use_cassette("tomorrow_io_service/get_weather_forecast_by_zip") do
      zip_code = "10001"
      fields = [ "temperature", "precipitation" ]
      units = "imperial"

      response = @service.get_weather_forecast_by_zip(zip_code, fields, units)

      assert response.is_a?(Hash)
      assert response["timelines"].is_a?(Hash)
      assert response["timelines"]["daily"].is_a?(Array)
      assert response["timelines"]["daily"].any?
      assert response["timelines"]["daily"][0].is_a?(Hash)
      assert response["timelines"]["daily"][0]["time"].is_a?(String)
      assert response["timelines"]["daily"][0]["values"].is_a?(Hash)
      assert response["timelines"]["daily"][0]["values"]["temperatureMax"].is_a?(Numeric)
    end
  end

  test "should fetch today's forecast temperatures by zip code" do
    VCR.use_cassette("tomorrow_io_service/get_weather_forecast_temperatures_by_zip") do
      zip_code = "10001"

      response = @service.get_weather_forecast_temperatures_by_zip(zip_code)

      assert response.is_a?(Hash)
      assert response["time"].is_a?(String)
      assert response["values"].is_a?(Hash)
      assert response["values"]["temperatureMax"].is_a?(Numeric)
      assert response["values"]["temperatureMin"].is_a?(Numeric)
      assert response["values"]["temperatureAvg"].is_a?(Numeric)
    end
  end
end
