class CreateSolidQueueClaimedExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_claimed_executions do |t|
      t.bigint :job_id, null: false
      t.bigint :process_id
      t.datetime :created_at, null: false

      t.index :job_id, unique: true
      t.index [:process_id, :job_id], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
    end

    add_foreign_key :solid_queue_claimed_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end
