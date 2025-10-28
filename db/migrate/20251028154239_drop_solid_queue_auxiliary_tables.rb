class DropSolidQueueAuxiliaryTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :solid_queue_auxiliary_tables, if_exists: true
  end
end
