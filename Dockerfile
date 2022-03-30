FROM nikolaik/python-nodejs:python3.7-nodejs16 as build
WORKDIR /wheels
COPY requirements.txt /opt/sherlock/
RUN pip3 wheel -r /opt/sherlock/requirements.txt


FROM nikolaik/python-nodejs:python3.7-nodejs16
RUN apt-get update && apt-get install jq -y
WORKDIR /opt/sherlock
ARG VCS_REF
ARG VCS_URL="https://github.com/sherlock-project/sherlock"
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL
COPY --from=build /wheels /wheels
COPY . /opt/sherlock/
RUN pip3 install -r requirements.txt -f /wheels \
  && rm -rf /wheels \
  && rm -rf /root/.cache/pip/*
RUN npm install -g apify-cli@0.7.1-beta.1

CMD ./.actor/start.sh
