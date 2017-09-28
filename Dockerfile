# Start with PHP 7.1
FROM drupalci/php-7.1-apache

# Update
RUN apt-get update 

# Install node/npm
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN \
	echo -e "\nInstalling nodejs..." && \
	apt-get install -y nodejs

# Install wget
RUN \
	echo -e "\nInstalling wget..." && \
	apt-get install -y wget

ENV \
	PHANTOMJS_VERSION=2.1.1 \
	CASPERJS_VERSION=1.1.4 \
	SLIMERJS_VERSION=0.10.3 \
	BACKSTOPJS_VERSION=3.0.25 \
	# Workaround to fix phantomjs-prebuilt installation errors
	# See https://github.com/Medium/phantomjs/issues/707
	NPM_CONFIG_UNSAFE_PERM=true \
	GULP_VERSION=3.9.1 \
	CHROMIUM_VERSION=61.0 \
	FIREFOX_VERSION=52.3 \
	CHROME_PATH=/usr/bin/chromium-browser

# Install jq
RUN \
	echo -e "\nInstalling jq..." && \
	apt-get install -y  jq

# Installing dependencies from archives - not only this allows us to control versions,
# but the resulting image size is 130MB+ less (!) compared to an npm install (440MB vs 575MB).
RUN \
	mkdir -p /opt && \
	# PhantomJS
	echo "Downloading PhantomJS v${PHANTOMJS_VERSION}..." && \
	curl -sL "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2" | tar jx && \
	mv phantomjs-${PHANTOMJS_VERSION}-linux-x86_64 /opt/phantomjs && \
	ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
	echo "Fixing PhantomJS on Alpine" && \
	curl -sL "https://github.com/dustinblackman/phantomized/releases/download/${PHANTOMJS_VERSION}/dockerized-phantomjs.tar.gz" | tar zx -C /

RUN \
	# CasperJS
	echo "Downloading CasperJS v${CASPERJS_VERSION}..." && \
	curl -sL "https://github.com/casperjs/casperjs/archive/${CASPERJS_VERSION}.tar.gz" | tar zx && \
	mv casperjs-${CASPERJS_VERSION} /opt/casperjs && \
	ln -s /opt/casperjs/bin/casperjs /usr/bin/casperjs

RUN \
	# SlimerJS
	echo "Downloading SlimerJS v${SLIMERJS_VERSION}..." && \
	curl -sL -O "http://download.slimerjs.org/releases/${SLIMERJS_VERSION}/slimerjs-${SLIMERJS_VERSION}.zip" && \
	unzip -q slimerjs-${SLIMERJS_VERSION}.zip && rm -f slimerjs-${SLIMERJS_VERSION}.zip && \
	mv slimerjs-${SLIMERJS_VERSION} /opt/slimerjs && \
	# Run slimer with xvfb
	echo '#!/usr/bin/env bash\nxvfb-run /opt/slimerjs/slimerjs "$@"' > /opt/slimerjs/slimerjs.sh && \
	chmod +x /opt/slimerjs/slimerjs.sh && \
	ln -s /opt/slimerjs/slimerjs.sh /usr/bin/slimerjs

# Install gulp globally
RUN \
	echo -e "\nInstalling gulp v${GULP_VERSION}..." && \
	npm install -g gulp@${GULP_VERSION}

# Install backstop globally
RUN \
	echo -e "\nInstalling BackstopJS v${BACKSTOPJS_VERSION}..." && \
	npm install -g backstopjs@${BACKSTOPJS_VERSION}

# Chrome (from edge)
RUN \
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
	apt-get update  && \
	apt-get install -y "google-chrome-stable=${CHROMIUM_VERSION}"

# SlimerJS dependencies
RUN \
	echo -e "\nInstalling SlimerJS dependencies..." && \
	apt-get install -y \
	dbus \
	xvfb

# xvfb wrapper
COPY xvfb-run /usr/bin/xvfb-run

# Install Terminus
RUN \
	echo -e "\nInstalling Terminus..." && \
	/usr/bin/env COMPOSER_BIN_DIR=$HOME/bin composer --working-dir=$HOME require pantheon-systems/terminus "^1"