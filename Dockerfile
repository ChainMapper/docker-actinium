FROM chainmapper/walletbase-bionic-build as builder

ENV GIT_COIN_URL    https://github.com/Actinium-project/Actinium-ng.git
ENV GIT_COIN_NAME   actinium   

RUN	apt-get -y update \
	&& apt-get -y install libunivalue0

RUN	git clone $GIT_COIN_URL $GIT_COIN_NAME \
	&& cd $GIT_COIN_NAME \
	&& git checkout tags/v0.19.0.0 \
	&& chmod +x autogen.sh \
	&& chmod +x share/genbuild.sh \
	&& chmod +x src/leveldb/build_detect_platform \
	&& ./autogen.sh && ./configure LIBS="-lcap -lseccomp" \
	&& make \
	&& make install

FROM chainmapper/walletbase-bionic as runtime

COPY --from=builder /usr/local/bin /usr/local/bin

RUN mkdir /data
ENV HOME /data

#zmq port, rpc port & main port
EXPOSE 5555 6666 4334

COPY start.sh /start.sh
COPY gen_config.sh /gen_config.sh
COPY wallet.sh /wallet.sh
RUN chmod 777 /*.sh
CMD /start.sh Actinium.conf ACM Actiniumd