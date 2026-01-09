# ESX Garage V2 - Script de Garage Simple avec ox_lib

## 🚗 Description

Script de garage **ultra-simple et performant** pour ESX avec interface **ox_lib**. Plus besoin de téléportation ou d'IPL, tout se fait directement avec un menu moderne !

Support complet pour:
- 🚗 **Voitures** (+ de 30 garages)
- 🚤 **Bateaux** (4 marinas)
- ✈️ **Avions/Hélicoptères** (2 hangars)

## ✨ Fonctionnalités

- **Menu ox_lib moderne** - Interface propre et intuitive avec la souris
- **Aucune téléportation** - Tu restes à ta position
- **Instantané** - Aucune animation, tout est rapide
- **Texte 3D simple** - Affichage clair du nom du garage
- **Support fourrière** - Système d'impound intégré
- **40+ emplacements** - Garages partout sur la map

## 📦 Installation

### 1. Prérequis

- **ESX Legacy** (dernière version)
- **oxmysql**
- **ox_lib** ⚠️ **OBLIGATOIRE**

### 2. Installation

1. Télécharge/clone le script dans `resources/esx_garage`
2. Importe le fichier SQL : `esx_garage.sql`
3. Ajoute à ton `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure esx_garage
   ```
4. Redémarre ton serveur

### 3. Base de données

Le script utilise la table `owned_vehicles` d'ESX. Assure-toi d'avoir ces colonnes :
- `owner` - Identifiant du propriétaire
- `plate` - Plaque du véhicule
- `vehicle` - Props en JSON
- `type` - Type : `'car'`, `'vehicle'`, `'boat'`, `'aircraft'`, `NULL` ou vide
- `stored` - `1` = rangé, `0` = sorti

## 🎮 Utilisation

### Sortir un véhicule

1. Approche-toi d'un garage (à pied)
2. **Texte 3D** s'affiche avec le nom du garage
3. Appuie sur **E**
4. **Menu ox_lib** s'ouvre avec tes véhicules
5. **Clique** sur le véhicule que tu veux
6. Le véhicule spawn **instantanément** et tu es dedans !

### Ranger un véhicule

1. **Monte dans ton véhicule**
2. Approche-toi d'un garage compatible
3. Appuie sur **E**
4. Le véhicule est rangé **instantanément**

## 📍 Emplacements des garages

### 🚗 Voitures (30+ garages)

**Centre-ville:**
- Legion Square
- Pillbox Hill
- Little Seoul
- Centro
- Motel
- Spanish Ave

**Plages:**
- San Andreas Beach
- Airport Los Santos
- Elysian

**Campagne:**
- Sandy Shores
- Paleto Bay
- Alamo Sea
- Grapeseed (x2)
- The Motor Hotel
- Gran Señora Desert

**Et bien plus !**

### 🚤 Bateaux (4 marinas)

- La Puerta Pier
- Paleto Cove Pier
- Paleto Bay Pier
- Pacific Small Pier

### ✈️ Avions (2 hangars)

- Airport Hangar
- Trevor Hangar

### 🚧 Fourrières (3)

- Hayes Autos (voitures)
- Airport Impound Hangar (avions)
- Boat Impound Pier (bateaux)

## ⚙️ Configuration

Édit `config.lua` pour personnaliser :

### Ajouter un nouveau garage

```lua
['Mon Garage'] = {
    type = 'vehicle', -- 'vehicle', 'boat' ou 'plane'
    coords = vec3(x, y, z), -- Position du point d'interaction
    spawnPoint = vec4(x, y, z, heading), -- Point de spawn du véhicule
    duiText = 'GARAGE\nMON NOM', -- Texte affiché (2 lignes max)
    isImpound = false -- true si c'est une fourrière
},
```

### Distances d'interaction

```lua
Config.DrawDistance = 10.0 -- Distance d'affichage du texte
Config.MarkerDistance = 2.5 -- Distance pour appuyer sur E
```

## 🏢 Garages Job / Entreprise

### Comment ça marche ?

Le script inclut un système de **garages d'entreprise** pour les jobs (police, ambulance, mécano, taxi).

**Règles :**
- ✅ **Sortir un véhicule** = Seuls les membres du job peuvent sortir
- ✅ **Ranger un véhicule** = N'importe qui peut ranger
- 🔄 **Transfert automatique** : Si tu ranges TON véhicule perso dans un garage job, il devient un véhicule d'entreprise !

**Avantages :**
- Les véhicules d'entreprise ont des plaques uniques (ex: `POLICE123`)
- Tous les membres du job peuvent les utiliser
- Possibilité de les customiser (peinture, upgrades, etc.)
- Les modifs sont sauvegardées

### Garages job inclus

- **Police** - Mission Row (452.6, -1017.4, 28.4)
- **Ambulance** - Pillbox Hill (307.0, -1433.0, 29.8)
- **Mécano** - Burton (-347.0, -133.0, 39.0)
- **Taxi** - Downtown (903.3, -191.7, 73.9)

## 🔧 Commandes

### Commandes admin

```bash
/addsocietycar [modèle] [job] - Ajoute un véhicule d'entreprise
```

Exemples :
```
/addsocietycar police police
/addsocietycar ambulance ambulance
/addsocietycar flatbed mechanic
/addsocietycar taxi taxi
```

### Commandes de développement

Active `Config.Debug = true` dans `config.lua` :

```
/checkvehicles - Liste tous tes véhicules dans la BDD
/addtestcar [modèle] - Ajoute une voiture de test
/addtestboat [modèle] - Ajoute un bateau de test
/addtestplane [modèle] - Ajoute un avion de test
```

Exemples :
```
/addtestcar adder
/addtestboat seashark
/addtestplane luxor
```

## 🎨 Personnalisation du menu ox_lib

Le menu ox_lib est entièrement personnalisable. Modifie dans `client/main.lua` :

```lua
lib.registerContext({
    id = 'garage_menu',
    title = garageName, -- Titre du menu
    options = options -- Options des véhicules
})
```

Chaque option de véhicule affiche :
- **Titre** : Nom du véhicule
- **Description** : Plaque d'immatriculation
- **Icône** : 🚗 (modifiable)

## 🐛 Dépannage

### Le menu ne s'ouvre pas
- Vérifie que **ox_lib** est bien installé et démarré
- Regarde la console F8 pour les erreurs
- Redémarre le script : `/restart esx_garage`

### Aucun véhicule dans le garage
- Tape `/checkvehicles` pour voir tes véhicules dans la BDD
- Vérifie que `stored = 1` pour les véhicules rangés
- Vérifie que le `type` correspond au garage

### Le véhicule ne spawn pas
- Vérifie les coordonnées du `spawnPoint` dans config.lua
- Assure-toi qu'il n'y a pas déjà un véhicule à cet endroit

## 📝 Différences avec la V1

| Fonctionnalité | V1 | V2 |
|----------------|----|----|
| Menu | DUI complexe avec flèches | ox_lib avec souris |
| Téléportation | Oui (vers IPL) | Non (restes sur place) |
| Animations | Fade in/out, particules | Aucune |
| Performance | Moyenne (chargement IPL) | Excellente |
| Facilité d'utilisation | Moyenne | Très facile |
| Nombre de garages | 13 | 40+ |

## 📄 Licence

Script libre d'utilisation et de modification.

## 🚀 Améliorations futures possibles

- Système de parking payant
- Partage de véhicules entre joueurs
- Restrictions de garages par job
- Intégration avec un système de clés
- Garages privés/propriétés

---

**Version 2.0.0** - Système simplifié avec ox_lib
**Bon jeu! 🎮**
