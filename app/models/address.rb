class Address < ApplicationRecord
  def to_s
    "#{street_address}, #{city}, #{state} #{zip_5}"
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
