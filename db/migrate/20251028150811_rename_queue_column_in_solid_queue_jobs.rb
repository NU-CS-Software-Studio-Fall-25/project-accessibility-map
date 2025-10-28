class RenameQueueColumnInSolidQueueJobs < ActiveRecord::Migration[7.0]
  def change
    rename_column :solid_queue_jobs, :queue, :queue_name
  end
end
