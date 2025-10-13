# Projet Covid19 – Simulation d’Infection Humaine

## Objectif du projet
Ce projet a pour but de **simuler la propagation d’un virus** dans un environnement **3D**.
L’utilisateur peut observer le comportement d’un groupe d’humains se déplaçant librement, ainsi que des virus capables d’infecter les humains au contact.  
L’expérience vise à modéliser, de manière simplifiée, la **dynamique de contamination et de mortalité**.

---

## Concept général
Le monde du jeu est un **quartier 3D**, dans lequel on retrouve **trois types d’agents** :

- **Humains sains** — se déplacent aléatoirement dans l’espace.  
- **Virus** — poursuivent les humains proches pour les contaminer.  
- **Cadavres (humains morts)** — remplacent les humains infectés après un certain délai.

---

## Fonctionnement du simulateur
- Les **humains** se déplacent librement avec un comportement semi-aléatoire.  
- Lorsqu’ils entrent en contact avec un **virus**, ils deviennent **Cadavre** (état infecté).  
- Une fois infectés, ils **meurent** et vont etre remplacés par un **cadavre** et au bout de **5 secondes** disparaissent.  
- Les **virus** se déplacent eux aussi dans le quartier et **cherchent activement les humains sains** les plus proches à infecter.  
- Les **cadavres** restent sur place, témoignant de la **progression de l’épidémie**.

