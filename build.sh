export GOOS=linux
export GOARCH=amd64

unameOut="$(uname -s)"
case "${unameOut}" in
    CYGWIN*|MINGW*)     machine=Windows;;
    Linux*|Darwin*|*)   machine=Unix
esac

echo "building for $GOOS-$GOARCH on $machine"

for lambda in `ls lambdas`
do
    echo ""
    echo "building $lambda"
    go build -o bin/$lambda lambdas/$lambda/main.go
    
    echo "zipping $lambda"
    if [ $machine = "Windows" ]; then
        # Grants the execute permission before zipping, on Windows
        # go get -u github.com/aws/aws-lambda-go/cmd/build-lambda-zip
        build-lambda-zip -o dist/$lambda.zip bin/$lambda
    else
        zip -j dist/$lambda.zip bin/$lambda
    fi

    # Add the /dist subfolder to the .zip if it exists
    [ -e lambdas/$lambda/dist ] && \
    echo "adding dist/" && \
    cd lambdas/$lambda && \
    zip -ru ../../dist/$lambda.zip dist && \
    cd ../..

    echo "built dist/$lambda.zip"
done
