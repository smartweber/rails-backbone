child locals[:notifications] => :notifications do |k|
  attribute :type
  child :arr do
    extends('api/users/notifications/_notifications')
  end
end
