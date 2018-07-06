class Address < ApplicationRecord
  def to_s
    # TODO: override the to_s method so that it prints out the address components as follows
    # house_number street_name street_predirection street_type street_postdirection unit_type unit_number, city, state, zip_5
  end

  def street_address
    [
      house_number,
      street_predirection,
      street_name,
      street_type,
      street_postdirection,
      unit_type,
      unit_number
    ].compact.join(' ')
  end
end
