#/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color]]'

# TODO optional clean
# rm -rf ejbuild 

echo -e "${GREEN}Pulling ejabberd build Docker image${NC}"
docker pull ejabberd/mix

echo -e "${GREEN}Cloning ejabberd${NC}"
if [ ! -d ejbuild ]; then
	git clone https://github.com/processone/ejabberd.git ejbuild 
fi

echo -e "${GREEN}Building ejabberd release${NC}"
if [ ! -e ejabberd.tar.gz ]; then
	# Copy release configuration
	cp rel/*.exs ejbuild/rel/
	# Force clock resync
	docker run -it  --rm --privileged --entrypoint="/sbin/hwclock" ejabberd/mix -s
	# Build ejabberd and generate release
	docker run -it -v $(pwd)/ejbuild:$(pwd)/ejbuild -w $(pwd)/ejbuild -e "MIX_ENV=prod" ejabberd/mix do deps.get, deps.compile, compile, release --env=prod
	# Copy generated ejabberd release archive 
	cp ejbuild/_build/prod/rel/ejabberd/releases/*/ejabberd.tar.gz .
fi

# Build ejabberd base container
echo -e "${GREEN}Building ejabberd Community Edition container${NC}"
docker build -t ejabberd/ecs .