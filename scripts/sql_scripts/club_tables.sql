-- create tables used in merging
CREATE TABLE if not exists club_elo.elo_clubs
(
    club character varying(100) COLLATE pg_catalog."default" NOT NULL,
    country character varying(10) COLLATE pg_catalog."default" NOT NULL,
    wy_alpha3 character varying(10) COLLATE pg_catalog."default" NOT NULL,
    level integer,
    rank_date date,
    name_norm character varying(100) COLLATE pg_catalog."default" NOT NULL,
    b_team integer,
    CONSTRAINT elo_clubs_pkey PRIMARY KEY (club, country, rank_date)
);

GRANT SELECT ON TABLE club_elo.elo_clubs TO aminghini;

GRANT SELECT ON TABLE club_elo.elo_clubs TO emassucco;


CREATE TABLE if not exists club_elo.wy_clubs
(
    wyid numeric(9,0),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    officialname character varying(100) COLLATE pg_catalog."default" NOT NULL,
    alpha3code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    divisionlevel integer,
    season date,
    name_norm character varying(100) COLLATE pg_catalog."default" NOT NULL,
    officialname_norm character varying(100) COLLATE pg_catalog."default" NOT NULL,
    b_team integer,
    CONSTRAINT wy_clubs_pkey PRIMARY KEY (wyid, divisionlevel, season)
);

GRANT SELECT ON TABLE club_elo.wy_clubs TO aminghini;

GRANT SELECT ON TABLE club_elo.wy_clubs TO emassucco;


-- and fill them with data
INSERT INTO club_elo.elo_clubs
SELECT distinct club, ce.country, wy_alpha3, level, rank_date,
	REGEXP_REPLACE(unaccent(lower(club)), '[^a-z0-9 ]', '', 'g') name_norm,
	(CASE when lower(club) similar to ('(% ii)|(% b)') then 1 else 0 end) b_team
FROM club_elo.club_elo ce
	join club_elo.reference_alpha3codes refer on refer.elo_alpha3 = ce.country
WHERE rank_date = current_date
	and level != 0
ON CONFLICT DO NOTHING;


INSERT INTO club_elo.wy_clubs
SELECT distinct te.wyid, te.name, officialname, ar.alpha3code, comp.divisionlevel, se.startdate,
	REGEXP_REPLACE(unaccent(lower(te.name)), '[^a-z0-9 ]', '', 'g') name_norm,
	REGEXP_REPLACE(unaccent(lower(officialname)), '[^a-z0-9 ]', '', 'g') officialname_norm,
	(CASE when lower(te.name) similar to ('(% ii)|(% b)') then 1
		when lower(officialname) similar to ('(% ii)|(% b)') then 1 else 0 end) b_team
FROM "wyScout".team te
	join "wyScout".areas ar on ar.id = te.areaid
	join "wyScout".competitions comp on comp.wyid = te.competitionid
	join "wyScout".season_extended se on se.wyid = te.seasonid and se.competitionid = te.competitionid
WHERE lower(te.type) = 'club'
	and lower(te.category) = 'default'
	and lower(te.gender) = 'male'
	and lower(te.name) not similar to ('(%(u|k)\d\d%)|(%under \d\d%)|(%uncer \d\d%)|(%sub(\s|-)?\d\d%)|(%junior%)|(%youth%)|(%academy%)|(%reserve%)')
	and lower(officialname) not similar to ('(%(u|k)\d\d%)|(%under \d\d%)|(%uncer \d\d%)|(%sub(\s|-)?\d\d%)|(%junior%)|(%youth%)|(%academy%)|(%reserve%)')
	and (comp.divisionlevel = 1 or comp.divisionlevel = 2)
ON CONFLICT DO NOTHING;


-- adjust Lokomotiv-like names in elo tables
UPDATE club_elo.elo_clubs
SET club = 'Lokomotiv' || substring(club from 4),
	name_norm = 'lokomotiv' || substring(name_norm from 4)
WHERE lower(club) like 'lok %';

-- and b teams which don't end on 'ii' or 'b'
UPDATE club_elo.wy_clubs
SET b_team = 1
WHERE name = 'Sevilla Atlético' or name = 'Real Madrid Castilla';