class CreateNewsSubjects < ActiveRecord::Migration
  def change
    create_table :news_subjects do |t|

      t.timestamps null: false
    end
  end
end
