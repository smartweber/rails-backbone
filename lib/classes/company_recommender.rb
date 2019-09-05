class CompanyRecommender

  def initialize(user)
    @user = user
  end

  def recommendations
    user_companies = @user.following_companies
    companies = Company.includes(:followers)
    companies_by_popularity = companies.sort_by{ |c| c.followers.size }
    maximum_popularity_index = companies_by_popularity.last.followers.size
    companies_by_high_market_cap = companies.sort_by{ |c| c.market_cap }
    maximum_market_cap_index = companies_by_high_market_cap.last.market_cap
    (companies - user_companies).each do |c|
      c.similarity_score = 0.0
      c.similarity_score += 0.5 if user_companies.map(&:sector).include? c.sector
      popularity_score = if maximum_popularity_index != 0
          1 - (maximum_popularity_index - c.followers.size).to_f/maximum_popularity_index.to_f
        else
          0
        end
      c.similarity_score += popularity_score
      market_cap_score = 1 - (maximum_market_cap_index - c.market_cap).to_f/maximum_market_cap_index.to_f
      c.similarity_score += market_cap_score
    end.sort_by{ |c| c.similarity_score }.reverse
  end

end
