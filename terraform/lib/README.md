# Home of our lambda code

Here you'll find javascript code that'll be run when we invoke our lambda. It might look weird though. Dependencies missing, chaos, CHAOS.

## Packaging

Lambda is able to take a zip file as a code package so we'll just zip up all of our code and just as important, our dependencies.

### Windows

`Compress-Archive -U .\* .\deployment_package.zip`

### Linux

`zip -r deployment_package.zip ./`
