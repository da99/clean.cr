
require "./Markup/Base"
require "./Markup/*"

module Mu_Html

  module Markup

    REGEX = {
      "id": /^[a-z0-9\_]+$/,
      "class": /^[a-z0-9\-\_\ ]+$/,
      "empty_string": /^$/
    }

    VALID_HTML = {
      "span": {
        attrs: ID_AND_OR_CLASS,
        tags: {
          { "span"=> String },
          { "span"=> Hash,       "data"=> String },
          { "span"=> Empty_Hash, "data"=> String }
        }
      },

      "footer" : {
        attrs: ID_AND_OR_CLASS,
        tags: {
          { "footer"=> Hash,       "data"=> String },
          { "footer"=> Empty_Hash, "data"=> String },
          { "footer"=> String }
        }
      }
    } # === VALID_HTML

    def self.validate_tag(o : Hash(String, JSON::Type))
      {%
       for mod in @type
        .constants
        .select { |x| @type.constant(x).is_a?(TypeNode) }
        .select { |x| @type.constant(x).has_constant?("TAG_NAME") }
        .map { |x| x.stringify }
      %}

        if o.has_key?({{mod.downcase}})
          {% for meth in @type.constant(mod).methods.map(&.name.stringify).map { |x| x[9..-1] }  %}
            o = {{mod.upcase.id}}.tag_attr_{{meth.id}}(o)
          {% end %}
          return o
        end

      {% end %}

      raise Exception.new("Unknown tag with keys: #{o.keys}")
    end # === validate

    def self.parse(json)
      markup = json.has_key?("markup") ? json["markup"] : nil

      case markup

      when Nil
        [] of JSON::Type

      when Array(JSON::Type)
        markup.map { | raw |
          case raw
          when Hash(String, JSON::Type)
            validate_tag(raw)
          else
            raise Exception.new("Invalid value: #{raw}")
          end
        }

      else
        raise Exception.new("Markup can only be an Array of items.")

      end # === case
    end # === def parse

  end # === module Markup

end # === module Mu_Html
