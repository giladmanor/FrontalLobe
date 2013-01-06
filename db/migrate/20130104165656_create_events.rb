class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :page_name
      t.string :word

      t.timestamps
    end
  end
end
