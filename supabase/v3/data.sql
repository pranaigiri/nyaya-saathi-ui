SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict 18gkVSu0n2ZH0MWECMjBOjawRquZCZjwJOKq34Um6ka19WcOFWBhzWL2yKHK72p

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."custom_oauth_providers" ("id", "provider_type", "identifier", "name", "client_id", "client_secret", "acceptable_client_ids", "scopes", "pkce_enabled", "attribute_mapping", "authorization_params", "enabled", "email_optional", "issuer", "discovery_url", "skip_nonce_check", "cached_discovery", "discovery_cached_at", "authorization_url", "token_url", "userinfo_url", "jwks_uri", "created_at", "updated_at", "custom_claims_allowlist") FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at", "invite_token", "referrer", "oauth_client_state_id", "linking_target_id", "email_optional") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") FROM stdin;
00000000-0000-0000-0000-000000000000	f60352e9-33a0-40f2-98f4-b79fe2795050	authenticated	authenticated	testcitizen1@ns.com	$2a$10$9DVNY/yC3Z6xTYs2qkQXQedi9lGEbVFGAlNnc/.HA0KMILb8kzocO	2026-08-14 11:01:07.12706+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-14 11:01:07.104692+00	2026-08-14 11:01:07.12801+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	08d3a553-becb-414a-959b-b4128059f0b4	authenticated	authenticated	mangan@ns.com	$2a$10$apgTHn53D0Gywidya8KJWevgM8f7LtGlCIlUUp4N3CY4VXC4uv3/C	2026-08-12 09:10:44.893575+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:10:44.890729+00	2026-08-12 09:10:44.894224+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f5c4ef6d-632c-4c91-bfd8-944db57db1c6	authenticated	authenticated	gyalshing@ns.com	$2a$10$9Tj..bVjsVLzgbKt6aoGDeuo/65kYuUu5elhJcuCOUBm2BVgJBDh6	2026-08-12 09:10:56.125549+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:10:56.121762+00	2026-08-12 09:10:56.126149+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6903780c-c138-463e-af24-35991d1c2add	authenticated	authenticated	testcitizen2@ns.com	$2a$10$aL1MDi9Zxvfqu6M./vP2neAe8z6IUTPvgEewalGmQvhPJFlr90JQK	2026-08-14 11:01:16.975626+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-14 11:01:16.972349+00	2026-08-14 11:01:16.979048+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d47c0484-3a48-49b9-a614-7fdf92c6c980	authenticated	authenticated	pakyong@ns.com	$2a$10$HmUPP.b6HzZVVwH.rVLI5.QqxX2RatlLeIe/jtdzoEGHg0Su6KcNO	2026-08-12 09:11:09.272845+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:11:09.270292+00	2026-08-12 09:11:09.273526+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	79a64c73-e2d6-4596-ade4-18cf376b4a69	authenticated	authenticated	namchi@ns.com	$2a$10$YTQY2IeqFzJWWpanX95FtOQ2soMEioukU/cxu0mvAg1MIlQhKYbYi	2026-08-12 09:10:33.949741+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:10:33.94694+00	2026-08-12 09:10:33.950435+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	authenticated	authenticated	sikkim@ns.com	$2a$10$UopJmNpbYDibFtCGu3z7g.i2shJLKBQOwlmckHnDW3BeZQZ/weZb2	2026-08-12 09:10:05.481438+00	\N		\N		\N			\N	2026-08-16 14:03:08.374586+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:10:05.476079+00	2026-08-16 14:03:08.376792+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4a451781-317b-41b0-b7d7-b2183204febd	authenticated	authenticated	admin@ns.com	$2a$10$FBdP9DpEJny54wj84fCNlOGsBqEgXj.0ttcUZOdfzDVsDObd3bnwK	2026-08-12 07:48:05.668231+00	\N		\N		\N			\N	2026-08-16 14:30:55.119165+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 07:48:05.648359+00	2026-08-16 14:30:55.144921+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5	authenticated	authenticated	soreng@ns.com	$2a$10$cuxK03nvMIM8ZM1jVG51EOv9q75jZ272eWeQO/WHLNPmzQZ1lnjJG	2026-08-12 09:11:18.791127+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:11:18.788339+00	2026-08-12 09:11:18.791836+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	68fe332c-25a5-4d47-a713-b2aea2f06d06	authenticated	authenticated	gangtok@ns.com	$2a$10$c1ukII/AptnykZJlEOf8kegsqQjbl9RLxqo0JoxshgyCBT8sFvQqa	2026-08-12 09:10:18.603568+00	\N		\N		\N			\N	2026-08-14 10:48:39.212938+00	{"provider": "email", "providers": ["email"]}	{"email_verified": true}	\N	2026-08-12 09:10:18.60037+00	2026-08-14 10:48:39.225746+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") FROM stdin;
4a451781-317b-41b0-b7d7-b2183204febd	4a451781-317b-41b0-b7d7-b2183204febd	{"sub": "4a451781-317b-41b0-b7d7-b2183204febd", "email": "admin@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 07:48:05.660688+00	2026-08-12 07:48:05.660753+00	2026-08-12 07:48:05.660753+00	b278ffff-1a64-4b20-922f-5833a3701c2f
8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	{"sub": "8a2d51e9-dfde-477c-b8d0-3bbf449f67b3", "email": "sikkim@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:10:05.47988+00	2026-08-12 09:10:05.479923+00	2026-08-12 09:10:05.479923+00	f0ef8565-f932-4765-bf64-69f9e95c6a24
68fe332c-25a5-4d47-a713-b2aea2f06d06	68fe332c-25a5-4d47-a713-b2aea2f06d06	{"sub": "68fe332c-25a5-4d47-a713-b2aea2f06d06", "email": "gangtok@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:10:18.602024+00	2026-08-12 09:10:18.602073+00	2026-08-12 09:10:18.602073+00	60d4df4d-d081-4434-ba11-85e4d15cde72
79a64c73-e2d6-4596-ade4-18cf376b4a69	79a64c73-e2d6-4596-ade4-18cf376b4a69	{"sub": "79a64c73-e2d6-4596-ade4-18cf376b4a69", "email": "namchi@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:10:33.948296+00	2026-08-12 09:10:33.948343+00	2026-08-12 09:10:33.948343+00	7cc02b84-351c-4149-a8f0-6829e4585e21
08d3a553-becb-414a-959b-b4128059f0b4	08d3a553-becb-414a-959b-b4128059f0b4	{"sub": "08d3a553-becb-414a-959b-b4128059f0b4", "email": "mangan@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:10:44.891986+00	2026-08-12 09:10:44.892026+00	2026-08-12 09:10:44.892026+00	840b25a0-9808-49db-81b0-ce8d28896865
f5c4ef6d-632c-4c91-bfd8-944db57db1c6	f5c4ef6d-632c-4c91-bfd8-944db57db1c6	{"sub": "f5c4ef6d-632c-4c91-bfd8-944db57db1c6", "email": "gyalshing@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:10:56.124187+00	2026-08-12 09:10:56.124246+00	2026-08-12 09:10:56.124246+00	4161baae-274f-4ee8-8568-aac5cc6f135a
d47c0484-3a48-49b9-a614-7fdf92c6c980	d47c0484-3a48-49b9-a614-7fdf92c6c980	{"sub": "d47c0484-3a48-49b9-a614-7fdf92c6c980", "email": "pakyong@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:11:09.271514+00	2026-08-12 09:11:09.271562+00	2026-08-12 09:11:09.271562+00	c4ac4846-91c5-4806-b611-36605eddbeb2
ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5	ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5	{"sub": "ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5", "email": "soreng@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-12 09:11:18.7898+00	2026-08-12 09:11:18.789846+00	2026-08-12 09:11:18.789846+00	5e048df8-e3be-4d60-9dd0-c27fe63aee8a
f60352e9-33a0-40f2-98f4-b79fe2795050	f60352e9-33a0-40f2-98f4-b79fe2795050	{"sub": "f60352e9-33a0-40f2-98f4-b79fe2795050", "email": "testcitizen1@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-14 11:01:07.120549+00	2026-08-14 11:01:07.120607+00	2026-08-14 11:01:07.120607+00	e78a2093-cacf-491f-a6f2-3f855f8907a2
6903780c-c138-463e-af24-35991d1c2add	6903780c-c138-463e-af24-35991d1c2add	{"sub": "6903780c-c138-463e-af24-35991d1c2add", "email": "testcitizen2@ns.com", "email_verified": false, "phone_verified": false}	email	2026-08-14 11:01:16.974257+00	2026-08-14 11:01:16.974308+00	2026-08-14 11:01:16.974308+00	64516e1d-519b-42c8-ab23-a90eb445cd11
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."instances" ("id", "uuid", "raw_base_config", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."oauth_clients" ("id", "client_secret_hash", "registration_type", "redirect_uris", "grant_types", "client_name", "client_uri", "logo_uri", "created_at", "updated_at", "deleted_at", "client_type", "token_endpoint_auth_method") FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") FROM stdin;
ce0fb6e7-fbe3-422b-aa4c-6e0d1a7206d3	68fe332c-25a5-4d47-a713-b2aea2f06d06	2026-08-14 10:48:39.214726+00	2026-08-14 10:48:39.214726+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0	117.194.169.97	\N	\N	\N	\N	\N
2ec31328-c034-4a91-9396-408d1b302127	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	2026-08-16 14:02:22.16313+00	2026-08-16 14:02:22.16313+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0	223.181.54.211	\N	\N	\N	\N	\N
95b21658-d01e-43c2-b072-035dde6f5bf8	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	2026-08-16 14:03:08.374686+00	2026-08-16 14:03:08.374686+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0	223.181.54.211	\N	\N	\N	\N	\N
b61fa71a-3995-4744-85ab-d1a8d3cbca2a	4a451781-317b-41b0-b7d7-b2183204febd	2026-08-16 14:30:55.119858+00	2026-08-16 14:30:55.119858+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0	223.181.54.211	\N	\N	\N	\N	\N
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") FROM stdin;
ce0fb6e7-fbe3-422b-aa4c-6e0d1a7206d3	2026-08-14 10:48:39.227107+00	2026-08-14 10:48:39.227107+00	password	942a4cab-3289-4cdd-9e5e-ca74f20d8893
2ec31328-c034-4a91-9396-408d1b302127	2026-08-16 14:02:22.229358+00	2026-08-16 14:02:22.229358+00	password	0fcf93e4-14b2-4805-aa85-8c87431afc04
95b21658-d01e-43c2-b072-035dde6f5bf8	2026-08-16 14:03:08.377148+00	2026-08-16 14:03:08.377148+00	password	f28f093a-fc29-48c5-bbb9-3c4ef0bce0dd
b61fa71a-3995-4744-85ab-d1a8d3cbca2a	2026-08-16 14:30:55.148421+00	2026-08-16 14:30:55.148421+00	password	1efe733e-e358-486d-8e8b-957b985deb86
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_factors" ("id", "user_id", "friendly_name", "factor_type", "status", "created_at", "updated_at", "secret", "phone", "last_challenged_at", "web_authn_credential", "web_authn_aaguid", "last_webauthn_challenge_data") FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_challenges" ("id", "factor_id", "created_at", "verified_at", "ip_address", "otp_code", "web_authn_session_data") FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."oauth_authorizations" ("id", "authorization_id", "client_id", "user_id", "redirect_uri", "scope", "state", "resource", "code_challenge", "code_challenge_method", "response_type", "status", "authorization_code", "created_at", "expires_at", "approved_at", "nonce") FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."oauth_client_states" ("id", "provider_type", "code_verifier", "created_at") FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."oauth_consents" ("id", "user_id", "client_id", "scopes", "granted_at", "revoked_at") FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."one_time_tokens" ("id", "user_id", "token_type", "token_hash", "relates_to", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") FROM stdin;
00000000-0000-0000-0000-000000000000	2	2u5ejg6d323r	68fe332c-25a5-4d47-a713-b2aea2f06d06	f	2026-08-14 10:48:39.223136+00	2026-08-14 10:48:39.223136+00	\N	ce0fb6e7-fbe3-422b-aa4c-6e0d1a7206d3
00000000-0000-0000-0000-000000000000	3	d23fpfktcxqt	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	f	2026-08-16 14:02:22.211012+00	2026-08-16 14:02:22.211012+00	\N	2ec31328-c034-4a91-9396-408d1b302127
00000000-0000-0000-0000-000000000000	4	z3bjnp4tuvtn	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	f	2026-08-16 14:03:08.375936+00	2026-08-16 14:03:08.375936+00	\N	95b21658-d01e-43c2-b072-035dde6f5bf8
00000000-0000-0000-0000-000000000000	5	v5erjedboywc	4a451781-317b-41b0-b7d7-b2183204febd	f	2026-08-16 14:30:55.138688+00	2026-08-16 14:30:55.138688+00	\N	b61fa71a-3995-4744-85ab-d1a8d3cbca2a
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."sso_providers" ("id", "resource_id", "created_at", "updated_at", "disabled") FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."saml_providers" ("id", "sso_provider_id", "entity_id", "metadata_xml", "metadata_url", "attribute_mapping", "created_at", "updated_at", "name_id_format") FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."saml_relay_states" ("id", "sso_provider_id", "request_id", "for_email", "redirect_to", "created_at", "updated_at", "flow_state_id") FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."sso_domains" ("id", "sso_provider_id", "domain", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."webauthn_challenges" ("id", "user_id", "challenge_type", "session_data", "created_at", "expires_at") FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."webauthn_credentials" ("id", "user_id", "credential_id", "public_key", "attestation_type", "aaguid", "sign_count", "transports", "backup_eligible", "backed_up", "friendly_name", "created_at", "updated_at", "last_used_at") FROM stdin;
\.


--
-- Data for Name: state_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."state_master" ("id", "state_name", "state_code", "created_at") FROM stdin;
1ba79647-e698-4d33-8fca-2b9ae70949b5	Sikkim	SK	2026-08-12 08:05:57.480303+00
\.


--
-- Data for Name: district_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."district_master" ("id", "district_name", "district_code", "state_id", "created_at") FROM stdin;
162e0db6-feb9-44ea-9476-483c844f4956	Gangtok	GTK	1ba79647-e698-4d33-8fca-2b9ae70949b5	2026-08-12 08:05:57.480303+00
7c7faa9f-4cbb-450d-9046-15ef51430cd9	Namchi	NAM	1ba79647-e698-4d33-8fca-2b9ae70949b5	2026-08-12 08:05:57.480303+00
d434b194-4038-4342-b475-0f1ef7b44ae4	Gyalshing	GYL	1ba79647-e698-4d33-8fca-2b9ae70949b5	2026-08-12 08:05:57.480303+00
18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	Mangan	MAN	1ba79647-e698-4d33-8fca-2b9ae70949b5	2026-08-12 08:05:57.480303+00
771eac9c-c0b1-4b1b-acfa-658163c4a82f	Pakyong	PAK	1ba79647-e698-4d33-8fca-2b9ae70949b5	2026-08-12 08:05:57.480303+00
2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	Soreng	SOR	1ba79647-e698-4d33-8fca-2b9ae70949b5	2026-08-12 08:05:57.480303+00
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."profiles" ("id", "full_name", "phone_number", "email", "dob", "gender", "village_or_town", "district_id", "user_type", "status", "last_login_at", "created_at", "updated_at") FROM stdin;
4a451781-317b-41b0-b7d7-b2183204febd	SuperAdmin	\N	admin@ns.com	\N	\N	\N	\N	SUPER_ADMIN	ACTIVE	\N	2026-08-12 07:48:05.647474+00	2026-08-12 09:15:01.201769+00
08d3a553-becb-414a-959b-b4128059f0b4	DLSA Mangan	\N	mangan@ns.com	\N	\N	\N	\N	DISTRICT_ADMIN	ACTIVE	\N	2026-08-12 09:10:44.890422+00	2026-08-12 09:15:49.384959+00
68fe332c-25a5-4d47-a713-b2aea2f06d06	DLSA Gangtok	\N	gangtok@ns.com	\N	\N	\N	\N	DISTRICT_ADMIN	ACTIVE	\N	2026-08-12 09:10:18.596224+00	2026-08-12 09:15:56.241861+00
79a64c73-e2d6-4596-ade4-18cf376b4a69	DLSA Namchi	\N	namchi@ns.com	\N	\N	\N	\N	DISTRICT_ADMIN	ACTIVE	\N	2026-08-12 09:10:33.946609+00	2026-08-12 09:16:01.12726+00
8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	Sikkim SLSA	\N	sikkim@ns.com	\N	\N	\N	\N	STATE_ADMIN	ACTIVE	\N	2026-08-12 09:10:05.475778+00	2026-08-12 09:16:06.341997+00
ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5	DLSA Soreng	\N	soreng@ns.com	\N	\N	\N	\N	DISTRICT_ADMIN	ACTIVE	\N	2026-08-12 09:11:18.78804+00	2026-08-12 09:16:10.367138+00
d47c0484-3a48-49b9-a614-7fdf92c6c980	DLSA Pakyong	\N	pakyong@ns.com	\N	\N	\N	\N	DISTRICT_ADMIN	ACTIVE	\N	2026-08-12 09:11:09.269998+00	2026-08-12 09:16:14.720121+00
f5c4ef6d-632c-4c91-bfd8-944db57db1c6	DLSA Gyalshing	\N	gyalshing@ns.com	\N	\N	\N	\N	DISTRICT_ADMIN	ACTIVE	\N	2026-08-12 09:10:56.120901+00	2026-08-12 09:16:18.85816+00
f60352e9-33a0-40f2-98f4-b79fe2795050	Citizen	\N	testcitizen1@ns.com	\N	\N	\N	\N	CITIZEN	ACTIVE	\N	2026-08-14 11:01:07.102296+00	2026-08-14 11:01:07.102296+00
6903780c-c138-463e-af24-35991d1c2add	Citizen	\N	testcitizen2@ns.com	\N	\N	\N	\N	CITIZEN	ACTIVE	\N	2026-08-14 11:01:16.972059+00	2026-08-14 11:01:16.972059+00
\.


--
-- Data for Name: admin_scope; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."admin_scope" ("id", "user_id", "is_global_super_admin", "state_id", "district_id", "scope_level", "created_at") FROM stdin;
26d556c2-5328-4a72-9f58-f1d805226506	4a451781-317b-41b0-b7d7-b2183204febd	t	\N	\N	GLOBAL	2026-08-12 09:15:01.201769+00
5c160124-13e3-44db-9828-24ef0eeb3560	8a2d51e9-dfde-477c-b8d0-3bbf449f67b3	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	\N	STATE	2026-08-12 09:15:01.201769+00
1cc64ce6-7315-4fea-aab3-fd4ef4181b57	68fe332c-25a5-4d47-a713-b2aea2f06d06	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	162e0db6-feb9-44ea-9476-483c844f4956	DISTRICT	2026-08-12 09:15:01.201769+00
0bfa8043-bab4-4caa-8a5c-14d837e41399	08d3a553-becb-414a-959b-b4128059f0b4	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	DISTRICT	2026-08-12 09:15:01.201769+00
95a3d3b4-6e0b-4c50-8086-abc684f2f201	ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	DISTRICT	2026-08-12 09:15:01.201769+00
2d4109f0-9dee-4bfe-8a0f-5ca7bb0afbe9	79a64c73-e2d6-4596-ade4-18cf376b4a69	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	7c7faa9f-4cbb-450d-9046-15ef51430cd9	DISTRICT	2026-08-12 09:15:01.201769+00
d40977c4-140c-4258-8073-ddfba525cef7	d47c0484-3a48-49b9-a614-7fdf92c6c980	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	771eac9c-c0b1-4b1b-acfa-658163c4a82f	DISTRICT	2026-08-12 09:15:01.201769+00
937d3505-ab14-494d-b5a0-2606a3815ff6	f5c4ef6d-632c-4c91-bfd8-944db57db1c6	f	1ba79647-e698-4d33-8fca-2b9ae70949b5	d434b194-4038-4342-b475-0f1ef7b44ae4	DISTRICT	2026-08-12 09:15:01.201769+00
\.


--
-- Data for Name: advocate_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."advocate_master" ("id", "user_id", "full_name", "gender", "enrollment_number", "primary_email", "secondary_email", "primary_phone_number", "secondary_phone_number", "office_address", "experience_years", "is_active", "is_available_for_assignment", "created_at", "updated_at") FROM stdin;
3cc31969-af68-4be9-bc9d-8e69bd810811	\N	Shri N.B. Khatiwada, Senior Advocate	Male	W/F/367/362/84	nbkhatiwada@gmail.com	\N	9434031910	\N	\N	20	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
47e0c7b9-eb0e-43ee-9776-89d161a02aec	\N	Shri A.K.Upadhayaya,Senior Advocate	Male	45/1978	akupadhyaya1952@gmail.com	\N	9832040696	\N	\N	20	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
365e9eca-06b6-4cd8-85dc-bfd96a013bad	\N	Shri Narendra Rai,Senior Advocate	Male	F/102/99/88	narendraraiadv@yahoo.co.in	\N	9434103497	\N	\N	20	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
71fce84b-4ac1-42b6-868d-b2448a8109d6	\N	Dr Doma T Bhutia, Senior Advocate	Female	TEMP/4/REG	domabhutia_gen@slsa.gov.in	\N	9000000004	\N	\N	20	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
4be9c9ee-bdfc-4284-a85e-9f11e7c36e65	\N	Mr. S.S Hamal,Senior Advocate	Male	SI62/157/88	hamalss@sify.com	\N	9832037913	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
9a69156c-e8fe-4499-8dcc-0220163e4a2f	\N	Mr. Jorgay Namka,Senior Advocate	Male	D/1365/2000	jorgaynamka@gmail.com	\N	9733018131	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
2f4fad71-8c19-4fef-9fec-f7ecf2334937	\N	Mr. Rajendra Upreti	Male	F/430/826/97	rajenupreti.adv@gmail.com	\N	9434109747	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a8ddba32-ba22-4c8b-8a0a-b77ca8c56b9e	\N	Mr. B.K Gupta	Male	F/54/57/1996	laxmisikkim@gmail.com	\N	943463112	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c416cbe7-0df7-4ced-ae54-485745b1f983	\N	Ms. Laxmi Chakraborty	Female	F/1880/1989 of 1995	bkgupta22@ymail.com	\N	9832005585	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
71ab48ae-0765-4462-9b13-185ffd482323	\N	Mr. Umesh Ranpal	Male	516 (B)/1996	umeshr_skm@yahoo.com	\N	9434117185	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
f94da927-1386-41ae-ab23-5be9a6e57348	\N	Mr. J.K.P Jaiswal	Male	F/1421/1525 of 2000	jk_jaiswal@yahoo.in	\N	9832039371	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
129b3db0-3889-46d7-bf7b-0b4dc5892446	\N	Mr. Devi Prasad Sharma	Male	WB/1476/2001	acharyadeviprasad15@gmail.com	\N	9832089946	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a6420833-f7d1-4ffe-999f-154933c96d58	\N	Mr. B.C Tamang	Male	926/910/2000	tamangbidya@yahoo.com	\N	9641832210	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ce44b191-b634-43ca-b9a2-57de646c1199	\N	Ms. Kessang Diki Bhutia	Female	1088/1015/2001	kissushanaz@yahoo.com	\N	9593676747	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
4bb8be65-61b4-457b-b803-8ea7982f579c	\N	Mr. Tempo Gyatso Bhutia	Male	15909/T/152	tgbhutia@yahoo.com	\N	8145003501	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e1aea0f2-32b5-4b07-995d-e2e60397d2e7	\N	Mr. R.C Sharma	Male	F/1669/2003	advocatercsharma@gmail.com	\N	9832052387	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
52a891d6-19c2-4012-92b7-9aa8e85a229b	\N	Mr. Sunil Baraily	Male	WB/699/2003	sunilbaraily@gmail.com	\N	7063679750	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
743a1a8b-5df8-4c86-a0c3-71340d53f7c9	\N	Mr. Leada Tshering	Male	WB/428/2004	leadaadv@gmail.com	\N	9832331806	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0d1ec98f-2081-46a4-b056-741832a3bf5d	\N	Mr. Kharga Bahadur Chettri	Male	270/310/2003	kaydeellb@gmail.com	\N	9832075869	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
01459d67-7440-4504-aa92-e9817b1ef0f9	\N	Mr. Ashok Pradhan-I	Male	WB/366/2005	ashokadvocate2014@gmail.com	\N	9434448022	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
30600c29-ff94-4063-a58f-16a8cabcbf18	\N	Mr. Umesh Pradhan	Male	F/1252/1230/2000	umeshpradhan@gmail.com	\N	9832370027	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ce28cd72-4827-401c-acbd-63bb8546c8ab	\N	Mr. Tashi Rapten Barfungpa	Male	D/1838/2002	trbarfungpa@gmail.com	\N	9933796599	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7b887b9f-0053-407a-bfe6-9cbc604e6dfb	\N	Mr. Ashok Pradhan-II	Male	F/329/2005	pradhanashok466@gmail.com	\N	9775960726	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5dddbef4-c331-4079-9811-d1f9c67532ff	\N	Ms. Kamala Giri	Female	F/101/2004	kamalagiri213@yahoo.com	\N	7063848938	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
4ba0e616-c860-441f-98d0-ec922e30e94c	\N	Mr. Laxuman Gurung	Male	318/2005	lgurung_33@yahoo.co.in	\N	9733049641	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
8c2d2159-6311-4767-96ff-6b081f848790	\N	Mr. Nima Tshering Sherpa	Male	F/627/578/2005	vida_lama@yahoo.com	\N	9733171595	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
45006a5e-b692-4384-ad8c-d19774b8332a	\N	Mr. Dik Kumar Siwakoti	Male	932 of 2005-06	siwakoti2@gmail.com	\N	9474526665	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a7a23a34-95b7-45e3-b4ba-83c818bb9845	\N	Ms. Navtara Sarda	Female	KAR/490/01(020)2001	navsasarda@gmail.com	\N	8145885717	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e09be191-c4ed-46cd-baf8-ddbfbc8c3795	\N	Mr. Tshewang Namgyal Bhutia	Male	F-1139/442/2005	tsewangnamgyal1977@gmail.com	\N	8373873815	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
760af78b-cb95-4979-a68a-945a6259d824	\N	Mr. Umesh Gurung	Male	F-1032/2004	umeshgurung1979@gmail.com	\N	9832070862	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
8f7becf8-46c3-4ad8-8066-a555e3aa741a	\N	Mr. Tashi Wongdi Bhutia	Male	F/167/2007	tbhutia26@yahoo.in	\N	9733250381	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5a3f8477-27f7-41d2-a450-c91ff35b6129	\N	Mr. Ranjan Chettri	Male	F/166/2007	ranjangtk21@yahoo.com	\N	9832304749	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b26940f6-600e-42a6-8c21-cdbcbfaa9f31	\N	Mr. Bhusan Nepal	Male	F/328/2005	bhusanadv@gmail.com	\N	9733304034	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5917a59c-be5e-4b0d-81f3-fb3f3a35e8d8	\N	Ms. Sabina Gurung	Female	F/636/2005	gurungsabina@hotmail.com	\N	9832377578	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
192d6451-4aa3-467b-85d1-df0a945504ae	\N	Ms. Prarthana Ghataney	Female	333/2006	prarthanaghataney@gmail.com	\N	9832304620	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b457a954-d9fa-4fc9-a4a5-e947c5e56b52	\N	Ms. Ranjeeta Kumari	Female	F/474/2006	ranjeetakmr@gmail.com	\N	9832005712	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
249f2753-af1a-47af-9637-66b345d862bf	\N	Ms. Zola Megi	Female	348/2008	zolamegi30@gmail.com	\N	9734190663	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
31f20f6e-ad1a-47c9-9155-1590bd8426ff	\N	Mr. L.B Gurung	Male	WB/306/2005	lbgurung111@gmail.com	\N	8967954848	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a24dda9a-c186-44f0-a9a1-0844bef8adf8	\N	Mr. Manish Kumar Jain	Male	378/2008	manishadv2008@gmail.com	\N	9734914769	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
6c2b9354-df63-433a-942e-4d83ba1107cb	\N	Mr. Gulshan Lama	Male	616/527/2006	reyanshtamang@yahoo.com	\N	9932240862	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
bfe83cda-4e4e-404b-9f2c-c1609677a522	\N	Mr. Ramesh Sharma	Male	WB/1177/2002	rsadv0926@gmail.com	\N	8768976199	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c8552373-0e18-488c-ac5c-18ea669797a7	\N	Mr. Deven Rai	Male	390/2008	dvr1316@yahoo.com	\N	9832611429	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e981d992-17c6-400a-8415-3808d4791b9a	\N	Ms. Pritima Sunam	Female	1594/2007	pritilibran@gmail.com	\N	9832368908	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
216e4773-084e-43cb-bcb9-e15765bc80b4	\N	Mr. Vivek Anand Basnett	Male	183/2008	basnetvivek9@gmail.com	\N	9475583657	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0a2aaf01-e97b-4a81-9a78-038a245bd591	\N	Ms. Yashoda Rai	Female	350/2009	yasodha_rai@yahoo.co.in	\N	9832029418	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e364a60d-225f-4659-b102-ee7fb4524576	\N	Ms. Phichim Bhutia	Female	2270/2010-11	phichimbhutia@gmail.com	\N	9733366239	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
8324444d-8abb-4481-81d8-f8975508a8d0	\N	Mr. Pema Ongchu Bhutia	Male	820/2010	pemaongchu26@gmail.com	\N	9593387318	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
775931d3-7d51-4b50-a6f2-83035b67e981	\N	Ms. Bimla Chettri	Female	934/2010	Bimlachettri2020@gmail.com	\N	9593278452	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7b644435-39b4-456a-8344-63e0b3703b2a	\N	Ms. Januka Sharma	Female	728/2009	janukasharma024@gmail.com	\N	9641720865	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
72865741-f50b-4909-8fe2-d100c8f2c190	\N	Mr. Sushant Subba	Male	1208/2011	subba13@gmail.com	\N	9635145055	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0ab123d9-2981-461f-8cc8-7b99d3d728b3	\N	Mr. Sudhir Prasad	Male	172/2011	sudhirprasadtna@gmail.com	\N	8972003358	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
cdf38621-a2ad-45ed-bb62-be290918401f	\N	Mr. Durga Prasad Luitel	Male	1659/2010	Sharmadurga83@yahoo.in	\N	9647873523	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7c4e4213-1b45-4126-b738-432095f1ab68	\N	Mr. Madan Kumar Sundas	Male	1216/2011	m2sundas@yahoo.com	\N	977598110	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0fcf4042-9c6c-4bad-a876-2f2ae74b916e	\N	Ms. Renuka Lohar	Female	1125/2011	renukaloharskm@gmail.com	\N	7407242982	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
2ad8fc0d-3116-4a33-b677-08526310ee66	\N	Ms. Pinku Subba	Female	1123/2011	pnkksubba16@gmail.com	\N	9593773794	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
3eb732ee-305f-4262-937d-00d1ade93ffe	\N	Mr. Chewang Norbu Bhutia	Male	1554/2011	chewang.6@gmail.com	\N	8918631290	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b75e621a-cc77-4150-9589-cd9d9835b4b5	\N	Ms. Tengop Subba	Female	1279/2012	tengopsubba@gmail.com	\N	8145011268	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
33f403cb-9ac5-411e-8bff-40c6f1804e25	\N	Ms. Gita Bista	Female	F/635/2005	bistagita1@gmail.com	\N	6297540306	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e958e42a-2fef-4ecb-ad22-ec00c5a84609	\N	Mr. Girmey Bhutia	Male	1688/2012-13	bhutiagirmey@gmail.com	\N	9775847161	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b218d666-d6f8-4b3b-ad08-12299ee7b4da	\N	Ms. Sashi Rai	Female	988/2012	sashirai009@gmail.com	\N	9775995670	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
91af4a2c-533e-4e91-9751-0ba012d63901	\N	Mr. Dewen Sharma Luitel	Male	623/2012	newedz@gmail.com	\N	9679907671	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7e9e7290-88d8-4160-b333-bcd2f280cbf4	\N	Mr. Rewat Pradhan	Male	1452/2010	rewatpradhan84@gmail.com	\N	9932637388	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
383e6c0a-0f9e-4ccf-923b-9369f4d1f8f3	\N	Ms. Chandrika Maya Karki	Female	563/2010	chandrikakarki@yahoo.co.in	\N	9775914829	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e97e137b-fb9a-4190-a702-791a4799da95	\N	Ms. Bhawana Chettri	Female	628/2014	bhawanachhetri1991@gmail.com	\N	7908106153	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
6f949782-cae9-4a0d-83ca-e22f275fd298	\N	Ms. Tshering Palmoo Bhutia	Female	1303/2012	tshering28@gmail.com	\N	7557821186	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c2224fe5-1990-4c40-a7e9-c0292c7a139a	\N	Mr. Bidur Renzyong Lepcha	Male	144/2013	punol.lepcha@yahoo.com	\N	967171595	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e62b226d-5c6a-48c9-bfb6-35e32ffacd22	\N	Ms. Beena Rai	Female	1471/2013	beena_rai89@yahoo.com	\N	7548998238	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
18130a28-381f-44b3-b5a7-db1f6bf23b24	\N	Ms. Roshni Chettri	Female	1629/2011	ros_ni11@yahoo.com	\N	9609010179	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7d6d13e6-dbf0-4e1f-9e9b-a3b86f9e9855	\N	Mr. Sunil Rai	Male	743/2014	raisunil824@gmail.com	\N	8348275022	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
bf12131d-e7a0-4673-ad25-73d8bd12fbb2	\N	Ms. Samita Gurung	Female	391/2014	gurungsamita@gmail.com	\N	8768926702	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
6c83dc20-86ce-4a4e-a0e8-fba088d23b8c	\N	Ms. Sachina P.Y Subba	Female	D/3444/2004	subbasachina8@gmail.com	\N	6297540306	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
9075d78d-cf57-47ba-b808-4d247ca0af20	\N	Mr. Passang Tshering Bhutia	Male	596/2014	bpassang12@gmail.com	\N	9563107631	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
23eba25f-a8f8-4922-9847-e309eef00035	\N	Ms. Monika Rai	Female	930/2010	raimonika382@gmail.com	\N	7407381060	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c67957aa-38a9-4895-a554-b57f134cf420	\N	Mr. Deepen Pradhan	Male	746/2010	deepenpradhan308@gmail.com	\N	9609863673	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0580a207-9583-45bc-9210-983c482d49f1	\N	Mr. Loknath Khanal	Male	750/2013	khanalloknath6@gmail.com	\N	9832414153	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c664bc2b-b36a-4744-a582-46bbc709ec13	\N	Mr. Thupden Yongda	Male	2960/2008	thupden@gmail.com	\N	9832089999	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ac9545da-d7c7-4836-b959-84c36e81f618	\N	Ms. Phu Doma Bhutia	Female	769/2014	phudomabhutia88@gmail.com	\N	9593746237	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
dd56e08a-bb7c-48c8-9105-9e02a164ad46	\N	Ms. Malati Sharma	Female	285/2014	malatisharma20@gmail.com	\N	7908332007	\N	\N	9	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7343470c-5155-454c-8e55-a364a8d5e36d	\N	Mr. Yozan Rai	Male	145/2019	advocateyozan@gmail.com	\N	8391911267	\N	\N	6	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
29e5481a-fff3-4678-9fd7-65906d2a5efc	\N	Mr. Nima Wongdi Lepcha	Male	769/2013	wongdinema@gmail.com	\N	9609984074	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
af24afbc-9c73-4062-9356-9c9c4288fe02	\N	Mr. Ranjit Prasad	Male	924/2010	ranjitprasadlaw@gmail.com	\N	9647852399	\N	\N	14	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
fda0c4e6-d653-49e2-9052-ba2b10a38669	\N	Mr. Sishir Mothay	Male	713/2013	mothaysishir25@gmail.com	\N	8906347205	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ec0823bf-6210-4982-ab1a-68275260af3f	\N	Mr. Hem Lall Manger	Male	1055/2017	hemlalmanger93@gmail.com	\N	7551845308	\N	\N	7	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
2b5c284d-b589-4f31-9298-14b9ebfab138	\N	Mr. Sangay Gyurmay Bhutia	Male	D/1626/2008	sangaygolok@gmail.com	\N	7602527538	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
f4b5a16e-43cb-4f8b-b565-6aebaed71cf1	\N	Mr. Sonam Bhutia	Male	618/2012	sonamadv@gmail.com	\N	9593985582	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1289c18b-2ef8-46f1-9b8f-722608dcace3	\N	Ms. Jyoti Pradhan	Female	F 430/274 of 2014	jyotipradhan27@yahoo.com	\N	9733443334	\N	\N	9	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d3c4213d-8732-49c1-a40d-f8384015218d	\N	Mr. M.N. Dhungel	Male	1467/2010	mndhungel2015@gmail.com	\N	7679533520	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5d6e5023-6ae2-4217-ac03-585fa24fc0e5	\N	Mr. Sajal Sharma	Male	D/4219/2016	sharmasajal21@gmail.com	\N	8372970487	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
501625d4-d369-4723-bb15-0aeba6320706	\N	Mr. Safal Sharma	Male	UK/392/2007	safalsharma970@gmail.com	\N	8918408203	\N	\N	6	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
fb1c8e4a-dbd2-4aca-ae49-4568b831e7e1	\N	Mr. Vedant Rai	Male	F-1797/03	rai.vedant26@gmail.com	\N	9733051864	\N	\N	19	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
3f74e2dc-3018-4938-b863-2d0779bf92cb	\N	Ms. Mingma Lhamu Sherpa - I	Female	769/2014_ALT	mingalhamu12@gmail.com	\N	7583900316	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
71b69a3d-8769-4e2b-bf9d-2e6aaac873c2	\N	Mr. Dechen Wangdi Lachungpa	Male	1084/ 2016	dechenwangdi@hotmail.com	\N	7478569541	\N	\N	9	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
7d6c25a4-520e-4588-bd47-5073ea02cf94	\N	Ms. Ashmeeta Rai	Female	745/2022	ashmeetarai_gen@slsa.gov.in	\N	7076109193	\N	\N	3	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e9bee74e-69b4-4031-ada2-dc1f2fda8856	\N	Mr. Tree Ranta Rai	Male	1403/2019	dhiwatpang511@gmail.com	\N	9064526103	\N	\N	6	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1e0db796-ff41-4f62-98ed-b7521073d660	\N	Ms. Tara Devi Chettri	Female	449/2021	Tarachettri587@gmail.com	\N	8250751210	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b5642866-54dc-4a17-a511-956d3eb5d82b	\N	Mr. Pradeep Tamang	Male	1072/2020	pradeepgyabak@gmail.com	\N	8391903204	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
3b935a8d-d1ae-4def-9557-1c7c8c5940a7	\N	Mr. Varun Pardhan	Male	993/2018	varunpradhan_gen@slsa.gov.in	\N	9123001206	\N	\N	6	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
729263a5-e525-4eca-965a-10bc3bbda6e4	\N	Mr. Jit Bahadur Chettri	Male	489/2021	jitchettri_gen@slsa.gov.in	\N	7876616609	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
232de221-2305-4521-818f-f511734f0765	\N	Mr. Avinash Dewan	Male	D/1401/2021	Akakuba26@gmail.com	\N	7042315496	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
eac2de39-3571-493b-966d-66f015eea38c	\N	Ms. Rinchen Ongmu Bhutia	Female	2378/2023	rinchen_bhutia@gmail.com	\N	8001949434	\N	\N	2	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e78365da-a472-4995-bc8d-aa361365a95f	\N	Mr. Pradeep Sharma	Male	1385/2019	Pradipsharma5215@gmail.com	\N	88944822950	\N	\N	6	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
28be4e46-04bf-4aae-b676-4b678d9b5ae7	\N	Ms. Yozna Shanker	Female	565/2024	Yoznashanker07@gmaile.com	\N	8348148693	\N	\N	9	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
14851c75-4f6e-49fb-a4f2-470646c877a3	\N	Ms. Songmith Leezum Lepcha	Female	1277/2027	Songmithlepcha7@gmail.com	\N	9679172094	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d41942db-a78a-4818-b846-d6bf112403f0	\N	Ms. Binu Rai	Female	625/2015	binurai_gen@slsa.gov.in	\N	9000000104	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
957ba8a5-2612-47d3-998b-725c728b285c	\N	Mr. Anirudh Gupta	Male	781/2022	Anirudhgupta2403@gmail.com	\N	825007830	\N	\N	3	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
eb0b7646-2cf2-485a-b2b5-a5787b1a792c	\N	Mr. Abhinav Kant Jha	Male	BR/1362/2021	abhinavlegals@gmail.com	\N	8078653189	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
09b035a7-a012-4d86-aecb-3bf4652d482c	\N	Ms. Sunita Lamichaney	Female	267/173/2006	Suneezool123@gmail.com	\N	8250237261	\N	\N	3	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
24b026ec-f83f-47cb-b1fa-61c7b53b7f1e	\N	Ms. Devika Tamang	Female	1586/2006-2007	bhivanhomestay@gmail.com	\N	9832370771	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
94174336-97cc-4af6-8fd3-eec6245fea83	\N	Mr. Dipendra Chettri	Male	531/2020	dipendrachettri_gen@slsa.gov.in	\N	9735833367	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d6c86a70-8535-4125-b977-57ae2b0cf6d8	\N	Mr. Romit Gurung	Male	1305/2027	Romitgurung8@gmail.com	\N	7602540042	7719147939	\N	7	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ae483326-e09a-49de-9eeb-6d43afd1b1f3	\N	Mr. Lekden Thondup Basi	Male	d/1020/2021	lekdenbasi@gmail.com	\N	7908150538	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0205ca0a-ae6e-4251-b280-9b1c4fd47a51	\N	Mr. Udai Kunwar	Male	873/2020	Udaikunwar121@gmail.com	\N	8250910647	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
2acdccf4-99fc-4b14-be90-66555fec0585	\N	Ms. Nirmala Nerola	Female	F/1111/1300/2021	nnerola@gmail.com	\N	8250527569	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a5f08483-0e2d-4f8e-af80-401c19be3e6a	\N	Ms. Preeti Basnett	Female	f/3820/3224/2021	preetibasnett@gmail.com	\N	8240302731	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
dcded46c-c064-4311-b8ee-97f988885275	\N	Mr. Amitabh Shankar	Male	7375/1999	amitabhsrai@gmail.com	\N	8167743743	9434184460	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c5948df5-0515-4eeb-bb58-2e6ff19edee1	\N	Mr. Prabhat Rai	Male	UP07337/2000	prabhatrai@rediffmail.com	\N	7063063827	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e57a0f2f-449a-4979-827d-93110aa4ecb5	\N	Ms. Prasunna Sharma	Female	F/1073/2004	prasunasharma6688@gmail.com	\N	9775901273	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
6eb277ca-5443-4f46-b9be-c29892f65f34	\N	Mr. Kumar Sharma	Male	2329/2005	kumarsharma59@yahoo.com	\N	9434487904	9635177029	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
856f1190-9334-4e8b-a114-a30cd7ed6303	\N	Mr. Bhupendra Giri	Male	WB/364/2005	giribhupendra45@yahoo.in	\N	9733147436	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d7ea0389-65ee-47b3-8710-7d843b1aebfa	\N	Mr. Prasun Adhikari	Male	911/2004-05	prasunadhikari007@gmail.com	\N	9775992242	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5d4cf8cb-57fc-4a49-8d05-470de6b92617	\N	Mr. Anjan Sharma	Male	WB/814/06	Sharmaanjan1982@gmail.com	\N	9933490695	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
506a1e45-98dd-4bdf-ad98-9e28dee1043c	\N	Ms. Yangzee Pinasha	Female	1221/2007	ypadvocate13@gmail.com	\N	9609935908	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d5f11d17-5d0e-4b91-a8c7-3b35ff5500c5	\N	Mr. Pema Tamang	Male	374/2008	tmpema@yahoo.in	\N	9832539518	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ff3996d2-ab6e-4444-a557-c785c68cbe97	\N	Ms. Geeta Subba	Female	1590/2006-07	geetapandhak@gmail.com	\N	9733161205	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
4515f1d2-dd05-4d02-9aec-ef554624fd49	\N	Ms. Sushila Thapa	Female	301/2009	thapasushila678@gmail.com	\N	9775972474	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
548bfa56-84cb-4ad3-97a1-a661cda4ffd0	\N	Ms. Pabitra Pradhan	Female	315/2009	pabitradhan09@gmail.com	\N	9734980062	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
abbec3f8-52ef-4264-a5c5-7e34ef51a55a	\N	Mr. Vivek Chandra Rai	Male	345/2009	vivekchandrar@yahoo.com	\N	9749598974	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
9871a0d7-91fc-4ade-9762-0848f36ba322	\N	Mr. Raj Kumar Chettri	Male	1585/2006-07	Rajkumarchettri35@yahoo.in	\N	9647569948	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b343613e-76d1-41b0-8ec4-6adda5d58bc8	\N	Ms. Doma Devi Sharma	Female	938/2010	prabitasharma92@yahoo.com	\N	9635289509	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
52897e4b-6561-4600-93bb-d76e896b3cda	\N	Mr. Nirmal Kumar Bardewa	Male	1047/2013	nirmalinchrist@yahoo.com	\N	7407178524	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
9548f89b-a2c9-421a-98ad-daa9d9fd2183	\N	Mr. Bhim Shankar Pradhan	Male	781/2013	pradhanbhim06@gmail.com	\N	7098988055	\N	\N	11	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a585da07-09e6-4c76-9779-6f69937d5d9b	\N	Mr. Sonam Jigmee Bhutia	Male	1231/2012	sonamjigmebhutia@gmail.com	\N	9647222207	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1a7078bd-d10a-49eb-b768-abd31a651bf1	\N	Ms. Janu Tamang	Female	1819/2013-14	janutamang@yahoo.com	\N	8145603895	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
18e154b7-afb5-41fc-8513-33d5f57346ef	\N	Ms. Aita Rani Subba	Female	903/2012	chukshi@gmail.com	\N	9775901146	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0a678b26-52c5-48c8-88a8-86f5aeb48c73	\N	Ms. Kesang Doma Bhutia	Female	1041 of 2014-15	ksangdee@gmail.com	\N	9382196537	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b46940c9-5aa0-4fa4-b6d4-fd0c16206c03	\N	Mr. Dilli Bdr. Pradhan	Male	1083 of 2017	dillib.pradhan03@gmail.com	\N	9382136403	9735370797	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
92508178-5a0d-41d2-8e88-d2e77d29c5fa	\N	Ms. Reshma Tewari	Female	1220 of 2011	reshmatewari83@gmail.com	\N	8768553722	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
adf0f298-eee7-446d-b6a2-63b27527e69c	\N	Ms. Tulasha Sharma	Female	1319 of 2018	tulashakabir96@gmail.com	\N	9647724315	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0c725ba4-2c47-448f-b156-1970047664d7	\N	Ms. Choki Sherpa	Female	1286/2004	choki54sherpa@gmail.com	\N	9593382954	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
29560d25-ccb0-4fce-ba0a-289c40fc940f	\N	Ms. Unisha Pradhan	Female	292 of 2015	pradhanunisha0@gmail.com	\N	8001404580	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
156e9966-f359-4f51-9a4b-f6c9fb8e12b2	\N	Ms. Chenga Doma Bhutia	Female	1086/2008	chengadoma@yahoo.com	\N	7797893437	9735955001	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
754bf6e3-e2cd-4caa-896b-dfdd66e8f4c6	\N	Ms. Sonam Phuti Bhutia	Female	629 of 2012	sonam.pbhutia@gmail.com	\N	8670500000	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
01f92d6e-8b2e-4587-9fc0-4716a1d0ab87	\N	Ms. Slomita Rai	Female	D/1428/2017	slomila90@gmail.com	\N	8375895932	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d9303d66-90a4-4885-9dd1-65b1dda7b4af	\N	Ms. Nim Phuti Sherpa	Female	F 687/541 of 2005	nimphuti80@gmail.com	\N	9434488558	8250027206	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1d955daf-831d-44d2-9f1e-8e31fb3c24fd	\N	Mr. Singhi Dadul Lachungpa	Male	D/6032/2018	singhilachungpa@gmail.com	\N	9832105709	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1734c51d-0a3d-46e3-9873-ddad0fc3d5f2	\N	Ms. Marina Rai	Female	466/2022	iammsrinarai@gmail.com	\N	7428852032	\N	\N	3	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
43ea5784-4f73-4c88-8296-1fdb8ed035a7	\N	Ms. Puja Lamichaney	Female	WB/828/2006	mailmychamber@gmail.com	\N	9775915626	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
15efb1d0-6cc0-456b-91da-3e4774eb822c	\N	Mr. Bikash Gurung	Male	1431/2007	gurungb506@gmail.com	\N	8597772341	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
52424eb8-af69-4612-be06-9d6ca3aed0e4	\N	Ms. Rekha Subba	Female	366/2008	nanumanisamma22@gmail.com	\N	9609853570	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
44745f9e-8523-41a6-8447-3e3e410f95af	\N	Mr. Pujan Chettri Kharga	Male	3221/2010	pujankharka@gmail.com	\N	9735088200	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
99945423-f6a3-4473-843d-86e4e087f72d	\N	Mr. Karma Bhutia	Male	798/2013	karmabhutia23@gmail.com	\N	7063150182	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
43043778-16a6-4c02-af0a-33c96ca0bd58	\N	Ms. Sita Kumari Chettri	Female	848/2014	chettrisita10@gmail.com	\N	7407700090	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
0f34ca16-1d4f-47b6-af0f-241bd6ef517d	\N	Ms. Binita Karki	Female	1741/2013-14	binitakarki07@gmail.com	\N	9593283657	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e348aa85-a0d6-4640-bdd3-37eb2f6cf5a5	\N	Ms. Sashi Pradhan	Female	819/2014	sassiepradhan1990@gmail.com	\N	9083099244	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
eddd64bf-c286-47da-a59e-57b8f6ce821a	\N	Ms. Aita Hangma Limboo	Female	1121/2015	aitahangmalimboo@gmail.com	\N	8001632305	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ab2ee49f-82d3-402d-9cc0-31fc0691c9af	\N	Ms. Anug Rai	Female	1011/2016	raianug8@gmail.com	\N	9733438775	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
c326bc7b-cc25-4f3d-9b0d-b694cc59b776	\N	Mr. Karma Dechen Bhutia	Male	1245/2011	mrkdbhutia@gmail.com	\N	9609964700	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
f163011a-d0c8-413a-99da-56a4c841afcf	\N	Ms. Sun Maya Subba	Female	824/2012	sonutamling120418@gmail.com	\N	9609867340	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
da531982-fb02-458f-beb6-0b1bdbfe2899	\N	Ms. Rachana Rai	Female	875 of 2015	julurai1114@gmail.com	\N	8159081168	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e7ad8118-6719-4929-8d0e-6ca74f4a2cc6	\N	Ms. Pema Dechen Bhutia	Female	737 of 2018	pemad1991@gmail.com	\N	9883905780	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5e0a0029-9c6a-4e61-8f3c-7b31af0e4f6b	\N	Ms. Sonam Lhamu Lepcha	Female	738 of 2018	mayelsonam6@gmail.com	\N	9000000161	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
da38eabe-c936-4b63-9f9a-7511b6789d5e	\N	Ms. Chunkila Bhutia	Female	1304 of 2012	cbhutia5@gmail.com	\N	9933877008	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
ea1480ea-09da-487c-8722-f7697620675b	\N	Ms. Saroja Chettri	Female	626 of 2015	sorojachettri1991@gmail.com	\N	9000000163	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1a37d603-6c89-43fb-a69b-0dbac3f30d29	\N	Mr. Pankaj Gautam	Male	TEMP/164/REG	Advpankajgautam111@gmail.com	Pgautam943@gmail.com	8448677980	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
40fe53f6-dff7-40cc-a445-118db8efb3a8	\N	Mr. Johnson Subba	Male	786/2016	advjohnsonsubbA@GMAIL.COM	\N	9910606889	\N	\N	10	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
d3040a0d-f051-473d-b887-959dadeb9848	\N	Ms. Sushan Subba	Female	1311/2017	sushanemma@gmail.com	\N	9593775590	\N	\N	6	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
59c6f67a-51e4-4703-8840-07c174acf755	\N	Mr. Shrawan Kumar Prasad	Male	49 of 2009 – 10	shrawan0102@yahoo.com	\N	9832655389	\N	\N	14	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
02399d3b-c5ab-48a4-a499-301673d67f97	\N	Ms. Dinku Khati	Female	F. 1195/483 of 2005	dinku422@gmail.com	\N	8420857253	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b6afa929-c1b6-4dc0-9fa1-2a9d2ec15039	\N	Ms. Mingma Lhamu Sherpa - II	Female	1153 of 2018	mingmalhamu2601@gmail.com	\N	8768868175	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
e111e115-13fd-4092-bde8-6f276bdd77b9	\N	Ms. Neetu Tamang	Female	398 of 2016	neetupakhrin007@gmail.com	\N	8768940811	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a58be060-9342-4499-9c8f-5cf6ea342db3	\N	Ms. Tshering Uden Sherpa	Female	390 of 2014	udensherpa10@gmail.com	\N	7001539512	\N	\N	9	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
26ed624a-2d03-4f62-822a-5f1544b8e464	\N	Mr. Kusan Limboo	Male	961 of 2016	kushanlimboo11@gmail.com	\N	9593980186	\N	\N	7	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a0ecf165-3717-4a40-9e97-943726399ee8	\N	Ms. Eme Rai Rai	Female	1388/2029	Emeraigankhu5@gmail.com	\N	9832159629	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
5a5484b0-da4b-4a28-b183-8e390147b9b3	\N	Ms. Anuradha Tamang	Female	430/2022	Tanuradha321@gmail.com	\N	8101038512	\N	\N	3	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
58c7fc77-9e56-49a9-a663-f7a79ba5eedf	\N	Mr. Roshan Tamang	Male	369/2008	piyushtamang11@gmail.com	\N	9647782187	\N	\N	12	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
a5d997d3-13c4-4342-a876-46071d9aae5a	\N	Mr. Yogesh Subba	Male	671/2015	yogeshsubba89@gmail.com	\N	7872223232	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
644b4d19-9fac-4e3f-9537-dbc2b94de67a	\N	Ms. Anusha Thapa	Female	993 of 2010	anushiya95@gmail.com	\N	9775965499	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
64ce6976-f204-41d9-8104-29eeb2a0120d	\N	Mr. Mang Hang Subba	Male	1156/2007	mang82@gmail.com	\N	7479052002	\N	\N	8	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
70509556-8bcb-46f0-8b6f-3ea17142a292	\N	Ms. Kanchan Rai	Female	55 of 2017	kanchanrai701@gmail.com	\N	7076287153	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
be42dd2a-2bba-42f5-a509-5aebccf49f39	\N	Ms. Sunita Chettri	Female	1180 of 2018	sunitachettri06@gmail.com	\N	7427991243	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
1c2ad25d-c6db-4d44-bf7b-9c2c79f380e9	\N	Mr. Manoj Subba	Male	1275 of 2017	namanzworld@gmail.com	\N	8372836935	\N	\N	5	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
f2769f50-d0ce-4768-b3f3-886806c9a18f	\N	Ms. Tashi Doma Bhutia	Female	F/583/474 of 2006	tashee5482@gmail.com	\N	9733051918	\N	\N	15	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
80e2a118-c63e-4dea-871c-512db17a5139	\N	Ms. Bichitra Thapa	Female	1812/2013-2024	bichitrathapa2021@gmail.co	\N	70012115113	\N	\N	4	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
b37ceb97-a500-441b-99d3-7c2f083a86d4	\N	Ms. Dipshika Tamang	Female	2319/2024	dipshikatamangdisshikatamang@gmail.com	\N	9002304122	\N	\N	3	t	t	2026-08-06 09:03:26.4597+00	2026-08-12 09:18:05.969483+00
\.


--
-- Data for Name: case_type_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."case_type_master" ("id", "case_type_code", "case_type_name", "icon_url", "display_order", "is_active", "created_at") FROM stdin;
1061ce0c-c230-47cc-b6d0-226e17acffbc	SUCCESSION_CERTIFICATE	Succession Certificate	\N	1	t	2026-08-14 11:05:55.727665+00
ff25398e-f2f5-4968-86d1-7720a5bd88f2	DOMESTIC_VIOLENCE	Domestic Violence	\N	2	t	2026-08-14 11:05:55.727665+00
06d00e86-e1c0-4a6f-9d87-3e204df00423	MAINTENANCE	Maintenance	\N	3	t	2026-08-14 11:05:55.727665+00
4ada5a92-b82f-4cb0-b16a-712125ad5f99	DIVORCE	Divorce	\N	4	t	2026-08-14 11:05:55.727665+00
30ac1c6c-144e-446d-a05b-151d558de1bd	CHILD_CUSTODY	Child Custody	\N	5	t	2026-08-14 11:05:55.727665+00
0e6b1747-e003-44e6-86dc-34ccb988658e	PROPERTY_DISPUTE	Property Dispute	\N	6	t	2026-08-14 11:05:55.727665+00
deebe4b2-0aea-464a-b766-b615e0c8d3ff	LAND_DISPUTE	Land Dispute	\N	7	t	2026-08-14 11:05:55.727665+00
ca1a23db-2c25-4e8e-8515-ee7a7d6e86b2	CHEQUE_BOUNCE	Cheque Bounce	\N	8	t	2026-08-14 11:05:55.727665+00
209612bf-4ed4-41eb-8743-227b12ae836a	MOTOR_ACCIDENT_CLAIM	Motor Accident Claim	\N	9	t	2026-08-14 11:05:55.727665+00
3822198c-0325-4077-b747-556b90764763	LABOUR_DISPUTE	Labour Dispute	\N	10	t	2026-08-14 11:05:55.727665+00
4ab875a1-9cfa-4cee-ba82-55dfb8c2045a	CONSUMER_DISPUTE	Consumer Dispute	\N	11	t	2026-08-14 11:05:55.727665+00
d6f90bb8-3a44-47f9-a8e0-23c28054220e	CRIMINAL_MATTER	Criminal Matter	\N	12	t	2026-08-14 11:05:55.727665+00
389a693f-2e92-4844-b0b9-073237976cc4	CIVIL_MATTER	Civil Matter	\N	13	t	2026-08-14 11:05:55.727665+00
a8275b55-e72f-4ae9-9b25-67554d7bb89f	VICTIM_COMPENSATION	Victim Compensation	\N	14	t	2026-08-14 11:05:55.727665+00
12569c3d-8f07-4ce1-b8cf-3d457c6dd87a	SENIOR_CITIZEN_MAINTENANCE	Senior Citizen Maintenance	\N	15	t	2026-08-14 11:05:55.727665+00
f10238bd-a3ba-4e55-9d63-18c2ccd80e8a	LEGAL_NOTICE	Legal Notice	\N	16	t	2026-08-14 11:05:55.727665+00
aa0bd8fb-c54f-472f-ab2b-9d0361cd0392	OTHER	Other	\N	17	t	2026-08-14 11:05:55.727665+00
\.


--
-- Data for Name: legal_aid_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."legal_aid_category" ("id", "category_code", "category_name", "description", "display_order", "icon_url", "created_at") FROM stdin;
5793c5e6-9236-4dfd-8b82-fbb3d82dc092	SC_ST	Scheduled Caste or Scheduled Tribe	Members of Scheduled Caste or Scheduled Tribe communities under Sec 12(a)	1	\N	2026-08-14 11:05:55.727665+00
196987de-5894-4a5a-9e0f-ddf23f50df12	TRAFFICKING_VICTIM	Victim of Trafficking	Victims of human trafficking or forced labor under Article 23 of the Constitution	2	\N	2026-08-14 11:05:55.727665+00
c8211997-2ac3-44cf-873b-949c2a44f431	BEGGARY_VICTIM	Victim of Beggary	Victims of forced begging as referred to in Article 23 of the Constitution	3	\N	2026-08-14 11:05:55.727665+00
837cce7d-b165-42d1-b6c8-7bcbcce502d1	WOMAN	Woman	All women are eligible regardless of income under Sec 12(c)	4	\N	2026-08-14 11:05:55.727665+00
37dbfb26-af99-4ea8-a756-c668bf7abe2a	CHILDREN	Children	All children are eligible under Sec 12(c)	5	\N	2026-08-14 11:05:55.727665+00
6d4367bd-b8ba-4509-935a-d56e3501ed6d	DISABLED_PERSON	Mentally Ill or Disabled Person	Persons with mental illness or physical disabilities under Sec 12(d)	6	\N	2026-08-14 11:05:55.727665+00
ec9e7d1a-b486-4a33-afc6-1b3cb465c6cc	DISASTER_VICTIM	Victim of Disaster or Atrocity	Victims of mass disasters, ethnic violence, caste atrocities, floods, earthquakes, or industrial disasters under Sec 12(e)	7	\N	2026-08-14 11:05:55.727665+00
777165d6-14a6-4f91-92a6-34714498c49f	INDUSTRIAL_WORKMAN	Industrial Workman	Industrial workers under Sec 12(f)	8	\N	2026-08-14 11:05:55.727665+00
f3595cfc-9d99-4e1f-89be-b0186267de66	GENERAL	General – Annual income below ₹3 Lakh	Individuals with annual household income less than 3 Lakh Rupees under Sec 12(h)	9	\N	2026-08-14 11:05:55.727665+00
\.


--
-- Data for Name: taluka_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."taluka_master" ("id", "taluka_name", "taluka_code", "district_id", "created_at") FROM stdin;
b8961244-05cf-4f40-8104-c06656479aeb	Gangtok	GANGTOK_TALUKA	162e0db6-feb9-44ea-9476-483c844f4956	2026-08-14 11:07:31.746433+00
5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa	Namchi	NAMCHI_TALUKA	7c7faa9f-4cbb-450d-9046-15ef51430cd9	2026-08-14 11:07:31.746433+00
582bd613-f9d4-4dab-8494-e2e84a896c7f	Jorethang Sub-Division	JORETHANG_TALUKA	7c7faa9f-4cbb-450d-9046-15ef51430cd9	2026-08-14 11:07:31.746433+00
65186ae8-347a-4e5e-afa6-07518e9e7c26	Yangang Sub-Division	YANGANG_TALUKA	7c7faa9f-4cbb-450d-9046-15ef51430cd9	2026-08-14 11:07:31.746433+00
bf52f805-f9a8-491d-acc0-256eb07ec801	Mangan	MANGAN_TALUKA	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	2026-08-14 11:07:31.746433+00
bdf12e3e-9847-4674-9094-5c79ee54f059	Chungthang Sub-Division	CHUNGTHANG_TALUKA	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	2026-08-14 11:07:31.746433+00
322b6b54-1bd9-4edf-ae16-e48b13f68f4f	Gyalshing	GYALSHING_TALUKA	d434b194-4038-4342-b475-0f1ef7b44ae4	2026-08-14 11:07:31.746433+00
12e67fb5-78bc-42cd-9ac2-efd9a6a32b90	Pakyong	PAKYONG_TALUKA	771eac9c-c0b1-4b1b-acfa-658163c4a82f	2026-08-14 11:07:31.746433+00
bddb9073-c8b3-4590-a589-b7d8c6fef2f4	Rangpo Sub-Division	RANGPO_TALUKA	771eac9c-c0b1-4b1b-acfa-658163c4a82f	2026-08-14 11:07:31.746433+00
2dac363a-683e-4924-90fb-2b2b4492a300	Rongli Sub-Division	RONGLI_TALUKA	771eac9c-c0b1-4b1b-acfa-658163c4a82f	2026-08-14 11:07:31.746433+00
c9138645-c5b9-4809-92d0-ff8f4d22bfad	Soreng	SORENG_TALUKA	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	2026-08-14 11:07:31.746433+00
\.


--
-- Data for Name: legal_aid_application; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."legal_aid_application" ("id", "tracking_number", "applicant_id", "category_id", "applicant_full_name", "applicant_phone_number", "applicant_dob", "applicant_gender", "village_or_town", "applicant_district_id", "case_type_id", "current_district_id", "current_taluka_id", "case_details", "preferred_advocate_id", "assigned_advocate_id", "advocate_acceptance_status", "assigned_at", "status", "is_withdrawn_by_citizen", "withdrawal_reason", "withdrawn_at", "created_at", "updated_at") FROM stdin;
4879def6-dfd6-4d4a-bda0-acb3d4916df4	LA-20260816-001	f60352e9-33a0-40f2-98f4-b79fe2795050	5793c5e6-9236-4dfd-8b82-fbb3d82dc092	Demo Applicant 1	+91-9000000001	1990-01-01	MALE	Demo Village 1	162e0db6-feb9-44ea-9476-483c844f4956	1061ce0c-c230-47cc-b6d0-226e17acffbc	162e0db6-feb9-44ea-9476-483c844f4956	b8961244-05cf-4f40-8104-c06656479aeb	Demo case details for legal aid application #1	\N	\N	NONE	\N	SUBMITTED	f	\N	\N	2026-08-16 14:33:09.879909+00	2026-08-16 14:33:09.879909+00
463991a4-cf51-47df-a98a-d98b49591b7f	LA-20260816-002	6903780c-c138-463e-af24-35991d1c2add	196987de-5894-4a5a-9e0f-ddf23f50df12	Demo Applicant 2	+91-9000000002	1991-01-01	FEMALE	Demo Village 2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	ff25398e-f2f5-4968-86d1-7720a5bd88f2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa	Demo case details for legal aid application #2	\N	\N	NONE	\N	SUBMITTED	f	\N	\N	2026-08-16 14:33:09.879909+00	2026-08-16 14:33:09.879909+00
09050539-7d28-48d8-b89f-51f9870dcf63	LA-20260816-2db24928	f60352e9-33a0-40f2-98f4-b79fe2795050	5793c5e6-9236-4dfd-8b82-fbb3d82dc092	Demo Applicant 1	+91-9000000001	1990-01-01	OTHER	Demo Village 1	162e0db6-feb9-44ea-9476-483c844f4956	1061ce0c-c230-47cc-b6d0-226e17acffbc	162e0db6-feb9-44ea-9476-483c844f4956	b8961244-05cf-4f40-8104-c06656479aeb	Case details: Under review	\N	\N	NONE	\N	UNDER_REVIEW	f	\N	\N	2026-08-16 14:37:37.660476+00	2026-08-16 14:37:37.660476+00
2d76c7cb-4d3c-4762-9f68-353a5cb432c0	LA-20260816-0b004e07	6903780c-c138-463e-af24-35991d1c2add	196987de-5894-4a5a-9e0f-ddf23f50df12	Demo Applicant 2	+91-9000000002	1991-01-01	FEMALE	Demo Village 2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	ff25398e-f2f5-4968-86d1-7720a5bd88f2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa	Case details: Advocate assigned	3cc31969-af68-4be9-bc9d-8e69bd810811	3cc31969-af68-4be9-bc9d-8e69bd810811	PENDING	2026-08-14 14:37:37.660476+00	ADVOCATE_ASSIGNED	f	\N	\N	2026-08-16 14:37:37.660476+00	2026-08-16 14:37:37.660476+00
81ee9973-ce8a-4475-92cd-1da7b60faee1	LA-20260816-f802cea5	6903780c-c138-463e-af24-35991d1c2add	5793c5e6-9236-4dfd-8b82-fbb3d82dc092	Demo Applicant 4	+91-9000000004	1992-12-31	FEMALE	Demo Village 4	162e0db6-feb9-44ea-9476-483c844f4956	1061ce0c-c230-47cc-b6d0-226e17acffbc	162e0db6-feb9-44ea-9476-483c844f4956	b8961244-05cf-4f40-8104-c06656479aeb	Case details: Resolved	3cc31969-af68-4be9-bc9d-8e69bd810811	3cc31969-af68-4be9-bc9d-8e69bd810811	ACCEPTED	2026-08-12 14:38:20.618704+00	RESOLVED	f	\N	\N	2026-08-16 14:38:20.618704+00	2026-08-16 14:38:20.618704+00
c0c66157-f2d6-42ae-b587-27292cc074a6	LA-20260816-7dfba7c1	f60352e9-33a0-40f2-98f4-b79fe2795050	5793c5e6-9236-4dfd-8b82-fbb3d82dc092	Demo Applicant 1	+91-9000000001	1990-01-01	FEMALE	Demo Village 1	162e0db6-feb9-44ea-9476-483c844f4956	1061ce0c-c230-47cc-b6d0-226e17acffbc	162e0db6-feb9-44ea-9476-483c844f4956	b8961244-05cf-4f40-8104-c06656479aeb	Case details: Submitted	\N	\N	NONE	\N	SUBMITTED	f	\N	\N	2026-08-16 14:38:20.618704+00	2026-08-16 14:38:20.618704+00
f10bf085-13e5-450b-9150-f7d134863908	LA-20260816-302a4223	f60352e9-33a0-40f2-98f4-b79fe2795050	196987de-5894-4a5a-9e0f-ddf23f50df12	Demo Applicant 5	+91-9000000005	1993-12-31	OTHER	Demo Village 5	7c7faa9f-4cbb-450d-9046-15ef51430cd9	ff25398e-f2f5-4968-86d1-7720a5bd88f2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa	Case details: Rejected	3cc31969-af68-4be9-bc9d-8e69bd810811	3cc31969-af68-4be9-bc9d-8e69bd810811	REJECTED	2026-08-13 14:38:20.618704+00	REJECTED	f	\N	\N	2026-08-16 14:38:20.618704+00	2026-08-16 14:38:20.618704+00
8ca4fd2a-d85d-4465-9567-50a2242e8f98	LA-20260816-56e6c3ae	6903780c-c138-463e-af24-35991d1c2add	196987de-5894-4a5a-9e0f-ddf23f50df12	Demo Applicant 2	+91-9000000002	1991-01-01	OTHER	Demo Village 2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	ff25398e-f2f5-4968-86d1-7720a5bd88f2	7c7faa9f-4cbb-450d-9046-15ef51430cd9	5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa	Case details: Under review	\N	\N	NONE	\N	UNDER_REVIEW	f	\N	\N	2026-08-16 14:38:20.618704+00	2026-08-16 14:38:20.618704+00
a6501732-9bd7-44bb-b89f-459643f37f5a	LA-20260816-9b76e062	6903780c-c138-463e-af24-35991d1c2add	c8211997-2ac3-44cf-873b-949c2a44f431	Demo Applicant 6	+91-9000000006	1994-12-31	MALE	Demo Village 6	7c7faa9f-4cbb-450d-9046-15ef51430cd9	06d00e86-e1c0-4a6f-9d87-3e204df00423	7c7faa9f-4cbb-450d-9046-15ef51430cd9	582bd613-f9d4-4dab-8494-e2e84a896c7f	Case details: Withdrawn	\N	\N	NONE	\N	WITHDRAWN	t	Citizen withdrew the application	2026-08-16 13:38:20.618704+00	2026-08-16 14:38:20.618704+00	2026-08-16 14:38:20.618704+00
8e4e380d-f49e-4248-951e-0453f39d7545	LA-20260816-9f43485a	f60352e9-33a0-40f2-98f4-b79fe2795050	c8211997-2ac3-44cf-873b-949c2a44f431	Demo Applicant 3	+91-9000000003	1992-01-01	MALE	Demo Village 3	7c7faa9f-4cbb-450d-9046-15ef51430cd9	06d00e86-e1c0-4a6f-9d87-3e204df00423	7c7faa9f-4cbb-450d-9046-15ef51430cd9	582bd613-f9d4-4dab-8494-e2e84a896c7f	Case details: Advocate assigned	3cc31969-af68-4be9-bc9d-8e69bd810811	3cc31969-af68-4be9-bc9d-8e69bd810811	PENDING	2026-08-14 14:38:20.618704+00	ADVOCATE_ASSIGNED	f	\N	\N	2026-08-16 14:38:20.618704+00	2026-08-16 14:38:20.618704+00
\.


--
-- Data for Name: advocate_case_action_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."advocate_case_action_log" ("id", "application_id", "advocate_id", "action_type", "reason", "action_at") FROM stdin;
\.


--
-- Data for Name: advocate_change_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."advocate_change_request" ("id", "application_id", "requested_by_citizen_id", "current_advocate_id", "preferred_new_advocate_id", "reason", "request_status", "reviewed_by_admin_id", "admin_remarks", "requested_at", "reviewed_at") FROM stdin;
\.


--
-- Data for Name: advocate_district_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."advocate_district_mapping" ("advocate_id", "district_id", "is_primary_district") FROM stdin;
3cc31969-af68-4be9-bc9d-8e69bd810811	162e0db6-feb9-44ea-9476-483c844f4956	t
47e0c7b9-eb0e-43ee-9776-89d161a02aec	162e0db6-feb9-44ea-9476-483c844f4956	t
365e9eca-06b6-4cd8-85dc-bfd96a013bad	162e0db6-feb9-44ea-9476-483c844f4956	t
71fce84b-4ac1-42b6-868d-b2448a8109d6	162e0db6-feb9-44ea-9476-483c844f4956	t
4be9c9ee-bdfc-4284-a85e-9f11e7c36e65	162e0db6-feb9-44ea-9476-483c844f4956	t
9a69156c-e8fe-4499-8dcc-0220163e4a2f	162e0db6-feb9-44ea-9476-483c844f4956	t
2f4fad71-8c19-4fef-9fec-f7ecf2334937	162e0db6-feb9-44ea-9476-483c844f4956	t
a8ddba32-ba22-4c8b-8a0a-b77ca8c56b9e	162e0db6-feb9-44ea-9476-483c844f4956	t
c416cbe7-0df7-4ced-ae54-485745b1f983	162e0db6-feb9-44ea-9476-483c844f4956	t
71ab48ae-0765-4462-9b13-185ffd482323	162e0db6-feb9-44ea-9476-483c844f4956	t
f94da927-1386-41ae-ab23-5be9a6e57348	162e0db6-feb9-44ea-9476-483c844f4956	t
129b3db0-3889-46d7-bf7b-0b4dc5892446	162e0db6-feb9-44ea-9476-483c844f4956	t
a6420833-f7d1-4ffe-999f-154933c96d58	162e0db6-feb9-44ea-9476-483c844f4956	t
ce44b191-b634-43ca-b9a2-57de646c1199	162e0db6-feb9-44ea-9476-483c844f4956	t
4bb8be65-61b4-457b-b803-8ea7982f579c	162e0db6-feb9-44ea-9476-483c844f4956	t
e1aea0f2-32b5-4b07-995d-e2e60397d2e7	162e0db6-feb9-44ea-9476-483c844f4956	t
52a891d6-19c2-4012-92b7-9aa8e85a229b	162e0db6-feb9-44ea-9476-483c844f4956	t
743a1a8b-5df8-4c86-a0c3-71340d53f7c9	162e0db6-feb9-44ea-9476-483c844f4956	t
0d1ec98f-2081-46a4-b056-741832a3bf5d	162e0db6-feb9-44ea-9476-483c844f4956	t
01459d67-7440-4504-aa92-e9817b1ef0f9	162e0db6-feb9-44ea-9476-483c844f4956	t
30600c29-ff94-4063-a58f-16a8cabcbf18	162e0db6-feb9-44ea-9476-483c844f4956	t
ce28cd72-4827-401c-acbd-63bb8546c8ab	162e0db6-feb9-44ea-9476-483c844f4956	t
7b887b9f-0053-407a-bfe6-9cbc604e6dfb	162e0db6-feb9-44ea-9476-483c844f4956	t
5dddbef4-c331-4079-9811-d1f9c67532ff	162e0db6-feb9-44ea-9476-483c844f4956	t
4ba0e616-c860-441f-98d0-ec922e30e94c	162e0db6-feb9-44ea-9476-483c844f4956	t
8c2d2159-6311-4767-96ff-6b081f848790	162e0db6-feb9-44ea-9476-483c844f4956	t
45006a5e-b692-4384-ad8c-d19774b8332a	162e0db6-feb9-44ea-9476-483c844f4956	t
a7a23a34-95b7-45e3-b4ba-83c818bb9845	162e0db6-feb9-44ea-9476-483c844f4956	t
e09be191-c4ed-46cd-baf8-ddbfbc8c3795	162e0db6-feb9-44ea-9476-483c844f4956	t
760af78b-cb95-4979-a68a-945a6259d824	162e0db6-feb9-44ea-9476-483c844f4956	t
8f7becf8-46c3-4ad8-8066-a555e3aa741a	162e0db6-feb9-44ea-9476-483c844f4956	t
5a3f8477-27f7-41d2-a450-c91ff35b6129	162e0db6-feb9-44ea-9476-483c844f4956	t
b26940f6-600e-42a6-8c21-cdbcbfaa9f31	162e0db6-feb9-44ea-9476-483c844f4956	t
5917a59c-be5e-4b0d-81f3-fb3f3a35e8d8	162e0db6-feb9-44ea-9476-483c844f4956	t
192d6451-4aa3-467b-85d1-df0a945504ae	162e0db6-feb9-44ea-9476-483c844f4956	t
b457a954-d9fa-4fc9-a4a5-e947c5e56b52	162e0db6-feb9-44ea-9476-483c844f4956	t
249f2753-af1a-47af-9637-66b345d862bf	162e0db6-feb9-44ea-9476-483c844f4956	t
31f20f6e-ad1a-47c9-9155-1590bd8426ff	162e0db6-feb9-44ea-9476-483c844f4956	t
a24dda9a-c186-44f0-a9a1-0844bef8adf8	162e0db6-feb9-44ea-9476-483c844f4956	t
6c2b9354-df63-433a-942e-4d83ba1107cb	162e0db6-feb9-44ea-9476-483c844f4956	t
bfe83cda-4e4e-404b-9f2c-c1609677a522	162e0db6-feb9-44ea-9476-483c844f4956	t
c8552373-0e18-488c-ac5c-18ea669797a7	162e0db6-feb9-44ea-9476-483c844f4956	t
e981d992-17c6-400a-8415-3808d4791b9a	162e0db6-feb9-44ea-9476-483c844f4956	t
216e4773-084e-43cb-bcb9-e15765bc80b4	162e0db6-feb9-44ea-9476-483c844f4956	t
0a2aaf01-e97b-4a81-9a78-038a245bd591	162e0db6-feb9-44ea-9476-483c844f4956	t
e364a60d-225f-4659-b102-ee7fb4524576	162e0db6-feb9-44ea-9476-483c844f4956	t
8324444d-8abb-4481-81d8-f8975508a8d0	162e0db6-feb9-44ea-9476-483c844f4956	t
775931d3-7d51-4b50-a6f2-83035b67e981	162e0db6-feb9-44ea-9476-483c844f4956	t
7b644435-39b4-456a-8344-63e0b3703b2a	162e0db6-feb9-44ea-9476-483c844f4956	t
72865741-f50b-4909-8fe2-d100c8f2c190	162e0db6-feb9-44ea-9476-483c844f4956	t
0ab123d9-2981-461f-8cc8-7b99d3d728b3	162e0db6-feb9-44ea-9476-483c844f4956	t
cdf38621-a2ad-45ed-bb62-be290918401f	162e0db6-feb9-44ea-9476-483c844f4956	t
7c4e4213-1b45-4126-b738-432095f1ab68	162e0db6-feb9-44ea-9476-483c844f4956	t
0fcf4042-9c6c-4bad-a876-2f2ae74b916e	162e0db6-feb9-44ea-9476-483c844f4956	t
2ad8fc0d-3116-4a33-b677-08526310ee66	162e0db6-feb9-44ea-9476-483c844f4956	t
3eb732ee-305f-4262-937d-00d1ade93ffe	162e0db6-feb9-44ea-9476-483c844f4956	t
b75e621a-cc77-4150-9589-cd9d9835b4b5	162e0db6-feb9-44ea-9476-483c844f4956	t
33f403cb-9ac5-411e-8bff-40c6f1804e25	162e0db6-feb9-44ea-9476-483c844f4956	t
e958e42a-2fef-4ecb-ad22-ec00c5a84609	162e0db6-feb9-44ea-9476-483c844f4956	t
b218d666-d6f8-4b3b-ad08-12299ee7b4da	162e0db6-feb9-44ea-9476-483c844f4956	t
91af4a2c-533e-4e91-9751-0ba012d63901	162e0db6-feb9-44ea-9476-483c844f4956	t
7e9e7290-88d8-4160-b333-bcd2f280cbf4	162e0db6-feb9-44ea-9476-483c844f4956	t
383e6c0a-0f9e-4ccf-923b-9369f4d1f8f3	162e0db6-feb9-44ea-9476-483c844f4956	t
e97e137b-fb9a-4190-a702-791a4799da95	162e0db6-feb9-44ea-9476-483c844f4956	t
6f949782-cae9-4a0d-83ca-e22f275fd298	162e0db6-feb9-44ea-9476-483c844f4956	t
c2224fe5-1990-4c40-a7e9-c0292c7a139a	162e0db6-feb9-44ea-9476-483c844f4956	t
e62b226d-5c6a-48c9-bfb6-35e32ffacd22	162e0db6-feb9-44ea-9476-483c844f4956	t
18130a28-381f-44b3-b5a7-db1f6bf23b24	162e0db6-feb9-44ea-9476-483c844f4956	t
7d6d13e6-dbf0-4e1f-9e9b-a3b86f9e9855	162e0db6-feb9-44ea-9476-483c844f4956	t
bf12131d-e7a0-4673-ad25-73d8bd12fbb2	162e0db6-feb9-44ea-9476-483c844f4956	t
6c83dc20-86ce-4a4e-a0e8-fba088d23b8c	162e0db6-feb9-44ea-9476-483c844f4956	t
9075d78d-cf57-47ba-b808-4d247ca0af20	162e0db6-feb9-44ea-9476-483c844f4956	t
23eba25f-a8f8-4922-9847-e309eef00035	162e0db6-feb9-44ea-9476-483c844f4956	t
c67957aa-38a9-4895-a554-b57f134cf420	162e0db6-feb9-44ea-9476-483c844f4956	t
0580a207-9583-45bc-9210-983c482d49f1	162e0db6-feb9-44ea-9476-483c844f4956	t
c664bc2b-b36a-4744-a582-46bbc709ec13	162e0db6-feb9-44ea-9476-483c844f4956	t
ac9545da-d7c7-4836-b959-84c36e81f618	162e0db6-feb9-44ea-9476-483c844f4956	t
dd56e08a-bb7c-48c8-9105-9e02a164ad46	162e0db6-feb9-44ea-9476-483c844f4956	t
7343470c-5155-454c-8e55-a364a8d5e36d	162e0db6-feb9-44ea-9476-483c844f4956	t
29e5481a-fff3-4678-9fd7-65906d2a5efc	162e0db6-feb9-44ea-9476-483c844f4956	t
af24afbc-9c73-4062-9356-9c9c4288fe02	162e0db6-feb9-44ea-9476-483c844f4956	t
fda0c4e6-d653-49e2-9052-ba2b10a38669	162e0db6-feb9-44ea-9476-483c844f4956	t
ec0823bf-6210-4982-ab1a-68275260af3f	162e0db6-feb9-44ea-9476-483c844f4956	t
2b5c284d-b589-4f31-9298-14b9ebfab138	162e0db6-feb9-44ea-9476-483c844f4956	t
f4b5a16e-43cb-4f8b-b565-6aebaed71cf1	162e0db6-feb9-44ea-9476-483c844f4956	t
1289c18b-2ef8-46f1-9b8f-722608dcace3	162e0db6-feb9-44ea-9476-483c844f4956	t
d3c4213d-8732-49c1-a40d-f8384015218d	162e0db6-feb9-44ea-9476-483c844f4956	t
5d6e5023-6ae2-4217-ac03-585fa24fc0e5	162e0db6-feb9-44ea-9476-483c844f4956	t
501625d4-d369-4723-bb15-0aeba6320706	162e0db6-feb9-44ea-9476-483c844f4956	t
fb1c8e4a-dbd2-4aca-ae49-4568b831e7e1	162e0db6-feb9-44ea-9476-483c844f4956	t
3f74e2dc-3018-4938-b863-2d0779bf92cb	162e0db6-feb9-44ea-9476-483c844f4956	t
71b69a3d-8769-4e2b-bf9d-2e6aaac873c2	162e0db6-feb9-44ea-9476-483c844f4956	t
7d6c25a4-520e-4588-bd47-5073ea02cf94	162e0db6-feb9-44ea-9476-483c844f4956	t
e9bee74e-69b4-4031-ada2-dc1f2fda8856	162e0db6-feb9-44ea-9476-483c844f4956	t
1e0db796-ff41-4f62-98ed-b7521073d660	162e0db6-feb9-44ea-9476-483c844f4956	t
b5642866-54dc-4a17-a511-956d3eb5d82b	162e0db6-feb9-44ea-9476-483c844f4956	t
3b935a8d-d1ae-4def-9557-1c7c8c5940a7	162e0db6-feb9-44ea-9476-483c844f4956	t
729263a5-e525-4eca-965a-10bc3bbda6e4	162e0db6-feb9-44ea-9476-483c844f4956	t
232de221-2305-4521-818f-f511734f0765	162e0db6-feb9-44ea-9476-483c844f4956	t
eac2de39-3571-493b-966d-66f015eea38c	162e0db6-feb9-44ea-9476-483c844f4956	t
e78365da-a472-4995-bc8d-aa361365a95f	162e0db6-feb9-44ea-9476-483c844f4956	t
28be4e46-04bf-4aae-b676-4b678d9b5ae7	162e0db6-feb9-44ea-9476-483c844f4956	t
14851c75-4f6e-49fb-a4f2-470646c877a3	162e0db6-feb9-44ea-9476-483c844f4956	t
d41942db-a78a-4818-b846-d6bf112403f0	162e0db6-feb9-44ea-9476-483c844f4956	t
957ba8a5-2612-47d3-998b-725c728b285c	162e0db6-feb9-44ea-9476-483c844f4956	t
eb0b7646-2cf2-485a-b2b5-a5787b1a792c	162e0db6-feb9-44ea-9476-483c844f4956	t
09b035a7-a012-4d86-aecb-3bf4652d482c	162e0db6-feb9-44ea-9476-483c844f4956	t
24b026ec-f83f-47cb-b1fa-61c7b53b7f1e	162e0db6-feb9-44ea-9476-483c844f4956	t
94174336-97cc-4af6-8fd3-eec6245fea83	162e0db6-feb9-44ea-9476-483c844f4956	t
d6c86a70-8535-4125-b977-57ae2b0cf6d8	162e0db6-feb9-44ea-9476-483c844f4956	t
ae483326-e09a-49de-9eeb-6d43afd1b1f3	162e0db6-feb9-44ea-9476-483c844f4956	t
0205ca0a-ae6e-4251-b280-9b1c4fd47a51	162e0db6-feb9-44ea-9476-483c844f4956	t
2acdccf4-99fc-4b14-be90-66555fec0585	162e0db6-feb9-44ea-9476-483c844f4956	t
a5f08483-0e2d-4f8e-af80-401c19be3e6a	162e0db6-feb9-44ea-9476-483c844f4956	t
dcded46c-c064-4311-b8ee-97f988885275	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
c5948df5-0515-4eeb-bb58-2e6ff19edee1	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
e57a0f2f-449a-4979-827d-93110aa4ecb5	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
6eb277ca-5443-4f46-b9be-c29892f65f34	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
856f1190-9334-4e8b-a114-a30cd7ed6303	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
d7ea0389-65ee-47b3-8710-7d843b1aebfa	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
5d4cf8cb-57fc-4a49-8d05-470de6b92617	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
506a1e45-98dd-4bdf-ad98-9e28dee1043c	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
d5f11d17-5d0e-4b91-a8c7-3b35ff5500c5	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
ff3996d2-ab6e-4444-a557-c785c68cbe97	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
4515f1d2-dd05-4d02-9aec-ef554624fd49	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
548bfa56-84cb-4ad3-97a1-a661cda4ffd0	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
abbec3f8-52ef-4264-a5c5-7e34ef51a55a	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
9871a0d7-91fc-4ade-9762-0848f36ba322	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
b343613e-76d1-41b0-8ec4-6adda5d58bc8	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
52897e4b-6561-4600-93bb-d76e896b3cda	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
9548f89b-a2c9-421a-98ad-daa9d9fd2183	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
a585da07-09e6-4c76-9779-6f69937d5d9b	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
1a7078bd-d10a-49eb-b768-abd31a651bf1	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
18e154b7-afb5-41fc-8513-33d5f57346ef	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
0a678b26-52c5-48c8-88a8-86f5aeb48c73	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
b46940c9-5aa0-4fa4-b6d4-fd0c16206c03	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
92508178-5a0d-41d2-8e88-d2e77d29c5fa	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
adf0f298-eee7-446d-b6a2-63b27527e69c	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
0c725ba4-2c47-448f-b156-1970047664d7	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
29560d25-ccb0-4fce-ba0a-289c40fc940f	7c7faa9f-4cbb-450d-9046-15ef51430cd9	t
156e9966-f359-4f51-9a4b-f6c9fb8e12b2	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	t
754bf6e3-e2cd-4caa-896b-dfdd66e8f4c6	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	t
01f92d6e-8b2e-4587-9fc0-4716a1d0ab87	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	t
d9303d66-90a4-4885-9dd1-65b1dda7b4af	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	t
1d955daf-831d-44d2-9f1e-8e31fb3c24fd	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	t
1734c51d-0a3d-46e3-9873-ddad0fc3d5f2	18bcf408-b669-4e7d-b52c-d3b0a9b7c89d	t
43ea5784-4f73-4c88-8296-1fdb8ed035a7	d434b194-4038-4342-b475-0f1ef7b44ae4	t
15efb1d0-6cc0-456b-91da-3e4774eb822c	d434b194-4038-4342-b475-0f1ef7b44ae4	t
52424eb8-af69-4612-be06-9d6ca3aed0e4	d434b194-4038-4342-b475-0f1ef7b44ae4	t
44745f9e-8523-41a6-8447-3e3e410f95af	d434b194-4038-4342-b475-0f1ef7b44ae4	t
99945423-f6a3-4473-843d-86e4e087f72d	d434b194-4038-4342-b475-0f1ef7b44ae4	t
43043778-16a6-4c02-af0a-33c96ca0bd58	d434b194-4038-4342-b475-0f1ef7b44ae4	t
0f34ca16-1d4f-47b6-af0f-241bd6ef517d	d434b194-4038-4342-b475-0f1ef7b44ae4	t
e348aa85-a0d6-4640-bdd3-37eb2f6cf5a5	d434b194-4038-4342-b475-0f1ef7b44ae4	t
eddd64bf-c286-47da-a59e-57b8f6ce821a	d434b194-4038-4342-b475-0f1ef7b44ae4	t
ab2ee49f-82d3-402d-9cc0-31fc0691c9af	d434b194-4038-4342-b475-0f1ef7b44ae4	t
c326bc7b-cc25-4f3d-9b0d-b694cc59b776	d434b194-4038-4342-b475-0f1ef7b44ae4	t
f163011a-d0c8-413a-99da-56a4c841afcf	d434b194-4038-4342-b475-0f1ef7b44ae4	t
da531982-fb02-458f-beb6-0b1bdbfe2899	d434b194-4038-4342-b475-0f1ef7b44ae4	t
e7ad8118-6719-4929-8d0e-6ca74f4a2cc6	d434b194-4038-4342-b475-0f1ef7b44ae4	t
5e0a0029-9c6a-4e61-8f3c-7b31af0e4f6b	d434b194-4038-4342-b475-0f1ef7b44ae4	t
da38eabe-c936-4b63-9f9a-7511b6789d5e	d434b194-4038-4342-b475-0f1ef7b44ae4	t
ea1480ea-09da-487c-8722-f7697620675b	d434b194-4038-4342-b475-0f1ef7b44ae4	t
1a37d603-6c89-43fb-a69b-0dbac3f30d29	d434b194-4038-4342-b475-0f1ef7b44ae4	t
40fe53f6-dff7-40cc-a445-118db8efb3a8	d434b194-4038-4342-b475-0f1ef7b44ae4	t
d3040a0d-f051-473d-b887-959dadeb9848	d434b194-4038-4342-b475-0f1ef7b44ae4	t
59c6f67a-51e4-4703-8840-07c174acf755	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
02399d3b-c5ab-48a4-a499-301673d67f97	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
b6afa929-c1b6-4dc0-9fa1-2a9d2ec15039	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
e111e115-13fd-4092-bde8-6f276bdd77b9	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
a58be060-9342-4499-9c8f-5cf6ea342db3	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
26ed624a-2d03-4f62-822a-5f1544b8e464	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
a0ecf165-3717-4a40-9e97-943726399ee8	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
5a5484b0-da4b-4a28-b183-8e390147b9b3	771eac9c-c0b1-4b1b-acfa-658163c4a82f	t
58c7fc77-9e56-49a9-a663-f7a79ba5eedf	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
a5d997d3-13c4-4342-a876-46071d9aae5a	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
644b4d19-9fac-4e3f-9537-dbc2b94de67a	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
64ce6976-f204-41d9-8104-29eeb2a0120d	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
70509556-8bcb-46f0-8b6f-3ea17142a292	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
be42dd2a-2bba-42f5-a509-5aebccf49f39	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
1c2ad25d-c6db-4d44-bf7b-9c2c79f380e9	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
f2769f50-d0ce-4768-b3f3-886806c9a18f	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
80e2a118-c63e-4dea-871c-512db17a5139	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
b37ceb97-a500-441b-99d3-7c2f083a86d4	2a8f7698-6ff5-48bf-a3c3-eea8a65109c6	t
\.


--
-- Data for Name: document_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."document_master" ("id", "document_code", "document_name", "description", "is_active", "created_at") FROM stdin;
e9ac3de5-068a-4e3b-8351-af22a7c6f5a1	DRIVING_LICENCE	Driving Licence	Motor vehicle driving licence	t	2026-08-14 11:05:55.727665+00
05cffb0c-2ae7-469f-918c-9208720dd9d9	INCOME_CERTIFICATE	Income Certificate	Government issued annual income certificate	t	2026-08-14 11:05:55.727665+00
a899b9db-3898-4a99-ad7c-ebe8ab9eecc8	CASTE_CERTIFICATE	Caste Certificate	SC/ST/OBC community status certificate	t	2026-08-14 11:05:55.727665+00
8b5e97fc-8f41-4562-bec4-01f4482f442f	DISABILITY_CERTIFICATE	Disability Certificate	Medical certificate of disability	t	2026-08-14 11:05:55.727665+00
4cc059bf-3167-4143-866c-9abaff5e2b1f	INDUSTRIAL_WORKER_ID	Industrial Worker Identity Card	Proof of employment in industrial sector	t	2026-08-14 11:05:55.727665+00
877e46ba-089c-4ce0-953a-43fdd4ad2ed7	DEATH_CERTIFICATE	Death Certificate	Official death registration certificate	t	2026-08-14 11:05:55.727665+00
8119b64f-d2a9-4190-9db2-b5be34c75fa2	MARRIAGE_CERTIFICATE	Marriage Certificate	Legal marriage registration document	t	2026-08-14 11:05:55.727665+00
9a357f9d-dcef-48e2-a2e0-47afbf0698fa	LEGAL_HEIR_CERTIFICATE	Legal Heir Certificate	Certificate establishing legal heirs	t	2026-08-14 11:05:55.727665+00
c5a99b97-54e5-4dcb-b85e-ba76b57cda37	POLICE_FIR	Police FIR (First Information Report)	Copy of police FIR or complaint acknowledgment	t	2026-08-14 11:05:55.727665+00
1874033d-0b5d-4f97-a657-6ee1c4724261	MEDICAL_CERTIFICATE	Medical Certificate	Hospital or medical officer report	t	2026-08-14 11:05:55.727665+00
2d30eaa3-ae5c-419c-9962-e13ad6a9333e	IDENTIFICATION_DOCUMENT	Identification Document (Voter, Aadhar)	A government-approved identification document (e.g., Aadhaar, Voter ID, Passport).	t	2026-08-16 14:18:31.149889+00
3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	AGE_PROOF_DOCUMENT	Birth/School Certificate	Official birth registration certificate or school certificate	t	2026-08-14 11:05:55.727665+00
\.


--
-- Data for Name: application_document; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."application_document" ("id", "application_id", "document_id", "file_url", "file_name", "file_size_in_bytes", "is_verified", "verified_by", "uploaded_at") FROM stdin;
bd423646-9ba0-4325-b0cd-9efb13576ce0	4879def6-dfd6-4d4a-bda0-acb3d4916df4	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Document+1	demo_1.png	204800	f	\N	2026-08-16 14:33:09.879909+00
8f58bc56-d711-4385-993d-9c6e37ac9c66	4879def6-dfd6-4d4a-bda0-acb3d4916df4	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Document+2	demo_2.png	204800	f	\N	2026-08-16 14:33:09.879909+00
c2bdb87c-843d-491b-ba26-c36cbcef36f7	463991a4-cf51-47df-a98a-d98b49591b7f	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Document+1	demo_1.png	204800	f	\N	2026-08-16 14:33:09.879909+00
32518dc7-326f-41c6-94cb-a1697bf691a4	463991a4-cf51-47df-a98a-d98b49591b7f	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Document+2	demo_2.png	204800	f	\N	2026-08-16 14:33:09.879909+00
809bde4d-4171-42ab-92cd-6d61971a362a	8e4e380d-f49e-4248-951e-0453f39d7545	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A	app_document_A.png	204800	f	\N	2026-08-16 13:38:41.727609+00
b8d1253d-8c54-4683-937c-0d8a0c73ebb3	8e4e380d-f49e-4248-951e-0453f39d7545	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B	app_document_B.png	204800	f	\N	2026-08-16 13:38:41.727609+00
cd80b54b-940f-4dae-9469-4d2a79cd8a19	c0c66157-f2d6-42ae-b587-27292cc074a6	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A	app_document_A.png	204800	f	\N	2026-08-16 13:38:41.727609+00
3780288a-d92d-4700-bf20-b3c07bcc8bad	c0c66157-f2d6-42ae-b587-27292cc074a6	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B	app_document_B.png	204800	f	\N	2026-08-16 13:38:41.727609+00
f8c12a8e-787c-4f21-9a2b-e2a5be071a9b	f10bf085-13e5-450b-9150-f7d134863908	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A	app_document_A.png	204800	f	\N	2026-08-16 13:38:41.727609+00
57633cf1-895a-4655-b359-74b33bf00ab2	f10bf085-13e5-450b-9150-f7d134863908	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B	app_document_B.png	204800	f	\N	2026-08-16 13:38:41.727609+00
bf06ff6e-fb08-4958-bcb9-821bf188b645	8ca4fd2a-d85d-4465-9567-50a2242e8f98	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A	app_document_A.png	204800	f	\N	2026-08-16 13:38:41.727609+00
3822013a-1d12-4e37-83bf-02b44702108a	8ca4fd2a-d85d-4465-9567-50a2242e8f98	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B	app_document_B.png	204800	f	\N	2026-08-16 13:38:41.727609+00
629a3567-6806-41af-a538-50f289fb428d	a6501732-9bd7-44bb-b89f-459643f37f5a	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A	app_document_A.png	204800	f	\N	2026-08-16 13:38:41.727609+00
b50bda4b-a9f7-455d-adc8-9ed7777c60ee	a6501732-9bd7-44bb-b89f-459643f37f5a	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B	app_document_B.png	204800	f	\N	2026-08-16 13:38:41.727609+00
5dd2f7b1-ef64-4fd1-803b-c3cf30089c1d	81ee9973-ce8a-4475-92cd-1da7b60faee1	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A	app_document_A.png	204800	f	\N	2026-08-16 13:38:41.727609+00
6f8a4c77-5c02-4ffa-b0d7-d66fa3f2c5bf	81ee9973-ce8a-4475-92cd-1da7b60faee1	05cffb0c-2ae7-469f-918c-9208720dd9d9	https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B	app_document_B.png	204800	f	\N	2026-08-16 13:38:41.727609+00
\.


--
-- Data for Name: application_forward_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."application_forward_log" ("id", "application_id", "from_district_id", "to_district_id", "forwarded_by_id", "reason", "forwarded_at") FROM stdin;
\.


--
-- Data for Name: application_status_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."application_status_history" ("id", "application_id", "previous_status", "new_status", "changed_by_id", "remarks", "created_at") FROM stdin;
141ffa47-b97e-4699-a938-8283e8789ebc	8e4e380d-f49e-4248-951e-0453f39d7545	SUBMITTED	ADVOCATE_ASSIGNED	f60352e9-33a0-40f2-98f4-b79fe2795050	Advocate assigned	2026-08-16 14:08:41.727609+00
22debbb8-8125-4f1b-b37d-ae68de5347ff	c0c66157-f2d6-42ae-b587-27292cc074a6	SUBMITTED	SUBMITTED	f60352e9-33a0-40f2-98f4-b79fe2795050	Status updated	2026-08-16 14:08:41.727609+00
e808a573-fda7-41f2-a17d-71f55c5b05d7	f10bf085-13e5-450b-9150-f7d134863908	SUBMITTED	REJECTED	f60352e9-33a0-40f2-98f4-b79fe2795050	Application rejected	2026-08-16 14:08:41.727609+00
4977cbc2-24ae-4697-a30a-eef62afe64f5	8ca4fd2a-d85d-4465-9567-50a2242e8f98	SUBMITTED	UNDER_REVIEW	6903780c-c138-463e-af24-35991d1c2add	Moved to UNDER_REVIEW	2026-08-16 14:08:41.727609+00
e57d56f8-d973-42d6-947d-61ad08381cde	a6501732-9bd7-44bb-b89f-459643f37f5a	SUBMITTED	WITHDRAWN	6903780c-c138-463e-af24-35991d1c2add	Application withdrawn by citizen	2026-08-16 14:08:41.727609+00
08213ae3-3c37-4b81-93f6-105314725216	81ee9973-ce8a-4475-92cd-1da7b60faee1	SUBMITTED	RESOLVED	6903780c-c138-463e-af24-35991d1c2add	Application resolved	2026-08-16 14:08:41.727609+00
\.


--
-- Data for Name: case_type_document_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."case_type_document_map" ("case_type_id", "document_id", "is_required") FROM stdin;
1061ce0c-c230-47cc-b6d0-226e17acffbc	9a357f9d-dcef-48e2-a2e0-47afbf0698fa	t
\.


--
-- Data for Name: legal_aid_category_document_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."legal_aid_category_document_map" ("category_id", "document_id", "is_required") FROM stdin;
c8211997-2ac3-44cf-873b-949c2a44f431	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
6d4367bd-b8ba-4509-935a-d56e3501ed6d	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
ec9e7d1a-b486-4a33-afc6-1b3cb465c6cc	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
f3595cfc-9d99-4e1f-89be-b0186267de66	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
777165d6-14a6-4f91-92a6-34714498c49f	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
5793c5e6-9236-4dfd-8b82-fbb3d82dc092	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
196987de-5894-4a5a-9e0f-ddf23f50df12	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
837cce7d-b165-42d1-b6c8-7bcbcce502d1	2d30eaa3-ae5c-419c-9962-e13ad6a9333e	t
37dbfb26-af99-4ea8-a756-c668bf7abe2a	3c9f29b2-79fb-4914-a3d5-d325b1c3b03e	t
5793c5e6-9236-4dfd-8b82-fbb3d82dc092	a899b9db-3898-4a99-ad7c-ebe8ab9eecc8	t
6d4367bd-b8ba-4509-935a-d56e3501ed6d	8b5e97fc-8f41-4562-bec4-01f4482f442f	t
f3595cfc-9d99-4e1f-89be-b0186267de66	05cffb0c-2ae7-469f-918c-9208720dd9d9	t
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."roles" ("id", "code", "name", "description", "is_active", "is_system", "created_at", "updated_at") FROM stdin;
e94b47ed-936d-425e-a917-a2e5adc1a4df	SUPER_ADMIN	Super Administrator	Full access to all states, districts and configuration	t	t	2026-08-12 08:40:05.448217+00	2026-08-12 08:40:05.448217+00
b9439c55-dcd6-4534-9454-bb2c324fd8da	STATE_ADMIN	State Administrator	Full access within an assigned state	t	t	2026-08-12 08:40:05.448217+00	2026-08-12 08:40:05.448217+00
dc8fbd0f-5681-4141-b591-8d535436f745	DISTRICT_ADMIN	District Administrator	Manage applications and advocates in one district	t	t	2026-08-12 08:40:05.448217+00	2026-08-12 08:40:05.448217+00
acefa6e2-b1a2-4ffb-adca-dfa2361bd96a	STAFF	Office Staff	Read-only / data entry support	t	t	2026-08-12 08:40:05.448217+00	2026-08-12 08:40:05.448217+00
379f40e1-6222-417b-9b79-66cb6d290d0d	ADVOCATE	Advocate	Accept and manage assigned legal aid cases	t	t	2026-08-12 08:40:05.448217+00	2026-08-12 08:40:05.448217+00
79a6d608-17c3-4669-aa59-25d0de2cf6d4	CITIZEN	Citizen	Submit and track legal aid applications	t	t	2026-08-12 08:40:05.448217+00	2026-08-12 08:40:05.448217+00
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type") FROM stdin;
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."buckets_analytics" ("name", "type", "format", "created_at", "updated_at", "id", "deleted_at") FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."buckets_vectors" ("id", "type", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata") FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."s3_multipart_uploads" ("id", "in_progress_size", "upload_signature", "bucket_id", "key", "version", "owner_id", "created_at", "user_metadata", "metadata") FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."s3_multipart_uploads_parts" ("id", "upload_id", "size", "part_number", "bucket_id", "key", "etag", "owner_id", "version", "created_at") FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."vector_indexes" ("id", "name", "bucket_id", "data_type", "dimension", "distance_metric", "metadata_configuration", "created_at", "updated_at") FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 5, true);


--
-- Name: application_tracking_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."application_tracking_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict 18gkVSu0n2ZH0MWECMjBOjawRquZCZjwJOKq34Um6ka19WcOFWBhzWL2yKHK72p

RESET ALL;
