-- create table script:
CREATE TABLE if not exists club_elo.reference_competitions
(
    competition_wyid numeric(9,0),
    elo_alpha3 character varying(10) COLLATE pg_catalog."default",
    tier integer,
	CONSTRAINT reference_competitions_pkey PRIMARY KEY (competition_wyid)
);

GRANT SELECT ON TABLE club_elo.reference_competitions TO aminghini;

GRANT SELECT ON TABLE club_elo.reference_competitions TO emassucco;


-- connects 48/56 competitions (Liechenstein + 7 former countries -> don't exist in wyscout)
-- there are 47 competitions in club_elo with level = 0, they are not considered
INSERT INTO club_elo.reference_competitions
WITH elo_comps as (
	SELECT distinct country, level
	FROM club_elo.club_elo
	WHERE level != 0
)
SELECT comp.wyid, ec.country, ec.level
FROM "wyScout".competitions comp
	join "wyScout".areas ar on ar.id = comp.areaid
	join club_elo.reference_alpha3codes rac on rac.wy_alpha3 = ar.alpha3code
	join elo_comps ec on ec.country = rac.elo_alpha3 and ec.level = comp.divisionlevel
WHERE lower(format) like '%domestic league%'
	and lower(comp.name) not similar to ('(%(u|k)\d\d%)|(%under \d\d%)|(%uncer \d\d%)|(%sub(\s|-)?\d\d%)|(%junior%)|(%youth%)|(%academy%)')
	and comp.gender = 'male'
	and comp.category = 'default'
ON CONFLICT DO NOTHING;