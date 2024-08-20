class ExportProductJob
  include Sidekiq::Job
  include Sidekiq::Status::Worker

  def perform(*args)
    file_number = *args[0]
    products = Product.all
    total products.size
    at 0, "Job started"
    # Create Axlsx package and workbook
    xlsx_package = Axlsx::Package.new
    xlsx_workbook = xlsx_package.workbook
    
    xlsx_workbook.add_worksheet(name: "Products") do |worksheet|
      worksheet.add_row %w(ID Name Description Price)
      
      products.each.with_index(1) do |product, idx|
        worksheet.add_row [ product.id, product.name, product.description, product.price ]
        
        # Caculate percentage 
        at idx
      end
    end

    # # Delete xlsx file from tmp
    #   tmp_folder_path = Rails.root.join('tmp', '*.xlsx')
    #   # Get all .xlsx files in the tmp folder
    #   xlsx_files = Dir.glob(tmp_folder_path)

    #   # Delete each .xlsx file
    #   xlsx_files.each do |file|
    #     if File.exist?(file)
    #       File.delete(file)
    #     end
    #   end
    xlsx_package.serialize Rails.root.join("tmp", "products_export_#{file_number[0]}.xlsx")
    at products.size, "Job completed"
    # Save file into tmp with suffix is jobId
  end
end
