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
    context.original_checks = context.original_product.checks.order(:created_at, :id).limit(1).to_a

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
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    context.fail!(error: "Failed to create check: #{e.message}")
  end

  def process_checks
    return { copied: 0, skipped: 1 } if Check.exists?(checkable: context.copied_product)

    copy_check(context.original_checks.first)
    { copied: 1, skipped: 0 }
  end

  def store_results(results)
    context.copied_checks_count = results[:copied]
    context.skipped_checks_count = results[:skipped]
  end

  def update_completion_message(results)
    context.message = build_summary_message(results)
  end

  def build_summary_message(results)
    "Copied #{results[:copied]} check(s), skipped #{results[:skipped]} existing check(s)"
  end

  def copy_check(original_check)
    Check.create!(
      user: original_check.user,
      checkable: context.copied_product
    )
  end
end
