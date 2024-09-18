# Home of our lambda code

Here you'll find javascript code that'll be run when we invoke our lambda. It might look weird though. Dependencies missing, chaos, CHAOS.

## Packaging

Lambda is able to take a zip file as a code package so we'll just zip up all of our code and just as important, our dependencies.
From within the `lib` directory, run the below

### Windows

Since windows is a pain to use, there isn't an *exclude-this* flag. You can zip manually if you find the package in your zip.

`Compress-Archive -U .\* .\deployment_package.zip`

### Linux

`zip -x testbench.js -x deployment_package.zip -r deployment_package.zip ./`
