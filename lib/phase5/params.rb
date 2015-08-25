require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @req = req
      @params = route_params
      parse_www_encoded_form(@req.query_string)
      parse_www_encoded_form(@req.body)
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      return if www_encoded_form.nil?
      hash_values = URI::decode_www_form(www_encoded_form)
      hash_values.each do |pair|
        populate_params(parse_key(pair[0]), pair[1])
      end
    end

    def populate_params(keys, value)
      keys.inject(@params) do |hash, key|
        if key == keys.last
          hash[key] = value
        else
          hash[key] ||= {}
        end
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      keys = key.split(/\]\[|\[|\]/)
    end
  end
end
