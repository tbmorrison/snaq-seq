#must be in dockerBuild directory
#buildDocker.sh <path/to/ref/>

rm -fr ./dockerBuild
mkdir -p ./dockerBuild/snaq-seq

echo "copy snaq-seq scripts...."
cp ./docker-scripts/* ./dockerBuild/snaq-seq

echo "Build Docker..."
docker build -t snaq-seq:v1.1 \
    -f ./base.df \
    ./dockerBuild 
docker push accugenomics/snaq-seq:v1.1

echo "Clean up..."
rm -fr ./dockerBuild
