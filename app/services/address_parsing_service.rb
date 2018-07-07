class AddressParsingService
  attr_accessor :address, :address_components, :search_result

  def initialize(address)
    @address = address
    @address_components = address.gsub(',', '').split(' ')
    @search_result = search_address
  end

  def parsed_address
    {
      city: search_result[:locality],
      state: search_result[:administrative_area_level_1],
      zip_5: search_result[:postal_code]
    }.merge(parse_unit_type_number)
      .merge(parse_street_name_predirection_postdirection_type)
      .merge(parse_house_number)
  end

  private

  def parse_unit_type_number
    unit_type, unit_number  = nil

    if search_result[:subpremise]
      unit_search_result = search_result[:subpremise]
      unit_number_index = address_components.index{|i| i =~ /#{unit_search_result}$/}
      unit_number = address_components[unit_number_index]

      if unit_number == unit_search_result
        unit_type = address_components[unit_number_index - 1]
      elsif unit_number[0] == '#'
        unit_type = '#'
        unit_number.sub!('#', '')
      end
    end

    {unit_type: unit_type, unit_number: unit_number}
  end

  def parse_street_name_predirection_postdirection_type
    street_name, street_predirection, street_postdirection, street_type = nil

    route = search_result[:route].dup

    if route
      route_first_chunk = route.split(' ').first
      if Address::DIRECTIONALS.include?(route_first_chunk)
        street_predirection = route_first_chunk
        route.sub!("#{street_predirection} ", '')
      end

      route_last_chunk = route.split(' ').last
      if Address::DIRECTIONALS.include?(route_last_chunk)
        street_postdirection = route_last_chunk
        route.sub!(" #{street_postdirection}", '')
      end

      last_space = route.rindex(' ')
      street_type = route[last_space + 1..-1]

      route.sub!(" #{street_type}", '')
    end

    {
      street_name: route,
      street_predirection: street_predirection,
      street_postdirection: street_postdirection,
      street_type: street_type
    }
  end

  def parse_house_number
    house_number = nil

    if search_result[:route]
      beginning_of_route_string = search_result[:route].split(' ').first
      route_start_index = address.index(" #{beginning_of_route_string}")
      house_number = address[0...route_start_index] if route_start_index
    elsif search_result[:street_number]
      house_number = search_result[:street_number]
    end

    { house_number: house_number }
  end

  def search_address
    GoogleMapService.new(address).hashed_address_components
  end
end
