---
id: qa-testing-mcp-chrome
title: "QA Testing avec MCP Chrome DevTools"
created: "2026-02-20"
last_verified: "2026-02-20"
references:
  conventions: []
  adrs: []
  features: []
watched_paths:
  - packages/kai-ui/.mcp.json
  - packages/kai-ui/package.json
  - packages/kai-ui/src/app/**/*.tsx
topics: [qa, testing, mcp, chrome-devtools, manual-testing, e2e]
---

## Overview

Guide pour tester manuellement l'application kai-ui en utilisant le serveur MCP Chrome DevTools. Ce workflow permet à Claude Code d'interagir directement avec le navigateur Chrome pour naviguer, inspecter, cliquer et valider le comportement de l'app — sans framework de test e2e dédié.

## Prérequis

- Node.js >= 18
- Google Chrome installé
- Le MCP `chrome-devtools` configuré dans `.mcp.json` (déjà en place)
- Chrome lancé avec le flag remote debugging :
  ```bash
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
  ```

## Steps

### 1. Lancer le serveur de dev

```bash
npm run dev
```

L'app est disponible sur `http://localhost:3000`.

### 2. Ouvrir l'app dans Chrome (remote debugging)

Naviguer vers `http://localhost:3000` dans le Chrome lancé avec `--remote-debugging-port=9222`.

Ou utiliser l'outil MCP :

```
mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
```

### 3. Prendre un snapshot de la page

Utiliser `take_snapshot` pour obtenir l'arbre d'accessibilité avec les `uid` de chaque élément :

```
mcp__chrome-devtools__take_snapshot
```

Cela retourne une liste structurée de tous les éléments interactifs avec leurs identifiants.

### 4. Interagir avec l'app

Avec les `uid` du snapshot, on peut :

- **Cliquer** : `mcp__chrome-devtools__click → uid: "<uid>"`
- **Remplir un champ** : `mcp__chrome-devtools__fill → uid: "<uid>", value: "..."`
- **Saisir une touche** : `mcp__chrome-devtools__press_key → key: "Enter"`
- **Hover** : `mcp__chrome-devtools__hover → uid: "<uid>"`
- **Screenshot** : `mcp__chrome-devtools__take_screenshot`

### 5. Vérifier les résultats

- Prendre un nouveau snapshot après chaque action pour valider les changements dans le DOM
- Vérifier la console pour les erreurs : `mcp__chrome-devtools__list_console_messages`
- Vérifier les requêtes réseau : `mcp__chrome-devtools__list_network_requests`

### 6. Tester les performances (optionnel)

```
mcp__chrome-devtools__performance_start_trace → reload: true, autoStop: true
```

Cela produit un rapport avec les Core Web Vitals et les insights de performance.

## Workflow type : session QA complète

1. `npm run dev` dans un terminal
2. Chrome avec remote debugging ouvert
3. Demander à Claude : "teste la page d'accueil" ou "vérifie que le bouton X fonctionne"
4. Claude utilise les outils MCP pour naviguer, interagir, capturer des screenshots et rapporter les résultats

## Notes

- Toujours prendre un **snapshot** (pas un screenshot) avant d'interagir — les snapshots fournissent les `uid` nécessaires
- Les screenshots sont utiles pour la validation visuelle mais ne contiennent pas les `uid`
- Si Chrome n'est pas lancé avec `--remote-debugging-port=9222`, le MCP ne pourra pas se connecter
- Le MCP Chrome est configuré dans `.mcp.json` à la racine du package `kai-ui`
