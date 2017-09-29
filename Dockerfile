# Start with PHP 7.1
FROM drupalci/php-7.1-apache:production

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
	BACKSTOPJS_VERSION=3.0.25 \
	GULP_VERSION=3.9.1

# Install jq
RUN \
	echo -e "\nInstalling jq..." && \
	apt-get install -y  jq

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
	echo -e "\nInstalling Google Chrome..." && \
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
	apt-get update  && \
	apt-get install -y "google-chrome-stable"

# Install Terminus
RUN \
	echo -e "\nInstalling Terminus 1.x..." && \
	/usr/bin/env COMPOSER_BIN_DIR=$HOME/bin composer --working-dir=$HOME require pantheon-systems/terminus "^1"

# Enable Composer parallel downloads
RUN \
	echo -e "\nInstalling hirak/prestissimo for parallel Composer downloads..." && \
	composer global require -n "hirak/prestissimo:^0.3"

# Install Terminus plugins
RUN \
	echo -e "\nInstalling Terminus plugins..." && \
	composer create-project -n -d $HOME/.terminus/plugins pantheon-systems/terminus-build-tools-plugin:dev-master && \
	composer create-project -n -d $HOME/.terminus/plugins pantheon-systems/terminus-secrets-plugin:^1