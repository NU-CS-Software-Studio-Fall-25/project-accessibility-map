# frozen_string_literal: true

class UpdateSolidQueueJobsTable < ActiveRecord::Migration[7.0]
  def change
    # Rename 'queue' to 'queue_name' if not already done
    if column_exists?(:solid_queue_jobs, :queue)
      rename_column(:solid_queue_jobs, :queue, :queue_name)
    end

    # Add ActiveJob ID
    unless column_exists?(:solid_queue_jobs, :active_job_id)
      add_column(:solid_queue_jobs, :active_job_id, :string)
    end

    # Optional: add priority
    unless column_exists?(:solid_queue_jobs, :priority)
      add_column(:solid_queue_jobs, :priority, :integer)
    end

    # Make sure indexes exist
    add_index(:solid_queue_jobs, :queue_name) unless index_exists?(:solid_queue_jobs, :queue_name)
    add_index(:solid_queue_jobs, :run_at) unless index_exists?(:solid_queue_jobs, :run_at)
  end
end
