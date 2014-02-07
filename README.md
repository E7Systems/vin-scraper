VIN Scraper
==========

##Installation

Tested with ruby-2.0.0-p353

Make sure that you have MySQL installed and you have created the database named `vin_data` and the table named `vins`. Change the MySQL username and/or password in `vin_scraper.rb` if necessary.

The SQL query to create the table is:

```
CREATE TABLE vins
(
    id INT NOT NULL AUTO_INCREMENT,
    year SMALLINT UNSIGNED NOT NULL,
    make VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    vin VARCHAR(255) NOT NULL,
    UNIQUE KEY unique_vin (vin),
    PRIMARY KEY(id)
);
```

Install required Ruby Gems to use the scraper (assuming you are using RVM)

```
rvm use ruby-2.0.0-p353
bundle install
```

Run the scraper.

```
ruby vin_scraper.rb
```

