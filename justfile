# ============================================================
# DevOps - Exercices Justfile
# ============================================================
# Commande par défaut : affiche toutes les recettes disponibles.
default:
    @just --list

# ------------------------------------------------------------
# 1. Hello world
# ------------------------------------------------------------
hello:
    @echo "Hello world"

# ------------------------------------------------------------
# 2 & 3. Workflow Git
# ------------------------------------------------------------

# Initialise un dépôt Git.
#
# Sans argument :
#   just init
#
# Avec un dépôt distant :
#   just init git@github.com:utilisateur/projet.git
#
# Une branche différente peut également être précisée :
#   just init git@github.com:utilisateur/projet.git develop
init remote="" branch="main":
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -d ".git" ]; then
        git init -b "{{branch}}"
        echo "Dépôt Git initialisé sur la branche {{branch}}."
    else
        echo "Le dépôt Git est déjà initialisé."
    fi

    if [ -n "{{remote}}" ]; then
        if git remote get-url origin >/dev/null 2>&1; then
            git remote set-url origin "{{remote}}"
        else
            git remote add origin "{{remote}}"
        fi

        echo "Remote origin configuré : {{remote}}"
        git fetch origin

        # Si la branche distante existe, on synchronise le poste local.
        if git show-ref --verify --quiet "refs/remotes/origin/{{branch}}"; then
            if git rev-parse --verify HEAD >/dev/null 2>&1; then
                git pull --rebase origin "{{branch}}"
            else
                git checkout -B "{{branch}}" "origin/{{branch}}"
            fi
        fi
    fi

# Affiche l'état du dépôt.
status:
    git status

# Ajoute toutes les modifications à l'index Git.
add:
    git add .

# Crée un commit.
# Exemple : just commit "Ajout de la fonctionnalité"
commit message:
    git commit -m "{{message}}"

# Affiche un historique lisible des commits.
log:
    git log --oneline --graph --decorate --all

# Synchronise la branche locale avec origin.
# Nécessite qu'un remote "origin" soit configuré.
sync branch="main":
    #!/usr/bin/env bash
    set -euo pipefail

    if ! git remote get-url origin >/dev/null 2>&1; then
        echo "Erreur : aucun remote 'origin' n'est configuré." >&2
        exit 1
    fi

    git pull --rebase origin "{{branch}}"
    git push -u origin "{{branch}}"

# ------------------------------------------------------------
# 4. Nettoyage
# ------------------------------------------------------------

# Supprime tmp.txt sans provoquer d'erreur s'il n'existe pas.
clean:
    rm -f tmp.txt

# ------------------------------------------------------------
# 5. Base SQL locale - PostgreSQL
# ------------------------------------------------------------
# Le sujet ne précise pas le SGBD : cette partie utilise PostgreSQL.
# Les valeurs peuvent être remplacées avec des variables d'environnement :
#
#   DB_HOST=localhost
#   DB_PORT=5432
#   DB_USER=postgres
#   DB_NAME=justfile_exercice
#
# Exemple :
#   DB_USER=mon_user DB_NAME=ma_base just db-create

db_host := env_var_or_default("DB_HOST", "localhost")
db_port := env_var_or_default("DB_PORT", "5432")
db_user := env_var_or_default("DB_USER", "postgres")
db_name := env_var_or_default("DB_NAME", "justfile_exercice")

# Crée la base si elle n'existe pas déjà.
db-create:
    #!/usr/bin/env bash
    set -euo pipefail

    if psql \
        -h "{{db_host}}" \
        -p "{{db_port}}" \
        -U "{{db_user}}" \
        -d postgres \
        -tAc "SELECT 1 FROM pg_database WHERE datname='{{db_name}}'" \
        | grep -q 1; then
        echo "La base {{db_name}} existe déjà."
    else
        createdb \
            -h "{{db_host}}" \
            -p "{{db_port}}" \
            -U "{{db_user}}" \
            "{{db_name}}"
        echo "Base {{db_name}} créée."
    fi

# Crée une table d'exemple représentant une entité.
db-schema: db-create
    psql -h "{{db_host}}" -p "{{db_port}}" -U "{{db_user}}" -d "{{db_name}}" -v ON_ERROR_STOP=1 -c "CREATE TABLE IF NOT EXISTS entities (id BIGSERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL UNIQUE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"

# Insère une entité d'exemple.
db-insert: db-schema
    psql -h "{{db_host}}" -p "{{db_port}}" -U "{{db_user}}" -d "{{db_name}}" -v ON_ERROR_STOP=1 -c "INSERT INTO entities (name) VALUES ('Entité exemple') ON CONFLICT (name) DO NOTHING;"

# Effectue une migration simple : ajout d'une colonne description.
db-migrate: db-schema
    psql -h "{{db_host}}" -p "{{db_port}}" -U "{{db_user}}" -d "{{db_name}}" -v ON_ERROR_STOP=1 -c "ALTER TABLE entities ADD COLUMN IF NOT EXISTS description TEXT;"

# Downgrade : remet la base dans un état vide en supprimant
# tous les objets du schéma public, sans supprimer la base elle-même.
db-downgrade:
    psql -h "{{db_host}}" -p "{{db_port}}" -U "{{db_user}}" -d "{{db_name}}" -v ON_ERROR_STOP=1 -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Affiche les tables de la base.
db-status:
    psql -h "{{db_host}}" -p "{{db_port}}" -U "{{db_user}}" -d "{{db_name}}" -c "\\dt"