module GftUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [GftUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\AFFF:\s*/,                                 # French Film Festival
          /\ATake 2(?: Access)?:\s*/i,                 # children's strand
          /\AAccess Film Club:\s*/i,                   # autism friendly strand
          /\AMovie Memories:\s*/i,                     # dementia friendly strand
          /\AYouth Screening:\s*/i,                    # 15-25 strand
          /\APreview:\s*/i,                            # preview
          /\s+-\s+\d+(?:st|nd|rd|th) Anniversary\b/i,  # anniversary re-release
          /\s+-\s+(?:4K|35mm|70mm)\b/i,                # restoration or print
          /\s*\+\s*Introduction\z/i                    # introduction add-on
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A(?:NT|National Theatre) Live:\s*(.*)/ => 'National Theatre Live: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
