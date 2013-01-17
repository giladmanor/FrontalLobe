class EventAument < ActiveRecord::Migration
  def up
    add_column :events, :user_action, :string
    add_column :events, :content_source, :string
  end

  def down
  end
end
