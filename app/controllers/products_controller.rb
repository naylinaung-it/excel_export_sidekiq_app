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

  # def export
  #   @products = Product.all

  #   respond_to do |format|
  #     format.csv { send_data generate_csv(@products), filename: "products-#{Date.today}.csv" }
  #     format.xlsx { send_data generate_xlsx(@products), filename: "products-#{Date.today}.xlsx" }
  #   end
  # end

  def export
    puts "----------------------export---------------"
    job_id = ExportProductJob.perform_async
    puts "----------------------export---------------"
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
