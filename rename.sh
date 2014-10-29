newName=$1
if [ -z "$newName" ]; then
  echo "Please specify a new project name"
  exit 1
fi

echo "Renaming MyPlayProject to $newName"
mkdir $newName 

echo "Moving submodules"
git mv MyPlayProject/ShinobiPlayUtils $newName

echo "Renaming directories"
rm -rf MyPlayProject/Build/
git mv MyPlayProject/* $newName/
git mv "$newName/MyPlayProject" "$newName/$newName"
rm -rf MyPlayProject

echo "Renaming files"
for file in $(git ls-files | grep MyPlayProject | sed -e 's/\(MyPlayProject[^/]*\).*/\1/' | uniq); do
  git mv $file `echo $file | sed -e "s/MyPlayProject/$newName/"`
done

echo "Replacing text inside files"
for file in $(git ls-files | grep -v rename); do
  if [ -f $file ]; then
    echo "Replacing text in $file"
    sed -i '' "s@MyPlayProject@$newName@g" $file
    git add $file
  fi
done

echo "Removing the utility script"
git rm rename.sh
