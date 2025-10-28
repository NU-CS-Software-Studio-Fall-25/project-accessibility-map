class CreateSolidQueueProcesses < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_processes do |t|
      t.string :kind, null: false
      t.datetime :last_heartbeat_at, null: false
      t.bigint :supervisor_id
      t.integer :pid, null: false
      t.string :hostname
      t.text :metadata
      t.datetime :created_at, null: false
      t.string :name, null: false

      t.index :last_heartbeat_at
      t.index [:name, :supervisor_id], unique: true
      t.index :supervisor_id
    end
  end
end
