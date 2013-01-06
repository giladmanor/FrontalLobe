class CreateAggregates < ActiveRecord::Migration
  def change
    create_table :aggregates do |t|
      t.integer :clues
      t.integer :glues
      t.integer :scribbles
      t.integer :users

      t.timestamps
    end
  end
end
