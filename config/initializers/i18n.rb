module I18n
  module Backend
    class Simple
      def available_locales
        init_translations unless initialized?
        translations.keys
      end
    end
  end
  def available_locales
    backend.available_locales
  end

  class << self
    alias :prev_translate :translate
    def translate(*args)
      prev_translate(*args).html_safe
    end
  end
end

