#must be in dockerBuild directory
#buildDocker.sh <path/to/ref/>

rm -fr ./dockerBuild
mkdir -p ./dockerBuild/REF
mkdir ./dockerBuild/snaq-seq

echo "copy snaq-seq scripts...."
cp ./docker-scripts/* ./dockerBuild/snaq-seq

echo "Altering ref and basechange file lookup"
awk '/if \[\[ ! -f \${rg} \]\];then/{sk=1;next}/ref="\${rg}"/{sk=0;print "ref=\"/REF/ref.fasta.gz\";bc=\"/REF/amplicon-basechange.txt\";re=\x27^[0-9]+$\x27;if ! [[ ${cc} =~ $re ]];then cc=2000;fi;if ! [[ ${is} =~ $re ]];then is=2000;fi;if [[ ! -f ${nf} ]];then nf=\"/REF/normalizer.txt\";fi" ;next}sk==1{next}{print $0}' ./docker-scripts/snaq > ./dockerBuild/snaq-seq/snaq

echo "copy genome ${1}"
cp "${1}/"* ./dockerBuild/REF/

echo "Build Docker..."
docker build -t snaq-seq:"v1.1-$(basename ${1})" \
    -f ./specific.df \
    ./dockerBuild 
docker tag snaq-seq:"v1.1-$(basename ${1})" accugenomics/snaq-seq:"v1.1-$(basename ${1})"
docker push accugenomics/snaq-seq:v1.1-$(basename ${1})

echo "Clean up..."
rm -fr ./dockerBuild
