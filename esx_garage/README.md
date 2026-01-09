# ESX Garage - Script de Garage Avancé

## 🚗 Description

Script de garage avancé pour ESX avec interface DUI (pas de NUI/menu), téléportation stylée vers des IPL de garage et support complet pour:
- 🚗 Voitures
- 🚤 Bateaux
- ✈️ Avions/Hélicoptères

## ✨ Fonctionnalités

- **Interface DUI uniquement** - Pas de menu NUI, tout en texte 3D autour du personnage
- **Téléportation stylée** - Effet de fade out/in lors de l'entrée dans le garage
- **IPL de garage** - Visualisez votre véhicule dans un vrai garage/hangar/marina
- **Navigation intuitive** - Parcourez vos véhicules avec les flèches ← →
- **Effets visuels** - Particules et animations lors du spawn des véhicules
- **Multi-types** - Support complet pour voitures, bateaux et avions
- **Configurable** - Ajoutez facilement vos propres emplacements de garages

## 📦 Installation

### 1. Prérequis

- ESX Legacy (dernière version recommandée)
- oxmysql (ou mysql-async)
- Base de données avec table `owned_vehicles`

### 2. Installation du script

1. Téléchargez ou clonez le script dans votre dossier `resources`
2. Renommez le dossier en `esx_garage`
3. Importez le fichier SQL dans votre base de données:
   ```sql
   -- Exécutez esx_garage.sql dans votre base de données
   ```

4. Ajoutez la ressource à votre `server.cfg`:
   ```cfg
   ensure esx_garage
   ```

### 3. Configuration de la base de données

Assurez-vous que votre table `owned_vehicles` possède les colonnes suivantes:
- `owner` (varchar) - Identifiant du propriétaire
- `plate` (varchar) - Plaque du véhicule
- `vehicle` (longtext) - Propriétés du véhicule en JSON
- `type` (varchar) - Type de véhicule: 'car', 'boat', 'aircraft'
- `stored` (tinyint) - 1 si rangé, 0 si sorti

Si vous n'avez pas ces colonnes, le fichier SQL les créera automatiquement.

## 🎮 Utilisation

### Pour les joueurs

#### Ranger un véhicule
1. Montez dans votre véhicule
2. Approchez-vous d'un garage compatible avec le type de véhicule
3. Appuyez sur **E** pour ranger le véhicule
4. Le véhicule sera rangé avec un effet de téléportation

#### Sortir un véhicule
1. Approchez-vous d'un garage (à pied)
2. Appuyez sur **E** pour ouvrir le garage
3. Vous serez téléporté dans l'IPL de garage
4. Utilisez **←** et **→** pour naviguer entre vos véhicules
5. Appuyez sur **E** pour sortir le véhicule sélectionné
6. Appuyez sur **BACKSPACE** pour quitter sans sortir de véhicule

### Contrôles dans le garage

- **E** - Sortir le véhicule sélectionné
- **←** - Véhicule précédent
- **→** - Véhicule suivant
- **BACKSPACE** - Quitter le garage

## ⚙️ Configuration

Éditez le fichier `config.lua` pour personnaliser le script.

### Ajouter un nouveau garage

```lua
{
    name = 'Nom du Garage',
    type = 'car', -- 'car', 'boat', ou 'plane'
    coords = vector3(x, y, z), -- Coordonnées du garage
    heading = 0.0, -- Direction du joueur
    spawnPoint = vector4(x, y, z, heading), -- Point de spawn du véhicule
    duiText = 'TEXTE\nDUI' -- Texte affiché (utilisez \n pour sauter une ligne)
}
```

### Types de véhicules

- `car` - Voitures, motos, véhicules terrestres
- `boat` - Bateaux, jet-skis
- `plane` - Avions, hélicoptères

### Modifier les IPL de garage

Dans `config.lua`, vous pouvez modifier les coordonnées des IPL:

```lua
Config.GarageIPL = {
    Interior = vector4(x, y, z, heading), -- Position du joueur dans le garage
    SpawnPoint = vector4(x, y, z, heading), -- Position du véhicule
    ExitPoint = vector4(x, y, z, heading) -- Point de sortie (optionnel)
}
```

## 🔧 Commandes de développement

Pour faciliter les tests, des commandes sont disponibles (activez `Config.Debug = true`):

```
/addtestcar [modèle] - Ajoute une voiture de test
/addtestboat [modèle] - Ajoute un bateau de test
/addtestplane [modèle] - Ajoute un avion de test
```

Exemples:
```
/addtestcar adder
/addtestboat seashark
/addtestplane luxor
```

## 📍 Emplacements des garages par défaut

### Voitures
- Garage Centre-Ville (Legion Square)
- Garage Vespucci
- Garage Sandy Shores
- Garage Paleto Bay

### Bateaux
- Marina Vespucci
- Marina Paleto Bay
- Marina Sandy Shores

### Avions
- Hangar LSIA
- Aérodrome Sandy Shores
- Héliport Hôpital

## 🎨 Personnalisation du DUI

Pour modifier l'apparence du texte DUI, éditez le HTML dans `client/main.lua`:

```javascript
-- Recherchez la fonction CreateHeadDUI
-- Modifiez les styles CSS pour changer les couleurs, tailles, animations
```

Styles personnalisables:
- Couleur du texte (`color`)
- Ombre du texte (`text-shadow`)
- Taille de la police (`font-size`)
- Animation (`animation`)

## 🐛 Dépannage

### Les véhicules ne s'affichent pas
- Vérifiez que la colonne `type` dans `owned_vehicles` correspond bien ('car', 'boat', 'aircraft')
- Vérifiez que `stored = 1` pour les véhicules rangés

### Erreur SQL
- Assurez-vous d'avoir oxmysql installé et configuré
- Vérifiez que la table `owned_vehicles` existe

### Le DUI ne s'affiche pas
- Les DUI peuvent avoir des problèmes sur certaines configurations
- Essayez de redémarrer le script avec `/restart esx_garage`

### Le joueur ne se téléporte pas
- Vérifiez les coordonnées de l'IPL dans `config.lua`
- Certains IPL nécessitent d'être chargés manuellement

## 📝 Support

Pour toute question ou problème:
1. Vérifiez la console F8 pour les erreurs
2. Vérifiez que toutes les dépendances sont installées
3. Assurez-vous d'avoir la dernière version d'ESX

## 📄 Licence

Ce script est fourni tel quel, libre d'utilisation et de modification.

## 🚀 Améliorations futures possibles

- Système de parking payant
- Partage de véhicules entre joueurs
- Historique des véhicules sortis
- Intégration avec un système de clés
- Support des garages privés/propriétés

---

**Bon jeu! 🎮**
