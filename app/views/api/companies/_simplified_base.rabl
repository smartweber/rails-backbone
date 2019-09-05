attributes :id, :name, :abbr, :exchange

node :followers_count do |c|
  c.followers_count
end

child @relationship => :relationship do |r|
  extends('api/relationships/_base')
end
