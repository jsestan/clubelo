-- create table sql
CREATE TABLE if not exists club_elo.clubs_ref_staging
(
    wyid numeric(9,0),
    club character varying(100) COLLATE pg_catalog."default",
    country character varying(10) COLLATE pg_catalog."default",
    name character varying(100) COLLATE pg_catalog."default",
    officialname character varying(100) COLLATE pg_catalog."default",
    sim_name numeric(8,6),
    sim_official numeric(8,6),
    name_norm character varying(100) COLLATE pg_catalog."default",
    b_team integer,
    merge_stage integer,
	CONSTRAINT constraintname_clubs_ref_staging_wyid UNIQUE (wyid),
	CONSTRAINT constraintname_clubs_ref_staging_club UNIQUE (club)
);

GRANT SELECT ON TABLE club_elo.clubs_ref_staging TO aminghini;

GRANT SELECT ON TABLE club_elo.clubs_ref_staging TO emassucco;

-- procedure for manual merging
CREATE OR REPLACE PROCEDURE club_elo.init_merge_stage (
	in_wyid numeric(9,0),
	in_club character varying(100),
	in_country character varying(10), 
	in_name character varying(100), 
	in_officialname character varying(100), 
	in_b_team integer
)
language plpgsql    
as $$
BEGIN
	INSERT INTO club_elo.clubs_ref_staging (wyid, club, country, name, officialname, sim_name, sim_official, name_norm, b_team, merge_stage)
	VALUES (in_wyid, in_club, in_country, in_name, in_officialname,
		similarity(REGEXP_REPLACE(unaccent(lower(in_club)), '[^a-z0-9 ]', '', 'g'), REGEXP_REPLACE(unaccent(lower(in_name)), '[^a-z0-9 ]', '', 'g')),
		similarity(REGEXP_REPLACE(unaccent(lower(in_club)), '[^a-z0-9 ]', '', 'g'), REGEXP_REPLACE(unaccent(lower(in_officialname)), '[^a-z0-9 ]', '', 'g')),
		REGEXP_REPLACE(unaccent(lower(in_name)), '[^a-z0-9 ]', '', 'g'), in_b_team, 0)
	ON CONFLICT DO NOTHING;
	commit;
END;$$

-- first connect clubs which are otherwise falsely connected in script (this is done before staging script, so merge_stage = 0)
CALL club_elo.init_merge_stage(12511, 'AEK', 'GRE', 'AEK Athens', 'AEK Athens FC', 0);

CALL club_elo.init_merge_stage(11259, 'Bohemians Praha', 'CZE', 'Bohemians 1905', 'Bohemians 1905', 0);

CALL club_elo.init_merge_stage(677, 'Depor', 'ESP', 'Deportivo La Coruña', 'Real Club Deportivo de La Coruña', 0);

-- ...and some clubs from the big 5 associations which aren't connected at all (different country or too different name)
CALL club_elo.init_merge_stage(10529, 'Cardiff', 'ENG', 'Cardiff City', 'Cardiff City FC', 0);

CALL club_elo.init_merge_stage(1650, 'QPR', 'ENG', 'Queens Park Rangers', 'Queens Park Rangers FC', 0);
	
CALL club_elo.init_merge_stage(10531, 'Swansea', 'ENG', 'Swansea City', 'Swansea City AFC', 0);
	
CALL club_elo.init_merge_stage(19830, 'Monaco', 'FRA', 'Monaco', 'AS Monaco FC', 0);

CALL club_elo.init_merge_stage(7502, 'Aarhus', 'DEN', 'Aarhus', 'Aarhus', 0);

CALL club_elo.init_merge_stage(4507, 'Ankaraspor', 'TUR', 'Ankaraspor', 'Ankaraspor', 0);

CALL club_elo.init_merge_stage(14509, 'Arsenal Kyiv', 'UKR', 'Arsenal Kyiv', 'Arsenal Kyiv', 0);

CALL club_elo.init_merge_stage(5079, 'Bergen', 'BEL', 'Bergen', 'Bergen', 0);

CALL club_elo.init_merge_stage(14507, 'Chernomorets', 'UKR', 'Chernomorets', 'Chernomorets', 0);

CALL club_elo.init_merge_stage(14535, 'Dniprodzerzhynsk', 'UKR', 'Dniprodzerzhynsk', 'Dniprodzerzhynsk', 0);

CALL club_elo.init_merge_stage(10210, 'Dunaferr', 'HUN', 'Dunaferr', 'Dunaferr', 0);

CALL club_elo.init_merge_stage(14510, 'Ilichivets', 'UKR', 'Ilichivets', 'Ilichivets', 0);

CALL club_elo.init_merge_stage(9492, 'Istra', 'CRO', 'Istra', 'Istra', 0);

CALL club_elo.init_merge_stage(12525, 'Kalamaria', 'GRE', 'Kalamaria', 'Kalamaria', 0);

CALL club_elo.init_merge_stage(30051, 'Krumkachy', 'BLR', 'Krumkachy', 'Krumkachy', 0);

CALL club_elo.init_merge_stage(14513, 'Kryvbas', 'UKR', 'Kryvbas', 'Kryvbas', 0);

CALL club_elo.init_merge_stage(11980, 'Livar', 'SVN', 'Livar', 'Livar', 0);

CALL club_elo.init_merge_stage(13528, 'LKS', 'POL', 'LKS', 'LKS', 0);

CALL club_elo.init_merge_stage(10094, 'MTZ-RIPO', 'BLR', 'MTZ-RIPO', 'MTZ-RIPO', 0);

CALL club_elo.init_merge_stage(5120, 'St Gillis', 'BEL', 'St Gillis', 'St Gillis', 0);

CALL club_elo.init_merge_stage(11565, 'Steaua', 'ROM', 'Steaua', 'Steaua', 0);

CALL club_elo.init_merge_stage(60582, 'Varteks', 'CRO', 'Varteks', 'Varteks', 0);

CALL club_elo.init_merge_stage(14511, 'Volyn Lutsk', 'UKR', 'Volyn Lutsk', 'Volyn Lutsk', 0);

CALL club_elo.init_merge_stage(8765, 'Wattens', 'AUT', 'Wattens', 'Wattens', 0);

CALL club_elo.init_merge_stage(10086, 'Zvyazda BDU', 'BLR', 'Zvyazda BDU', 'Zvyazda BDU', 0);

-- 940 clubs from elo in range: '2007-12-01' to '2020-09-29'

-- staging: same country, divisionlevel in the same season, b_team tag
-- and (official)name similarity greater than 100/90/80/70.../30/20% (9 stages) + 7 manual -> (919/940) / remains 21 clubs

do $$
begin
	FOR i IN 0..8 LOOP
		execute(format(
			'INSERT INTO club_elo.clubs_ref_staging
			WITH merged as (
				SELECT wyid, club
				FROM club_elo.clubs_ref_staging
			)
			, elo_clubs as (
				SELECT *
				FROM club_elo.elo_clubs
				WHERE club not in (SELECT club FROM merged)
			)
			, wy_clubs as (
				SELECT *
				FROM club_elo.wy_clubs
				WHERE wyid not in (SELECT wyid FROM merged)
			)
			, distinct_wyid as (
				SELECT distinct on (wyid) wyid, club, country, name, officialname,
					similarity(ec.name_norm, wc.name_norm)::numeric(8,6) "sim_name",
					similarity(ec.name_norm, wc.officialname_norm)::numeric(8,6) "sim_official",
					wc.name_norm, ec.b_team
				FROM elo_clubs ec, wy_clubs wc
				WHERE alpha3code = wy_alpha3
					and divisionlevel = level
					and ec.b_team = wc.b_team
					and DATE_PART(''year'', rank_date - interval ''7 month'') = DATE_PART(''year'', season)
					and (similarity(ec.name_norm, wc.officialname_norm) >= (1 - %s * 0.1) or similarity(ec.name_norm, wc.name_norm) >= (1 - %s * 0.1))
				ORDER BY wyid, sim_official desc nulls last, sim_name desc nulls last
			)
			, distinct_clubs as (
				SELECT distinct on (club) wyid, club, country, name, officialname, sim_name, sim_official, name_norm, b_team, (%s + 1) merge_stage
				FROM distinct_wyid
				ORDER BY club, sim_official desc nulls last, sim_name desc nulls last
			)
			SELECT * FROM distinct_clubs
			ON CONFLICT DO NOTHING;', i, i, i));
		commit;
	end loop;
end$$;