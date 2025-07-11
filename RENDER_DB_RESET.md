# 🔧 Guide de Reset DB pour Render

## Problème
Si vous avez des erreurs FK sur Render après suppression de migrations, la DB peut être incohérente.

## Solution 1 : Migration automatique
La migration `ForceRecreateDatabase` va automatiquement corriger la structure lors du prochain déploiement.

## Solution 2 : Reset complet (si Solution 1 ne marche pas)
Si les erreurs persistent, forcez un reset complet :

### Sur Render.com :
1. Allez dans votre service
2. Environment Variables
3. Ajoutez : `FORCE_DB_RESET` = `true`
4. Redéployez

### Après le reset :
1. Supprimez la variable `FORCE_DB_RESET`
2. Les prochains déploiements utiliseront les migrations normales

## Structure finale attendue
```
🔗 CONTRAINTES FK:
  cart_items -> items: CASCADE
  cart_items -> carts: CASCADE  
  order_items -> items: CASCADE
  order_items -> orders: CASCADE
  orders -> users: CASCADE
  carts -> users: SET NULL

📋 order_items colonnes:
  - id, order_id, item_id, price, quantity, created_at, updated_at
```

## Test après déploiement
- ✅ Ajout/suppression panier fonctionne
- ✅ Paiement Stripe fonctionne  
- ✅ Page success fonctionne
- ✅ Plus d'erreur FK
