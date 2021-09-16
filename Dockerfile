FROM ubuntu:20.04

ENV PRIVACYIDEA_CONFIGFILE=/etc/privacyidea/pi.cfg
ENV TZ=Europe/Prague

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update \
  # build deps
  && apt-get install -y \
    apt-utils \
    build-essential \
    default-libmysqlclient-dev \
    libffi-dev \
    libgdbm-dev \
    libjpeg-dev \
    libldap2-dev \
    libncurses5-dev \
    libnss3-dev \
    libpq-dev \
    libreadline-dev \
    libsasl2-dev \
    libssl-dev \
    libxslt1-dev \
    libz-dev \
    zlib1g-dev \
  # python3
  && apt-get install -y \
    python3 \
    python3-pip \
    python-is-python3 \
  # apache, mods and wsgi (python support)
  && apt-get install -y \
    apache2 \
    apache2-dev \
    libapache2-mod-wsgi-py3 \
  && rm -f /etc/apache2/sites-enabled/*.conf \
  && a2enmod wsgi auth_digest \
  # install stunnel
  && apt-get install -y stunnel4 \
  # add user
  && adduser --disabled-password --disabled-login --gecos "" privacyidea \
  && mkdir -p /opt/privacyidea \
  ## fix log dir
  && mkdir -p /var/log/privacyidea && touch /var/log/privacyidea/privacyidea.log && chmod a+rw /var/log/privacyidea/privacyidea.log \
  # check python
  && python3 --version \
  && pip3 install --upgrade setuptools \
  && pip3 install --upgrade pip \
  # mysql driver
  && pip3 install --no-cache-dir 'pymysql-sa==1.0' 'PyMySQL==0.9.3' \
  # deps
  && pip3 install --no-cache-dir -r "https://raw.githubusercontent.com/privacyidea/privacyidea/v3.6/requirements.txt" \
  && pip3 install --no-cache-dir 'privacyidea==3.6' \
  # cleanup
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/privacyidea

COPY apache.conf /etc/apache2/sites-enabled/privacyidea.conf

COPY privacyideaapp.py /opt/privacyidea/privacyideaapp.wsgi

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
