create table if not exists stations (
    id integer primary key autoincrement,
    name text not null,
    position integer not null unique,
    stream_url text not null,
    image_url text,
    volume integer default 80
);

create table if not exists current_info (
    station_id integer,
    title text,
    name text
);
