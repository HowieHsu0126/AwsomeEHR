-- 目的: 识别在ICU入住前就已接受替代性肾脏治疗（如透析）的慢性AKI患者。
-- 操作: 查询treatment表，筛选出包含特定治疗（如各种透析方式）的记录。选择独特的patientunitstayid以确定慢性AKI患者。

DROP TABLE IF EXISTS aki_rrt;

-- 创建一个视图，以识别在ICU入住前就已接受替代性肾脏治疗的慢性AKI患者
CREATE TABLE aki_rrt AS
WITH ranked_treatments AS (
    SELECT
        patientunitstayid,
        treatmentstring,
        treatmentoffset,
        ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY treatmentoffset ASC) AS row_num
    FROM eicu_crd.treatment
    WHERE
        (LOWER(treatmentstring) LIKE '%rrt%'
        OR LOWER(treatmentstring) LIKE '%dialysis%'
        OR LOWER(treatmentstring) LIKE '%ultrafiltration%'
        OR LOWER(treatmentstring) LIKE '%cavhd%'
        OR LOWER(treatmentstring) LIKE '%cvvh%'
        OR LOWER(treatmentstring) LIKE '%sled%')
        AND LOWER(treatmentstring) LIKE '%chronic%'
)
SELECT
    patientunitstayid,
    treatmentoffset
FROM
    ranked_treatments
WHERE
    row_num = 1;  -- 只选择每个患者的最早记录
