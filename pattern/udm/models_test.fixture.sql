PRAGMA foreign_keys = on; -- check foreign key reference, slightly worst performance

-- reference tables
CREATE TABLE IF NOT EXISTS "execution_context" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_role_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_relation_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_identifier_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "person_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "contact_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- content tables
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "organization_role_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN'
);
CREATE TABLE IF NOT EXISTS "party" (
    "party_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "party_type_id" TEXT NOT NULL,
    "party_name" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("code")
);
CREATE TABLE IF NOT EXISTS "party_identifier" (
    "party_identifier_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "identifier_number" TEXT NOT NULL,
    "party_identifier_type_id" TEXT NOT NULL,
    "party_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("party_identifier_type_id") REFERENCES "party_identifier_type"("code"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "person" (
    "person_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "party_id" INTEGER NOT NULL,
    "person_type_id" TEXT NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_last_name" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("person_type_id") REFERENCES "person_type"("code")
);
CREATE TABLE IF NOT EXISTS "party_relation" (
    "party_relation_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "party_id" INTEGER NOT NULL,
    "related_party_id" INTEGER NOT NULL,
    "relation_type_id" TEXT NOT NULL,
    "party_role_id" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("related_party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("relation_type_id") REFERENCES "party_relation_type"("code"),
    FOREIGN KEY("party_role_id") REFERENCES "party_role_type"("code")
);
CREATE TABLE IF NOT EXISTS "organization" (
    "organization_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "party_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "license" TEXT NOT NULL,
    "registration_date" DATE NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "organization_role" (
    "organization_role_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "person_id" INTEGER NOT NULL,
    "organization_id" INTEGER NOT NULL,
    "organization_role_type_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("organization_role_type_id")
);
CREATE TABLE IF NOT EXISTS "contact_electronic" (
    "contact_electronic_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "contact_type_id" TEXT NOT NULL,
    "party_id" INTEGER NOT NULL,
    "electronics_details" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("contact_type_id") REFERENCES "contact_type"("code"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "contact_land" (
    "contact_land_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "contact_type_id" TEXT NOT NULL,
    "party_id" INTEGER NOT NULL,
    "address_line1" TEXT NOT NULL,
    "address_line2" TEXT NOT NULL,
    "address_zip" TEXT NOT NULL,
    "address_city" TEXT NOT NULL,
    "address_state" TEXT NOT NULL,
    "address_country" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    FOREIGN KEY("contact_type_id") REFERENCES "contact_type"("code"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);

--content views
CREATE VIEW IF NOT EXISTS "vender_view"("name", "email", "address", "state", "city", "zip", "country") AS
    SELECT pr.party_name as name,
    e.electronics_details as email,
    l.address_line1 as address,
    l.address_state as state,
    l.address_city as city,
    l.address_zip as zip,
    l.address_country as country
    FROM party_relation prl
    INNER JOIN party pr ON pr.party_id = prl.party_id
    INNER JOIN contact_electronic e ON e.party_id = pr.party_id AND e.contact_type_id = 'OFFICIAL_EMAIL'
    INNER JOIN contact_land l ON l.party_id = pr.party_id AND l.contact_type_id = 'OFFICIAL_ADDRESS'
    WHERE prl.party_role_id = 'VENDOR' AND prl.relation_type_id = 'ORGANIZATION_TO_PERSON';

-- seed Data
INSERT INTO "execution_context" ("code", "value") VALUES ('PRODUCTION', 'production');
INSERT INTO "execution_context" ("code", "value") VALUES ('TEST', 'test');
INSERT INTO "execution_context" ("code", "value") VALUES ('DEVELOPMENT', 'devl');
INSERT INTO "execution_context" ("code", "value") VALUES ('SANDBOX', 'sandbox');
INSERT INTO "execution_context" ("code", "value") VALUES ('EXPERIMENTAL', 'experimental');
INSERT INTO "party_type" ("code", "value") VALUES ('PERSON', 'Person');
INSERT INTO "party_type" ("code", "value") VALUES ('ORGANIZATION', 'Organization');
INSERT INTO "party_role_type" ("code", "value") VALUES ('CUSTOMER', 'Customer');
INSERT INTO "party_role_type" ("code", "value") VALUES ('VENDOR', 'Vendor');
INSERT INTO "party_relation_type" ("code", "value") VALUES ('PERSON_TO_PERSON', 'Person To Person');
INSERT INTO "party_relation_type" ("code", "value") VALUES ('ORGANIZATION_TO_PERSON', 'Organization To Person');
INSERT INTO "party_relation_type" ("code", "value") VALUES ('ORGANIZATION_TO_ORGANIZATION', 'Organization To Organization');
INSERT INTO "party_identifier_type" ("code", "value") VALUES ('UUID', 'UUID');
INSERT INTO "party_identifier_type" ("code", "value") VALUES ('DRIVING_LICENSE', 'Driving License');
INSERT INTO "party_identifier_type" ("code", "value") VALUES ('PASSPORT', 'Passport');
INSERT INTO "person_type" ("code", "value") VALUES ('INDIVIDUAL', 'Individual');
INSERT INTO "person_type" ("code", "value") VALUES ('PROFESSIONAL', 'Professional');
INSERT INTO "contact_type" ("code", "value") VALUES ('HOME_ADDRESS', 'Home Address');
INSERT INTO "contact_type" ("code", "value") VALUES ('OFFICIAL_ADDRESS', 'Official Address');
INSERT INTO "contact_type" ("code", "value") VALUES ('MOBILE_PHONE_NUMBER', 'Mobile Phone Number');
INSERT INTO "contact_type" ("code", "value") VALUES ('LAND_PHONE_NUMBER', 'Land Phone Number');
INSERT INTO "contact_type" ("code", "value") VALUES ('OFFICIAL_EMAIL', 'Official Email');
INSERT INTO "contact_type" ("code", "value") VALUES ('PERSONAL_EMAIL', 'Personal Email');
;

-- synthetic / test data

INSERT INTO "party" ("party_type_id", "party_name", "created_by") VALUES ('PERSON', 'person', NULL);

INSERT INTO "party_identifier" ("identifier_number", "party_identifier_type_id", "party_id", "created_by") VALUES ('test identifier', 'PASSPORT', (SELECT "party_id" FROM "party" WHERE "party_type_id" = 'PERSON' AND "party_name" = 'person'), NULL);

INSERT INTO "person" ("party_id", "person_type_id", "person_first_name", "person_last_name", "created_by") VALUES ((SELECT "party_id" FROM "party" WHERE "party_type_id" = 'PERSON' AND "party_name" = 'person'), 'PROFESSIONAL', 'Test First Name', 'Test Last Name', NULL);

INSERT INTO "party_relation" ("party_id", "related_party_id", "relation_type_id", "party_role_id", "created_by") VALUES ((SELECT "party_id" FROM "party" WHERE "party_type_id" = 'PERSON' AND "party_name" = 'person'), (SELECT "party_id" FROM "party" WHERE "party_type_id" = 'PERSON' AND "party_name" = 'person'), 'ORGANIZATION_TO_PERSON', 'VENDOR', NULL);

INSERT INTO "organization" ("party_id", "name", "license", "registration_date", "created_by") VALUES ((SELECT "party_id" FROM "party" WHERE "party_type_id" = 'PERSON' AND "party_name" = 'person'), 'Test Name', 'Test License', '2023-02-06', NULL);

INSERT INTO "organization_role_type" ("code", "value", "created_by") VALUES ('ASSOCIATE_MANAGER_TECHNOLOGY', 'Associate Manager Technology', NULL);

INSERT INTO "organization_role" ("person_id", "organization_id", "organization_role_type_id", "created_by") VALUES ((SELECT "person_id" FROM "person" WHERE "person_first_name" = 'Test First Name' AND "person_last_name" = 'Test Last Name'), (SELECT "organization_id" FROM "organization" WHERE "name" = 'Test Name'), (SELECT "organization_role_type_id" FROM "organization_role_type" WHERE "code" = 'ASSOCIATE_MANAGER_TECHNOLOGY'), NULL);

INSERT INTO "contact_electronic" ("contact_type_id", "party_id", "electronics_details", "created_by") VALUES ('MOBILE_PHONE_NUMBER', (SELECT "party_id" FROM "party" WHERE "party_type_id" = 'PERSON' AND "party_name" = 'person'), 'electronics details', NULL);
