-- 04_legal_aid_category_display_order.sql
-- Reorder eligibility categories in Step 1:
-- Woman, Children, SC/ST, General, then the remaining categories.
-- Values kept in sync with the live database.

UPDATE "public"."legal_aid_category" SET "display_order" = 1 WHERE "category_code" = 'WOMAN';
UPDATE "public"."legal_aid_category" SET "display_order" = 2 WHERE "category_code" = 'CHILDREN';
UPDATE "public"."legal_aid_category" SET "display_order" = 3 WHERE "category_code" = 'SC_ST';
UPDATE "public"."legal_aid_category" SET "display_order" = 4 WHERE "category_code" = 'GENERAL';
UPDATE "public"."legal_aid_category" SET "display_order" = 5 WHERE "category_code" = 'TRAFFICKING_VICTIM';
UPDATE "public"."legal_aid_category" SET "display_order" = 6 WHERE "category_code" = 'DISABLED_PERSON';
UPDATE "public"."legal_aid_category" SET "display_order" = 7 WHERE "category_code" = 'DISASTER_VICTIM';
UPDATE "public"."legal_aid_category" SET "display_order" = 8 WHERE "category_code" = 'INDUSTRIAL_WORKMAN';
UPDATE "public"."legal_aid_category" SET "display_order" = 9 WHERE "category_code" = 'BEGGARY_VICTIM';
