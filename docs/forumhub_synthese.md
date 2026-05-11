# ForumHub — Synthèse de projet

**Projet :** entraînement formation — application forum  
**Stack :** Supabase (PostgreSQL + Auth) · RLS · Postman

---

## Modèle de données

Trois entités, schéma ERD validé :

- **auth.users** — géré par Supabase Auth (`id`, `email`, `encrypted_password`, `created_at`)
- **Topic** — sujet de forum (`id`, `title`, `content`, `created_at`, `is_published`, `deleted_at`, `author_id FK`)
- **Comment** — commentaire lié à un topic (`id`, `content`, `created_at`, `deleted_at`, `author_id FK`, `topic_id FK`)

Relations : un utilisateur écrit plusieurs topics et plusieurs commentaires ; un topic reçoit plusieurs commentaires.

---

## Sécurité — RLS & Policies

Row Level Security activé sur `Topic` et `Comment`. Policies implémentées et validées via Postman pour deux utilisateurs de test (Sophie et Bob) :

| Table   | Policy | Comportement                                                                  |
| ------- | ------ | ----------------------------------------------------------------------------- |
| Topic   | SELECT | Visible si `is_published = true` et non supprimé, ou si l'auteur est connecté |
| Topic   | INSERT | `author_id` automatiquement renseigné via trigger                             |
| Topic   | UPDATE | Seul l'auteur peut modifier (couvre le soft delete)                           |
| Topic   | DELETE | Seul l'auteur peut supprimer                                                  |
| Comment | SELECT | Visible si topic parent publié et non supprimé, ou si l'auteur est connecté   |
| Comment | INSERT | `author_id` automatiquement renseigné via trigger                             |
| Comment | UPDATE | Seul l'auteur peut modifier (couvre le soft delete)                           |
| Comment | DELETE | Seul l'auteur peut supprimer                                                  |

---

## Soft Delete

Suppression logique implémentée sur `Topic` et `Comment` via une colonne `deleted_at` (`timestamptz`, `NULL` par défaut) :

- Un enregistrement est considéré supprimé si `deleted_at IS NOT NULL`
- Le soft delete se déclenche via un `PATCH` avec `deleted_at = now()`
- L'auteur voit ses propres enregistrements supprimés ; les autres utilisateurs ne les voient pas
- Les commentaires d'un topic supprimé logiquement sont invisibles pour les non-auteurs

---

## Triggers & Fonctions

Deux fonctions `SECURITY DEFINER` et leurs triggers associés, déclenchés `BEFORE INSERT` :

| Trigger                      | Table     | Fonction               | Rôle                                  |
| ---------------------------- | --------- | ---------------------- | ------------------------------------- |
| `trigger_set_topic_author`   | `Topic`   | `set_topic_author()`   | Injecte `auth.uid()` dans `author_id` |
| `trigger_set_comment_author` | `Comment` | `set_comment_author()` | Injecte `auth.uid()` dans `author_id` |

---

## Authentification

- Méthode : email + mot de passe (`POST /auth/v1/signup`)
- Confirmation email activée (limite Free tier : **3 emails/heure**)
- Domaines réservés RFC (`example.com`, `test.com`) rejetés par Supabase
- Tous les cas d'usage testés et validés via Postman

---

## Structure du dépôt GitHub

```
forumhub/
├── migrations/
│   ├── 01_create_tables.sql
│   ├── 02_rls_policies.sql
│   ├── 03_triggers_functions.sql
│   └── 04_soft_delete.sql
├── docs/
│   └── forumhub_synthese.md
└── README.md
```

---

## Prochaine étape

Intégration frontend : appels au backend Supabase depuis une interface **HTML/CSS/JS vanilla**.

---

_Prompt de reprise :_ Récapitulatif de session — ForumHub / Supabase + Postman. Tables `Topic` et `Comment`, RLS activé, policies CRUD validées, signup et authentification fonctionnels. Triggers `set_topic_author` et `set_comment_author` en place. Fichiers SQL exportés et structurés dans le dépôt GitHub. On attaque l'intégration dans un **frontend simple** : appels au backend Supabase depuis une interface HTML/CSS/JS vanilla.
