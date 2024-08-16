require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "create with valid attributes" do
    product = Product.new(name: "product_1", description: "one", price: 2)
    assert product.valid?
  end

  test "create without name field" do
    product = Product.new(name: nil, description: "description", price: 2)
    assert product.invalid?, "saved the product without name"
  end

  test "create without description field" do
    product = Product.new(name: "product", description: nil, price: 2)
    assert product.invalid?, "saved the product without description"
  end

  test "create without price field" do
    product = Product.new(name: "product", description: "description", price: nil)
    assert product.invalid?, "saved the product without price"
  end
end
