# frozen_string_literal: true

class CopyCheck
  include Interactor

  def call
    # Skip if no product was copied but consider it successful
    unless context.copied_product && context.original_product
      context.message = 'No product available for check copying, skipping'
      return
    end

    find_original_checks
    copy_all_checks
  end

  private

  def find_original_checks
    context.original_checks = context.original_product.checks.to_a

    context.message = if context.original_checks.empty?
                        'No checks found to copy'
                      else
                        "Found #{context.original_checks.size} check(s) to copy"
                      end
  end

  def copy_all_checks
    return if context.original_checks.empty?

    results = process_checks
    store_results(results)
    update_completion_message(results)
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: "Failed to create check: #{e.message}")
  end

  def process_checks
    copied_count = 0
    skipped_count = 0

    # Fetch all existing check user IDs for the copied product in one query
    existing_user_ids = Check.where(checkable: context.copied_product)
                             .pluck(:user_id)
                             .to_set

    context.original_checks.each do |original_check|
      if copy_check(original_check, existing_user_ids)
        copied_count += 1
      else
        skipped_count += 1
      end
    end

    { copied: copied_count, skipped: skipped_count }
  end

  def store_results(results)
    context.copied_checks_count = results[:copied]
    context.skipped_checks_count = results[:skipped]
  end

  def update_completion_message(results)
    context.message = build_summary_message(results)
  end

  def products_available?
    context.original_product && context.copied_product
  end

  def build_summary_message(results)
    "Copied #{results[:copied]} check(s), skipped #{results[:skipped]} existing check(s)"
  end

  def copy_check(original_check, existing_user_ids)
    # Check if this user already has a check for the copied product
    return false if existing_user_ids.include?(original_check.user_id)

    Check.create!(
      user: original_check.user,
      checkable: context.copied_product
    )

    # Add the new user ID to the set to avoid duplicates in subsequent iterations
    existing_user_ids.add(original_check.user_id)
    true
  end
end
