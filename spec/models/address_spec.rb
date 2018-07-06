require 'rails_helper'

RSpec.describe Address, :type => :model do
  describe '#new' do
    context 'Given a valid address' do
      it 'can create a new address' do
        expect(Address.new(
                          house_number: 1600,
                          street_name: 'Pennsylvania',
                          street_type: 'Avenue',
                          street_postdirection: 'NW',
                          city: 'Washington',
                          state: 'DC',
                          zip_5: 20500
                        )).to be_valid
      end
    end

    context 'Given bad address values' do
      it 'cannot create a new address' do
        expect(Address.new(
                          house_number: 1600,
                          street_name: 'Pennsylvania',
                          street_type: 'Avenue',
                          street_postdirection: 'NW',
                          city: 'Washington',
                          state: 'DC',
                          zip_5: 123
                        )).not_to be_valid
      end
    end

    describe '#to_s' do
      let(:address) { create(:address_ny) }
      it 'prints out the address components needed for mailing together as a string' do
        expect(address.to_s).to eq('129 W 81st St Apt 5A, New York, NY 10024')
      end
    end

    describe '#street_address' do
      context 'address does not have a predirection' do
        let(:address) { create(:address_ny, street_predirection: nil) }
        it 'prints the street address components without an extra space' do
          expect(address.street_address).to eq('129 81st St Apt 5A')
        end
      end

      context 'address does not have a postdirection' do
        let(:address) { create(:address_ny, street_postdirection: nil) }
        it 'prints the street address components without an extra space' do
          expect(address.street_address).to eq('129 W 81st St Apt 5A')
        end
      end

      context 'address does not have a unit type' do
        let(:address) { create(:address_ny, unit_type: nil) }
        it 'prints the street address components without an extra space' do
          expect(address.street_address).to eq('129 W 81st St 5A')
        end
      end

      context 'address does not have a unit number' do
        let(:address) { create(:address_ny, unit_number: nil) }
        it 'prints the street address components without an extra space' do
          expect(address.street_address).to eq('129 W 81st St Apt')
        end
      end
    end

    # Do we want to add other addresses that we know are good or bad and say that those should no be valid
  end
end
