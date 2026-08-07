# frozen_string_literal: true

class UserRegion
  def initialize(user)
    @user = user
  end

  def country_name
    country = ISO3166::Country[@user.country_code]
    country.translations[I18n.locale.to_sym]
  end

  def subdivision_name
    country = ISO3166::Country[@user.country_code]
    subdivision = country.subdivisions[@user.subdivision_code]
    subdivision.translations[I18n.locale.to_sym]
  end

  def subdivision_codes
    country = ISO3166::Country[@user.country_code]
    country ? country.subdivisions.keys : []
  end

  def area
    if @user.country_code == 'JP'
      subdivision = ISO3166::Country['JP'].subdivisions[@user.subdivision_code]
      subdivision ? subdivision.translations[:ja] : nil
    else
      country = ISO3166::Country[@user.country_code]
      country ? country.translations[:ja] : nil
    end
  end
end