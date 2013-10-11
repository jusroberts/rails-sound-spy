class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.integer :number_of_hits
      t.integer :time
      t.timestamps
    end
  end
end
