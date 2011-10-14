Running Sorcery's Specs
=======================
Sorcery is meant to be used with Rails and Sinatra so sample apps have been included in `spec/`.  

Each sample app runs a set of shared specs ( `spec/shared_examples/*_example.rb`) and also includes specs that address framework specific concerns.

Sorcery has one set of specs (`sorcery_crypto_providers_spec.rb`) that can be run outside of any of the frameworks. To run it simply:
    
    cd spec/
    bundle install
    rake spec

Running Framework Specs
-----------------------
To run framework specs, cd into each directory, bundle, and run the specs. For example, to run the rails3 specs you would:

    cd spec/rails3/
    bundle install
    rake spec

**Note:** the rails3_mongoid and rails3_mongo_mapper sample apps do require, well, MongoDB. Installing MongoDB on mac osx is easy with homebrew. Seeing as you're reading the readme for running specs, I'll assume you can install MongoDB on your machine. For the purpose of running these tests, I put mongod in verbose mode and in the background so I can see it log to stdout. 

    cd spec/rails3_mongoid
    bundle install
    mongod -v &
    rake spec
    
    cd spec/rails3_mongo_mapper
    bundle install
    mongod -v &
    rake spec