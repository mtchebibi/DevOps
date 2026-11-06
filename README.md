# DevOps

## Importation Repository

```
git clone git@github.com:mtchebibi/DevOps.git
```

## Transformation sur les branches

```
git switch -c nom_de_la_branche         #changer branche
git checkout main                       #revenir main

git branche                             #afficher branche

git merge nom_de_la_branche             #fusionner branche

git branche -d nom_de_la_branche        #delete
```

## Communication serveur distant

```
git pull
git add .
git commit -m "Message"
git push origin main

git status #afficher état actuelle
```

## TP Docker Hub + GitHub Pages

Le workflow `.github/workflows/deploy-pages.yml` :

1. vérifie le HTML, le Dockerfile, les fichiers YAML et la syntaxe Ansible ;
2. construit l'image et la pousse sur Docker Hub
   (tags `latest` et `$GITHUB_SHA`) ;
3. publie le site sur GitHub Pages :
   <https://mtchebibi.github.io/DevOps/>.

`site/index.html` est versionné et sert de source commune à l'image Docker
et à GitHub Pages.

### Configuration à faire une fois

1. Créer un compte Docker Hub (offre Free) :
   <https://app.docker.com/signup/>.
2. Créer un dépôt **privé** `devops-hello` dans Docker Hub.
3. Créer un token Docker Hub (Account settings → Personal access tokens)
   avec les droits **Read & Write**.
4. Ajouter les secrets GitHub du dépôt :
   - `DOCKERHUB_USERNAME` : nom d'utilisateur Docker Hub ;
   - `DOCKERHUB_TOKEN` : token Docker Hub (pas le mot de passe).

   Avec GitHub CLI :

   ```bash
   gh secret set DOCKERHUB_USERNAME --body "VOTRE_USERNAME"
   gh secret set DOCKERHUB_TOKEN
   ```

5. Dans GitHub : **Settings → Pages → Build and deployment → Source :
   GitHub Actions**.

### Commandes utiles

```bash
# Lancer le pipeline manuellement
gh workflow run deploy-pages.yml

# Suivre le dernier run
gh run watch

# Se connecter à Docker Hub si nécessaire, puis vérifier l'image publiée
docker login
docker pull VOTRE_USERNAME/devops-hello:latest
```

Si le dépôt Docker Hub change de nom, adaptez `IMAGE_NAME` dans le workflow.
