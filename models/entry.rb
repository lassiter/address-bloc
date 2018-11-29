require 'bloc_record/base'

class Entry < MiniORM::Base

  def to_s
    "Name: #{name}\nPhone Number: #{phone_number}\nEmail: #{email}"
  end
end
