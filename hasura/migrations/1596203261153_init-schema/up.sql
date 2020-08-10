CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.event (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    title name NOT NULL,
    start_date_time_utc timestamp with time zone NOT NULL,
    end_date_time_utc timestamp with time zone NOT NULL,
    is_all_day boolean,
    is_recurring boolean DEFAULT false NOT NULL,
    recurrence_pattern text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    created_by integer NOT NULL,
    status text
);
CREATE TABLE public.event_attendee (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    user_id integer NOT NULL,
    status text DEFAULT 'not-confirmed'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);
CREATE TABLE public."user" (
    id integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;
ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
ALTER TABLE ONLY public.event_attendee
    ADD CONSTRAINT event_attendees_event_id_user_id_key UNIQUE (event_id, user_id);
ALTER TABLE ONLY public.event_attendee
    ADD CONSTRAINT event_attendees_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
CREATE TRIGGER set_public_event_attendees_updated_at BEFORE UPDATE ON public.event_attendee FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_event_attendees_updated_at ON public.event_attendee IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.event_attendee
    ADD CONSTRAINT event_attendees_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.event_attendee
    ADD CONSTRAINT event_attendees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
