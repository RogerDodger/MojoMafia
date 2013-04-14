--
-- Schema for Mafia::Schema v1
-- Author: Cameron Thornton <cthor@cpan.org>
--

PRAGMA foreign_keys = ON;

CREATE TABLE users (
	id        INTEGER PRIMARY KEY,
	-- no password; using Persona
	name      VARCHAR(24) NOT NULL,
	is_admin  BOOLEAN DEFAULT 0,
	is_mod    BOOLEAN DEFAULT 0,
	active    BOOLEAN DEFAULT 1,
	token     VARCHAR(32),
	-- Game stats
	wins      INTEGER DEFAULT 0,
	losses    INTEGER DEFAULT 0,
	games     INTEGER DEFAULT 0,
	-- Timestamps
	created   TIMESTAMP,
	updated   TIMESTAMP
);

CREATE TABLE emails (
	address   VARCHAR(256) PRIMARY KEY,
	user_id   INTEGER REFERENCES users(id),
	main      BOOLEAN DEFAULT 0,
	verified  BOOLEAN DEFAULT 0,
	created   TIMESTAMP
);

-- Player roles, e.g., "Townie", "Goon", "Cop"
CREATE TABLE roles (
	id    INTEGER PRIMARY KEY,
	name  TEXT,
	type  TEXT NOT NULL CHECK(type IN ("Town", "Scum", "Other"))
);

CREATE TABLE teams (
	id    INTEGER PRIMARY KEY,
	name  TEXT,
	type  TEXT NOT NULL CHECK(type IN ("Town", "Scum", "Other"))
);

CREATE TABLE setup_role (
	role_id   INTEGER REFERENCES roles(id) ON DELETE CASCADE,
	team_id   INTEGER REFERENCES teams(id) ON DELETE CASCADE,
	pool      INTEGER,
	count     INTEGER NOT NULL,
	PRIMARY KEY (role_id, team_id, pool)
);

CREATE TABLE setups (
	id         INTEGER PRIMARY KEY,
	user_id    INTEGER REFERENCES users(id) ON DELETE SET NULL,
	title      VARCHAR(64),
	descr      VARCHAR(2048),
	allow_nk   BOOLEAN DEFAULT 1,
	allow_nv   BOOLEAN DEFAULT 1,
	day_start  BOOLEAN DEFAULT 0,
	final      BOOLEAN DEFAULT 0,
	private    BOOLEAN DEFAULT 1,
	-- Stats
	plays      INTEGER DEFAULT 0,
	-- Timestamps
	created    TIMESTAMP,
	updated    TIMESTAMP
);

CREATE TABLE games (
	id        INTEGER PRIMARY KEY,
	host_id   INTEGER REFERENCES users(id) ON DELETE SET NULL,
	setup_id  INTEGER REFERENCES setups(id),
	is_day    BOOLEAN,
	gamedate  INTEGER,
	end       TIMESTAMP,
	created   TIMESTAMP
);

CREATE TABLE players (
	id       INTEGER PRIMARY KEY,
	name     VARCHAR(16),
	user_id  INTEGER REFERENCES users(id) ON DELETE SET NULL,
	game_id  INTEGER REFERENCES games(id) ON DELETE CASCADE,
	role_id  INTEGER REFERENCES roles(id) ON DELETE RESTRICT,
	vote_id  INTEGER REFERENCES players(id) ON DELETE SET NULL,
	team_id  INTEGER REFERENCES teams(id) ON DELETE RESTRICT,
	life     INTEGER DEFAULT 1,
	UNIQUE (user_id, game_id)
);

CREATE TABLE actions (
	actor_id   INTEGER REFERENCES players(id) ON DELETE CASCADE,
	target_id  INTEGER REFERENCES players(id) ON DELETE CASCADE,
	gamedate   INTEGER,
	PRIMARY KEY (actor_id, target_id, gamedate)
);

CREATE TABLE threads (
	id       INTEGER PRIMARY KEY,
	board_id INTEGER REFERENCES boards(id) ON DELETE SET NULL,
	game_id  INTEGER REFERENCES games(id) ON DELETE CASCADE,
	title    VARCHAR(64)
);

CREATE TABLE posts (
	id        INTEGER PRIMARY KEY,
	thread_id INTEGER REFERENCES threads(id) ON DELETE CASCADE,
	user_id   INTEGER REFERENCES users(id) ON DELETE SET NULL,
	is_op     BOOLEAN DEFAULT 0,
	class     TEXT,
	plain     TEXT,
	render    TEXT,
	gamedate  INTEGER,
	created   TIMESTAMP,
	updated   TIMESTAMP
);
