/************************************************************************
   Banco de dados: Oracle 19
   Objetivo: Gerar classe Config para EF Core Fluent API
   Versão: Entity Framework 8
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
              THEN 'SuaClasse.Max'||COLUMN_NAME||''
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
WHERE TABLE_NAME IN ('PIT_PENF_ITEM')
  AND OWNER = 'B8CT'
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
