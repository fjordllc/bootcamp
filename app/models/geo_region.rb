# frozen_string_literal: true

# 国コード・都道府県コードから、表示名を組み立てるための値オブジェクト。
# Userの構造を知らなくてよいように、必要な値(country_code/subdivision_code)だけを受け取る。
class GeoRegion
  def initialize(country_code, subdivision_code)
    @country_code = country_code
    @subdivision_code = subdivision_code
  end

  def country_name
    country = ISO3166::Country[@country_code]
    country.translations[I18n.locale.to_sym]
  end

  def subdivision_name
    country = ISO3166::Country[@country_code]
    subdivision = country.subdivisions[@subdivision_code]
    subdivision.translations[I18n.locale.to_sym]
  end

  def subdivision_codes
    country = ISO3166::Country[@country_code]
    country ? country.subdivisions.keys : []
  end

  def area
    if @country_code == 'JP'
      subdivision = ISO3166::Country['JP'].subdivisions[@subdivision_code]
      subdivision ? subdivision.translations[:ja] : nil
    else
      country = ISO3166::Country[@country_code]
      country ? country.translations[:ja] : nil
    end
  end
end
