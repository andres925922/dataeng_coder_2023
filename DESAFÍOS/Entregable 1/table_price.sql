CREATE TABLE IF NOT EXISTS bitcoin_prices (
    id INT IDENTITY(1,1) PRIMARY KEY,
    price FLOAT(8,2),
    date TIMESTAMP
);