<!--
================================================================================
  README.md — 13345_Cursors
  Auteur : Pascal Delfosse
  Description : Collection de curseurs Windows (.ani et .cur) rangés en tiroirs
                de 250 fichiers chacun.
  Encodage : UTF-8
================================================================================
-->

# 13345_Cursors

> Collection de **13 345 curseurs Windows** (animés et statiques)
> rangés automatiquement en tiroirs de 250 fichiers par dossier.

---

## Sommaire

- [À propos](#-à-propos)
- [Contenu du dépôt](#-contenu-du-dépôt)
- [Structure des dossiers](#-structure-des-dossiers)
- [Format des fichiers](#-format-des-fichiers)
- [Script de rangement automatique](#-script-de-rangement-automatique)
- [Installation d'un curseur sous Windows](#-installation-dun-curseur-sous-windows)
- [Convention de nommage](#-convention-de-nommage)
- [Exclusions Git](#-exclusions-git)
- [Licence et usage](#-licence-et-usage)

---

## À propos

Ce dépôt regroupe une **bibliothèque exhaustive de curseurs Windows** :

- **11 948 curseurs animés** au format `.ani`
- **1 397 curseurs statiques** au format `.cur`
- **1 script batch** d'organisation automatique (`.bat`)

Total : **~13 346 fichiers** pour un poids d'environ **145 Mo**.

Les fichiers sont rangés dans **54 tiroirs** numérotés (`000` à `053`),
chacun contenant un maximum de **250 curseurs**, pour faciliter la navigation
et éviter les dossiers surchargés sous l'Explorateur Windows.

---

## Contenu du dépôt

```
13345_Cursors/
├── README.md                  <- Ce fichier
├── .gitignore                 <- Exclusions Git (médias, archives, etc.)
├── 000/                       <- Tiroir 0   (~250 curseurs)
├── 001/                       <- Tiroir 1   (~250 curseurs)
├── 002/                       <- Tiroir 2   (~250 curseurs)
│   ...
├── 040/
│   └── rangement -par 250 UNIVERSELLE .bat   <- Script de classement
│   ...
└── 053/                       <- Tiroir 53  (curseurs restants)
```

> **Note :** Le dépôt respecte une **profondeur maximale d'un niveau** de
> sous-dossiers. Aucun sous-sous-dossier n'est versionné.

---

## Structure des dossiers

| Dossier         | Contenu                              | Nombre approx. |
| --------------- | ------------------------------------ | -------------- |
| `000/` → `052/` | Tiroirs pleins (250 curseurs chacun) | 250 fichiers   |
| `053/`          | Tiroir final (curseurs résiduels)    | ~95 fichiers   |
| Racine          | `README.md`, `.gitignore`            | 2 fichiers     |

---

## Format des fichiers

### `.ani` — Curseur animé Windows

Format propriétaire Microsoft basé sur RIFF.
Contient une séquence d'images affichées en boucle (effet d'animation).

### `.cur` — Curseur statique Windows

Format dérivé de `.ico` (icône Windows).
Image unique servant de pointeur de souris fixe.

Les deux formats sont reconnus nativement par Windows
(`Panneau de configuration → Souris → Pointeurs`).

---

## Script de rangement automatique

Le fichier [`040/rangement -par 250 UNIVERSELLE .bat`](040/) est un script
**Batch Windows** qui classe automatiquement n'importe quel ensemble de
fichiers en tiroirs numérotés (`000`, `001`, `002`, …) de **250 fichiers**
chacun.

### Usage

1. Copier le `.bat` dans le dossier à organiser.
2. Double-cliquer pour l'exécuter.
3. Les fichiers sont déplacés dans des dossiers `000/`, `001/`, etc.

### Paramètres modifiables (en tête de script)

```batch
set "NB_PAR_TIROIR=250"   :: nombre de fichiers par dossier
set "MAX_TIROIRS=5000"    :: limite de sécurité
```

> ⚠️ Le script **déplace** les fichiers (move), il ne les copie pas.
> Faire une **sauvegarde** avant exécution si nécessaire.

---

## Installation d'un curseur sous Windows

### Méthode rapide (un seul curseur)

1. Clic droit sur un fichier `.ani` ou `.cur`.
2. Choisir **« Installer »** dans le menu contextuel.
3. Le curseur est ajouté au système.

### Méthode par schéma (curseur complet)

1. Ouvrir **Panneau de configuration → Souris → Pointeurs**.
2. Pour chaque rôle (Sélection normale, Aide, Travail en arrière-plan, …),
   cliquer **Parcourir…** et choisir le curseur souhaité.
3. Cliquer **Enregistrer sous…** pour sauvegarder le schéma personnalisé.

---

## Convention de nommage

Les fichiers conservent leur **nom d'origine** (variable selon la source).
Aucune normalisation n'a été appliquée afin de préserver les noms d'auteurs
et les références d'origine.

Quelques motifs courants observés :

- `precision1.ani`, `precision2.ani`, … → variantes d'un même curseur
- `yellow.ani`, `yellowglitter.ani`, … → famille thématique
- `xharlow.ani`, `yharlow.ani` → variantes typographiques (couleur, taille)

---

## Exclusions Git

Le fichier [`.gitignore`](.gitignore) exclut volontairement du suivi Git :

- **Images** : `.jpg`, `.png`, `.gif`, `.bmp`, `.svg`, `.webp`, …
- **PDF** : `.pdf`
- **Vidéos** : `.mp4`, `.avi`, `.mkv`, `.mov`, …
- **Archives** : `.zip`, `.rar`, `.7z`, `.tar.gz`, …
- **Audio** : `.mp3`, `.wav`, `.flac`, `.ogg`, …
- **Ebooks** : `.epub`, `.mobi`, `.azw`, `.djvu`, …
- **Curseurs** : `.ani`, `.cur`
- **Polices** : `.ttf`, `.otf`, `.woff`, `.woff2`, `.fon`, `.fnt`, …
- **Sous-dossiers profonds** (au-delà du 1er niveau)
- **Fichiers système** : `Thumbs.db`, `Desktop.ini`, `.DS_Store`

> **Note importante :** Les **fichiers curseurs eux-mêmes ne sont pas
> versionnés** dans ce dépôt Git. Seuls la **documentation** (`README.md`),
> les **règles d'exclusion** (`.gitignore`) et le **script d'organisation**
> (`.bat`) sont publiés sur GitHub.
>
> La collection complète des curseurs reste disponible **localement** dans
> les dossiers `000/` à `053/`, mais n'est pas distribuée via le dépôt afin
> de respecter les droits d'auteur d'origine de chaque curseur.

---

## Licence et usage

Les curseurs proviennent de **sources publiques diverses** rassemblées
au fil du temps. Les droits d'auteur appartiennent à leurs créateurs
respectifs.

Ce dépôt est mis à disposition pour un **usage personnel et non commercial**.
Pour toute utilisation commerciale, vérifier la licence d'origine de chaque
curseur auprès de son auteur.

---

<!--
================================================================================
  Fin du README.md
  Pour toute question ou correction : ouvrir une issue sur GitHub.
  https://github.com/Delfosse-Pascal/13345_Cursors
================================================================================
-->
