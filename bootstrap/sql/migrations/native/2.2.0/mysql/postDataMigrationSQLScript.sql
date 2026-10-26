-- `tableCustomSQLQuery.operator` was seeded in #20307 but seeding only creates missing
-- definitions (EntityRepository.initializeEntity returns early once the entity exists), and the
-- 2.1.0 backfill (#33242) declared the operator present and untouched — an assumption that does
-- not hold for a definition record created from a pre-#20307 seed. Such deployments keep rendering
-- the Add Test Case form with no Operator to compare the query result to the threshold. The same
-- holds for `partitionExpression`, seeded in #22697 for Compute Row Count. Both are appended to
-- the migrated definitions, after the `thresholdUnit` the 2.1.0 script appended, so the parameter
-- order matches a fresh install except for these two trailing entries. Each statement is guarded
-- on the parameter being absent, which keeps re-runs — and every deployment that already has the
-- parameter — a no-op.
UPDATE test_definition
SET json = JSON_ARRAY_APPEND(
    json,
    '$.parameterDefinition',
    JSON_OBJECT(
        'name', 'operator',
        'displayName', 'Operator',
        'description', 'Operator to use to compare the result of the custom SQL query to the threshold.',
        'dataType', 'STRING',
        'required', false,
        'optionValues', JSON_ARRAY('==', '>', '>=', '<', '<=', '!=')
    )
)
WHERE name = 'tableCustomSQLQuery'
  AND NOT JSON_CONTAINS(
    COALESCE(JSON_EXTRACT(json, '$.parameterDefinition[*].name'), JSON_ARRAY()),
    '"operator"'
  );

UPDATE test_definition
SET json = JSON_ARRAY_APPEND(
    json,
    '$.parameterDefinition',
    JSON_OBJECT(
        'name', 'partitionExpression',
        'displayName', 'Partition Expression',
        'description', 'Partition expression that will be used to compute the passed/failed row count, if compute row count is enabled.',
        'dataType', 'STRING',
        'required', false
    )
)
WHERE name = 'tableCustomSQLQuery'
  AND NOT JSON_CONTAINS(
    COALESCE(JSON_EXTRACT(json, '$.parameterDefinition[*].name'), JSON_ARRAY()),
    '"partitionExpression"'
  );