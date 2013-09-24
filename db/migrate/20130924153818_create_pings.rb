class CreatePings < ActiveRecord::Migration
  def change
    create_table :pings do |t|
      t.time :datetime

      t.timestamps
    end
  end
end
