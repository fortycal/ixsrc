FROM fluent/fluentd:v1.12-debian-1

ENV FLUENT_UID=0
USER root
RUN mkdir /buffer
RUN ["gem", "install", "fluent-plugin-kafka"]
# RUN ["gem", "install", "fluent-plugin-newsyslog"]
RUN ["apt", "update"]
RUN ["apt", "install", "telnet", "-y"]
