class ExportProductJob
  include Sidekiq::Job
  include Sidekiq::Status::Worker

  puts "*============================background job"

  def perform(*args)
    puts "***************************product export"
    products = Product.all
    total products.size
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
    
    # Save file into tmp with suffix is jobId
    xlsx_package.serialize Rails.root.join("tmp", "products_21_#{self.jid}.xlsx")
  end
end
