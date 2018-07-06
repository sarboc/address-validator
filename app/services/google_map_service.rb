require 'httparty'

class GoogleMapService
  attr_accessor :search_address

  def initialize(search_address)
    @search_address = search_address
  end

  def hashed_address_components
    address_components.reduce({}) do |hashed_components, component|
      key = component[:types].first.to_sym
      hashed_components[key] = component[:short_name]
      hashed_components
    end
  end

  private

  def address_components
    JSON.parse(HTTParty.get(url).body).deep_symbolize_keys[:results].first[:address_components]
  end

  def url
    "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(search_address)}&key=#{api_key}"
  end

  def api_key
    ENV['GOOGLE_API_KEY']
  end
end
