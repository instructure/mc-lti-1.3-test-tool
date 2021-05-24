FROM instructure/ruby-passenger:2.6

ENV APP_HOME "/usr/src/app/"

USER root

# Upgrade to PostgreSQL 9.6 and install the client with pg_dump for schema.
RUN echo "deb https://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && apt-get update && apt-get install -y postgresql-client-9.6 \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Gemfile Gemfile.lock $APP_HOME
RUN chown -R docker:docker $APP_HOME

USER docker
RUN bundle install --quiet --jobs 8
USER root

COPY . $APP_HOME
RUN mkdir -p coverage log tmp && chown -R docker:docker $APP_HOME

USER docker
