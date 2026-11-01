require_relative '../../../test_helper'

class GftUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Primetime', 'Primetime'
    assert_sanitized 'GIANT - The Play', 'GIANT - The Play'
    assert_sanitized 'Don’t Cry, Pretty Girls!', 'Don’t Cry, Pretty Girls!'
  end

  def test_strand_and_festival_prefixes
    assert_sanitized 'Violette', 'FFF: Violette'
    assert_sanitized 'Flight of the Navigator', 'Take 2: Flight of the Navigator'
    assert_sanitized 'The LEGO Movie', 'Take 2 Access: The LEGO Movie'
    assert_sanitized 'Tokyo Godfathers', 'Access Film Club: Tokyo Godfathers'
    assert_sanitized 'An Affair to Remember', 'Movie Memories: An Affair to Remember'
    assert_sanitized 'Attack the Block', 'Youth Screening: Attack the Block'
    assert_sanitized 'The History of Concrete', 'Preview: The History of Concrete'
  end

  def test_anniversaries_restorations_and_prints
    assert_sanitized 'Marie Antoinette', 'Marie Antoinette - 20th Anniversary - 4K'
    assert_sanitized 'Ninja Scroll', 'Ninja Scroll - 4K'
    assert_sanitized 'Short Cuts', 'Short Cuts - 35mm'
    assert_sanitized 'A Silent Voice', 'A Silent Voice (10th Anniversary)'
  end

  def test_add_ons
    assert_sanitized "It's Nice Up North", "It's Nice Up North - 20th Anniversary + Q&A"
    assert_sanitized 'The Money Maker', 'FFF: The Money Maker + Q&A'
    assert_sanitized 'Malina', 'Malina + introduction'
    assert_sanitized 'A Woman Under the Influence', 'A Woman Under the Influence + discussion'
  end

  def test_national_theatre_live
    assert_sanitized 'National Theatre Live: Hay Fever', 'NT Live: Hay Fever'
  end

  def test_royal_ballet_and_opera
    assert_sanitized 'Royal Ballet and Opera: Swan Lake', 'RBO 2026-27: Swan Lake'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, GftUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
