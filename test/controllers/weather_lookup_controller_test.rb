require "test_helper"

class WeatherLookupControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get weather_lookup_index_url
    assert_response :success
  end

  test "should return weather data for valid zip code" do
    # Use VCR to record the API response for the given ZIP code
    VCR.use_cassette("weather_lookup/10001") do
      get weather_lookup_index_url, params: { zip_code: "10001" }
    end
    assert_response :success
    assert_not_nil assigns(:weather_data)
    assert_nil assigns(:error_message)
  end

  test "should return error message for invalid zip code" do
    # Use VCR to record the API response for an invalid ZIP code
    VCR.use_cassette("weather_lookup/invalid_zip") do
      get weather_lookup_index_url, params: { zip_code: "invalid_zip" }
    end
    assert_response :success
    assert_nil assigns(:weather_data)
    assert_not_nil assigns(:error_message)
  end

  test "should set cache headers" do
    get weather_lookup_index_url
    assert_response :success
    assert_includes response.headers["Cache-Control"], "max-age=1800"
    assert_includes response.headers["Cache-Control"], "public"
  end

  test "should set cache expiration" do
    get weather_lookup_index_url
    assert_response :success
    assert_includes response.headers["Cache-Control"], "max-age=#{WeatherLookupController::CACHE_EXPIRATION.to_i}"
  end

  test "should handle empty zip code gracefully" do
    # Use VCR to record the API response for an empty ZIP code
    VCR.use_cassette("weather_lookup/empty_zip") do
      get weather_lookup_index_url, params: { zip_code: "" }
    end
    assert_response :success
    assert_nil assigns(:weather_data)
    assert_not_nil assigns(:error_message)
  end

  test "should handle incorrect zip code format gracefully" do
    # Use VCR to record the API response for an incorrect ZIP code format
    VCR.use_cassette("weather_lookup/incorrect_zip_format") do
      get weather_lookup_index_url, params: { zip_code: "1234" }
    end
    assert_response :success
    assert_nil assigns(:weather_data)
    assert_not_nil assigns(:error_message)
  end
end
