require 'csv'
require 'caxlsx'

class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # smiple download
  # def export
  #   @products = Product.all

  #   respond_to do |format|
  #     format.csv { send_data generate_csv(@products), filename: "products-#{Date.today}.csv" }
  #     format.xlsx { send_data generate_xlsx(@products), filename: "products-#{Date.today}.xlsx" }
  #   end
  # end

  # one page with background job download
  # def export
  #   file_number = Time.now.to_i
  #   job_id = ExportProductJob.perform_async(file_number)
  #   render json: { 
  #     jid: job_id,
  #     file_number: file_number
  #   }
  # end
  
  # another page with background job download
  def export
    file_number = Time.now.to_i
    job_id = ExportProductJob.perform_async(file_number)
    redirect_to export_result_products_path(job_id: job_id, file_number: file_number)
  end

  # for another page download
  def export_result
    @job_id = params[:job_id]
    @file_number = params[:file_number]    
    @job_status = Sidekiq::Status.get_all(@job_id).symbolize_keys
  end

  # for background job download
  def export_status
    job_id = params[:job_id]
    # Check job status and percentage using JobId
    job_status = Sidekiq::Status.get_all(job_id).symbolize_keys

    render json: {
      status: job_status[:status],
      percentage: job_status[:pct_complete]
    }
  end

  # for background job download
  def export_download
    job_id = params[:id]
    file_number = params[:file_number]
    exported_file_name = "products_export_#{file_number}.xlsx"
    filename = "Products_#{DateTime.now.strftime("%Y%m%d_%H%M%S")}.xlsx"

    # Start excel download
    send_file Rails.root.join("tmp", exported_file_name), type: :xlsx, filename: filename
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :description, :price)
    end

    def generate_csv(products)
      CSV.generate(headers: true) do |csv|
        csv << ["ID", "Name", "Description", "Price"]
  
        products.each do |product|
          csv << [product.id, product.name, product.description, product.price ]
        end
      end
    end
  
    def generate_xlsx(products)
      p = Axlsx::Package.new
      wb = p.workbook
      wb.add_worksheet(name: "Products") do |sheet|
        sheet.add_row ["ID", "Name", "Description", "Price"]
  
        products.each do |product|
          sheet.add_row [product.id, product.name, product.description, product.price ]
        end
      end
      p.to_stream.read
    end
end
