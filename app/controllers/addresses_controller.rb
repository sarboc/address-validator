class AddressesController < ApplicationController
  def index
    render 'new'
  end

  def new; end

  def create
    parsed_address = AddressParsingService.new(address_search_string).parsed_address
    @address = Address.new(parsed_address)

    if @address.save
      @message = 'address was saved!'
      @street_address, @city, @state, @zip_code = nil
    else
      @message = 'fix that address!'
      @street_address = address_params[:street_address]
      @city = address_params[:city]
      @state = address_params[:state]
      @zip_code = address_params[:zip_code]
    end

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
