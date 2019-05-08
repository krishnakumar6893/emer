#set base image
FROM ubuntu:14.04

#set working directory
WORKDIR /opt/fontli

ADD . /opt/fontli

#Opening ports
EXPOSE 8088

#Installing curl
RUN apt update && apt install curl -y && apt-get install gnupg2 -y
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -

#Installing and setting up RVM
RUN curl -L https://get.rvm.io | bash -s stable
RUN usermod -a -G rvm root
RUN /bin/bash -c "source /etc/profile.d/rvm.sh"
#RUN cd .. && cd fontli
#CMD rvm reload

#Installing ruby
RUN /bin/bash -l -c "rvm install ruby-1.9.3-p547" 
RUN /bin/bash -l -c "gem install bundler -v 1.15.4"
COPY Gemfile Gemfile.lock ./
RUN mkdir /opt/bundle
ENV BUNDLE_PATH /opt/bundle
RUN /bin/bash -l -c "bundle install"

#Installing MongoDB
RUN curl -O http://downloads.mongodb.org/linux/mongodb-linux-x86_64-2.6.12.tgz
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
RUN apt update && apt install mongodb-org=2.6.12 mongodb-org-server=2.6.12 mongodb-org-shell=2.6.12 mongodb-org-mongos=2.6.12 mongodb-org-tools=2.6.12

#Starting MongoDB
RUN mongod -f /etc/mongod.conf &

COPY script.sh .

ENTRYPOINT [ "./script.sh" ]

#Copying yml file
RUN mkdir /var/local/config
COPY ./fontli.yml /var/local/config/
COPY ./config/mongoid.yml.sample ./config/mongoid.yml

#Starting the rails server
RUN cd .. && cd fontli
CMD rvm reload
RUN /bin/bash -c "source /etc/profile.d/rvm.sh"
CMD /bin/bash -l -c "APP_SECRET_TOKEN='e00eef067487aa443c6ab9b9f4dd1c8es' rails s -p 8088"
