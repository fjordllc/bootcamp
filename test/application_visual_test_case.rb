# frozen_string_literal: true

require 'application_system_test_case'
require 'capybara_screenshot_diff/minitest'

# Base class for visual regression tests.
#
# These tests capture a screenshot of a page and compare it, pixel by pixel,
# against a committed baseline image. They are meant to catch *unintended*
# visual changes (e.g. during a CSS refactor).
#
# IMPORTANT: baseline images are environment-sensitive. Font anti-aliasing
# differs between macOS and Linux, so a baseline generated on a Mac will not
# match one compared on CI. Always generate and compare baselines in the SAME
# environment (the CI Ubuntu image or an equivalent Docker container).
# See test/visual/README.md for the full workflow.
class ApplicationVisualTestCase < ApplicationSystemTestCase
  include CapybaraScreenshotDiff::Minitest::Assertions

  # Screenshots (baseline + diff) live under test/visual/screenshots.
  Capybara::Screenshot.save_path = 'test/visual/screenshots'
  # Compare against the whole page at a fixed viewport for reproducibility.
  Capybara::Screenshot.window_size = [1400, 1400]
  # Allow a tiny tolerance so sub-pixel anti-aliasing noise does not fail a run.
  # Passed per-screenshot below (module-level key varies between gem versions).
  TOLERANCE = 0.001
  # Wait until the rendered image stops changing before snapping (async UI).
  Capybara::Screenshot.stability_time_limit = 0.5
  # Do NOT use the gem's blur_active_element: it calls `.click` on the value
  # returned by evaluate_script(document.activeElement), which the
  # capybara-playwright-driver serializes to a Hash (not a Capybara node),
  # raising NoMethodError. The blinking caret is instead neutralized by the
  # `caret-color: transparent` rule injected via STABILIZE_CSS below.
  Capybara::Screenshot.blur_active_element = false

  # CSS injected before every capture to remove non-deterministic motion.
  STABILIZE_CSS = <<~CSS
    *, *::before, *::after {
      transition: none !important;
      animation: none !important;
      caret-color: transparent !important;
      scroll-behavior: auto !important;
    }
  CSS

  # Elements whose content changes run to run (heatmaps, avatars pulled from
  # Gravatar, relative timestamps, …). They are masked so only layout/styling
  # is compared. Tune this list for your pages.
  DEFAULT_MASK_SELECTORS = [
    '.a-user-icons',
    '.a-user-icon', # the avatar <img> itself carries this class (header "Me", comments)
    '.a-user-icon img',
    '.user-icon img',
    '.a-grass',
    '.user-grass',
    '.niconico-calendar',
    '.a-elapsed-days',
    '.random-tags-items', # users index sidebar renders a RANDOM set of tags
    'time'
  ].freeze

  setup do
    # Freeze time so relative timestamps ("3日前") and elapsed-day badges are
    # stable across runs.
    travel_to Time.zone.local(2025, 1, 1, 12, 0, 0)
  end

  teardown do
    travel_back
  end

  # Capture the current page and compare it against the baseline named +name+.
  # Waits for JS components, fonts, and lazy images before snapping.
  #
  # +extra_mask+ adds page-specific selectors on top of DEFAULT_MASK_SELECTORS
  # (e.g. a panel whose row order/height is non-deterministic on that page).
  def capture(name, mask: DEFAULT_MASK_SELECTORS, extra_mask: [])
    wait_for_javascript_components
    wait_for_fonts_and_images
    stabilize_page(mask + extra_mask)
    screenshot(name, tolerance: TOLERANCE)
  end

  private

  def stabilize_page(mask_selectors)
    css = STABILIZE_CSS.dup
    css << mask_selectors.map { |sel| "#{sel} { visibility: hidden !important; }" }.join("\n")
    execute_script(<<~JS, css)
      const style = document.createElement('style');
      style.setAttribute('data-visual-test', 'stabilize');
      style.textContent = arguments[0];
      document.head.appendChild(style);
    JS
  end

  def wait_for_fonts_and_images
    page.document.synchronize(5) do
      ready = evaluate_script(<<~JS)
        (document.fonts ? document.fonts.status === 'loaded' : true) &&
        Array.from(document.images).every((img) => img.complete)
      JS
      raise Capybara::ElementNotFound, 'fonts/images not ready' unless ready
    end
  rescue Capybara::ElementNotFound
    # Best effort: proceed even if a slow asset never settles.
    nil
  end
end
