# frozen_string_literal: true

namespace :issues do
  namespace :issue3038 do
    desc 'Add commented at in products'
    task add_commented_at_in_products: :environment do |task|
      Product.all.includes(:comments).each do |product|
        next if product.comments.blank?

        product.commented_at = product.comments.last.updated_at
        product.save!
      end

      puts %(Task "#{task.name}" is done.)
    end
  end
end
