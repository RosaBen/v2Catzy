class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def show
    @item = Item.find_by(id: params[:id])
  end

private
  def item_params
    params.require(:item).permit(:title, :description, :price, :image_url)
  end
end
