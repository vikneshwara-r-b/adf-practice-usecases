/*
Export the following SAP tables data with 20 columns and 50 records as CSV file.
1.	MARA
2.	VBRK
3.	VBAP
4.	VBRK_SPPAYM
5.	SR01A

Load them into ADLS Gen2 container into source table

Use ADF to copy the CSV files into tables from source table to target tables in different servers


Parameter name: table_list
Datatype: array
Value:
[
  {
    "tableName": "MARA",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  },
  {
    "tableName": "VBRK",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  },
  {
    "tableName": "VBAP",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  },
  {
    "tableName": "VBRK_SPPAYM",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  },
  {
    "tableName": "SR01A",
    "tableSchemaName": "dbo",
    "Watermark_Column": "last_updated"
  }
]
*/

/* Create the following DB in source server*/
CREATE DATABASE sql_prod_sap_source; 

/* Create the following DB in target server*/
CREATE DATABASE sql_prod_sap_target;

/* Create the following 5 tables in both source server and target server*/

CREATE TABLE dbo.MARA (
    MANDT        CHAR(3)   NOT NULL,
    MATNR        CHAR(18)  NOT NULL,
    ERSDA        CHAR(8)   NULL,
    ERNAM        CHAR(12)  NULL,
    LAEDA        CHAR(8)   NULL,
    AENAM        CHAR(12)  NULL,
    VPSTA        CHAR(15)  NULL,
    PSTAT        CHAR(15)  NULL,
    LVORM        CHAR(1)   NULL,
    MTART        CHAR(4)   NULL,
    MBRSH        CHAR(1)   NULL,
    MATKL        CHAR(9)   NULL,
    BISMT        CHAR(18)  NULL,
    MEINS        CHAR(3)   NULL,
    BSTME        CHAR(3)   NULL,
    ZEINR        CHAR(22)  NULL,
    ZEIAR        CHAR(3)   NULL,
    ZEIVR        CHAR(2)   NULL,
    ZEIFO        CHAR(4)   NULL,
    AESZN        CHAR(6)   NULL,
    last_updated DATETIME2(3) NOT NULL,

    CONSTRAINT PK_MARA PRIMARY KEY (MANDT, MATNR)
);


CREATE TABLE dbo.VBRK (
    MANDT        CHAR(3)   NOT NULL,
    VBELN        CHAR(10)  NOT NULL,
    FKART        CHAR(4)   NULL,
    FKTYP        CHAR(1)   NULL,
    VBTYP        CHAR(1)   NULL,
    WAERK        CHAR(5)   NULL,
    VKORG        CHAR(4)   NULL,
    VTWEG        CHAR(2)   NULL,
    KALSM        CHAR(6)   NULL,
    KNUMV        CHAR(10)  NULL,
    VSBED        CHAR(2)   NULL,
    FKDAT        CHAR(8)   NULL,
    BELNR        CHAR(10)  NULL,
    GJAHR        CHAR(4)   NULL,
    POPER        CHAR(3)   NULL,
    KONDA        CHAR(2)   NULL,
    KDGRP        CHAR(2)   NULL,
    BZIRK        CHAR(6)   NULL,
    PLTYP        CHAR(2)   NULL,
    INCO1        CHAR(3)   NULL,
    last_updated DATETIME2(3) NOT NULL,

    CONSTRAINT PK_VBRK PRIMARY KEY (MANDT, VBELN)
);

CREATE TABLE dbo.VBAP (
    MANDT        CHAR(3)   NOT NULL,
    VBELN        CHAR(10)  NOT NULL,
    POSNR        CHAR(6)   NOT NULL,
    MATNR        CHAR(18)  NULL,
    MATWA        CHAR(18)  NULL,
    PMATN        CHAR(18)  NULL,
    CHARG        CHAR(10)  NULL,
    MATKL        CHAR(9)   NULL,
    ARKTX        CHAR(40)  NULL,
    PSTYV        CHAR(4)   NULL,
    POSAR        CHAR(1)   NULL,
    LFREL        CHAR(1)   NULL,
    FKREL        CHAR(1)   NULL,
    UEPOS        CHAR(6)   NULL,
    GRPOS        CHAR(6)   NULL,
    ABGRU        CHAR(2)   NULL,
    PRODH        CHAR(18)  NULL,
    ZWERT        DECIMAL(13,2) NULL,
    ZMENG        DECIMAL(13,3) NULL,
    ZIEME        CHAR(3)   NULL,
    last_updated DATETIME2(3) NOT NULL,

    CONSTRAINT PK_VBAP PRIMARY KEY (MANDT, VBELN, POSNR)
);

CREATE TABLE dbo.VBRK_SPPAYM (
    SPPAYM       CHAR(2)  NOT NULL,
    SPPORD       CHAR(10) NOT NULL,
    last_updated DATETIME2(3) NOT NULL,

    CONSTRAINT PK_VBRK_SPPAYM PRIMARY KEY (SPPAYM, SPPORD)
);

CREATE TABLE dbo.SR01A (
    RCSZK        CHAR(2)   NULL,
    RNAME        CHAR(30)  NULL,
    REPID        CHAR(40)  NULL,
    OBJECT       CHAR(10)  NULL,
    DBNAM        CHAR(20)  NULL,
    CLIENT       CHAR(3)   NOT NULL,
    DATUM        CHAR(8)   NULL,
    UZEIT        CHAR(6)   NULL,
    UNAME        CHAR(12)  NULL,
    DSN          CHAR(60)  NULL,
    HOST         CHAR(8)   NULL,
    OPSYS        CHAR(10)  NULL,
    DBSYS        CHAR(10)  NULL,
    SYSID        CHAR(8)   NULL,
    SAPRL        CHAR(4)   NULL,
    APPLI        CHAR(2)   NULL,
    ARKEY        CHAR(20)  NOT NULL,
    SZEIT        CHAR(6)   NULL,
    AZAHL        CHAR(10)  NULL,
    NWKEY        CHAR(20)  NULL,
    last_updated DATETIME2(3) NOT NULL,

    CONSTRAINT PK_SR01A PRIMARY KEY (CLIENT, ARKEY)
);

/* Print all records in each table*/
SELECT * FROM dbo.MARA;
SELECT * FROM dbo.VBRK;
SELECT * FROM dbo.VBAP;
SELECT * FROM dbo.VBRK_SPPAYM;
SELECT * FROM dbo.SR01A;

/*Truncate and Drop table statements*/
TRUNCATE TABLE dbo.MARA;
TRUNCATE TABLE dbo.VBRK;
TRUNCATE TABLE dbo.VBAP;
TRUNCATE TABLE dbo.VBRK_SPPAYM;
TRUNCATE TABLE dbo.SR01A;

DROP TABLE dbo.MARA;
DROP TABLE dbo.VBRK;
DROP TABLE dbo.VBAP;
DROP TABLE dbo.VBRK_SPPAYM;
DROP TABLE dbo.SR01A;

/* Create the following watermark metadata table in source*/

USE DATABASE sql_prod_sap_source; 

CREATE TABLE dbo.watermarktable (
    SchemaName VARCHAR(100),
    TableName VARCHAR(100),
    PK_List VARCHAR(100),
    WatermarkValue DATETIME
);

--  '2024-01-01 00:00:00'

INSERT INTO dbo.watermarktable (SchemaName, TableName, PK_List, WatermarkValue)
VALUES
('dbo' ,'MARA', 'MANDT,MATNR', '2024-01-01 00:00:00'),
('dbo' ,'VBRK', 'MANDT,VBELN', '2024-01-01 00:00:00'),
('dbo' ,'VBAP', 'MANDT,VBELN,POSNR', '2024-01-01 00:00:00'),
('dbo' ,'VBRK_SPPAYM', 'SPPAYM,SPPORD', '2024-01-01 00:00:00'),
('dbo' ,'SR01A', 'CLIENT,ARKEY', '2024-01-01 00:00:00');


SELECT * FROM dbo.watermarktable;

TRUNCATE TABLE dbo.watermarktable;

DROP TABLE dbo.watermarktable;

-- To update latest watermark value in target audit table
CREATE PROCEDURE [dbo].[usp_write_watermark]
    @SchemaName VARCHAR(100),
    @last_updated DATETIME,
    @tableName VARCHAR(100)
AS
BEGIN
    UPDATE watermarktable
    SET WatermarkValue = @last_updated
    WHERE TableName = @tableName
    AND SchemaName = @SchemaName;
END;

DROP PROCEDURE [dbo].[usp_write_watermark];