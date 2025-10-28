class CreateSolidQueueReadyExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_ready_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, null: false, default: 0
      t.datetime :created_at, null: false

      t.index :job_id, unique: true
      t.index [:priority, :job_id], name: "index_solid_queue_poll_all"
      t.index [:queue_name, :priority, :job_id], name: "index_solid_queue_poll_by_queue"
    end

    add_foreign_key :solid_queue_ready_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end

