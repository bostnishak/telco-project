-- -------------------------------------------------------------
-- TARIFFS Table Creation and Constraints
-- -------------------------------------------------------------
CREATE TABLE TARIFFS (
    TARIFF_ID NUMBER,
    NAME VARCHAR2(100) NOT NULL,
    MONTHLY_FEE NUMBER NOT NULL,
    DATA_LIMIT NUMBER NOT NULL,
    MINUTE_LIMIT NUMBER NOT NULL,
    SMS_LIMIT NUMBER NOT NULL,
    CONSTRAINT PK_TARIFFS PRIMARY KEY (TARIFF_ID)
);

-- -------------------------------------------------------------
-- CUSTOMERS Table Creation, Constraints, and Indexes
-- -------------------------------------------------------------
CREATE TABLE CUSTOMERS (
    CUSTOMER_ID NUMBER,
    NAME VARCHAR2(100) NOT NULL,
    CITY VARCHAR2(100) NOT NULL,
    SIGNUP_DATE DATE NOT NULL,
    TARIFF_ID NUMBER NOT NULL,
    CONSTRAINT PK_CUSTOMERS PRIMARY KEY (CUSTOMER_ID),
    CONSTRAINT FK_CUST_TARIFF FOREIGN KEY (TARIFF_ID) REFERENCES TARIFFS(TARIFF_ID)
);

-- Index on TARIFF_ID for faster table joins when querying by tariff type
CREATE INDEX IDX_CUST_TARIFF ON CUSTOMERS(TARIFF_ID);
-- Index on CITY for location based groupings and queries
CREATE INDEX IDX_CUST_CITY ON CUSTOMERS(CITY);
-- Index on SIGNUP_DATE for time based filtering
CREATE INDEX IDX_CUST_SIGNUP ON CUSTOMERS(SIGNUP_DATE);

-- -------------------------------------------------------------
-- MONTHLY_STATS Table Creation, Constraints, and Indexes
-- -------------------------------------------------------------
CREATE TABLE MONTHLY_STATS (
    STAT_ID NUMBER,
    CUSTOMER_ID NUMBER NOT NULL,
    DATA_USAGE NUMBER(10, 2) NOT NULL,
    MINUTE_USAGE NUMBER NOT NULL,
    SMS_USAGE NUMBER NOT NULL,
    PAYMENT_STATUS VARCHAR2(20) NOT NULL,
    CONSTRAINT PK_MONTHLY_STATS PRIMARY KEY (STAT_ID),
    CONSTRAINT FK_STATS_CUST FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID),
    CONSTRAINT CHK_PAYMENT_STATUS CHECK (PAYMENT_STATUS IN ('PAID', 'UNPAID', 'LATE'))
);

-- Index on CUSTOMER_ID to speed up joins between CUSTOMERS and their MONTHLY_STATS
CREATE INDEX IDX_STATS_CUST ON MONTHLY_STATS(CUSTOMER_ID);
-- Index on PAYMENT_STATUS to optimize unpaid/late fee filtering
CREATE INDEX IDX_STATS_PAYMENT ON MONTHLY_STATS(PAYMENT_STATUS);

-- Note: The dataset will rely on EXPLICIT ID insertion rather than sequences,
-- ensuring precise compatibility with the provided data sets.
