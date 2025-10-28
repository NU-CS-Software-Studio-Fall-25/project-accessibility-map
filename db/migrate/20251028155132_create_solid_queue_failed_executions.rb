class CreateSolidQueueFailedExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_failed_executions do |t|
      t.bigint :job_id, null: false
      t.text :error
      t.datetime :created_at, null: false

      t.index :job_id, unique: true
    end

    add_foreign_key :solid_queue_failed_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end
