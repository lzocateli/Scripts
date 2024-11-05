/************************************************************************
   Banco de dados: Oracle 19
   Objetivo: Gera classe de dominio com as propriedades, constantes com 
             tamanho maximo e minimo dos campos e os metodos Define para 
             validar as propriedades do dominio.
   Versão: Entity Framework 8
*************************************************************************/
SELECT 
'public '
||
CASE
    WHEN (DATA_TYPE = 'VARCHAR2' OR DATA_TYPE = 'NVARCHAR2' OR DATA_TYPE = 'NCHAR'
       OR DATA_TYPE = 'NCLOB' OR DATA_TYPE = 'CLOB' OR DATA_TYPE = 'CHAR' 
       OR DATA_TYPE = 'ROWID' OR DATA_TYPE = 'UROWID')
      THEN 'string'
    ELSE ''
    END ||
CASE 
    WHEN (DATA_TYPE = 'NUMBER' AND DATA_LENGTH = 1 AND DATA_PRECISION is null)
      THEN 'bool'
    ELSE ''
    END ||    
CASE 
    WHEN (DATA_TYPE = 'NUMBER' AND DATA_LENGTH = 3 AND DATA_PRECISION is null)
      THEN 'byte'
    ELSE ''
    END ||    
CASE
    WHEN DATA_TYPE = 'NUMBER' AND (DATA_LENGTH <= 9 AND DATA_PRECISION is null)
      THEN 'int'    
    ELSE ''
    END ||
CASE
    WHEN DATA_TYPE = 'NUMBER' AND (DATA_LENGTH <= 18 AND DATA_PRECISION is null)
      THEN 'long'    
    ELSE ''
    END ||    
CASE
    WHEN DATA_TYPE = 'NUMBER'
      THEN 'decimal'    
    ELSE ''
    END ||
CASE
    WHEN DATA_TYPE = 'BINARY_DOUBLE'
      THEN 'double'    
    ELSE ''
    END ||
CASE 
    WHEN DATA_TYPE = 'DATE' AND NULLABLE = 'Y'
      THEN 'DateTime?'    
    ELSE ''
    END ||    
CASE 
    WHEN DATA_TYPE = 'DATE' AND NULLABLE = 'N'
      THEN 'DateTime'    
    ELSE ''
    END ||    
CASE
    WHEN DATA_TYPE = 'timestamp with time zone'
      THEN 'DateTimeOffset'    
    ELSE ''
    END ||' '||COLUMN_NAME||' { get; private set; }'
AS CLASSE
,CASE
    WHEN DATA_TYPE <> 'DATE' AND DATA_TYPE <> 'NUMBER'
      THEN 'public const int Max'||COLUMN_NAME||'='||DATA_LENGTH||';'
    ELSE ''
  END  AS ConstantesMAX
,CASE
    WHEN DATA_TYPE = 'VARCHAR2' AND NULLABLE = 'N'
      THEN 'public const int Min'||COLUMN_NAME||'='||1||';'
    ELSE 
      CASE WHEN DATA_TYPE = 'VARCHAR2' AND NULLABLE = 'Y'
        THEN 'public const int Min'||COLUMN_NAME||'='||0||';'
      END
  END  AS ConstantesMIN
,OWNER
,TABLE_NAME
,COLUMN_ID
,','||COLUMN_NAME AS COLUNAS_SELECT
,'Definir_'||COLUMN_NAME||'('||lower(COLUMN_NAME)||');' AS METODOS_CONTRUTOR
,'private void Definir_'||COLUMN_NAME||'('||
(
CASE
    WHEN (DATA_TYPE = 'VARCHAR2' OR DATA_TYPE = 'NVARCHAR2' OR DATA_TYPE = 'NCHAR'
       OR DATA_TYPE = 'NCLOB' OR DATA_TYPE = 'CLOB' OR DATA_TYPE = 'CHAR' 
       OR DATA_TYPE = 'ROWID' OR DATA_TYPE = 'UROWID')
      THEN 'string'
    ELSE ''
    END ||
CASE 
    WHEN (DATA_TYPE = 'NUMBER' AND DATA_LENGTH = 1 AND DATA_PRECISION is null)
      THEN 'bool'
    ELSE ''
    END ||    
CASE 
    WHEN (DATA_TYPE = 'NUMBER' AND DATA_LENGTH = 3 AND DATA_PRECISION is null)
      THEN 'byte'
    ELSE ''
    END ||    
CASE
    WHEN DATA_TYPE = 'NUMBER' AND (DATA_LENGTH <= 9 AND DATA_PRECISION is null)
      THEN 'int'    
    ELSE ''
    END ||
CASE
    WHEN DATA_TYPE = 'NUMBER' AND (DATA_LENGTH <= 18 AND DATA_PRECISION is null)
      THEN 'long'    
    ELSE ''
    END ||    
CASE
    WHEN DATA_TYPE = 'NUMBER'
      THEN 'decimal'    
    ELSE ''
    END ||
CASE
    WHEN DATA_TYPE = 'BINARY_DOUBLE'
      THEN 'double'    
    ELSE ''
    END ||
CASE 
    WHEN DATA_TYPE = 'DATE' AND NULLABLE = 'Y'
      THEN 'DateTime?'    
    ELSE ''
    END ||    
CASE 
    WHEN DATA_TYPE = 'DATE' AND NULLABLE = 'N'
      THEN 'DateTime'    
    ELSE ''
    END ||    
CASE
    WHEN DATA_TYPE = 'timestamp with time zone'
      THEN 'DateTimeOffset'    
    ELSE ''
    END ||''
)
||' '||lower(COLUMN_NAME)||') { '||COLUMN_NAME||' = '||lower(COLUMN_NAME)||'; }' AS METODOS_DEFINIR
,DATA_TYPE
,DATA_LENGTH
,DATA_PRECISION
,DATA_SCALE
,NULLABLE
FROM all_tab_columns
WHERE TABLE_NAME IN ('PIT_PENF_ITEM')
  AND OWNER = 'B8CT'
ORDER BY OWNER, TABLE_NAME,COLUMN_ID;
