# SQL script to create users
CREATE TABLE Users (
    user_id INT(11) NOT NULL AUTO_INCREMENT,
    username VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL,
    realname VARCHAR(40),
    password VARCHAR(20) NOT NULL,
    status VARCHAR(40),
    created DATETIME,
    lasttime DATETIME, # last access
    ip_addr VARCHAR(40), # last IP address
    PRIMARY KEY (user_id),
    UNIQUE (username)
);
