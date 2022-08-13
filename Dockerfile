FROM julia:1.5.3-buster

RUN apt-get update && apt-get install -y \
    curl \
    groff \
    less \
    unzip \
    python3-pip \
    cron \
    software-properties-common;

RUN mkdir -p /usr/share/man/man1/

# Installing AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/root/awscliv2.zip"
RUN unzip /root/awscliv2.zip
RUN ./aws/install

# Install Java
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless && \
    apt-get clean;

# Fix certificate issues
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
RUN export JAVA_HOME

RUN mkdir /opt/auth
RUN mkdir /opt/auth/src

COPY src/* /opt/auth/src/
COPY build.jl /opt/auth/
COPY *.toml /opt/auth/

WORKDIR /opt/auth/

RUN julia build.jl

CMD ["julia","/opt/auth/src/main.jl"]
