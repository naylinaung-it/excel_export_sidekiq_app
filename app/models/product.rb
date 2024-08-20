class Product < ApplicationRecord
    validates :name, presence: true
    validates :description, presence: true
    validates :price, presence: true

    def self.test_method
        # Delete xlsx file from tmp
        tmp_folder_path = Rails.root.join('tmp', '*.xlsx')
        # Get all .xlsx files in the tmp folder
        xlsx_files = Dir.glob(tmp_folder_path)

        # Delete each .xlsx file
        xlsx_files.each do |file|
            created_time = file.match(/products_export_(\d+)\.xlsx/)[1]
            time_gap = Time.now - Time.at(created_time.to_i)

            if File.exist?(file) && time_gap.to_i > 86400
                File.delete(file)
            end
        end
    end
end
