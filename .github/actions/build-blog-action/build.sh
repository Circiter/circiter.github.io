#!/bin/sh

bundle install

bundle exec jekyll build --trace

latex --version

cd "./$FOLDER"
#echo > .nojekyll
if [ -e index.html ]; then mv index.html _.html; fi
echo 'under construction' > index.html
if [ "x$CNAME" != x ]; then
  echo "$CNAME" > CNAME
fi
cd ..

COMMIT_EMAIL="${GITHUB_ACTOR:-github-pages-deploy-action}@users.noreply.github.com"

COMMIT_NAME="${GITHUB_ACTOR:-GitHub Pages Deploy Action}"

git config --global user.email "${COMMIT_EMAIL}"
git config --global user.name "${COMMIT_NAME}"

REPOSITORY_PATH="https://${ACCESS_TOKEN:-"x-access-token:$GITHUB_TOKEN"}@github.com/${GITHUB_REPOSITORY}.git"

rm -r .git
#git clone $REPOSITORY_PATH
#cd `basename "$GITHUB_REPOSITORY"`
mkdir result
cd result
git init
#git checkout $BRANCH
#[ `ls . | wc -l` = 0 ] || rm -r *
#[ -e .nojekyll ] && rm .nojekyll
mv ../$FOLDER/* .
git add --all --force
git commit --quiet --allow-empty -m -
git push --force "$REPOSITORY_PATH" $BRANCH
