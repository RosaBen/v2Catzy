class OrderMailer < ApplicationMailer
  default from: 'catzy957@gmail.com'

  def order_confirmation(order)
    
    @order = order 
    @user = @order.user

    #on définit une variable @url qu'on utilisera dans la view d’e-mail
    # @url  = 'http://monsite.fr/login' 

    # c'est cet appel à mail() qui permet d'envoyer l’e-mail en définissant destinataire et sujet.
    mail(to: @user.email, subject: 'Confirmation de votre commande ##{@order.id}') 
  end

  def order_notification_admin(order)
    @order = order
    @user = @order.user

    
    admin_email = "ebony.breitenberg73@yopmail.com" 

    mail(to: admin_email, subject: "Nouvelle commande passée : ##{@order.id}")
    
  end

end