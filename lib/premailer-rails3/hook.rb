module PremailerRails
  class Hook
    def self.delivering_email(message)
      if html_part = (message.html_part || (message.content_type =~ /text\/html/ && message))
        # Generate an email with all CSS inlined (access CSS a FS path)
        premailer = Premailer.new(html_part.body.to_s, :with_html_string => true)

        # Prepend host to remaning URIs.
        # Two-phase conversion to avoid request deadlock from dev. server
        # premailer = Premailer.new(premailer.to_inline_css, :base_url => message.header[:host].to_s)

        # Capture existing plain text email content if it is present.
        existing_text_part = message.text_part && message.text_part.body.to_s
        existing_attachments = message.attachments
        msg_charset = message.charset

        # Reset the body
        message.body = nil
        message.body.instance_variable_set("@parts", Mail::PartsList.new)

        # Add an HTML part with CSS inlined.
        message.html_part do
          content_type "text/html; charset=#{msg_charset}"
          body premailer.to_inline_css
        end

        # Add a text part with either the pre-existing text part, or one generated with premailer.
        message.text_part do
          content_type "text/plain; charset=#{msg_charset}"
          body existing_text_part || premailer.to_plain_text
        end

        # Re-add any attachments
        existing_attachments.each {|a| message.body << a }

        # Return new message
        message
      end

      # # If the mail only has one part, it may be stored in message.body. In that
      # # case, if the mail content type is text/html, the body part will be the
      # # html body.
      # if message.html_part
      #   html_body = message.html_part.body.to_s
      # elsif message.content_type =~ /text\/html/
      #   html_body = message.body.to_s
      #   message.body = nil
      # end

      # if html_body
      #   premailer = Premailer.new(html_body)
      #   charset   = message.charset

      #   # IMPRTANT: Plain text part must be generated before CSS is inlined.
      #   # Not doing so results in CSS declarations visible in the plain text
      #   # part.
      #   message.text_part do
      #     content_type "text/plain; charset=#{charset}"
      #     body premailer.to_plain_text
      #   end unless message.text_part

      #   message.html_part do
      #     content_type "text/html; charset=#{charset}"
      #     body premailer.to_inline_css
      #   end
      # end
    end
  end
end
