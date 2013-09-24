class CreatePings < ActiveRecord::Migration
  def change
    create_table :pings do |t|
      t.datetime :time

      t.timestamps
    end
  end
end
