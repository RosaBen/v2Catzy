class PendingOrderService
  def self.storage_path
    Rails.root.join('tmp', 'pending_orders.json')
  end

  def self.store_pending_order(user_id, order_data)
    pending_orders = load_pending_orders
    
    # Ajouter la nouvelle commande en attente
    pending_order = {
      user_id: user_id,
      timestamp: Time.current.to_i,
      items: order_data[:items],
      total_amount: order_data[:total_amount],
      stripe_success: true
    }
    
    pending_orders << pending_order
    save_pending_orders(pending_orders)
    
    Rails.logger.info "✅ Commande en attente stockée pour utilisateur #{user_id}"
    pending_order
  end

  def self.process_pending_orders_for_user(user)
    pending_orders = load_pending_orders
    user_pending_orders = pending_orders.select { |po| po['user_id'] == user.id }
    
    created_orders = []
    
    user_pending_orders.each do |pending_order|
      begin
        order = create_order_from_pending(user, pending_order)
        if order
          created_orders << order
          Rails.logger.info "✅ Commande #{order.id} créée depuis stockage temporaire"
        end
      rescue => e
        Rails.logger.error "❌ Erreur création commande depuis stockage: #{e.message}"
      end
    end
    
    # Supprimer les commandes traitées
    remaining_orders = pending_orders.reject { |po| po['user_id'] == user.id }
    save_pending_orders(remaining_orders)
    
    created_orders
  end

  private

  def self.load_pending_orders
    if File.exist?(storage_path)
      JSON.parse(File.read(storage_path))
    else
      []
    end
  rescue JSON::ParserError => e
    Rails.logger.error "❌ Erreur lecture pending orders: #{e.message}"
    []
  end

  def self.save_pending_orders(orders)
    # S'assurer que le dossier tmp existe
    FileUtils.mkdir_p(File.dirname(storage_path))
    File.write(storage_path, JSON.pretty_generate(orders))
  rescue => e
    Rails.logger.error "❌ Erreur sauvegarde pending orders: #{e.message}"
  end

  def self.create_order_from_pending(user, pending_order_data)
    # Vérifier si on peut créer des orders avec amount
    can_use_amount = Order.column_names.include?('amount')
    
    order_attributes = {}
    order_attributes[:amount] = pending_order_data['total_amount'] if can_use_amount
    
    order = user.orders.build(order_attributes)
    
    if order.save
      # Créer les order_items
      pending_order_data['items'].each do |item_data|
        item = Item.find_by(id: item_data['id'])
        if item
          order.order_items.create!(
            item: item,
            price: (item_data['price'].to_f * 100).round,
            quantity: item_data['quantity'] || 1
          )
        end
      end
      
      order
    else
      Rails.logger.error "❌ Erreur création order: #{order.errors.full_messages}"
      nil
    end
  end
end
