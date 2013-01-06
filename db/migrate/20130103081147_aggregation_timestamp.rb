class AggregationTimestamp < ActiveRecord::Migration
  def up
    add_column :aggregates,:timestamp,:datetime 
  end

  def down
    remove_column :aggregates,:timestamp
  end
end
