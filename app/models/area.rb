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

  class << self
    # regionとareaによって分類されたユーザー数をハッシュで取得して返す関数
    # country_codeかsubdivision_codeのどちらかがnullのユーザーのデータは無視されます
    #
    # 返されるハッシュの例
    # {
    #   '関東地方' => { '東京都' => 1, '栃木県' => 1 },
    #   '九州・沖縄地方' => { '長崎県' => 1 },
    #   '海外' => { '米国' => 2, 'カナダ' => 1 }
    # }
    #
    def number_of_users_by_region
      translated_pairs = translate(country_subdivision_pairs)
      by_countries = translated_pairs.group_by(&:first)
      # hash autovivification https://stackoverflow.com/questions/50468234/better-way-to-initialize-and-update-deeply-nested-hash
      by_countries.each_with_object(Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }) do |v, result|
        country, pair_array = v
        if country == '日本'
          pair_array.each do |pair|
            result = select_region(pair[1], result)
          end
        else
          result['海外'][pair_array.map(&:first)[0]] = pair_array.map(&:second).length
        end
      end
    end

    def sorted_user_groups_by_area_user_num
      users_group_by_areas = User.with_attached_avatar.order(created_at: :desc).group_by(&:area)

      sorted_users_group_by_non_nil_areas =
        users_group_by_areas.map do |area, users|
          { users:, area: } unless area.nil?
        end.compact

      sorted_users_group_by_non_nil_areas.sort_by { |hash| -hash[:users].size }
    end

    private

    def country_subdivision_pairs
      User
        .select('country_code, subdivision_code')
        .where.not(country_code: [nil, ''])
        .where.not(subdivision_code: [nil, ''])
        .pluck(:country_code, :subdivision_code)
        .filter do |country_code, subdivision_code|
          # country_codeが間違っている場合は配列から削除する
          if ISO3166::Country.codes.include?(country_code)
            # subdivision_codeが間違っている場合は配列から削除する
            ISO3166::Country[country_code].subdivisions.key?(subdivision_code)
          else
            false
          end
        end
    end

    def translate(country_subdivision_pairs)
      country_subdivision_pairs.map do |country_code, subdivision_code|
        country = ISO3166::Country[country_code]
        subdivision = country.subdivisions[subdivision_code]
        [country.translations['ja'], subdivision.translations['ja']]
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
