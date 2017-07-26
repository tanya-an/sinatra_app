class CreateUserLevels < ActiveRecord::Migration[5.1]
   def change 
    create_table :user_levels do |t|
      t.integer :user_id
      t.integer :level_id
    end
  end
end
