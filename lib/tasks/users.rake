namespace :users do
  desc "Creates fake users"
  task :populate => :environment do
    females =["Astrid Hats", "Angeline Hayes", "Coty Wehner", "Adelbert Ma", "Otilia Gleichne", "Josefa White", "Kayla Fritsch", "Lilian Quitzon", "Peyton Wess", "Bernadine Brown"]
    males = ["Justyn Lockman", "Brendon Lang", "Jacques Bernhar", "Jasper DuBuque", "Bernhard Lakin", "Damian Schmuth", "Karl Kuvalis", "Sam Larson", "Gilberto Jones", "Guiseppe Lindgron", "Rahsaan Zieme", "Roger Connell", "Roberto Oberbru", "Russ Hintz", "Vadym Chumel", "Jessy Milkman", "Frodo Baggyns", "John Smith"]
    # females
    User.transaction do
      Dir[Rails.root.join("public/temp/f/*")].each do |filepath|
        avatar = File.open(filepath)
        begin
          FactoryGirl.create(:user, avatar: avatar, name: females.pop)
        rescue ActiveRecord::RecordInvalid
          next
        end
      end
      # males
      Dir[Rails.root.join("public/temp/m/*")].each do |filepath|
        avatar = File.open(filepath)
        begin
          FactoryGirl.create(:user, avatar: avatar, name: males.pop)
        rescue ActiveRecord::RecordInvalid
          next
        end
      end
    end
  end
end
