require "reversible_cryptography"

def decrypt(encrypted)
  ReversibleCryptography::Message.decrypt(encrypted, ENV["ENCRYPTION_KEY"])
end

def decrypt_attributes(obj)
  case obj
  when Hash
    if obj.keys == ["_encrypted"]
      decrypt(obj["_encrypted"])
    else
      obj.transform_values{|v|
        decrypt_attributes(v)
      }
    end
  when Array
    obj.map{|e| decrypt_attributes(e) }
  else
    obj
  end
end
