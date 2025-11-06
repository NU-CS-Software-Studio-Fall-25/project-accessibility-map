class ChangeSolidQueueJobsIdToBigint < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TABLE solid_queue_jobs DROP COLUMN id CASCADE;"
    add_column :solid_queue_jobs, :id, :bigint, primary_key: true
  end

  def down
    execute "ALTER TABLE solid_queue_jobs DROP COLUMN id CASCADE;"
    add_column :solid_queue_jobs, :id, :uuid, default: "gen_random_uuid()", null: false, primary_key: true
  end
end
