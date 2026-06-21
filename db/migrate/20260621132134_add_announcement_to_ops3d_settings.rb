class AddAnnouncementToOps3dSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :ops3d_settings, :announcement_enabled, :boolean, null: false, default: false
    add_column :ops3d_settings, :announcement_text, :string
    add_column :ops3d_settings, :announcement_link_url, :string
    add_column :ops3d_settings, :announcement_link_label, :string
  end
end
