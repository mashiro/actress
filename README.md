# ACTress

ACT Log Viewer

## Requirements

* mroonga (MariaDB is recommended)
* ruby
* node

## Getting Started

### Install ruby gems

```bash
gem install bundler
bundle install
```

### Install npm modules

```bash
npm install
```

### Install bower modules

```bash
npm install -g bower
bower install
```

### Build application

```bash
npm run build
```

### Create act database environment

create database

```sql
create database act;
```

create act users

```bash
rake db:user:create_sql > create_user.sql
mysql -uroot -p < create_user.sql
```

### Edit database configuration

```
cp config/database.yml.sample config/database.yml
vim config/database.yml # override act user password
```

### Database migration

```bash
rake db:migrate
```

### Run the application

```bash
./bin/ctl start
```

### ACT client configuration

* Install MySQL ODBC
* Set ACT ODBC ConnectionString (use act-clinet user)

