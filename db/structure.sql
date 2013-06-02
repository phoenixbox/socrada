--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: twitter_relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE twitter_relationships (
    id integer NOT NULL,
    friends hstore,
    followers hstore,
    mutual hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    uid integer
);


--
-- Name: twitter_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE twitter_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: twitter_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE twitter_relationships_id_seq OWNED BY twitter_relationships.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    uid character varying(255),
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_image_url character varying(255),
    provider character varying(255),
    screen_name character varying(255),
    location character varying(255),
    followers_count integer,
    friends_count integer,
    statuses_count integer,
    authorizations hstore
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY twitter_relationships ALTER COLUMN id SET DEFAULT nextval('twitter_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: twitter_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY twitter_relationships
    ADD CONSTRAINT twitter_relationships_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_authorizations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_authorizations ON users USING gin (authorizations);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130529213738');

INSERT INTO schema_migrations (version) VALUES ('20130529221124');

INSERT INTO schema_migrations (version) VALUES ('20130530003320');

INSERT INTO schema_migrations (version) VALUES ('20130530020348');

INSERT INTO schema_migrations (version) VALUES ('20130530040441');

INSERT INTO schema_migrations (version) VALUES ('20130530041228');

INSERT INTO schema_migrations (version) VALUES ('20130601230946');

INSERT INTO schema_migrations (version) VALUES ('20130601231334');

INSERT INTO schema_migrations (version) VALUES ('20130601231509');

INSERT INTO schema_migrations (version) VALUES ('20130602052152');

INSERT INTO schema_migrations (version) VALUES ('20130602053145');

INSERT INTO schema_migrations (version) VALUES ('20130602060519');