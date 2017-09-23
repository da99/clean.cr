
module Mu_Clean

  def string(*args)
    String_.clean *args
  end # === def string

  module String_

    extend self

    def clean(s : String)
      if s.valid_encoding?
        # From: https://stackoverflow.com/questions/1176904/php-how-to-remove-all-non-printable-characters-in-a-string
        s.gsub(/\t/, "  ").gsub(/[#{8287.chr}#{8199.chr}#{12288.chr}\x00-\x1F\x7F\x85\xA0[:cntrl:]]/ix, " ")
      else
        nil
      end
    end # === def clean

  end # === module String_

end # === module Mu_Clean
