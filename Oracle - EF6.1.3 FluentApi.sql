/************************************************************************
   Banco de dados: Oracle 12c
   Objetivo: Gerar classe Config e Entidade de Dominio
             A classe de cnfig é gerado com comandos do EF Fluent API
   Versão: Entity Framework 6.1.3
*************************************************************************/
SELECT 
'builder.Property(x => x.'||COLUMN_NAME||')'||
CASE
    WHEN DATA_TYPE = 'VARCHAR2'
      THEN '.IsUnicode(false)'
    END ||
CASE
    WHEN NULLABLE = 'N'
      THEN '.IsRequired()'
    END ||
CASE
    WHEN DATA_TYPE <> 'DATE' AND DATA_TYPE <> 'NUMBER'
      THEN '.HasMaxLength('||
      (
        CASE
            WHEN DATA_TYPE <> 'DATE' AND DATA_TYPE <> 'NUMBER'
              THEN 'SuaClasse.max'||COLUMN_NAME||''
            ELSE ''
          END 
      )||')'
    ELSE ''
 END ||';' AS FLUENT_API
,OWNER
,TABLE_NAME
,COLUMN_ID
,COLUMN_NAME
,DATA_TYPE
,DATA_LENGTH
,DATA_PRECISION
,DATA_SCALE
,NULLABLE
FROM all_tab_columns
WHERE TABLE_NAME IN ('CLIENTES')
  AND OWNER = 'B8UA'
ORDER BY OWNER, TABLE_NAME,COLUMN_ID;

/*************************************************
   GERA CLASSE DE DOMINIO OU COMMAND RESULT
*************************************************/
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
      THEN 'public const int max'||COLUMN_NAME||'='||DATA_LENGTH||';'
    ELSE ''
  END  AS ConstantesMAX
,CASE
    WHEN DATA_TYPE = 'VARCHAR2' AND NULLABLE = 'N'
      THEN 'public const int min'||COLUMN_NAME||'='||1||';'
    ELSE 
      CASE WHEN DATA_TYPE = 'VARCHAR2' AND NULLABLE = 'Y'
        THEN 'public const int min'||COLUMN_NAME||'='||0||';'
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
WHERE TABLE_NAME IN ('Clientes')
  AND OWNER = 'LZO'
ORDER BY OWNER, TABLE_NAME,COLUMN_ID;

/*********************************************
* FILHA = Sempre onde ficara o mapeamento do
* EntityFramework
*********************************************/
select 
cons.owner            as filha_owner, 
cons.table_name       as filha_table,
cons.constraint_name  as constaint_name,
cons.constraint_type  as constraint_type,
col.owner             as pai_owner, 
col.table_name        as pai_table,
col.column_name       as column_name
from dba_cons_columns col, 
     dba_constraints  cons
where cons.r_owner = col.owner
  and cons.r_constraint_name = col.constraint_name
  and cons.table_name = 'Clientes'
  and cons.owner = 'dbo'
