FROM ruby:2.5.1

RUN apt-get update -qq

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get install -y nodejs
RUN apt-get update -qq && apt-get install -y yarn

RUN bundle config --global frozen 1

WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . .

EXPOSE 3000
ENV RAILS_ENV production
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
