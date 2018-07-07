class AddressesController < ApplicationController
  def index
    render 'new'
  end

  def new; end

  def create
    parsed_address = AddressParsingService.new(address_search_string).parsed_address
    @address = Address.new(parsed_address)
    @address.save

    render 'new'
  end

  private

  def address_search_string
    address_params.values.join(' ')
  end

  def address_params
    params.permit(:street_address, :city, :state, :zip_code)
  end
end
