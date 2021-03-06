class Address < ApplicationRecord
  DIRECTIONALS = %w(N NE NW S SE SW E W)
  validates :house_number, :street_name, :street_type, :city, :state, :zip_5, presence: true
  validates :zip_5, length: { is:5 }

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
