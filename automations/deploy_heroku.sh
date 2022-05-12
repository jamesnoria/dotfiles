#chmod 754 for permission
git add .
git commit -m "$*"
git push heroku main
