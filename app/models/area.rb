# frozen_string_literal: true

class Area
  HOKKAIDO_TOHOKU = %w[北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県].freeze
  KANTO = %w[茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県].freeze
  CHUBU = %w[新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県 愛知県].freeze
  KINKI = %w[三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県].freeze
  CHUGOKU = %w[鳥取県 島根県 岡山県 広島県 山口県].freeze
  SHIKOKU = %w[徳島県 香川県 愛媛県 高知県].freeze
  KYUSHU_OKINAWA = %w[福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県].freeze
  REGIONS = {
    '北海道・東北地方' => HOKKAIDO_TOHOKU,
    '関東地方' => KANTO,
    '中部地方' => CHUBU,
    '近畿地方' => KINKI,
    '中国地方' => CHUGOKU,
    '四国地方' => SHIKOKU,
    '九州・沖縄地方' => KYUSHU_OKINAWA
  }.freeze
  JP = ISO3166::Country[:JP]

  class << self
    # 日本の場合は都道府県、海外の場合は国名によってユーザーを取得
    def users(subdivision_or_country, region)
      if region == '海外'
        country = ISO3166::Country.find_country_by_any_name(subdivision_or_country)
        User
          .with_attached_avatar
          .where(country_code: country.alpha2)
      else
        subdivision_code = JP.find_subdivision_by_name(subdivision_or_country).code
        User
          .with_attached_avatar
          .where(subdivision_code: subdivision_code.to_s)
      end
    end

    def user_counts_by_subdivision
      translated_pairs = to_jp(country_subdivision_pairs)
      by_countries = translated_pairs.group_by(&:first)
      # hash autovivification https://stackoverflow.com/questions/50468234/better-way-to-initialize-and-update-deeply-nested-hash
      by_countries.each_with_object(Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }) do |v, result|
        country, pair_array = v
        if country == '日本'
          pair_array.each do |_, s|
            result = select_region(s, result)
          end
        else
          result['海外'][pair_array.map(&:first)[0]] = pair_array.map(&:second).length
        end
      end
    end

    private

    def country_subdivision_pairs
      User
        .select('country_code, subdivision_code')
        .where.not(subdivision_code: nil)
        .pluck(:country_code, :subdivision_code)
    end

    def to_jp(country_subdivision_pairs)
      country_subdivision_pairs.map do |country_code, subdivision_code|
        country = ISO3166::Country[country_code]
        subdivision = country.subdivisions[subdivision_code]
        [country.translations[I18n.locale.to_s], subdivision.translations[I18n.locale.to_s]]
      end
    end

    def select_region(subdivision, result)
      REGIONS.each do |region_name, region_array|
        if region_array.include?(subdivision)
          result[region_name][subdivision] = result[region_name][subdivision].is_a?(Numeric) ? result[region_name][subdivision] + 1 : 1
        end
      end
      result
    end
  end
end
