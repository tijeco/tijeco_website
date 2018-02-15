hugo
#
# pwd
# ls public/index.html
sed -ie 's/<li><i class="fa fa-home"/<li id="active"><i class="fa fa-home"/g' public/index.html

sed -ie 's/<li><i class="fa fa-user"/<li id="active"><i class="fa fa-user"/g' public/about/index.html

sed -ie 's/<li><i class="fa fa-bar-chart"/<li id="active"><i class="fa fa-bar-chart"/g' public/research/index.html

sed -ie 's/<li><i class="fa fa-book"/<li id="active"><i class="fa fa-book"/g' public/publications/index.html

sed -ie 's/<li><i class="fa fa-folder"/<li id="active"><i class="fa fa-folder"/g' public/projects/index.html
