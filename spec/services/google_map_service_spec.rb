require 'rails_helper'

RSpec.describe 'GoogleMapService' do
  describe '#search_address' do
    it 'sets the search address on init' do
      address = '1234 Somewhere Lane, CA'
      search = GoogleMapService.new(address)
      expect(search.search_address).to eq(address)
    end
  end

  describe '#hashed_address_components' do
    let(:response) do
      {results: [
        {
          address_components: [
            {
              long_name: '5A',
              short_name: '5A',
              types: ['subpremise']
            },
            {
              long_name: '129',
              short_name: '129',
              types: ['street_number']
            },
            {
              long_name: 'West 81st Street',
              short_name: 'W 81st St',
              types: ['route']
            },
            {
              long_name: 'Manhattan',
              short_name: 'Manhattan',
              types: ['political', 'sublocality', 'sublocality_level_1']
            },
            {
              long_name: 'New York',
              short_name: 'New York',
              types: ['locality', 'political']
            },
            {
              long_name: 'New York County',
              short_name: 'New York County',
              types: ['administrative_area_level_2', 'political']
            },
            {
              long_name: 'New York',
              short_name: 'NY',
              types: ['administrative_area_level_1', 'political']
            },
            {
              long_name: 'United States',
              short_name: 'US',
              types: ['country', 'political']
            },
            {
              long_name: '10024',
              short_name: '10024',
              types: ['postal_code']
            },
            {
              long_name: '7207',
              short_name: '7207',
              types: ['postal_code_suffix']
            }
          ],
          formatted_address: '129 W 81st St #5A, New York, NY 10024, USA',
        }
      ]}.to_json
    end
    let(:address) { '129 W 81st St Apt 5A, New York, NY 10024' }
    let(:api_key) { 'ABC123' }
    let(:api_url) { "https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&key=#{api_key}" }
    let(:map_service) { GoogleMapService.new(address) }

    before do
      expect(ENV).to receive(:[]).with('GOOGLE_API_KEY').and_return(api_key)
      expect(HTTParty).to receive(:get).with(api_url).and_return(double(body: response))
    end

    it 'returns formatted address components based on the search' do
      expect(map_service.hashed_address_components).to match a_hash_including(
        administrative_area_level_1: 'NY',
        locality: 'New York',
        postal_code: '10024',
        route: 'W 81st St',
        street_number: '129',
        subpremise: '5A'
      )
    end
  end
end
