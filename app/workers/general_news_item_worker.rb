class GeneralNewsItemWorker < NewsItemWorker
  def self.find_by_id(id)
    GeneralNewsItem.find(id)
  end
end
