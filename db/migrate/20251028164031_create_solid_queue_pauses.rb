class CreateSolidQueuePauses < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false
      t.datetime :created_at, null: false

      t.index :queue_name, unique: true
    end
  end
end
