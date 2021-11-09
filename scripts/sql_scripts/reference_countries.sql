-- create table script:
CREATE TABLE if not exists club_elo.reference_alpha3codes
(
	elo_alpha3 character varying(10) COLLATE pg_catalog."default",
	wy_alpha3 character varying(10) COLLATE pg_catalog."default",
	country character varying(100) COLLATE pg_catalog."default",
	CONSTRAINT reference_alpha3codes_pkey PRIMARY KEY (elo_alpha3)
);

GRANT SELECT ON TABLE club_elo.reference_alpha3codes TO aminghini;

GRANT SELECT ON TABLE club_elo.reference_alpha3codes TO emassucco;


-- this connects 34/61 elo countries, others are manually updated
-- also, MAC is North Macedonia in elo -> MAC in wyScout is Macao and MKD is Macedonia FYR (false connect)
INSERT INTO club_elo.reference_alpha3codes
WITH elo_alpha as (
	SELECT distinct country
	FROM club_elo.club_elo
)
SELECT ea.country, ar.alpha3code, ar.name
FROM elo_alpha ea
	left join "wyScout".areas ar on ar.alpha3code = ea.country
ON CONFLICT DO NOTHING;

-- manual updates:
UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'BIH'
WHERE elo_alpha3 = 'BHZ';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'BGR'
WHERE elo_alpha3 = 'BUL';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'HRV'
WHERE elo_alpha3 = 'CRO';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'DNK'
WHERE elo_alpha3 = 'DEN';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'XEN'
WHERE elo_alpha3 = 'ENG';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'FRO'
WHERE elo_alpha3 = 'FAR';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'DDR'
WHERE elo_alpha3 = 'GDR';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'DEU'
WHERE elo_alpha3 = 'GER';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'GRC'
WHERE elo_alpha3 = 'GRE';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'XKS'
WHERE elo_alpha3 = 'KOS';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'LVA'
WHERE elo_alpha3 = 'LAT';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'LTU'
WHERE elo_alpha3 = 'LIT';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'MKD'
WHERE elo_alpha3 = 'MAC';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'MNE'
WHERE elo_alpha3 = 'MNT';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'MHL'
WHERE elo_alpha3 = 'MOL';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'NLD'
WHERE elo_alpha3 = 'NED';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'XNI'
WHERE elo_alpha3 = 'NIR';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'PRT'
WHERE elo_alpha3 = 'POR';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'ROU'
WHERE elo_alpha3 = 'ROM';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'SRB'
WHERE elo_alpha3 = 'SCG';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'XSC'
WHERE elo_alpha3 = 'SCO';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'SVK'
WHERE elo_alpha3 = 'SLK';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'CHE'
WHERE elo_alpha3 = 'SUI';

UPDATE club_elo.reference_alpha3codes
SET wy_alpha3 = 'XWA'
WHERE elo_alpha3 = 'WAL';

-- get country names from wyscout-transfermarkt reference table
UPDATE club_elo.reference_alpha3codes ce
SET country = refer."Country"
FROM reference.wyscout_transfermarkt_countries refer
	join "wyScout".areas ar on ar.name = refer."WyCountry"
WHERE ce.wy_alpha3 = ar.alpha3code;

-- and add a few manually, those which don't exist in wyScout
UPDATE club_elo.reference_alpha3codes
SET country = 'CSSR'
WHERE elo_alpha3 = 'CSR';

UPDATE club_elo.reference_alpha3codes
SET country = 'West Germany'
WHERE elo_alpha3 = 'FRG';

UPDATE club_elo.reference_alpha3codes
SET country = 'DDR'
WHERE elo_alpha3 = 'GDR';

UPDATE club_elo.reference_alpha3codes
SET country = 'UdSSR'
WHERE elo_alpha3 = 'URS';

UPDATE club_elo.reference_alpha3codes
SET country = 'Yugoslavia'
WHERE elo_alpha3 = 'YUG';