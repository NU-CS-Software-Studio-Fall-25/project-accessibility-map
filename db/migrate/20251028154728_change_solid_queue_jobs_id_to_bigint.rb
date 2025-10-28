class ChangeSolidQueueJobsIdToBigint < ActiveRecord::Migration[7.0]
  def up
    # Remove primary key constraint temporarily
    remove_column :solid_queue_jobs, :id

    # Add a new bigint id column as primary key
    add_column :solid_queue_jobs, :id, :bigint, primary_key: true
  end

  def down
    remove_column :solid_queue_jobs, :id
    add_column :solid_queue_jobs, :id, :uuid, default: "gen_random_uuid()", null: false, primary_key: true
  end
end
