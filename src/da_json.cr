
require "da_html"
require "json"

module Mu_Clean

  module DA_JSON

    VALID_KEY = /^[a-zA-Z0-9\_\-]{1,20}$/
    DATA_ID_INVALID = /[^a-zA-Z0-9\_\-]+/

    def self.clean(json : Hash(String, JSON::Type) )
      data = json["data"]?

        case data

      when Hash(String, JSON::Type)
        data.each do |k, v|
          data[clean_key(k)] = clean_value(v)
        end

      when Nil
        json["data"] = {} of String => JSON::Type

      else
        raise Exception.new("section data can only be a key => value structure")

      end
    end # === def self.parse

    def self.clean_key(s : String)
      unless s =~ VALID_KEY 
        raise Exception.new("Invalid key in data section: #{s.inspect}")
      end
      s
    end # === def self.clean_key

    def self.clean_value(s : String)
      DA_HTML.escape(s)
    end # === def self.clean_value

    def self.clean_value(i : Int32 | Int64)
      i
    end

    def self.clean_value(arr : Array(JSON::Type))
      arr.each_index { |i|
        arr[i] = clean_value(arr[i])
      }
      arr
    end

    def self.clean_value(h : Hash(String, JSON::Type))
      h.each do |k, v|
        clean_k = clean_key(k)
        raise Exception.new("Invalid key in data: #{k.inspect}") if clean_k != k
        clean_v = clean_value(v)
        case clean_v
        when JSON::Type
          h[clean_k] = clean_v
        else
          raise Exception.new("Invalid value for #{k}: #{v.inspect}")
        end
      end
      h
    end # === def self.clean_value

    def self.clean_value(u : Bool)
      u
    end

    def self.clean_value(u)
      raise Exception.new("Invalid value for data: #{u.inspect}")
      u
    end

    def self.get(data : Hash(String, JSON::Type))
      v = data["data"]?
        case v
      when Hash(String, JSON::Type)
        :ignore
      else
        raise Exception.new("Data section not found. Keys: #{data.keys}")
      end

      v
    end # === def self.get

    def self.get(data : Hash(String, JSON::Type), key : String )
      if key =~ DATA_ID_INVALID
        raise Exception.new("Invalid data key: #{key}")
      end
      keys = key.strip.split(".")
      get(get(data), 0, keys)
    end # === def self.get

    def self.get(data : Hash(String, JSON::Type), i : Int32, keys : Array(String))
      if i >= keys.size || !data.has_key?(keys[i])
        raise Exception.new("Data not found: #{keys.join(".")}")
      end
      get(data[keys[i]], i+1, keys)
    end # === def self.get

    def self.get(data : String | Int64, i : Int32, keys : Array(String))
      DA_HTML.escape(data.to_s)
    end # === def self.get

    def self.get(u1, u2, keys : Array(String))
      raise Exception.new("Invalid data value: #{keys.join(".")}")
    end # === def self.get

    def self.get(data : JSON::Type, key : JSON::Type)
      case data
      when Hash(String, JSON::Type)
        case key
        when String
          return data[key] if data.has_key?(key)
        end
      end

      raise Exception.new("Data not found: #{key.inspect} in #{data.inspect}")
    end # === def self.get

    def self.get_each(data, key)
      v = get(data, key)
      case v
      when Array, Hash
        return v
      end
      raise Exception.new("Invalid data: #{key.inspect} in #{data.inspect}")
    end # === def self.get_each

    def self.new_key(data : Hash(String, JSON::Type), key : String, v : String | Int32 | Int64)
      raise Exception.new("Data already exists: #{key.inspect}") if data.has_key?(key)
      data[key] = v
    end # === def self.new_key

    def self.new_key(data, key, v)
      raise Exception.new("Invalid retrieval of data: #{data.inspect}, #{key.inspect}, #{v.inspect}")
    end

    def self.delete(data : Hash(String, JSON::Type), key : String)
      data.delete(key)
    end # === def self.delete

    def self.delete(data, key)
      raise Exception.new("Can't delete data: #{data.inspect}, #{key.inspect}")
    end # === def self.delete

    # =========================================================================
    # === .escape =============================================================
    # =========================================================================

    def self.escape(s : String) : String
      new_s = unescape(s)
      DA_HTML.escape(new_s)
    end # === def self.escape

    def self.escape(i : Int32 | Int64)
      i
    end # === def self.escape

    def self.escape(b : Bool)
      b
    end # === def self.escape

    def self.escape(a : Array)
      a.map { |v| escape(v) }
    end # === def self.escape

    def self.escape(h : Hash(String | Symbol, JSON::Type))
      h.each do |k, v|
        h[k] = escape(v)
      end
      h
    end # === def self.escape

    def self.escape(u)
      raise Exception.new("Invalid value: #{u.class}")
      escape(u.to_s)
    end # === def self.escape

    def self.unescape(s : String)
      old_s = ""
      new_s = s
      while old_s != new_s
        old_s = new_s
        new_s = HTML.unescape(new_s)
      end
      new_s
    end

    def self.unescape(u)
      unescape(u.to_s)
    end

  end # === module DA_JSON
end # === module Mu_Clean

