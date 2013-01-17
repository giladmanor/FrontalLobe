class IpToEvent < ActiveRecord::Migration
  def up
    add_column :events, :ip, :string
    
  end

  def down
  end
end
