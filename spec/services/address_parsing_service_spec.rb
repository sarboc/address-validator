require 'rails_helper'

RSpec.describe 'AddressParsingService' do
  let(:address_components) { {} }

  before do
    expect(GoogleMapService).to receive(:new).and_return(
      double(hashed_address_components: address_components)
    )
  end

  describe '#address' do
    let(:address) { '129 W 81st St #5A, New York, NY 10024, USA' }
    it 'responds to address' do
      expect(AddressParsingService.new(address).address).to eq(address)
    end
  end

  describe '#parse' do
    subject { AddressParsingService.new(address).parsed_address }

    context 'address has a city, state, and zip' do
      let(:address) { '129 W 81st St Apt 5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'W 81st St',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the city, state and zip_5' do
        expect(subject).to match(a_hash_including({
          city: 'New York',
          state: 'NY',
          zip_5: '10024'
        }))
      end
    end

    context 'address has a unit type and number' do
      let(:address) { '129 W 81st St Apt 5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'W 81st St',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the proper unit_type and unit_number' do
        expect(subject).to match(a_hash_including({
          unit_type: 'Apt',
          unit_number: '5A'
        }))
      end
    end

    context 'address has a unit number with a pound sign' do
      let(:address) { '129 W 81st St #5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'W 81st St',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the proper unit_type and unit_number' do
        expect(subject).to match(a_hash_including({
          unit_type: '#',
          unit_number: '5A'
        }))
      end
    end

    context 'address has a street predirection' do
      let(:address) { '129 W Two Name St #5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'W Two Name St',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the proper street_predirection, street_name and street_type' do
        expect(subject).to match(a_hash_including({
          street_predirection: 'W',
          street_name: 'Two Name',
          street_type: 'St'
        }))
      end
    end

    context 'address has a street postdirection' do
      let(:address) { '129 Two Name St W #5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'Two Name St W',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the proper street_postdirection, street_name and street_type' do
        expect(subject).to match(a_hash_including({
          street_postdirection: 'W',
          street_name: 'Two Name',
          street_type: 'St'
        }))
      end
    end

    context 'address has no street pre nor post direction' do
      let(:address) { '129 Two Name St, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'Two Name St',
          street_number: '129',
        }
      end

      it 'returns the proper street_postdirection, street_name and street_type' do
        expect(subject).to match(a_hash_including({
          street_predirection: nil,
          street_postdirection: nil,
          street_name: 'Two Name',
          street_type: 'St'
        }))
      end
    end

    context 'address has no street' do
      let(:address) { 'New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
        }
      end

      it 'returns the proper street_postdirection, street_name and street_type' do
        expect(subject).to match(a_hash_including({
          street_predirection: nil,
          street_postdirection: nil,
          street_name: nil,
          street_type: nil
        }))
      end
    end

    context 'address has a street number' do
      let(:address) { '129 Two Name St W #5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'Two Name St W',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the proper house_number' do
        expect(subject).to match(a_hash_including({
          house_number: '129',
        }))
      end
    end

    context 'address has a street number that includes a space' do
      let(:address) { '129 1/2 Two Name St W #5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'Two Name St W',
          street_number: '129',
          subpremise: '5A'
        }
      end

      it 'returns the proper house_number' do
        expect(subject).to match(a_hash_including({
          house_number: '129 1/2',
        }))
      end
    end

    context 'address has a street number but no route' do
      let(:address) { '129 New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          street_number: '129',
        }
      end

      it 'returns the proper house_number' do
        expect(subject).to match(a_hash_including({
          house_number: '129',
        }))
      end
    end

    context 'address does not contain a street number' do
      let(:address) { 'Two Name St W #5A, New York, NY 10024, USA' }
      let(:address_components) do
        {
          administrative_area_level_1: 'NY',
          locality: 'New York',
          postal_code: '10024',
          route: 'Two Name St W',
          subpremise: '5A'
        }
      end

      it 'returns the proper house_number' do
        expect(subject).to match(a_hash_including({
          house_number: nil,
        }))
      end
    end
  end
end
