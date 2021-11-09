with clubs_years_elo as (
    select distinct club, country, level, extract(year from rank_date) yr
    from club_elo.club_elo
    where extract(year from rank_date) >= 2008 and level > 0
)
, clubs_years_elo_row as (
    select club, string_agg(yr || ',' || country || "level", '|' order by yr, country, "level") str_car
    from clubs_years_elo
    group by club
)
, clubs_years_wy_unwind as (
    select distinct tm.wyid, tm.officialname, refs.club, ra.elo_alpha3 country, cp.divisionlevel "level", extract(year from sex.enddate) seasend, extract(year from sex.startdate) seasstart
    from club_elo.reference_alpha3codes ra
    join "wyScout".areas ar on ar.alpha3code = ra.wy_alpha3
    join "wyScout".team tm on tm.areaid = ar.id
    join "wyScout".competitions cp on cp.wyid = tm.competitionid
    --join club_elo.reference_competitions cr on cr.elo_alpha3 = ra.elo_aplha3 and cr.tier = cp.divisionlevel
    join "wyScout".season_extended sex on sex.wyid = tm.seasonid
    join club_elo.clubs_ref_staging_2 refs on refs.wyid = tm.wyid
    where cp.format = 'Domestic league' and cp.category = 'default' and cp.divisionlevel between 1 and 2
    and extract(year from sex.enddate) >= 2008
)
, club_names_wy as (
    select distinct wyid, max(officialname) officialname
    from clubs_years_wy_unwind
    group by wyid
)
, clubs_years_wy as (
    select distinct wyid, club, country, "level", seasend yr
        from clubs_years_wy_unwind
    union
    select distinct wyid, club, country, "level", seasstart yr
        from clubs_years_wy_unwind
    where seasstart >= 2008
)
, club_years_wy_row as (
    select wyid, string_agg(yr || ',' || country || "level", '|' order by yr, country, "level") str_car
    from clubs_years_wy
    group by wyid
)
, results as (
    select w.wyid, officialname, w.club, count(distinct (w.wyid, w.country, w."level", w.yr)) wyscout_str_len
        , count(distinct (e.club, e.country, e."level", e.yr)) elo_str_len, 
        sum(case when e.country = w.country and e."level" = w."level" and e.yr = w.yr then 1 else 0 end) matching
    from clubs_years_wy w
    join clubs_years_elo e on e.club = w.club
    join club_names_wy cn on w.wyid = cn.wyid
    group by w.wyid, officialname, w.club
    having sum(case when e.country = w.country and e."level" = w."level" and e.yr = w.yr then 1 else 0 end) != 
        least(count(distinct (w.wyid, w.country, w."level", w.yr))
        , count(distinct (e.club, e.country, e."level", e.yr)))
)
select r.*, wr.str_car wyscout_car, er.str_car elo_car 
from results r
join club_years_wy_row wr on wr.wyid = r.wyid
join clubs_years_elo_row er on er.club = r.club;