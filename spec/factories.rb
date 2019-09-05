FactoryGirl.define do

  factory :breaking_news do
    title { Faker::Lorem.sentence }
    trending_until { Time.now.advance(hours: 3) }
  end

  factory :tag do
    word { Faker::Lorem.word }
    trending_until nil
    mute_until nil
    position nil
    taggings_count 0

    factory :hashtag, class: Tag do
      tag_type Tag::TYPES[:hashtags]
    end
  end

  factory :tagging do
  end

  factory :news_subject do
  end

  factory :admin_user do
  end

  factory :news_item do
    url { Faker::Internet.url }
    title { Faker::Lorem.sentence }
    published_at { Time.now.advance(days: -1) }
    position nil

    trait :with_image do
      news_thumbnail { File.open(Rails.root.join('spec/fixtures/image.png')) }
    end

    factory :general_news_item, class: GeneralNewsItem, traits: [:uncategorized] do
      agency { APP_CONFIG[:feed_sources].keys.sample }
      summary { Faker::Lorem.paragraph }
      trending_until nil

      trait :categorized do
        news_subject
      end

      trait :uncategorized do
        news_subject nil
      end

      trait :positioned do

        after(:create) do |news_item|
          last = GeneralNewsItem.where.not(position: nil).order('position ASC').last
          news_item.insert_at(last.try(:position).try(:+, 1) || 1)
        end
      end

      after(:build){ |news_item| news_item.set_keywords! if news_item.stemmed_keywords.empty? and news_item.not_stemmed_keywords.empty? }

      factory :positioned_general_news_item, traits: [:uncategorized, :positioned]
      factory :categorized_general_news_item, traits: [:categorized]
      factory :uncategorized_general_news_item, traits: [:uncategorized]
      factory :uncategorized_general_news_item_with_image, traits: [:uncategorized, :with_image]
    end

    factory :company_news_item, class: CompanyNewsItem do
      company
    end
  end

  factory :mention do
    user
    association :mentionable, factory: :post
  end

  factory :article do
    title { Faker::Lorem.words(4).join(' ') }
    body { Faker::Lorem.paragraph }
    position nil
    trending_until nil
    posts_count 0
  end

  factory :participant do
    user
    chat
    last_seen_message_id nil

    after(:create) do |participant|
      create(:message, participant: participant, chat: participant.chat) if participant.messages.empty?
    end
  end

  factory :chat do
    created_at DateTime.now

    transient do
      participants_count 2
    end

    after(:create) do |chat, evaluator|
      (evaluator.participants_count - chat.participants.size).times do
        chat.participants << create(:participant, chat: chat)
      end
    end
  end

  factory :message do
    body { Faker::Lorem.words(4).join(' ') }
    participant
    chat
  end

  # TODO: rename to attachment
  factory :user_attachment, class: UserAttachment do
    user
    association :attachable, factory: :message

    factory :link_attachment do
      type_of_attachment 'link'
      title { Faker::Lorem.sentence }
      description { Faker::Lorem.sentence }

      initialize_with { a = new(attributes); a.instance_variable_set(:@link, 'http://example.org/page'); a }
    end

    factory :image_attachment do
      type_of_attachment 'image'
      image { File.open(Rails.root.join('spec/fixtures/image.png')) }

      initialize_with { a = new(attributes); a.instance_variable_set(:@link, 'http://example.org/image.png'); a }
    end
  end

  factory :market_headline do
    title { Faker::Lorem.sentence }
    position nil
    trending_until nil
  end

  factory :company do
    name { Faker::Company.name }
    abbr { ('a'..'z').to_a.shuffle[0,4].join }
    exchange "NYSE"
    market_cap { 50000000 + rand(10000) }

    trait :not_trending do
      trending_until nil
      position nil
    end

    trait :trending do
      trending_until 2.hours.since
      position 1
    end

    factory :not_trending_company, traits: [:not_trending]
    factory :trending_company, traits: [:trending]
  end

  factory :friendship do
    user
    association :friend, factory: :user
  end

  factory :like do
    user
    association :likeable, factory: :comment
  end

  factory :relationship do
    association :follower, factory: :user
    association :followable, factory: :user
  end

  factory :notification do
    seen false
    user

    factory :message_notification do
      association :notifiable, factory: :message
      notification_type 'new_message'
    end

    factory :follower_notification do
      association :notifiable, factory: :user
      notification_type 'new_follower'
    end

    factory :like_notification do
      association :notifiable, factory: :like
      notification_type 'post_liked'
    end

    factory :comment_notification do
      association :notifiable, factory: :user
      notification_type 'new_comment'
    end
  end

  factory :user do
    name  { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    username { name.gsub(/\W/, '').downcase.first(15) }
    email { Faker::Internet.email }
    password "password"
    password_confirmation "password"
    confirmed_at { DateTime.now }
    tos_and_pp_accepted true
  end

  factory :post do
    content { Faker::Lorem.sentence }
    user
    friends_only false
    article nil
  end

  factory :comment do
    body { Faker::Lorem.sentence }
    created_at { DateTime.now }
    updated_at { DateTime.now }
    user
    association :commentable, factory: :post
  end
end
