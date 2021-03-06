module PremailerRails
  class Premailer < ::Premailer
    def initialize(html, options = {})
      # In order to pass the CSS as string to super it is necessary to access
      # the parsed HTML beforehand. To do so, the adapter needs to be
      # initialized. The ::Premailer::Adaptor handles the discovery of a
      # suitable adaptor (Nokogiri or Hpricot). To make load_html work, an
      # adaptor needs to be included and @options[:with_html_string] needs to be
      # set. For further information, refer to ::Premailer#initialize.
      @options = { :with_html_string => true }
      ::Premailer.send(:include, Adapter.find(Adapter.use))
      doc = load_html(html)

      options = PremailerRails3.config.merge(
        :with_html_string => true,
        :css_string       => CSSHelper.css_for_doc(doc)
      ).update(options)
      super(html, options)
    end
  end
end
