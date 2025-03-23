cat Base/*.lua Game/*.lua Libraries/*.lua > Blob.lua
printf "game.init() function TIC() game.update() end" >> Blob.lua

pushd Tools/lua-minifier
./bin/python minify.py ../../Blob.lua
mv mini.lua ../../BlobMin.lua
popd

rm Blob.lua
