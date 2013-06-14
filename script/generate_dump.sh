#write xhtml+rdfa file
FILE=../cocoon/dump/nomisma.org.xml
cat ../cocoon/dump/xhtml-header.txt > $FILE
for i in `ls /usr/local/projects/nomisma-ids/id/*.txt`; do cat $i >> $FILE; echo "Writing `basename $i`"; done;
echo '</body></html>' >> $FILE
