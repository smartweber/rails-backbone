class CompanyNewsItemWorker < NewsItemWorker
  def self.find_by_id(id)
    CompanyNewsItem.find(id)
  end
end
