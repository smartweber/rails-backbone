collection @companies, root: false, object_root: false

node(:target_url) do |c|
  company_path(c.abbr)
end

extends('api/companies/_base')
