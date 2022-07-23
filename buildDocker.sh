#must be in dockerBuild directory
#buildDocker.sh <path/to/ref/>

#mkdir /NGS/code/snaq-vsoft/dockerBuild
#
#echo "copy snaq-seq scripts...."
#cp -r /NGS/code/snaq-vsoft/docker-scripts/. /NGS/code/snaq-vsoft/dockerBuild
#
#echo "Altering ref and basechange file lookup"
#awk '/if \[\[ ! -f \${rg} \]\];then/{sk=1;next}/ref="\${rg}"/{sk=0;print "ref=\"/snaq-seq/ref.fasta\";bc=\"/snaq-seq/amplicon-basechange.txt\";nf=\"/snaq-seq/normalizer.txt\";cc=2000;is=2000" ;next}sk==1{next}{print $0}' /NGS/code/snaq-vsoft/docker-scripts/snaq > /NGS/code/snaq-vsoft/dockerBuild/snaq
#
#echo "copy genome ${1}"
#cp -a "${1}/." /NGS/code/snaq-vsoft/dockerBuild/
#
#echo "Build Docker..."
#docker build -t $(basename ${1}) -f /NGS/code/snaq-vsoft/specific.df /NGS/code/snaq-vsoft/dockerBuild 
docker tag "$(basename ${1}):latest" accugenomics/snaq-seq:v1.1-$(basename ${1})
docker push accugenomics/snaq-seq:v1.1-$(basename ${1})

echo "Clean up..."
rm -fr /NGS/code/snaq-vsoft/dockerBuild
