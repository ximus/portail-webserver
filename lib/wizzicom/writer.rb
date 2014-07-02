module Wizzicom
  class Writer
    def self.dump(message)
      new.dump(message)
    end

    def dump(message)
      message.assert_valid_keys(:id)
      ret = ""

      body = message[:data] || ""
      body = body.encode(Encoding::BINARY)

      ret << SYNC0
      ret << SYNC1
      ret << body.bytesize # body length
      ret << 0 # no sequence
      ret << message[:id] # no id
      ret << body # body

      ret
    end
  end
end