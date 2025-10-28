class CreateSolidQueueJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :solid_queue_jobs, id: :uuid do |t|
      t.string   :queue
      t.text     :payload
      t.integer  :attempts, default: 0
      t.datetime :run_at
      t.datetime :locked_at
      t.datetime :failed_at
      t.timestamps
    end

    add_index :solid_queue_jobs, :queue
    add_index :solid_queue_jobs, :run_at
  end
end
