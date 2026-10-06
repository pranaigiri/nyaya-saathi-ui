SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict Ozw4SrdDchdJ6xnbLSn5OqyxGIEfsqTZTdzapWsZiItVFakPePKYH6q7DFjJZgY

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



--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at", "invite_token", "referrer", "oauth_client_state_id", "linking_target_id", "email_optional") VALUES
	('f28a1f78-cd70-4d40-b04e-28b6cd0c3060', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '739dbabf-9775-417a-b78b-e5bb97a27df1', 's256', 'miUdg44uW_wyxC7EnyAu-IJMkmqYgSIr3GhekgFrZ-I', 'email', '', '', '2026-08-16 20:05:22.559794+00', '2026-08-16 20:06:09.728273+00', 'email/signup', '2026-08-16 20:06:09.728232+00', NULL, NULL, NULL, NULL, false),
	('a34a022d-e7d7-4714-b9f4-d79388afcaea', '22d7227d-4705-4657-a6bd-3efd86df22f0', '124a875f-a6af-419e-9c11-c6ea7544badb', 's256', 'OWOJ6je5lIPbz3LVvDpttM8f9DF-hS4fnETCT_77VjM', 'email', '', '', '2026-09-01 09:23:21.272162+00', '2026-09-01 09:23:50.042573+00', 'email/signup', '2026-09-01 09:23:50.042528+00', NULL, NULL, NULL, NULL, false);


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '08d3a553-becb-414a-959b-b4128059f0b4', 'authenticated', 'authenticated', 'mangan@ns.com', '$2a$10$apgTHn53D0Gywidya8KJWevgM8f7LtGlCIlUUp4N3CY4VXC4uv3/C', '2026-08-12 09:10:44.893575+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:10:44.890729+00', '2026-08-12 09:10:44.894224+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '6903780c-c138-463e-af24-35991d1c2add', 'authenticated', 'authenticated', 'testcitizen2@ns.com', '$2a$10$aL1MDi9Zxvfqu6M./vP2neAe8z6IUTPvgEewalGmQvhPJFlr90JQK', '2026-08-14 11:01:16.975626+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-14 11:01:16.972349+00', '2026-08-14 11:01:16.979048+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'd47c0484-3a48-49b9-a614-7fdf92c6c980', 'authenticated', 'authenticated', 'pakyong@ns.com', '$2a$10$HmUPP.b6HzZVVwH.rVLI5.QqxX2RatlLeIe/jtdzoEGHg0Su6KcNO', '2026-08-12 09:11:09.272845+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:11:09.270292+00', '2026-08-12 09:11:09.273526+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '4a451781-317b-41b0-b7d7-b2183204febd', 'authenticated', 'authenticated', 'admin@ns.com', '$2a$10$FBdP9DpEJny54wj84fCNlOGsBqEgXj.0ttcUZOdfzDVsDObd3bnwK', '2026-08-12 07:48:05.668231+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-10 15:30:05.096863+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 07:48:05.648359+00', '2026-09-10 17:35:33.442459+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', 'authenticated', 'authenticated', 'soreng@ns.com', '$2a$10$cuxK03nvMIM8ZM1jVG51EOv9q75jZ272eWeQO/WHLNPmzQZ1lnjJG', '2026-08-12 09:11:18.791127+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-10 17:38:31.02706+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:11:18.788339+00', '2026-09-11 12:18:39.63761+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'f5c4ef6d-632c-4c91-bfd8-944db57db1c6', 'authenticated', 'authenticated', 'gyalshing@ns.com', '$2a$10$9Tj..bVjsVLzgbKt6aoGDeuo/65kYuUu5elhJcuCOUBm2BVgJBDh6', '2026-08-12 09:10:56.125549+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-08-16 16:22:27.106111+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:10:56.121762+00', '2026-08-16 16:22:27.110719+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'f60352e9-33a0-40f2-98f4-b79fe2795050', 'authenticated', 'authenticated', 'testcitizen1@ns.com', '$2a$10$9DVNY/yC3Z6xTYs2qkQXQedi9lGEbVFGAlNnc/.HA0KMILb8kzocO', '2026-08-14 11:01:07.12706+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-08-16 18:01:50.575088+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-14 11:01:07.104692+00', '2026-08-16 19:01:16.302574+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', 'authenticated', 'authenticated', 'sikkim@ns.com', '$2a$10$UopJmNpbYDibFtCGu3z7g.i2shJLKBQOwlmckHnDW3BeZQZ/weZb2', '2026-08-12 09:10:05.481438+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-29 09:11:23.95+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:10:05.476079+00', '2026-09-29 11:13:45.491834+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', 'authenticated', 'authenticated', 'pranaigirisikkim@gmail.com', '$2a$10$l3/v4pAQc2ABbZ6zwVgHCuVMSr1AhgWhwjLrU5KASISdqSXZWhUg.', '2026-08-16 20:06:09.717403+00', NULL, '', '2026-08-16 20:05:22.567082+00', '', NULL, '', '', NULL, '2026-10-06 09:53:50.180165+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "7d6cf0f7-41ff-4095-ac26-8386242ee00d", "email": "pranaigirisikkim@gmail.com", "full_name": "Pranai Giri", "phone_number": "8918674671", "email_verified": true, "phone_verified": false}', NULL, '2026-08-16 20:05:22.508147+00', '2026-10-06 09:53:50.222061+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '22d7227d-4705-4657-a6bd-3efd86df22f0', 'authenticated', 'authenticated', 'prannyll@gmail.com', '$2a$10$iLwi5hFrZE16ynAVGnq6HuAjzRdZYWZxBDqjaO/T6AnC1fsVHjLZW', '2026-09-01 09:23:50.036153+00', NULL, '', '2026-09-01 09:23:21.281477+00', '', NULL, '', '', NULL, '2026-09-01 09:24:39.725515+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "22d7227d-4705-4657-a6bd-3efd86df22f0", "email": "prannyll@gmail.com", "full_name": "Pran Nyll", "phone_number": "9907049407", "email_verified": true, "phone_verified": false}', NULL, '2026-09-01 09:23:21.215473+00', '2026-09-01 09:24:39.757843+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '68fe332c-25a5-4d47-a713-b2aea2f06d06', 'authenticated', 'authenticated', 'gangtok@ns.com', '$2a$10$c1ukII/AptnykZJlEOf8kegsqQjbl9RLxqo0JoxshgyCBT8sFvQqa', '2026-08-12 09:10:18.603568+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-05 09:08:38.199657+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:10:18.60037+00', '2026-09-05 09:08:38.203413+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '79a64c73-e2d6-4596-ade4-18cf376b4a69', 'authenticated', 'authenticated', 'namchi@ns.com', '$2a$10$YTQY2IeqFzJWWpanX95FtOQ2soMEioukU/cxu0mvAg1MIlQhKYbYi', '2026-08-12 09:10:33.949741+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-05 09:21:52.981655+00', '{"provider": "email", "providers": ["email"]}', '{"email_verified": true}', NULL, '2026-08-12 09:10:33.94694+00', '2026-09-05 09:21:52.993643+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('4a451781-317b-41b0-b7d7-b2183204febd', '4a451781-317b-41b0-b7d7-b2183204febd', '{"sub": "4a451781-317b-41b0-b7d7-b2183204febd", "email": "admin@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 07:48:05.660688+00', '2026-08-12 07:48:05.660753+00', '2026-08-12 07:48:05.660753+00', 'b278ffff-1a64-4b20-922f-5833a3701c2f'),
	('8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', '{"sub": "8a2d51e9-dfde-477c-b8d0-3bbf449f67b3", "email": "sikkim@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:10:05.47988+00', '2026-08-12 09:10:05.479923+00', '2026-08-12 09:10:05.479923+00', 'f0ef8565-f932-4765-bf64-69f9e95c6a24'),
	('68fe332c-25a5-4d47-a713-b2aea2f06d06', '68fe332c-25a5-4d47-a713-b2aea2f06d06', '{"sub": "68fe332c-25a5-4d47-a713-b2aea2f06d06", "email": "gangtok@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:10:18.602024+00', '2026-08-12 09:10:18.602073+00', '2026-08-12 09:10:18.602073+00', '60d4df4d-d081-4434-ba11-85e4d15cde72'),
	('79a64c73-e2d6-4596-ade4-18cf376b4a69', '79a64c73-e2d6-4596-ade4-18cf376b4a69', '{"sub": "79a64c73-e2d6-4596-ade4-18cf376b4a69", "email": "namchi@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:10:33.948296+00', '2026-08-12 09:10:33.948343+00', '2026-08-12 09:10:33.948343+00', '7cc02b84-351c-4149-a8f0-6829e4585e21'),
	('08d3a553-becb-414a-959b-b4128059f0b4', '08d3a553-becb-414a-959b-b4128059f0b4', '{"sub": "08d3a553-becb-414a-959b-b4128059f0b4", "email": "mangan@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:10:44.891986+00', '2026-08-12 09:10:44.892026+00', '2026-08-12 09:10:44.892026+00', '840b25a0-9808-49db-81b0-ce8d28896865'),
	('f5c4ef6d-632c-4c91-bfd8-944db57db1c6', 'f5c4ef6d-632c-4c91-bfd8-944db57db1c6', '{"sub": "f5c4ef6d-632c-4c91-bfd8-944db57db1c6", "email": "gyalshing@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:10:56.124187+00', '2026-08-12 09:10:56.124246+00', '2026-08-12 09:10:56.124246+00', '4161baae-274f-4ee8-8568-aac5cc6f135a'),
	('d47c0484-3a48-49b9-a614-7fdf92c6c980', 'd47c0484-3a48-49b9-a614-7fdf92c6c980', '{"sub": "d47c0484-3a48-49b9-a614-7fdf92c6c980", "email": "pakyong@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:11:09.271514+00', '2026-08-12 09:11:09.271562+00', '2026-08-12 09:11:09.271562+00', 'c4ac4846-91c5-4806-b611-36605eddbeb2'),
	('ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', 'ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', '{"sub": "ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5", "email": "soreng@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-12 09:11:18.7898+00', '2026-08-12 09:11:18.789846+00', '2026-08-12 09:11:18.789846+00', '5e048df8-e3be-4d60-9dd0-c27fe63aee8a'),
	('f60352e9-33a0-40f2-98f4-b79fe2795050', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '{"sub": "f60352e9-33a0-40f2-98f4-b79fe2795050", "email": "testcitizen1@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-14 11:01:07.120549+00', '2026-08-14 11:01:07.120607+00', '2026-08-14 11:01:07.120607+00', 'e78a2093-cacf-491f-a6f2-3f855f8907a2'),
	('6903780c-c138-463e-af24-35991d1c2add', '6903780c-c138-463e-af24-35991d1c2add', '{"sub": "6903780c-c138-463e-af24-35991d1c2add", "email": "testcitizen2@ns.com", "email_verified": false, "phone_verified": false}', 'email', '2026-08-14 11:01:16.974257+00', '2026-08-14 11:01:16.974308+00', '2026-08-14 11:01:16.974308+00', '64516e1d-519b-42c8-ab23-a90eb445cd11'),
	('7d6cf0f7-41ff-4095-ac26-8386242ee00d', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '{"sub": "7d6cf0f7-41ff-4095-ac26-8386242ee00d", "email": "pranaigirisikkim@gmail.com", "full_name": "Pranai Giri", "phone_number": "8918674671", "email_verified": true, "phone_verified": false}', 'email', '2026-08-16 20:05:22.547041+00', '2026-08-16 20:05:22.547085+00', '2026-08-16 20:05:22.547085+00', 'a9081837-abd9-4417-9d50-5886b50f7100'),
	('22d7227d-4705-4657-a6bd-3efd86df22f0', '22d7227d-4705-4657-a6bd-3efd86df22f0', '{"sub": "22d7227d-4705-4657-a6bd-3efd86df22f0", "email": "prannyll@gmail.com", "full_name": "Pran Nyll", "phone_number": "9907049407", "email_verified": true, "phone_verified": false}', 'email', '2026-09-01 09:23:21.263049+00', '2026-09-01 09:23:21.263108+00', '2026-09-01 09:23:21.263108+00', 'a3db23e2-bd55-4c34-91e9-ddb497793632');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('843b97ee-2da8-4971-8635-9cf31a276100', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', '2026-09-11 12:19:06.585828+00', '2026-09-11 12:19:06.585828+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '223.181.51.64', NULL, NULL, NULL, NULL, NULL),
	('7289db1a-daf1-47b9-a77f-cc2b4c5c0caa', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-08-16 20:10:44.601979+00', '2026-09-13 09:35:39.723357+00', NULL, 'aal1', NULL, '2026-09-13 09:35:39.723247', 'Dart/3.12 (dart:io)', '223.181.51.205', NULL, NULL, NULL, NULL, NULL),
	('663b3b6b-62ac-4109-a78b-59e164bf81c1', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-13 11:05:48.837282+00', '2026-09-13 11:05:48.837282+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '223.181.51.205', NULL, NULL, NULL, NULL, NULL),
	('0678c85a-e4a9-4122-ab44-bee109b963b8', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-13 11:38:37.346521+00', '2026-09-13 11:38:37.346521+00', NULL, 'aal1', NULL, NULL, 'Dart/3.12 (dart:io)', '223.181.51.205', NULL, NULL, NULL, NULL, NULL),
	('296c4fd4-3472-4f65-9c3d-7a71b4970234', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-13 11:50:32.35168+00', '2026-09-13 11:50:32.35168+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '223.181.51.205', NULL, NULL, NULL, NULL, NULL),
	('89600e00-9bd1-4ea0-9b2b-7a3b2be2d09b', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-13 11:55:27.1276+00', '2026-09-13 11:55:27.1276+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '223.181.51.205', NULL, NULL, NULL, NULL, NULL),
	('8a30ba2b-8178-423a-838c-031f9951f47a', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 15:41:02.152974+00', '2026-08-16 16:40:31.092379+00', NULL, 'aal1', NULL, '2026-08-16 16:40:31.092282', 'Dart/3.12 (dart:io)', '223.181.54.211', NULL, NULL, NULL, NULL, NULL),
	('7c2c024e-823a-4079-805f-e19c11143c79', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:01:50.575709+00', '2026-08-16 19:01:16.31694+00', NULL, 'aal1', NULL, '2026-08-16 19:01:16.316836', 'Dart/3.12 (dart:io)', '223.181.54.211', NULL, NULL, NULL, NULL, NULL),
	('82c0eaea-9889-4fe4-91c7-2ad8112b2612', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-08-31 08:42:40.258512+00', '2026-08-31 12:45:19.341504+00', NULL, 'aal1', NULL, '2026-08-31 12:45:19.341385', 'Dart/3.12 (dart:io)', '152.59.160.196', NULL, NULL, NULL, NULL, NULL),
	('e01ec924-aca6-49a4-a55e-16be474b5a74', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-01 04:04:57.632596+00', '2026-09-02 14:47:47.369802+00', NULL, 'aal1', NULL, '2026-09-02 14:47:47.369682', 'Dart/3.12 (dart:io)', '223.181.52.100', NULL, NULL, NULL, NULL, NULL),
	('6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-08-31 14:12:50.001747+00', '2026-09-01 04:01:53.081828+00', NULL, 'aal1', NULL, '2026-09-01 04:01:53.081681', 'Dart/3.12 (dart:io)', '223.181.49.162', NULL, NULL, NULL, NULL, NULL),
	('93adcdec-f1be-4063-8e13-39ece2c61210', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-13 12:14:43.116177+00', '2026-09-13 14:13:54.270609+00', NULL, 'aal1', NULL, '2026-09-13 14:13:54.270483', 'Dart/3.12 (dart:io)', '223.181.51.205', NULL, NULL, NULL, NULL, NULL),
	('7f768f82-7dc7-4ab1-bb98-2e80222ec21f', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', '2026-09-29 09:11:23.950816+00', '2026-09-29 11:13:45.511226+00', NULL, 'aal1', NULL, '2026-09-29 11:13:45.511129', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '152.59.161.243', NULL, NULL, NULL, NULL, NULL),
	('237c9ce1-e84f-47b6-b6ef-398e052d8554', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-10-06 09:53:50.181378+00', '2026-10-06 09:53:50.181378+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '117.194.168.4', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('8a30ba2b-8178-423a-838c-031f9951f47a', '2026-08-16 15:41:02.20224+00', '2026-08-16 15:41:02.20224+00', 'password', 'e3acd9a7-f5ba-4389-9253-4832da571d2b'),
	('843b97ee-2da8-4971-8635-9cf31a276100', '2026-09-11 12:19:06.604164+00', '2026-09-11 12:19:06.604164+00', 'password', '687d60c0-ef51-44f2-b551-c1c7ef52483f'),
	('663b3b6b-62ac-4109-a78b-59e164bf81c1', '2026-09-13 11:05:48.894164+00', '2026-09-13 11:05:48.894164+00', 'password', 'eb11aaa8-788b-4beb-baf3-112d881dcf07'),
	('0678c85a-e4a9-4122-ab44-bee109b963b8', '2026-09-13 11:38:37.393759+00', '2026-09-13 11:38:37.393759+00', 'password', '003f0c8e-2cb3-47a4-a3a9-50e26891ac81'),
	('7c2c024e-823a-4079-805f-e19c11143c79', '2026-08-16 18:01:50.603313+00', '2026-08-16 18:01:50.603313+00', 'password', 'b0e1b85a-40b4-42b6-8ce4-b82b245a1a4a'),
	('7289db1a-daf1-47b9-a77f-cc2b4c5c0caa', '2026-08-16 20:10:44.638595+00', '2026-08-16 20:10:44.638595+00', 'password', '8d3fffed-dcba-46fa-8f7a-b7ea1bf8eca8'),
	('296c4fd4-3472-4f65-9c3d-7a71b4970234', '2026-09-13 11:50:32.363333+00', '2026-09-13 11:50:32.363333+00', 'password', '606f55df-2d85-4a99-89ac-4ef837f58fb5'),
	('89600e00-9bd1-4ea0-9b2b-7a3b2be2d09b', '2026-09-13 11:55:27.141372+00', '2026-09-13 11:55:27.141372+00', 'password', '36633e06-362f-4f22-8bd8-b8cc9edf9164'),
	('93adcdec-f1be-4063-8e13-39ece2c61210', '2026-09-13 12:14:43.15388+00', '2026-09-13 12:14:43.15388+00', 'password', 'c891cd86-6972-4bae-abc2-bd856c394a76'),
	('7f768f82-7dc7-4ab1-bb98-2e80222ec21f', '2026-09-29 09:11:23.991726+00', '2026-09-29 09:11:23.991726+00', 'password', 'ee2fd59a-e653-4651-bd5c-1bbf2592e2d4'),
	('82c0eaea-9889-4fe4-91c7-2ad8112b2612', '2026-08-31 08:42:40.350312+00', '2026-08-31 08:42:40.350312+00', 'password', '29f85f54-f903-4bff-a66f-0f6850c376f0'),
	('6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4', '2026-08-31 14:12:50.05684+00', '2026-08-31 14:12:50.05684+00', 'password', '6eb6becb-e8a5-446c-900b-24bf924da7e9'),
	('e01ec924-aca6-49a4-a55e-16be474b5a74', '2026-09-01 04:04:57.670007+00', '2026-09-01 04:04:57.670007+00', 'password', '703f27c4-9167-4d0f-9dfb-2b0e64b22681'),
	('237c9ce1-e84f-47b6-b6ef-398e052d8554', '2026-10-06 09:53:50.234414+00', '2026-10-06 09:53:50.234414+00', 'password', 'ac3700fa-40e5-4861-a73b-c84e0ca058a6');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_recovery_code_sets; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_recovery_codes; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 6, 'ihtesdtlj4h7', 'f60352e9-33a0-40f2-98f4-b79fe2795050', true, '2026-08-16 15:41:02.171558+00', '2026-08-16 16:40:31.062145+00', NULL, '8a30ba2b-8178-423a-838c-031f9951f47a'),
	('00000000-0000-0000-0000-000000000000', 12, 'ytqq6qoj6bxn', 'f60352e9-33a0-40f2-98f4-b79fe2795050', false, '2026-08-16 16:40:31.070629+00', '2026-08-16 16:40:31.070629+00', 'ihtesdtlj4h7', '8a30ba2b-8178-423a-838c-031f9951f47a'),
	('00000000-0000-0000-0000-000000000000', 14, 'qmt23k7a5yce', 'f60352e9-33a0-40f2-98f4-b79fe2795050', true, '2026-08-16 18:01:50.591409+00', '2026-08-16 19:01:16.29276+00', NULL, '7c2c024e-823a-4079-805f-e19c11143c79'),
	('00000000-0000-0000-0000-000000000000', 16, '6nvjznt6gext', 'f60352e9-33a0-40f2-98f4-b79fe2795050', false, '2026-08-16 19:01:16.301095+00', '2026-08-16 19:01:16.301095+00', 'qmt23k7a5yce', '7c2c024e-823a-4079-805f-e19c11143c79'),
	('00000000-0000-0000-0000-000000000000', 23, 'a3h7n6g343yb', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-08-31 08:42:40.31187+00', '2026-08-31 12:45:19.292381+00', NULL, '82c0eaea-9889-4fe4-91c7-2ad8112b2612'),
	('00000000-0000-0000-0000-000000000000', 25, 'f475qzotoclw', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-08-31 12:45:19.313212+00', '2026-08-31 12:45:19.313212+00', 'a3h7n6g343yb', '82c0eaea-9889-4fe4-91c7-2ad8112b2612'),
	('00000000-0000-0000-0000-000000000000', 26, 'kdo7uswgfk7s', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-08-31 14:12:50.032647+00', '2026-08-31 15:12:20.268371+00', NULL, '6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4'),
	('00000000-0000-0000-0000-000000000000', 27, 'q2b2eox6adm4', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-08-31 15:12:20.284657+00', '2026-08-31 16:11:46.345041+00', 'kdo7uswgfk7s', '6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4'),
	('00000000-0000-0000-0000-000000000000', 28, 'oibykfartwzv', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-08-31 16:11:46.359006+00', '2026-08-31 17:11:17.425037+00', 'q2b2eox6adm4', '6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4'),
	('00000000-0000-0000-0000-000000000000', 29, 'jxbrecrmbzys', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-08-31 17:11:17.435222+00', '2026-09-01 04:01:53.033602+00', 'oibykfartwzv', '6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4'),
	('00000000-0000-0000-0000-000000000000', 32, 'i27vaok4sejg', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-01 04:01:53.049796+00', '2026-09-01 04:01:53.049796+00', 'jxbrecrmbzys', '6cbd68b2-8b91-4f92-ba84-61ceaee1bfa4'),
	('00000000-0000-0000-0000-000000000000', 116, 'tounqurk3iat', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', false, '2026-09-11 12:19:06.597009+00', '2026-09-11 12:19:06.597009+00', NULL, '843b97ee-2da8-4971-8635-9cf31a276100'),
	('00000000-0000-0000-0000-000000000000', 18, 'yfafesl7thyq', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-08-16 20:10:44.624404+00', '2026-09-13 09:35:39.664793+00', NULL, '7289db1a-daf1-47b9-a77f-cc2b4c5c0caa'),
	('00000000-0000-0000-0000-000000000000', 117, 'uritieyc5ajz', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-13 09:35:39.685877+00', '2026-09-13 09:35:39.685877+00', 'yfafesl7thyq', '7289db1a-daf1-47b9-a77f-cc2b4c5c0caa'),
	('00000000-0000-0000-0000-000000000000', 118, 'hp3hjryrbe2w', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-13 11:05:48.861722+00', '2026-09-13 11:05:48.861722+00', NULL, '663b3b6b-62ac-4109-a78b-59e164bf81c1'),
	('00000000-0000-0000-0000-000000000000', 119, 'u4352neninx7', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-13 11:38:37.370204+00', '2026-09-13 11:38:37.370204+00', NULL, '0678c85a-e4a9-4122-ab44-bee109b963b8'),
	('00000000-0000-0000-0000-000000000000', 120, 'dldfjl2t5bi3', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-13 11:50:32.357872+00', '2026-09-13 11:50:32.357872+00', NULL, '296c4fd4-3472-4f65-9c3d-7a71b4970234'),
	('00000000-0000-0000-0000-000000000000', 121, 'xoyh6czv6g4r', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-13 11:55:27.134841+00', '2026-09-13 11:55:27.134841+00', NULL, '89600e00-9bd1-4ea0-9b2b-7a3b2be2d09b'),
	('00000000-0000-0000-0000-000000000000', 122, 'vdyqnwybvipp', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-09-13 12:14:43.131635+00', '2026-09-13 13:14:20.618841+00', NULL, '93adcdec-f1be-4063-8e13-39ece2c61210'),
	('00000000-0000-0000-0000-000000000000', 123, 'p3ewqsyzbj55', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-09-13 13:14:20.631385+00', '2026-09-13 14:13:54.218659+00', 'vdyqnwybvipp', '93adcdec-f1be-4063-8e13-39ece2c61210'),
	('00000000-0000-0000-0000-000000000000', 124, 'mzjjdkqbwhsh', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-13 14:13:54.235344+00', '2026-09-13 14:13:54.235344+00', 'p3ewqsyzbj55', '93adcdec-f1be-4063-8e13-39ece2c61210'),
	('00000000-0000-0000-0000-000000000000', 126, 'gqrf2zcpvxfi', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', true, '2026-09-29 09:11:23.97558+00', '2026-09-29 10:15:35.912048+00', NULL, '7f768f82-7dc7-4ab1-bb98-2e80222ec21f'),
	('00000000-0000-0000-0000-000000000000', 33, 'asug4vbbpc6u', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', true, '2026-09-01 04:04:57.657929+00', '2026-09-02 14:47:47.315261+00', NULL, 'e01ec924-aca6-49a4-a55e-16be474b5a74'),
	('00000000-0000-0000-0000-000000000000', 48, 'lebvk4myetma', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-09-02 14:47:47.336126+00', '2026-09-02 14:47:47.336126+00', 'asug4vbbpc6u', 'e01ec924-aca6-49a4-a55e-16be474b5a74'),
	('00000000-0000-0000-0000-000000000000', 127, 'uyzxa77pdeud', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', true, '2026-09-29 10:15:35.930887+00', '2026-09-29 11:13:45.47821+00', 'gqrf2zcpvxfi', '7f768f82-7dc7-4ab1-bb98-2e80222ec21f'),
	('00000000-0000-0000-0000-000000000000', 129, '32pmsfiyirdq', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', false, '2026-09-29 11:13:45.486979+00', '2026-09-29 11:13:45.486979+00', 'uyzxa77pdeud', '7f768f82-7dc7-4ab1-bb98-2e80222ec21f'),
	('00000000-0000-0000-0000-000000000000', 130, 'np5xbdywfngy', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', false, '2026-10-06 09:53:50.216078+00', '2026-10-06 09:53:50.216078+00', NULL, '237c9ce1-e84f-47b6-b6ef-398e052d8554');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: scim_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: scim_users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: state_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."state_master" ("id", "state_name", "state_code", "created_at") VALUES
	('1ba79647-e698-4d33-8fca-2b9ae70949b5', 'Sikkim', 'SK', '2026-08-12 08:05:57.480303+00');


--
-- Data for Name: district_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."district_master" ("id", "district_name", "district_code", "state_id", "created_at") VALUES
	('162e0db6-feb9-44ea-9476-483c844f4956', 'Gangtok', 'GTK', '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2026-08-12 08:05:57.480303+00'),
	('7c7faa9f-4cbb-450d-9046-15ef51430cd9', 'Namchi', 'NAM', '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2026-08-12 08:05:57.480303+00'),
	('d434b194-4038-4342-b475-0f1ef7b44ae4', 'Gyalshing', 'GYL', '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2026-08-12 08:05:57.480303+00'),
	('18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', 'Mangan', 'MAN', '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2026-08-12 08:05:57.480303+00'),
	('771eac9c-c0b1-4b1b-acfa-658163c4a82f', 'Pakyong', 'PAK', '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2026-08-12 08:05:57.480303+00'),
	('2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', 'Soreng', 'SOR', '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2026-08-12 08:05:57.480303+00');


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "full_name", "phone_number", "email", "dob", "gender", "village_or_town", "district_id", "user_type", "status", "last_login_at", "created_at", "updated_at", "fcm_token") VALUES
	('7d6cf0f7-41ff-4095-ac26-8386242ee00d', 'Pranai Giri', '8918674671', 'pranaigirisikkim@gmail.com', '2001-08-23', 'Male', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', 'CITIZEN', 'ACTIVE', NULL, '2026-08-16 20:05:22.505852+00', '2026-09-29 10:59:55.952213+00', 'esED2VqjQ7-qdzU1wLieym:APA91bE_mXiyuKO20HUtbTHglb9x0gHtXePbvgmZnhcVfLW6xlo26Kzoxy7OfSJ5mnO3_xD20eBohTZ3MUIYswylzXY5V-KWNmXPSph1j1XEfntLU23kO6I'),
	('f60352e9-33a0-40f2-98f4-b79fe2795050', 'Citizen', NULL, 'testcitizen1@ns.com', NULL, NULL, NULL, NULL, 'CITIZEN', 'ACTIVE', NULL, '2026-08-14 11:01:07.102296+00', '2026-08-16 19:44:03.27684+00', NULL),
	('22d7227d-4705-4657-a6bd-3efd86df22f0', 'Pran Nyll', '9907049407', 'prannyll@gmail.com', NULL, NULL, NULL, NULL, 'CITIZEN', 'ACTIVE', NULL, '2026-09-01 09:23:21.213827+00', '2026-09-01 09:24:41.310249+00', 'esED2VqjQ7-qdzU1wLieym:APA91bE_mXiyuKO20HUtbTHglb9x0gHtXePbvgmZnhcVfLW6xlo26Kzoxy7OfSJ5mnO3_xD20eBohTZ3MUIYswylzXY5V-KWNmXPSph1j1XEfntLU23kO6I'),
	('6903780c-c138-463e-af24-35991d1c2add', 'Citizen', NULL, 'testcitizen2@ns.com', NULL, NULL, NULL, NULL, 'CITIZEN', 'ACTIVE', NULL, '2026-08-14 11:01:16.972059+00', '2026-08-14 11:01:16.972059+00', NULL),
	('4a451781-317b-41b0-b7d7-b2183204febd', 'SuperAdmin', NULL, 'admin@ns.com', NULL, NULL, NULL, NULL, 'SUPER_ADMIN', 'ACTIVE', NULL, '2026-08-12 07:48:05.647474+00', '2026-09-07 11:01:36.876234+00', NULL),
	('8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', 'Sikkim SLSA', NULL, 'sikkim@ns.com', NULL, NULL, NULL, NULL, 'STATE_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:10:05.475778+00', '2026-09-07 11:01:36.876234+00', NULL),
	('68fe332c-25a5-4d47-a713-b2aea2f06d06', 'DLSA Gangtok', NULL, 'gangtok@ns.com', NULL, NULL, NULL, NULL, 'DISTRICT_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:10:18.596224+00', '2026-09-07 11:01:36.876234+00', NULL),
	('08d3a553-becb-414a-959b-b4128059f0b4', 'DLSA Mangan', NULL, 'mangan@ns.com', NULL, NULL, NULL, NULL, 'DISTRICT_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:10:44.890422+00', '2026-09-07 11:01:36.876234+00', NULL),
	('ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', 'DLSA Soreng', NULL, 'soreng@ns.com', NULL, NULL, NULL, NULL, 'DISTRICT_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:11:18.78804+00', '2026-09-07 11:01:36.876234+00', NULL),
	('79a64c73-e2d6-4596-ade4-18cf376b4a69', 'DLSA Namchi', NULL, 'namchi@ns.com', NULL, NULL, NULL, NULL, 'DISTRICT_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:10:33.946609+00', '2026-09-07 11:01:36.876234+00', NULL),
	('d47c0484-3a48-49b9-a614-7fdf92c6c980', 'DLSA Pakyong', NULL, 'pakyong@ns.com', NULL, NULL, NULL, NULL, 'DISTRICT_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:11:09.269998+00', '2026-09-07 11:01:36.876234+00', NULL),
	('f5c4ef6d-632c-4c91-bfd8-944db57db1c6', 'DLSA Gyalshing', NULL, 'gyalshing@ns.com', NULL, NULL, NULL, NULL, 'DISTRICT_ADMIN', 'ACTIVE', NULL, '2026-08-12 09:10:56.120901+00', '2026-09-07 11:01:36.876234+00', NULL);


--
-- Data for Name: admin_scope; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."admin_scope" ("id", "user_id", "is_global_super_admin", "state_id", "district_id", "scope_level", "created_at") VALUES
	('26d556c2-5328-4a72-9f58-f1d805226506', '4a451781-317b-41b0-b7d7-b2183204febd', true, NULL, NULL, 'GLOBAL', '2026-08-12 09:15:01.201769+00'),
	('5c160124-13e3-44db-9828-24ef0eeb3560', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', NULL, 'STATE', '2026-08-12 09:15:01.201769+00'),
	('1cc64ce6-7315-4fea-aab3-fd4ef4181b57', '68fe332c-25a5-4d47-a713-b2aea2f06d06', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', '162e0db6-feb9-44ea-9476-483c844f4956', 'DISTRICT', '2026-08-12 09:15:01.201769+00'),
	('0bfa8043-bab4-4caa-8a5c-14d837e41399', '08d3a553-becb-414a-959b-b4128059f0b4', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', 'DISTRICT', '2026-08-12 09:15:01.201769+00'),
	('95a3d3b4-6e0b-4c50-8086-abc684f2f201', 'ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', 'DISTRICT', '2026-08-12 09:15:01.201769+00'),
	('2d4109f0-9dee-4bfe-8a0f-5ca7bb0afbe9', '79a64c73-e2d6-4596-ade4-18cf376b4a69', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', 'DISTRICT', '2026-08-12 09:15:01.201769+00'),
	('d40977c4-140c-4258-8073-ddfba525cef7', 'd47c0484-3a48-49b9-a614-7fdf92c6c980', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', 'DISTRICT', '2026-08-12 09:15:01.201769+00'),
	('937d3505-ab14-494d-b5a0-2606a3815ff6', 'f5c4ef6d-632c-4c91-bfd8-944db57db1c6', false, '1ba79647-e698-4d33-8fca-2b9ae70949b5', 'd434b194-4038-4342-b475-0f1ef7b44ae4', 'DISTRICT', '2026-08-12 09:15:01.201769+00');


--
-- Data for Name: advocate_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."advocate_master" ("id", "user_id", "full_name", "gender", "enrollment_number", "primary_email", "secondary_email", "primary_phone_number", "secondary_phone_number", "office_address", "experience_years", "is_active", "is_available_for_assignment", "created_at", "updated_at") VALUES
	('3cc31969-af68-4be9-bc9d-8e69bd810811', NULL, 'Shri N.B. Khatiwada, Senior Advocate', 'Male', 'W/F/367/362/84', 'nbkhatiwada@gmail.com', NULL, '9434031910', NULL, NULL, 20, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('47e0c7b9-eb0e-43ee-9776-89d161a02aec', NULL, 'Shri A.K.Upadhayaya,Senior Advocate', 'Male', '45/1978', 'akupadhyaya1952@gmail.com', NULL, '9832040696', NULL, NULL, 20, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('365e9eca-06b6-4cd8-85dc-bfd96a013bad', NULL, 'Shri Narendra Rai,Senior Advocate', 'Male', 'F/102/99/88', 'narendraraiadv@yahoo.co.in', NULL, '9434103497', NULL, NULL, 20, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('71fce84b-4ac1-42b6-868d-b2448a8109d6', NULL, 'Dr Doma T Bhutia, Senior Advocate', 'Female', 'TEMP/4/REG', 'domabhutia_gen@slsa.gov.in', NULL, '9000000004', NULL, NULL, 20, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('4be9c9ee-bdfc-4284-a85e-9f11e7c36e65', NULL, 'Mr. S.S Hamal,Senior Advocate', 'Male', 'SI62/157/88', 'hamalss@sify.com', NULL, '9832037913', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('9a69156c-e8fe-4499-8dcc-0220163e4a2f', NULL, 'Mr. Jorgay Namka,Senior Advocate', 'Male', 'D/1365/2000', 'jorgaynamka@gmail.com', NULL, '9733018131', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('2f4fad71-8c19-4fef-9fec-f7ecf2334937', NULL, 'Mr. Rajendra Upreti', 'Male', 'F/430/826/97', 'rajenupreti.adv@gmail.com', NULL, '9434109747', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a8ddba32-ba22-4c8b-8a0a-b77ca8c56b9e', NULL, 'Mr. B.K Gupta', 'Male', 'F/54/57/1996', 'laxmisikkim@gmail.com', NULL, '943463112', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c416cbe7-0df7-4ced-ae54-485745b1f983', NULL, 'Ms. Laxmi Chakraborty', 'Female', 'F/1880/1989 of 1995', 'bkgupta22@ymail.com', NULL, '9832005585', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('71ab48ae-0765-4462-9b13-185ffd482323', NULL, 'Mr. Umesh Ranpal', 'Male', '516 (B)/1996', 'umeshr_skm@yahoo.com', NULL, '9434117185', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('f94da927-1386-41ae-ab23-5be9a6e57348', NULL, 'Mr. J.K.P Jaiswal', 'Male', 'F/1421/1525 of 2000', 'jk_jaiswal@yahoo.in', NULL, '9832039371', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('129b3db0-3889-46d7-bf7b-0b4dc5892446', NULL, 'Mr. Devi Prasad Sharma', 'Male', 'WB/1476/2001', 'acharyadeviprasad15@gmail.com', NULL, '9832089946', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a6420833-f7d1-4ffe-999f-154933c96d58', NULL, 'Mr. B.C Tamang', 'Male', '926/910/2000', 'tamangbidya@yahoo.com', NULL, '9641832210', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ce44b191-b634-43ca-b9a2-57de646c1199', NULL, 'Ms. Kessang Diki Bhutia', 'Female', '1088/1015/2001', 'kissushanaz@yahoo.com', NULL, '9593676747', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('4bb8be65-61b4-457b-b803-8ea7982f579c', NULL, 'Mr. Tempo Gyatso Bhutia', 'Male', '15909/T/152', 'tgbhutia@yahoo.com', NULL, '8145003501', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e1aea0f2-32b5-4b07-995d-e2e60397d2e7', NULL, 'Mr. R.C Sharma', 'Male', 'F/1669/2003', 'advocatercsharma@gmail.com', NULL, '9832052387', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('52a891d6-19c2-4012-92b7-9aa8e85a229b', NULL, 'Mr. Sunil Baraily', 'Male', 'WB/699/2003', 'sunilbaraily@gmail.com', NULL, '7063679750', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('743a1a8b-5df8-4c86-a0c3-71340d53f7c9', NULL, 'Mr. Leada Tshering', 'Male', 'WB/428/2004', 'leadaadv@gmail.com', NULL, '9832331806', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0d1ec98f-2081-46a4-b056-741832a3bf5d', NULL, 'Mr. Kharga Bahadur Chettri', 'Male', '270/310/2003', 'kaydeellb@gmail.com', NULL, '9832075869', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('01459d67-7440-4504-aa92-e9817b1ef0f9', NULL, 'Mr. Ashok Pradhan-I', 'Male', 'WB/366/2005', 'ashokadvocate2014@gmail.com', NULL, '9434448022', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('30600c29-ff94-4063-a58f-16a8cabcbf18', NULL, 'Mr. Umesh Pradhan', 'Male', 'F/1252/1230/2000', 'umeshpradhan@gmail.com', NULL, '9832370027', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ce28cd72-4827-401c-acbd-63bb8546c8ab', NULL, 'Mr. Tashi Rapten Barfungpa', 'Male', 'D/1838/2002', 'trbarfungpa@gmail.com', NULL, '9933796599', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7b887b9f-0053-407a-bfe6-9cbc604e6dfb', NULL, 'Mr. Ashok Pradhan-II', 'Male', 'F/329/2005', 'pradhanashok466@gmail.com', NULL, '9775960726', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5dddbef4-c331-4079-9811-d1f9c67532ff', NULL, 'Ms. Kamala Giri', 'Female', 'F/101/2004', 'kamalagiri213@yahoo.com', NULL, '7063848938', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('4ba0e616-c860-441f-98d0-ec922e30e94c', NULL, 'Mr. Laxuman Gurung', 'Male', '318/2005', 'lgurung_33@yahoo.co.in', NULL, '9733049641', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('8c2d2159-6311-4767-96ff-6b081f848790', NULL, 'Mr. Nima Tshering Sherpa', 'Male', 'F/627/578/2005', 'vida_lama@yahoo.com', NULL, '9733171595', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('45006a5e-b692-4384-ad8c-d19774b8332a', NULL, 'Mr. Dik Kumar Siwakoti', 'Male', '932 of 2005-06', 'siwakoti2@gmail.com', NULL, '9474526665', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a7a23a34-95b7-45e3-b4ba-83c818bb9845', NULL, 'Ms. Navtara Sarda', 'Female', 'KAR/490/01(020)2001', 'navsasarda@gmail.com', NULL, '8145885717', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e09be191-c4ed-46cd-baf8-ddbfbc8c3795', NULL, 'Mr. Tshewang Namgyal Bhutia', 'Male', 'F-1139/442/2005', 'tsewangnamgyal1977@gmail.com', NULL, '8373873815', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('760af78b-cb95-4979-a68a-945a6259d824', NULL, 'Mr. Umesh Gurung', 'Male', 'F-1032/2004', 'umeshgurung1979@gmail.com', NULL, '9832070862', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('8f7becf8-46c3-4ad8-8066-a555e3aa741a', NULL, 'Mr. Tashi Wongdi Bhutia', 'Male', 'F/167/2007', 'tbhutia26@yahoo.in', NULL, '9733250381', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5a3f8477-27f7-41d2-a450-c91ff35b6129', NULL, 'Mr. Ranjan Chettri', 'Male', 'F/166/2007', 'ranjangtk21@yahoo.com', NULL, '9832304749', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b26940f6-600e-42a6-8c21-cdbcbfaa9f31', NULL, 'Mr. Bhusan Nepal', 'Male', 'F/328/2005', 'bhusanadv@gmail.com', NULL, '9733304034', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5917a59c-be5e-4b0d-81f3-fb3f3a35e8d8', NULL, 'Ms. Sabina Gurung', 'Female', 'F/636/2005', 'gurungsabina@hotmail.com', NULL, '9832377578', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('192d6451-4aa3-467b-85d1-df0a945504ae', NULL, 'Ms. Prarthana Ghataney', 'Female', '333/2006', 'prarthanaghataney@gmail.com', NULL, '9832304620', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b457a954-d9fa-4fc9-a4a5-e947c5e56b52', NULL, 'Ms. Ranjeeta Kumari', 'Female', 'F/474/2006', 'ranjeetakmr@gmail.com', NULL, '9832005712', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('249f2753-af1a-47af-9637-66b345d862bf', NULL, 'Ms. Zola Megi', 'Female', '348/2008', 'zolamegi30@gmail.com', NULL, '9734190663', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('31f20f6e-ad1a-47c9-9155-1590bd8426ff', NULL, 'Mr. L.B Gurung', 'Male', 'WB/306/2005', 'lbgurung111@gmail.com', NULL, '8967954848', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a24dda9a-c186-44f0-a9a1-0844bef8adf8', NULL, 'Mr. Manish Kumar Jain', 'Male', '378/2008', 'manishadv2008@gmail.com', NULL, '9734914769', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('6c2b9354-df63-433a-942e-4d83ba1107cb', NULL, 'Mr. Gulshan Lama', 'Male', '616/527/2006', 'reyanshtamang@yahoo.com', NULL, '9932240862', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('bfe83cda-4e4e-404b-9f2c-c1609677a522', NULL, 'Mr. Ramesh Sharma', 'Male', 'WB/1177/2002', 'rsadv0926@gmail.com', NULL, '8768976199', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c8552373-0e18-488c-ac5c-18ea669797a7', NULL, 'Mr. Deven Rai', 'Male', '390/2008', 'dvr1316@yahoo.com', NULL, '9832611429', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e981d992-17c6-400a-8415-3808d4791b9a', NULL, 'Ms. Pritima Sunam', 'Female', '1594/2007', 'pritilibran@gmail.com', NULL, '9832368908', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('216e4773-084e-43cb-bcb9-e15765bc80b4', NULL, 'Mr. Vivek Anand Basnett', 'Male', '183/2008', 'basnetvivek9@gmail.com', NULL, '9475583657', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0a2aaf01-e97b-4a81-9a78-038a245bd591', NULL, 'Ms. Yashoda Rai', 'Female', '350/2009', 'yasodha_rai@yahoo.co.in', NULL, '9832029418', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e364a60d-225f-4659-b102-ee7fb4524576', NULL, 'Ms. Phichim Bhutia', 'Female', '2270/2010-11', 'phichimbhutia@gmail.com', NULL, '9733366239', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('8324444d-8abb-4481-81d8-f8975508a8d0', NULL, 'Mr. Pema Ongchu Bhutia', 'Male', '820/2010', 'pemaongchu26@gmail.com', NULL, '9593387318', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('775931d3-7d51-4b50-a6f2-83035b67e981', NULL, 'Ms. Bimla Chettri', 'Female', '934/2010', 'Bimlachettri2020@gmail.com', NULL, '9593278452', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7b644435-39b4-456a-8344-63e0b3703b2a', NULL, 'Ms. Januka Sharma', 'Female', '728/2009', 'janukasharma024@gmail.com', NULL, '9641720865', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('72865741-f50b-4909-8fe2-d100c8f2c190', NULL, 'Mr. Sushant Subba', 'Male', '1208/2011', 'subba13@gmail.com', NULL, '9635145055', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0ab123d9-2981-461f-8cc8-7b99d3d728b3', NULL, 'Mr. Sudhir Prasad', 'Male', '172/2011', 'sudhirprasadtna@gmail.com', NULL, '8972003358', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('cdf38621-a2ad-45ed-bb62-be290918401f', NULL, 'Mr. Durga Prasad Luitel', 'Male', '1659/2010', 'Sharmadurga83@yahoo.in', NULL, '9647873523', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7c4e4213-1b45-4126-b738-432095f1ab68', NULL, 'Mr. Madan Kumar Sundas', 'Male', '1216/2011', 'm2sundas@yahoo.com', NULL, '977598110', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0fcf4042-9c6c-4bad-a876-2f2ae74b916e', NULL, 'Ms. Renuka Lohar', 'Female', '1125/2011', 'renukaloharskm@gmail.com', NULL, '7407242982', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('2ad8fc0d-3116-4a33-b677-08526310ee66', NULL, 'Ms. Pinku Subba', 'Female', '1123/2011', 'pnkksubba16@gmail.com', NULL, '9593773794', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('3eb732ee-305f-4262-937d-00d1ade93ffe', NULL, 'Mr. Chewang Norbu Bhutia', 'Male', '1554/2011', 'chewang.6@gmail.com', NULL, '8918631290', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b75e621a-cc77-4150-9589-cd9d9835b4b5', NULL, 'Ms. Tengop Subba', 'Female', '1279/2012', 'tengopsubba@gmail.com', NULL, '8145011268', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('33f403cb-9ac5-411e-8bff-40c6f1804e25', NULL, 'Ms. Gita Bista', 'Female', 'F/635/2005', 'bistagita1@gmail.com', NULL, '6297540306', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e958e42a-2fef-4ecb-ad22-ec00c5a84609', NULL, 'Mr. Girmey Bhutia', 'Male', '1688/2012-13', 'bhutiagirmey@gmail.com', NULL, '9775847161', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b218d666-d6f8-4b3b-ad08-12299ee7b4da', NULL, 'Ms. Sashi Rai', 'Female', '988/2012', 'sashirai009@gmail.com', NULL, '9775995670', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('91af4a2c-533e-4e91-9751-0ba012d63901', NULL, 'Mr. Dewen Sharma Luitel', 'Male', '623/2012', 'newedz@gmail.com', NULL, '9679907671', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7e9e7290-88d8-4160-b333-bcd2f280cbf4', NULL, 'Mr. Rewat Pradhan', 'Male', '1452/2010', 'rewatpradhan84@gmail.com', NULL, '9932637388', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('383e6c0a-0f9e-4ccf-923b-9369f4d1f8f3', NULL, 'Ms. Chandrika Maya Karki', 'Female', '563/2010', 'chandrikakarki@yahoo.co.in', NULL, '9775914829', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e97e137b-fb9a-4190-a702-791a4799da95', NULL, 'Ms. Bhawana Chettri', 'Female', '628/2014', 'bhawanachhetri1991@gmail.com', NULL, '7908106153', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('6f949782-cae9-4a0d-83ca-e22f275fd298', NULL, 'Ms. Tshering Palmoo Bhutia', 'Female', '1303/2012', 'tshering28@gmail.com', NULL, '7557821186', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c2224fe5-1990-4c40-a7e9-c0292c7a139a', NULL, 'Mr. Bidur Renzyong Lepcha', 'Male', '144/2013', 'punol.lepcha@yahoo.com', NULL, '967171595', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e62b226d-5c6a-48c9-bfb6-35e32ffacd22', NULL, 'Ms. Beena Rai', 'Female', '1471/2013', 'beena_rai89@yahoo.com', NULL, '7548998238', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('18130a28-381f-44b3-b5a7-db1f6bf23b24', NULL, 'Ms. Roshni Chettri', 'Female', '1629/2011', 'ros_ni11@yahoo.com', NULL, '9609010179', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7d6d13e6-dbf0-4e1f-9e9b-a3b86f9e9855', NULL, 'Mr. Sunil Rai', 'Male', '743/2014', 'raisunil824@gmail.com', NULL, '8348275022', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('bf12131d-e7a0-4673-ad25-73d8bd12fbb2', NULL, 'Ms. Samita Gurung', 'Female', '391/2014', 'gurungsamita@gmail.com', NULL, '8768926702', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('6c83dc20-86ce-4a4e-a0e8-fba088d23b8c', NULL, 'Ms. Sachina P.Y Subba', 'Female', 'D/3444/2004', 'subbasachina8@gmail.com', NULL, '6297540306', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('9075d78d-cf57-47ba-b808-4d247ca0af20', NULL, 'Mr. Passang Tshering Bhutia', 'Male', '596/2014', 'bpassang12@gmail.com', NULL, '9563107631', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('23eba25f-a8f8-4922-9847-e309eef00035', NULL, 'Ms. Monika Rai', 'Female', '930/2010', 'raimonika382@gmail.com', NULL, '7407381060', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c67957aa-38a9-4895-a554-b57f134cf420', NULL, 'Mr. Deepen Pradhan', 'Male', '746/2010', 'deepenpradhan308@gmail.com', NULL, '9609863673', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0580a207-9583-45bc-9210-983c482d49f1', NULL, 'Mr. Loknath Khanal', 'Male', '750/2013', 'khanalloknath6@gmail.com', NULL, '9832414153', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c664bc2b-b36a-4744-a582-46bbc709ec13', NULL, 'Mr. Thupden Yongda', 'Male', '2960/2008', 'thupden@gmail.com', NULL, '9832089999', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ac9545da-d7c7-4836-b959-84c36e81f618', NULL, 'Ms. Phu Doma Bhutia', 'Female', '769/2014', 'phudomabhutia88@gmail.com', NULL, '9593746237', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('dd56e08a-bb7c-48c8-9105-9e02a164ad46', NULL, 'Ms. Malati Sharma', 'Female', '285/2014', 'malatisharma20@gmail.com', NULL, '7908332007', NULL, NULL, 9, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7343470c-5155-454c-8e55-a364a8d5e36d', NULL, 'Mr. Yozan Rai', 'Male', '145/2019', 'advocateyozan@gmail.com', NULL, '8391911267', NULL, NULL, 6, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('29e5481a-fff3-4678-9fd7-65906d2a5efc', NULL, 'Mr. Nima Wongdi Lepcha', 'Male', '769/2013', 'wongdinema@gmail.com', NULL, '9609984074', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('af24afbc-9c73-4062-9356-9c9c4288fe02', NULL, 'Mr. Ranjit Prasad', 'Male', '924/2010', 'ranjitprasadlaw@gmail.com', NULL, '9647852399', NULL, NULL, 14, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('fda0c4e6-d653-49e2-9052-ba2b10a38669', NULL, 'Mr. Sishir Mothay', 'Male', '713/2013', 'mothaysishir25@gmail.com', NULL, '8906347205', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ec0823bf-6210-4982-ab1a-68275260af3f', NULL, 'Mr. Hem Lall Manger', 'Male', '1055/2017', 'hemlalmanger93@gmail.com', NULL, '7551845308', NULL, NULL, 7, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('2b5c284d-b589-4f31-9298-14b9ebfab138', NULL, 'Mr. Sangay Gyurmay Bhutia', 'Male', 'D/1626/2008', 'sangaygolok@gmail.com', NULL, '7602527538', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('f4b5a16e-43cb-4f8b-b565-6aebaed71cf1', NULL, 'Mr. Sonam Bhutia', 'Male', '618/2012', 'sonamadv@gmail.com', NULL, '9593985582', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1289c18b-2ef8-46f1-9b8f-722608dcace3', NULL, 'Ms. Jyoti Pradhan', 'Female', 'F 430/274 of 2014', 'jyotipradhan27@yahoo.com', NULL, '9733443334', NULL, NULL, 9, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d3c4213d-8732-49c1-a40d-f8384015218d', NULL, 'Mr. M.N. Dhungel', 'Male', '1467/2010', 'mndhungel2015@gmail.com', NULL, '7679533520', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5d6e5023-6ae2-4217-ac03-585fa24fc0e5', NULL, 'Mr. Sajal Sharma', 'Male', 'D/4219/2016', 'sharmasajal21@gmail.com', NULL, '8372970487', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('501625d4-d369-4723-bb15-0aeba6320706', NULL, 'Mr. Safal Sharma', 'Male', 'UK/392/2007', 'safalsharma970@gmail.com', NULL, '8918408203', NULL, NULL, 6, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('fb1c8e4a-dbd2-4aca-ae49-4568b831e7e1', NULL, 'Mr. Vedant Rai', 'Male', 'F-1797/03', 'rai.vedant26@gmail.com', NULL, '9733051864', NULL, NULL, 19, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('3f74e2dc-3018-4938-b863-2d0779bf92cb', NULL, 'Ms. Mingma Lhamu Sherpa - I', 'Female', '769/2014_ALT', 'mingalhamu12@gmail.com', NULL, '7583900316', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('71b69a3d-8769-4e2b-bf9d-2e6aaac873c2', NULL, 'Mr. Dechen Wangdi Lachungpa', 'Male', '1084/ 2016', 'dechenwangdi@hotmail.com', NULL, '7478569541', NULL, NULL, 9, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('7d6c25a4-520e-4588-bd47-5073ea02cf94', NULL, 'Ms. Ashmeeta Rai', 'Female', '745/2022', 'ashmeetarai_gen@slsa.gov.in', NULL, '7076109193', NULL, NULL, 3, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e9bee74e-69b4-4031-ada2-dc1f2fda8856', NULL, 'Mr. Tree Ranta Rai', 'Male', '1403/2019', 'dhiwatpang511@gmail.com', NULL, '9064526103', NULL, NULL, 6, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1e0db796-ff41-4f62-98ed-b7521073d660', NULL, 'Ms. Tara Devi Chettri', 'Female', '449/2021', 'Tarachettri587@gmail.com', NULL, '8250751210', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b5642866-54dc-4a17-a511-956d3eb5d82b', NULL, 'Mr. Pradeep Tamang', 'Male', '1072/2020', 'pradeepgyabak@gmail.com', NULL, '8391903204', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('3b935a8d-d1ae-4def-9557-1c7c8c5940a7', NULL, 'Mr. Varun Pardhan', 'Male', '993/2018', 'varunpradhan_gen@slsa.gov.in', NULL, '9123001206', NULL, NULL, 6, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('729263a5-e525-4eca-965a-10bc3bbda6e4', NULL, 'Mr. Jit Bahadur Chettri', 'Male', '489/2021', 'jitchettri_gen@slsa.gov.in', NULL, '7876616609', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('232de221-2305-4521-818f-f511734f0765', NULL, 'Mr. Avinash Dewan', 'Male', 'D/1401/2021', 'Akakuba26@gmail.com', NULL, '7042315496', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('eac2de39-3571-493b-966d-66f015eea38c', NULL, 'Ms. Rinchen Ongmu Bhutia', 'Female', '2378/2023', 'rinchen_bhutia@gmail.com', NULL, '8001949434', NULL, NULL, 2, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e78365da-a472-4995-bc8d-aa361365a95f', NULL, 'Mr. Pradeep Sharma', 'Male', '1385/2019', 'Pradipsharma5215@gmail.com', NULL, '88944822950', NULL, NULL, 6, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('28be4e46-04bf-4aae-b676-4b678d9b5ae7', NULL, 'Ms. Yozna Shanker', 'Female', '565/2024', 'Yoznashanker07@gmaile.com', NULL, '8348148693', NULL, NULL, 9, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('14851c75-4f6e-49fb-a4f2-470646c877a3', NULL, 'Ms. Songmith Leezum Lepcha', 'Female', '1277/2027', 'Songmithlepcha7@gmail.com', NULL, '9679172094', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d41942db-a78a-4818-b846-d6bf112403f0', NULL, 'Ms. Binu Rai', 'Female', '625/2015', 'binurai_gen@slsa.gov.in', NULL, '9000000104', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('957ba8a5-2612-47d3-998b-725c728b285c', NULL, 'Mr. Anirudh Gupta', 'Male', '781/2022', 'Anirudhgupta2403@gmail.com', NULL, '825007830', NULL, NULL, 3, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('eb0b7646-2cf2-485a-b2b5-a5787b1a792c', NULL, 'Mr. Abhinav Kant Jha', 'Male', 'BR/1362/2021', 'abhinavlegals@gmail.com', NULL, '8078653189', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('09b035a7-a012-4d86-aecb-3bf4652d482c', NULL, 'Ms. Sunita Lamichaney', 'Female', '267/173/2006', 'Suneezool123@gmail.com', NULL, '8250237261', NULL, NULL, 3, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('24b026ec-f83f-47cb-b1fa-61c7b53b7f1e', NULL, 'Ms. Devika Tamang', 'Female', '1586/2006-2007', 'bhivanhomestay@gmail.com', NULL, '9832370771', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('94174336-97cc-4af6-8fd3-eec6245fea83', NULL, 'Mr. Dipendra Chettri', 'Male', '531/2020', 'dipendrachettri_gen@slsa.gov.in', NULL, '9735833367', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d6c86a70-8535-4125-b977-57ae2b0cf6d8', NULL, 'Mr. Romit Gurung', 'Male', '1305/2027', 'Romitgurung8@gmail.com', NULL, '7602540042', '7719147939', NULL, 7, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ae483326-e09a-49de-9eeb-6d43afd1b1f3', NULL, 'Mr. Lekden Thondup Basi', 'Male', 'd/1020/2021', 'lekdenbasi@gmail.com', NULL, '7908150538', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0205ca0a-ae6e-4251-b280-9b1c4fd47a51', NULL, 'Mr. Udai Kunwar', 'Male', '873/2020', 'Udaikunwar121@gmail.com', NULL, '8250910647', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('2acdccf4-99fc-4b14-be90-66555fec0585', NULL, 'Ms. Nirmala Nerola', 'Female', 'F/1111/1300/2021', 'nnerola@gmail.com', NULL, '8250527569', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a5f08483-0e2d-4f8e-af80-401c19be3e6a', NULL, 'Ms. Preeti Basnett', 'Female', 'f/3820/3224/2021', 'preetibasnett@gmail.com', NULL, '8240302731', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('dcded46c-c064-4311-b8ee-97f988885275', NULL, 'Mr. Amitabh Shankar', 'Male', '7375/1999', 'amitabhsrai@gmail.com', NULL, '8167743743', '9434184460', NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c5948df5-0515-4eeb-bb58-2e6ff19edee1', NULL, 'Mr. Prabhat Rai', 'Male', 'UP07337/2000', 'prabhatrai@rediffmail.com', NULL, '7063063827', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e57a0f2f-449a-4979-827d-93110aa4ecb5', NULL, 'Ms. Prasunna Sharma', 'Female', 'F/1073/2004', 'prasunasharma6688@gmail.com', NULL, '9775901273', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('6eb277ca-5443-4f46-b9be-c29892f65f34', NULL, 'Mr. Kumar Sharma', 'Male', '2329/2005', 'kumarsharma59@yahoo.com', NULL, '9434487904', '9635177029', NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('856f1190-9334-4e8b-a114-a30cd7ed6303', NULL, 'Mr. Bhupendra Giri', 'Male', 'WB/364/2005', 'giribhupendra45@yahoo.in', NULL, '9733147436', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d7ea0389-65ee-47b3-8710-7d843b1aebfa', NULL, 'Mr. Prasun Adhikari', 'Male', '911/2004-05', 'prasunadhikari007@gmail.com', NULL, '9775992242', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5d4cf8cb-57fc-4a49-8d05-470de6b92617', NULL, 'Mr. Anjan Sharma', 'Male', 'WB/814/06', 'Sharmaanjan1982@gmail.com', NULL, '9933490695', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('506a1e45-98dd-4bdf-ad98-9e28dee1043c', NULL, 'Ms. Yangzee Pinasha', 'Female', '1221/2007', 'ypadvocate13@gmail.com', NULL, '9609935908', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d5f11d17-5d0e-4b91-a8c7-3b35ff5500c5', NULL, 'Mr. Pema Tamang', 'Male', '374/2008', 'tmpema@yahoo.in', NULL, '9832539518', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ff3996d2-ab6e-4444-a557-c785c68cbe97', NULL, 'Ms. Geeta Subba', 'Female', '1590/2006-07', 'geetapandhak@gmail.com', NULL, '9733161205', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('4515f1d2-dd05-4d02-9aec-ef554624fd49', NULL, 'Ms. Sushila Thapa', 'Female', '301/2009', 'thapasushila678@gmail.com', NULL, '9775972474', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('548bfa56-84cb-4ad3-97a1-a661cda4ffd0', NULL, 'Ms. Pabitra Pradhan', 'Female', '315/2009', 'pabitradhan09@gmail.com', NULL, '9734980062', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('abbec3f8-52ef-4264-a5c5-7e34ef51a55a', NULL, 'Mr. Vivek Chandra Rai', 'Male', '345/2009', 'vivekchandrar@yahoo.com', NULL, '9749598974', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('9871a0d7-91fc-4ade-9762-0848f36ba322', NULL, 'Mr. Raj Kumar Chettri', 'Male', '1585/2006-07', 'Rajkumarchettri35@yahoo.in', NULL, '9647569948', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b343613e-76d1-41b0-8ec4-6adda5d58bc8', NULL, 'Ms. Doma Devi Sharma', 'Female', '938/2010', 'prabitasharma92@yahoo.com', NULL, '9635289509', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('52897e4b-6561-4600-93bb-d76e896b3cda', NULL, 'Mr. Nirmal Kumar Bardewa', 'Male', '1047/2013', 'nirmalinchrist@yahoo.com', NULL, '7407178524', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('9548f89b-a2c9-421a-98ad-daa9d9fd2183', NULL, 'Mr. Bhim Shankar Pradhan', 'Male', '781/2013', 'pradhanbhim06@gmail.com', NULL, '7098988055', NULL, NULL, 11, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a585da07-09e6-4c76-9779-6f69937d5d9b', NULL, 'Mr. Sonam Jigmee Bhutia', 'Male', '1231/2012', 'sonamjigmebhutia@gmail.com', NULL, '9647222207', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1a7078bd-d10a-49eb-b768-abd31a651bf1', NULL, 'Ms. Janu Tamang', 'Female', '1819/2013-14', 'janutamang@yahoo.com', NULL, '8145603895', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('18e154b7-afb5-41fc-8513-33d5f57346ef', NULL, 'Ms. Aita Rani Subba', 'Female', '903/2012', 'chukshi@gmail.com', NULL, '9775901146', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0a678b26-52c5-48c8-88a8-86f5aeb48c73', NULL, 'Ms. Kesang Doma Bhutia', 'Female', '1041 of 2014-15', 'ksangdee@gmail.com', NULL, '9382196537', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b46940c9-5aa0-4fa4-b6d4-fd0c16206c03', NULL, 'Mr. Dilli Bdr. Pradhan', 'Male', '1083 of 2017', 'dillib.pradhan03@gmail.com', NULL, '9382136403', '9735370797', NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('92508178-5a0d-41d2-8e88-d2e77d29c5fa', NULL, 'Ms. Reshma Tewari', 'Female', '1220 of 2011', 'reshmatewari83@gmail.com', NULL, '8768553722', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('adf0f298-eee7-446d-b6a2-63b27527e69c', NULL, 'Ms. Tulasha Sharma', 'Female', '1319 of 2018', 'tulashakabir96@gmail.com', NULL, '9647724315', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0c725ba4-2c47-448f-b156-1970047664d7', NULL, 'Ms. Choki Sherpa', 'Female', '1286/2004', 'choki54sherpa@gmail.com', NULL, '9593382954', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('29560d25-ccb0-4fce-ba0a-289c40fc940f', NULL, 'Ms. Unisha Pradhan', 'Female', '292 of 2015', 'pradhanunisha0@gmail.com', NULL, '8001404580', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('156e9966-f359-4f51-9a4b-f6c9fb8e12b2', NULL, 'Ms. Chenga Doma Bhutia', 'Female', '1086/2008', 'chengadoma@yahoo.com', NULL, '7797893437', '9735955001', NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('754bf6e3-e2cd-4caa-896b-dfdd66e8f4c6', NULL, 'Ms. Sonam Phuti Bhutia', 'Female', '629 of 2012', 'sonam.pbhutia@gmail.com', NULL, '8670500000', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('01f92d6e-8b2e-4587-9fc0-4716a1d0ab87', NULL, 'Ms. Slomita Rai', 'Female', 'D/1428/2017', 'slomila90@gmail.com', NULL, '8375895932', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d9303d66-90a4-4885-9dd1-65b1dda7b4af', NULL, 'Ms. Nim Phuti Sherpa', 'Female', 'F 687/541 of 2005', 'nimphuti80@gmail.com', NULL, '9434488558', '8250027206', NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1d955daf-831d-44d2-9f1e-8e31fb3c24fd', NULL, 'Mr. Singhi Dadul Lachungpa', 'Male', 'D/6032/2018', 'singhilachungpa@gmail.com', NULL, '9832105709', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1734c51d-0a3d-46e3-9873-ddad0fc3d5f2', NULL, 'Ms. Marina Rai', 'Female', '466/2022', 'iammsrinarai@gmail.com', NULL, '7428852032', NULL, NULL, 3, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('43ea5784-4f73-4c88-8296-1fdb8ed035a7', NULL, 'Ms. Puja Lamichaney', 'Female', 'WB/828/2006', 'mailmychamber@gmail.com', NULL, '9775915626', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('15efb1d0-6cc0-456b-91da-3e4774eb822c', NULL, 'Mr. Bikash Gurung', 'Male', '1431/2007', 'gurungb506@gmail.com', NULL, '8597772341', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('52424eb8-af69-4612-be06-9d6ca3aed0e4', NULL, 'Ms. Rekha Subba', 'Female', '366/2008', 'nanumanisamma22@gmail.com', NULL, '9609853570', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('44745f9e-8523-41a6-8447-3e3e410f95af', NULL, 'Mr. Pujan Chettri Kharga', 'Male', '3221/2010', 'pujankharka@gmail.com', NULL, '9735088200', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('99945423-f6a3-4473-843d-86e4e087f72d', NULL, 'Mr. Karma Bhutia', 'Male', '798/2013', 'karmabhutia23@gmail.com', NULL, '7063150182', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('43043778-16a6-4c02-af0a-33c96ca0bd58', NULL, 'Ms. Sita Kumari Chettri', 'Female', '848/2014', 'chettrisita10@gmail.com', NULL, '7407700090', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('0f34ca16-1d4f-47b6-af0f-241bd6ef517d', NULL, 'Ms. Binita Karki', 'Female', '1741/2013-14', 'binitakarki07@gmail.com', NULL, '9593283657', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e348aa85-a0d6-4640-bdd3-37eb2f6cf5a5', NULL, 'Ms. Sashi Pradhan', 'Female', '819/2014', 'sassiepradhan1990@gmail.com', NULL, '9083099244', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('eddd64bf-c286-47da-a59e-57b8f6ce821a', NULL, 'Ms. Aita Hangma Limboo', 'Female', '1121/2015', 'aitahangmalimboo@gmail.com', NULL, '8001632305', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ab2ee49f-82d3-402d-9cc0-31fc0691c9af', NULL, 'Ms. Anug Rai', 'Female', '1011/2016', 'raianug8@gmail.com', NULL, '9733438775', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('c326bc7b-cc25-4f3d-9b0d-b694cc59b776', NULL, 'Mr. Karma Dechen Bhutia', 'Male', '1245/2011', 'mrkdbhutia@gmail.com', NULL, '9609964700', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('f163011a-d0c8-413a-99da-56a4c841afcf', NULL, 'Ms. Sun Maya Subba', 'Female', '824/2012', 'sonutamling120418@gmail.com', NULL, '9609867340', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('da531982-fb02-458f-beb6-0b1bdbfe2899', NULL, 'Ms. Rachana Rai', 'Female', '875 of 2015', 'julurai1114@gmail.com', NULL, '8159081168', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e7ad8118-6719-4929-8d0e-6ca74f4a2cc6', NULL, 'Ms. Pema Dechen Bhutia', 'Female', '737 of 2018', 'pemad1991@gmail.com', NULL, '9883905780', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5e0a0029-9c6a-4e61-8f3c-7b31af0e4f6b', NULL, 'Ms. Sonam Lhamu Lepcha', 'Female', '738 of 2018', 'mayelsonam6@gmail.com', NULL, '9000000161', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('da38eabe-c936-4b63-9f9a-7511b6789d5e', NULL, 'Ms. Chunkila Bhutia', 'Female', '1304 of 2012', 'cbhutia5@gmail.com', NULL, '9933877008', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('ea1480ea-09da-487c-8722-f7697620675b', NULL, 'Ms. Saroja Chettri', 'Female', '626 of 2015', 'sorojachettri1991@gmail.com', NULL, '9000000163', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1a37d603-6c89-43fb-a69b-0dbac3f30d29', NULL, 'Mr. Pankaj Gautam', 'Male', 'TEMP/164/REG', 'Advpankajgautam111@gmail.com', 'Pgautam943@gmail.com', '8448677980', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('40fe53f6-dff7-40cc-a445-118db8efb3a8', NULL, 'Mr. Johnson Subba', 'Male', '786/2016', 'advjohnsonsubbA@GMAIL.COM', NULL, '9910606889', NULL, NULL, 10, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('d3040a0d-f051-473d-b887-959dadeb9848', NULL, 'Ms. Sushan Subba', 'Female', '1311/2017', 'sushanemma@gmail.com', NULL, '9593775590', NULL, NULL, 6, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('59c6f67a-51e4-4703-8840-07c174acf755', NULL, 'Mr. Shrawan Kumar Prasad', 'Male', '49 of 2009 – 10', 'shrawan0102@yahoo.com', NULL, '9832655389', NULL, NULL, 14, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('02399d3b-c5ab-48a4-a499-301673d67f97', NULL, 'Ms. Dinku Khati', 'Female', 'F. 1195/483 of 2005', 'dinku422@gmail.com', NULL, '8420857253', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b6afa929-c1b6-4dc0-9fa1-2a9d2ec15039', NULL, 'Ms. Mingma Lhamu Sherpa - II', 'Female', '1153 of 2018', 'mingmalhamu2601@gmail.com', NULL, '8768868175', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('e111e115-13fd-4092-bde8-6f276bdd77b9', NULL, 'Ms. Neetu Tamang', 'Female', '398 of 2016', 'neetupakhrin007@gmail.com', NULL, '8768940811', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a58be060-9342-4499-9c8f-5cf6ea342db3', NULL, 'Ms. Tshering Uden Sherpa', 'Female', '390 of 2014', 'udensherpa10@gmail.com', NULL, '7001539512', NULL, NULL, 9, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('26ed624a-2d03-4f62-822a-5f1544b8e464', NULL, 'Mr. Kusan Limboo', 'Male', '961 of 2016', 'kushanlimboo11@gmail.com', NULL, '9593980186', NULL, NULL, 7, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a0ecf165-3717-4a40-9e97-943726399ee8', NULL, 'Ms. Eme Rai Rai', 'Female', '1388/2029', 'Emeraigankhu5@gmail.com', NULL, '9832159629', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('5a5484b0-da4b-4a28-b183-8e390147b9b3', NULL, 'Ms. Anuradha Tamang', 'Female', '430/2022', 'Tanuradha321@gmail.com', NULL, '8101038512', NULL, NULL, 3, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('58c7fc77-9e56-49a9-a663-f7a79ba5eedf', NULL, 'Mr. Roshan Tamang', 'Male', '369/2008', 'piyushtamang11@gmail.com', NULL, '9647782187', NULL, NULL, 12, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('a5d997d3-13c4-4342-a876-46071d9aae5a', NULL, 'Mr. Yogesh Subba', 'Male', '671/2015', 'yogeshsubba89@gmail.com', NULL, '7872223232', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('644b4d19-9fac-4e3f-9537-dbc2b94de67a', NULL, 'Ms. Anusha Thapa', 'Female', '993 of 2010', 'anushiya95@gmail.com', NULL, '9775965499', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('64ce6976-f204-41d9-8104-29eeb2a0120d', NULL, 'Mr. Mang Hang Subba', 'Male', '1156/2007', 'mang82@gmail.com', NULL, '7479052002', NULL, NULL, 8, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('70509556-8bcb-46f0-8b6f-3ea17142a292', NULL, 'Ms. Kanchan Rai', 'Female', '55 of 2017', 'kanchanrai701@gmail.com', NULL, '7076287153', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('be42dd2a-2bba-42f5-a509-5aebccf49f39', NULL, 'Ms. Sunita Chettri', 'Female', '1180 of 2018', 'sunitachettri06@gmail.com', NULL, '7427991243', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('1c2ad25d-c6db-4d44-bf7b-9c2c79f380e9', NULL, 'Mr. Manoj Subba', 'Male', '1275 of 2017', 'namanzworld@gmail.com', NULL, '8372836935', NULL, NULL, 5, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('f2769f50-d0ce-4768-b3f3-886806c9a18f', NULL, 'Ms. Tashi Doma Bhutia', 'Female', 'F/583/474 of 2006', 'tashee5482@gmail.com', NULL, '9733051918', NULL, NULL, 15, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('80e2a118-c63e-4dea-871c-512db17a5139', NULL, 'Ms. Bichitra Thapa', 'Female', '1812/2013-2024', 'bichitrathapa2021@gmail.co', NULL, '70012115113', NULL, NULL, 4, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00'),
	('b37ceb97-a500-441b-99d3-7c2f083a86d4', NULL, 'Ms. Dipshika Tamang', 'Female', '2319/2024', 'dipshikatamangdisshikatamang@gmail.com', NULL, '9002304122', NULL, NULL, 3, true, true, '2026-08-06 09:03:26.4597+00', '2026-08-12 09:18:05.969483+00');


--
-- Data for Name: case_type_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."case_type_master" ("id", "case_type_code", "case_type_name", "icon_url", "display_order", "is_active", "created_at", "case_type_description") VALUES
	('06d00e86-e1c0-4a6f-9d87-3e204df00423', 'MAINTENANCE', 'Maintenance', 'tabler:file-text', 3, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance to claim financial support for oneself or dependent family members when legally entitled.'),
	('f10238bd-a3ba-4e55-9d63-18c2ccd80e8a', 'LEGAL_NOTICE', 'Legal Notice', 'tabler:file-time', 16, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance related to sending, receiving or responding to a formal legal notice.'),
	('aa0bd8fb-c54f-472f-ab2b-9d0361cd0392', 'OTHER', 'Other', 'lucide:pc-case', 17, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance for matters that do not fall under the other listed case types.'),
	('d6f90bb8-3a44-47f9-a8e0-23c28054220e', 'CRIMINAL_MATTER', 'Criminal Matter', 'tabler:shield', 12, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance in matters involving alleged offences, criminal proceedings or related legal issues.'),
	('30ac1c6c-144e-446d-a05b-151d558de1bd', 'CHILD_CUSTODY', 'Child Custody', 'tabler:users', 5, true, '2026-08-14 11:05:55.727665+00', 'Legal help regarding the care, custody and welfare of children after separation or during family disputes.'),
	('ff25398e-f2f5-4968-86d1-7720a5bd88f2', 'DOMESTIC_VIOLENCE', 'Domestic Violence', 'tabler:home', 2, true, '2026-08-14 11:05:55.727665+00', 'Legal help for persons facing physical, emotional, verbal, sexual or economic abuse within the family.'),
	('3822198c-0325-4077-b747-556b90764763', 'LABOUR_DISPUTE', 'Labour Dispute', 'tabler:briefcase', 10, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance for disputes between workers and employers involving employment-related rights and issues.'),
	('ca1a23db-2c25-4e8e-8515-ee7a7d6e86b2', 'CHEQUE_BOUNCE', 'Cheque Bounce', 'tabler:wallet', 8, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance in matters involving dishonoured or bounced cheques and related legal remedies.'),
	('4ab875a1-9cfa-4cee-ba82-55dfb8c2045a', 'CONSUMER_DISPUTE', 'Consumer Dispute', 'tabler:shopping-cart', 11, true, '2026-08-14 11:05:55.727665+00', 'Legal help for consumers facing issues with defective goods, poor services, unfair practices or related matters.'),
	('209612bf-4ed4-41eb-8743-227b12ae836a', 'MOTOR_ACCIDENT_CLAIM', 'Motor Accident Claim', 'tabler:car', 9, true, '2026-08-14 11:05:55.727665+00', 'Legal help for victims or families seeking compensation arising from motor vehicle accidents.'),
	('1061ce0c-c230-47cc-b6d0-226e17acffbc', 'SUCCESSION_CERTIFICATE', 'Succession Certificate', 'tabler:certificate', 1, true, '2026-08-14 11:05:55.727665+00', 'Help with obtaining a legal certificate to establish the rightful successors of a deceased person.'),
	('a8275b55-e72f-4ae9-9b25-67554d7bb89f', 'VICTIM_COMPENSATION', 'Victim Compensation', 'lucide:receipt-indian-rupee', 14, true, '2026-08-14 11:05:55.727665+00', 'Legal help for eligible victims seeking compensation for loss, injury or harm caused by a crime.'),
	('12569c3d-8f07-4ce1-b8cf-3d457c6dd87a', 'SENIOR_CITIZEN_MAINTENANCE', 'Senior Citizen Maintenance', 'material:elderly-woman-rounded', 15, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance for senior citizens seeking financial support and protection of their rights.'),
	('0e6b1747-e003-44e6-86dc-34ccb988658e', 'PROPERTY_DISPUTE', 'Property Dispute', 'lucide:building-2', 6, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance for disputes involving ownership, possession, transfer or rights related to property.'),
	('deebe4b2-0aea-464a-b766-b615e0c8d3ff', 'LAND_DISPUTE', 'Land Dispute', 'material:landscape', 7, true, '2026-08-14 11:05:55.727665+00', 'Legal help for disputes concerning land ownership, boundaries, possession or other land-related rights.'),
	('4ada5a92-b82f-4cb0-b16a-712125ad5f99', 'DIVORCE', 'Divorce', 'material:heart-broken-outline', 4, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance for ending a marriage and understanding related rights, procedures and family matters.'),
	('389a693f-2e92-4844-b0b9-073237976cc4', 'CIVIL_MATTER', 'Civil Matter', 'material:man', 13, true, '2026-08-14 11:05:55.727665+00', 'Legal assistance for disputes involving civil rights, obligations, claims or other non-criminal matters.');


--
-- Data for Name: legal_aid_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."legal_aid_category" ("id", "category_code", "category_name", "description", "display_order", "icon_url", "created_at") VALUES
	('6d4367bd-b8ba-4509-935a-d56e3501ed6d', 'DISABLED_PERSON', 'Mentally Ill or Disabled', 'Persons with mental illness or physical disabilities under Sec 12(d)', 6, 'tabler:disabled', '2026-08-14 11:05:55.727665+00'),
	('5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'SC_ST', 'SC/ST', 'Members of Scheduled Caste or Scheduled Tribe communities under Sec 12(a)', 3, 'material:forest-outline-rounded', '2026-08-14 11:05:55.727665+00'),
	('f3595cfc-9d99-4e1f-89be-b0186267de66', 'GENERAL', 'General', 'Individuals with annual household income less than 3 Lakh Rupees under Sec 12(h)', 4, 'tabler:coin-rupee', '2026-08-14 11:05:55.727665+00'),
	('ec9e7d1a-b486-4a33-afc6-1b3cb465c6cc', 'DISASTER_VICTIM', 'Victim of Disaster', 'Victims of mass disasters, ethnic violence, caste atrocities, floods, earthquakes, or industrial disasters under Sec 12(e)', 7, 'material:flood-outline', '2026-08-14 11:05:55.727665+00'),
	('196987de-5894-4a5a-9e0f-ddf23f50df12', 'TRAFFICKING_VICTIM', 'Victim of Trafficking', 'Victims of human trafficking or forced labor under Article 23 of the Constitution', 5, 'tabler:car', '2026-08-14 11:05:55.727665+00'),
	('c8211997-2ac3-44cf-873b-949c2a44f431', 'BEGGARY_VICTIM', 'Victim of Beggary', 'Victims of forced begging as referred to in Article 23 of the Constitution', 9, 'tabler:user', '2026-08-14 11:05:55.727665+00'),
	('777165d6-14a6-4f91-92a6-34714498c49f', 'INDUSTRIAL_WORKMAN', 'Industrial Workman', 'Industrial workers under Sec 12(f)', 8, 'tabler:building-factory', '2026-08-14 11:05:55.727665+00'),
	('837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'WOMAN', 'Woman', 'All women are eligible regardless of income under Sec 12(c)', 1, 'material:woman-2-rounded', '2026-08-14 11:05:55.727665+00'),
	('37dbfb26-af99-4ea8-a756-c668bf7abe2a', 'CHILDREN', 'Children', 'All children are eligible under Sec 12(c)', 2, 'material:child-hat', '2026-08-14 11:05:55.727665+00');


--
-- Data for Name: taluka_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."taluka_master" ("id", "taluka_name", "taluka_code", "district_id", "created_at") VALUES
	('b8961244-05cf-4f40-8104-c06656479aeb', 'Gangtok', 'GANGTOK_TALUKA', '162e0db6-feb9-44ea-9476-483c844f4956', '2026-08-14 11:07:31.746433+00'),
	('5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa', 'Namchi', 'NAMCHI_TALUKA', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '2026-08-14 11:07:31.746433+00'),
	('582bd613-f9d4-4dab-8494-e2e84a896c7f', 'Jorethang Sub-Division', 'JORETHANG_TALUKA', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '2026-08-14 11:07:31.746433+00'),
	('65186ae8-347a-4e5e-afa6-07518e9e7c26', 'Yangang Sub-Division', 'YANGANG_TALUKA', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '2026-08-14 11:07:31.746433+00'),
	('bf52f805-f9a8-491d-acc0-256eb07ec801', 'Mangan', 'MANGAN_TALUKA', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', '2026-08-14 11:07:31.746433+00'),
	('bdf12e3e-9847-4674-9094-5c79ee54f059', 'Chungthang Sub-Division', 'CHUNGTHANG_TALUKA', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', '2026-08-14 11:07:31.746433+00'),
	('322b6b54-1bd9-4edf-ae16-e48b13f68f4f', 'Gyalshing', 'GYALSHING_TALUKA', 'd434b194-4038-4342-b475-0f1ef7b44ae4', '2026-08-14 11:07:31.746433+00'),
	('12e67fb5-78bc-42cd-9ac2-efd9a6a32b90', 'Pakyong', 'PAKYONG_TALUKA', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', '2026-08-14 11:07:31.746433+00'),
	('bddb9073-c8b3-4590-a589-b7d8c6fef2f4', 'Rangpo Sub-Division', 'RANGPO_TALUKA', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', '2026-08-14 11:07:31.746433+00'),
	('2dac363a-683e-4924-90fb-2b2b4492a300', 'Rongli Sub-Division', 'RONGLI_TALUKA', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', '2026-08-14 11:07:31.746433+00'),
	('c9138645-c5b9-4809-92d0-ff8f4d22bfad', 'Soreng', 'SORENG_TALUKA', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', '2026-08-14 11:07:31.746433+00');


--
-- Data for Name: legal_aid_application; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."legal_aid_application" ("id", "tracking_number", "applicant_id", "category_id", "applicant_full_name", "applicant_phone_number", "applicant_dob", "applicant_gender", "village_or_town", "applicant_district_id", "case_type_id", "current_district_id", "current_taluka_id", "case_details", "preferred_advocate_id", "assigned_advocate_id", "advocate_acceptance_status", "assigned_at", "status", "is_withdrawn_by_citizen", "withdrawal_reason", "withdrawn_at", "created_at", "updated_at") VALUES
	('4879def6-dfd6-4d4a-bda0-acb3d4916df4', 'LA-20260816-001', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'Demo Applicant 1', '+91-9000000001', '1990-01-01', 'MALE', 'Demo Village 1', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', 'b8961244-05cf-4f40-8104-c06656479aeb', 'Demo case details for legal aid application #1', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-08-16 14:33:09.879909+00', '2026-08-16 14:33:09.879909+00'),
	('463991a4-cf51-47df-a98a-d98b49591b7f', 'LA-20260816-002', '6903780c-c138-463e-af24-35991d1c2add', '196987de-5894-4a5a-9e0f-ddf23f50df12', 'Demo Applicant 2', '+91-9000000002', '1991-01-01', 'FEMALE', 'Demo Village 2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', 'ff25398e-f2f5-4968-86d1-7720a5bd88f2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa', 'Demo case details for legal aid application #2', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-08-16 14:33:09.879909+00', '2026-08-16 14:33:09.879909+00'),
	('09050539-7d28-48d8-b89f-51f9870dcf63', 'LA-20260816-2db24928', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'Demo Applicant 1', '+91-9000000001', '1990-01-01', 'OTHER', 'Demo Village 1', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', 'b8961244-05cf-4f40-8104-c06656479aeb', 'Case details: Under review', NULL, NULL, 'NONE', NULL, 'UNDER_REVIEW', false, NULL, NULL, '2026-08-16 14:37:37.660476+00', '2026-08-16 14:37:37.660476+00'),
	('2d76c7cb-4d3c-4762-9f68-353a5cb432c0', 'LA-20260816-0b004e07', '6903780c-c138-463e-af24-35991d1c2add', '196987de-5894-4a5a-9e0f-ddf23f50df12', 'Demo Applicant 2', '+91-9000000002', '1991-01-01', 'FEMALE', 'Demo Village 2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', 'ff25398e-f2f5-4968-86d1-7720a5bd88f2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa', 'Case details: Advocate assigned', '3cc31969-af68-4be9-bc9d-8e69bd810811', '3cc31969-af68-4be9-bc9d-8e69bd810811', 'PENDING', '2026-08-14 14:37:37.660476+00', 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-08-16 14:37:37.660476+00', '2026-08-16 14:37:37.660476+00'),
	('81ee9973-ce8a-4475-92cd-1da7b60faee1', 'LA-20260816-f802cea5', '6903780c-c138-463e-af24-35991d1c2add', '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'Demo Applicant 4', '+91-9000000004', '1992-12-31', 'FEMALE', 'Demo Village 4', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', 'b8961244-05cf-4f40-8104-c06656479aeb', 'Case details: Resolved', '3cc31969-af68-4be9-bc9d-8e69bd810811', '3cc31969-af68-4be9-bc9d-8e69bd810811', 'ACCEPTED', '2026-08-12 14:38:20.618704+00', 'RESOLVED', false, NULL, NULL, '2026-08-16 14:38:20.618704+00', '2026-08-16 14:38:20.618704+00'),
	('f10bf085-13e5-450b-9150-f7d134863908', 'LA-20260816-302a4223', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '196987de-5894-4a5a-9e0f-ddf23f50df12', 'Demo Applicant 5', '+91-9000000005', '1993-12-31', 'OTHER', 'Demo Village 5', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', 'ff25398e-f2f5-4968-86d1-7720a5bd88f2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa', 'Case details: Rejected', '3cc31969-af68-4be9-bc9d-8e69bd810811', '3cc31969-af68-4be9-bc9d-8e69bd810811', 'REJECTED', '2026-08-13 14:38:20.618704+00', 'REJECTED', false, NULL, NULL, '2026-08-16 14:38:20.618704+00', '2026-08-16 14:38:20.618704+00'),
	('8ca4fd2a-d85d-4465-9567-50a2242e8f98', 'LA-20260816-56e6c3ae', '6903780c-c138-463e-af24-35991d1c2add', '196987de-5894-4a5a-9e0f-ddf23f50df12', 'Demo Applicant 2', '+91-9000000002', '1991-01-01', 'OTHER', 'Demo Village 2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', 'ff25398e-f2f5-4968-86d1-7720a5bd88f2', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '5d1502f3-bc89-41f1-a75f-5d1b6b0f61aa', 'Case details: Under review', NULL, NULL, 'NONE', NULL, 'UNDER_REVIEW', false, NULL, NULL, '2026-08-16 14:38:20.618704+00', '2026-08-16 14:38:20.618704+00'),
	('a6501732-9bd7-44bb-b89f-459643f37f5a', 'LA-20260816-9b76e062', '6903780c-c138-463e-af24-35991d1c2add', 'c8211997-2ac3-44cf-873b-949c2a44f431', 'Demo Applicant 6', '+91-9000000006', '1994-12-31', 'MALE', 'Demo Village 6', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '06d00e86-e1c0-4a6f-9d87-3e204df00423', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '582bd613-f9d4-4dab-8494-e2e84a896c7f', 'Case details: Withdrawn', NULL, NULL, 'NONE', NULL, 'WITHDRAWN', true, 'Citizen withdrew the application', '2026-08-16 13:38:20.618704+00', '2026-08-16 14:38:20.618704+00', '2026-08-16 14:38:20.618704+00'),
	('8e4e380d-f49e-4248-951e-0453f39d7545', 'LA-20260816-9f43485a', 'f60352e9-33a0-40f2-98f4-b79fe2795050', 'c8211997-2ac3-44cf-873b-949c2a44f431', 'Demo Applicant 3', '+91-9000000003', '1992-01-01', 'MALE', 'Demo Village 3', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '06d00e86-e1c0-4a6f-9d87-3e204df00423', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', '582bd613-f9d4-4dab-8494-e2e84a896c7f', 'Case details: Advocate assigned', '3cc31969-af68-4be9-bc9d-8e69bd810811', '3cc31969-af68-4be9-bc9d-8e69bd810811', 'PENDING', '2026-08-14 14:38:20.618704+00', 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-08-16 14:38:20.618704+00', '2026-08-16 14:38:20.618704+00'),
	('13dc867d-f9b9-459b-97ff-33eae110862e', 'SK-GTK-26-00021', NULL, '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'RLS ANON TEST - IGNORE', '+91-0000000000', '1990-01-01', 'MALE', 'Test', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'RLS verification test 2', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-01 07:39:19.302194+00', '2026-09-01 07:39:19.302194+00'),
	('a4239fed-7f0b-47ed-9a67-8f71fceb4d2c', 'SK-GTK-26-00023', NULL, '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'RLS ANON TEST - IGNORE', '+91-0000000000', '1990-01-01', 'MALE', 'Test', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'variant test', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-01 07:43:02.543094+00', '2026-09-01 07:43:02.543094+00'),
	('d36069f1-81fc-460e-b5b5-8076df522fc3', 'SK-GTK-26-00027', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Test User', '9898989898', '2001-09-07', 'FEMALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', 'aa0bd8fb-c54f-472f-ab2b-9d0361cd0392', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'This is a test grievances', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-01 07:53:52.373208+00', '2026-09-01 07:53:52.373208+00'),
	('657d406f-7b21-4fd7-a473-d3a8adfbdbc9', 'SK-SOR-26-00028', NULL, '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Test User', '9898989898', '2001-09-07', 'FEMALE', 'Soreng', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', 'aa0bd8fb-c54f-472f-ab2b-9d0361cd0392', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', NULL, 'test summary of grievances', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-01 07:59:53.261892+00', '2026-09-01 07:59:53.261892+00'),
	('f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'SK-PAK-26-00012', 'f60352e9-33a0-40f2-98f4-b79fe2795050', 'f3595cfc-9d99-4e1f-89be-b0186267de66', 'Test', '9696969696', '2001-08-22', 'MALE', 'Test', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', 'deebe4b2-0aea-464a-b766-b615e0c8d3ff', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', NULL, 'test this is app submission', 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'NONE', NULL, 'RESOLVED', false, NULL, NULL, '2026-08-16 16:17:26.413432+00', '2026-08-16 19:44:01.654429+00'),
	('eccd9ae5-6dd6-4b47-a0e7-034305426197', 'SK-GTK-26-00029', NULL, '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Test Women User', '8918674671', '2001-09-07', 'FEMALE', 'Tadong', '162e0db6-feb9-44ea-9476-483c844f4956', 'aa0bd8fb-c54f-472f-ab2b-9d0361cd0392', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'this is the test grievances', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-01 08:55:19.506673+00', '2026-09-01 08:55:19.506673+00'),
	('c0c66157-f2d6-42ae-b587-27292cc074a6', 'LA-20260816-7dfba7c1', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'Demo Applicant 1', '+91-9000000001', '1990-01-01', 'FEMALE', 'Demo Village 1', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', 'b8961244-05cf-4f40-8104-c06656479aeb', 'Case details: Submitted', 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'dcded46c-c064-4311-b8ee-97f988885275', 'NONE', NULL, 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-08-16 14:38:20.618704+00', '2026-08-19 10:15:26.827635+00'),
	('2f55a346-859a-4318-a451-baaced3605ec', 'SK-GTK-26-00030', NULL, '37dbfb26-af99-4ea8-a756-c668bf7abe2a', 'Test Child', '6969696969', '2013-09-07', 'MALE', 'Tadong', '162e0db6-feb9-44ea-9476-483c844f4956', '30ac1c6c-144e-446d-a05b-151d558de1bd', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'this is a teset Child custody required details', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-01 09:21:12.974164+00', '2026-09-01 09:21:12.974164+00'),
	('d111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', 'SK-GTK-26-00013', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', 'f3595cfc-9d99-4e1f-89be-b0186267de66', 'Pranai Giri', '8918674671', '2001-08-23', 'MALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'Urgent Need of Succession Certificate', 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'NONE', NULL, 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-08-31 08:47:06.213664+00', '2026-08-31 08:50:57.144672+00'),
	('9b345236-cbc2-4887-a7a5-1dad2a209fd3', 'SK-GTK-26-00031', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Pranai Giri', '8918674671', '2001-08-23', 'FEMALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'this is a test succession', 'b343613e-76d1-41b0-8ec4-6adda5d58bc8', 'dcded46c-c064-4311-b8ee-97f988885275', 'NONE', NULL, 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-09-03 10:37:11.020871+00', '2026-09-03 10:38:41.032248+00'),
	('ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', 'SK-GTK-26-00014', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', 'f3595cfc-9d99-4e1f-89be-b0186267de66', 'Pranai Giri', '8918674671', '2001-08-23', 'MALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'urgent need for the Succession certificate', NULL, 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'NONE', NULL, 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-09-01 03:24:46.902076+00', '2026-09-01 06:27:29.611809+00'),
	('0e9e54f4-bc7e-40ec-b9c6-f70adaacecfa', 'SK-GTK-26-00045', NULL, '5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'Samiee', '9832611223', '2001-10-05', 'FEMALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', 'ca1a23db-2c25-4e8e-8515-ee7a7d6e86b2', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'fghfhhryfhjh k', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-29 09:48:08.721445+00', '2026-09-29 09:48:08.721445+00'),
	('d5855490-a80a-4dc3-a13b-5b7686255475', 'SK-GTK-26-00034', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', 'f3595cfc-9d99-4e1f-89be-b0186267de66', 'Pranai Giri', '8918674671', '2001-08-23', 'MALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', 'd434b194-4038-4342-b475-0f1ef7b44ae4', NULL, 'test summary frievance', NULL, 'dcded46c-c064-4311-b8ee-97f988885275', 'PENDING', '2026-09-10 10:41:51.439+00', 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-09-10 07:44:56.081356+00', '2026-09-10 15:29:35.106655+00'),
	('0d0158c8-3df9-4a4a-b776-8608c603c166', 'SK-GTK-26-00043', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', 'f3595cfc-9d99-4e1f-89be-b0186267de66', 'Pranai Giri', '8918674671', '2001-08-23', 'MALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', 'f10238bd-a3ba-4e55-9d63-18c2ccd80e8a', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'this is a test legal notice', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-09-13 14:17:13.121315+00', '2026-09-13 14:17:13.121315+00'),
	('5ddefe95-fba8-4456-9ed6-9e44883f0297', 'SK-GTK-26-00044', NULL, '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Hema Chettri', '9609755220', '2000-10-05', 'FEMALE', 'Sombaray', '162e0db6-feb9-44ea-9476-483c844f4956', 'aa0bd8fb-c54f-472f-ab2b-9d0361cd0392', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, 'test grievamce', NULL, '71fce84b-4ac1-42b6-868d-b2448a8109d6', 'NONE', '2026-09-29 09:12:37.426+00', 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-09-29 09:06:38.686376+00', '2026-09-29 09:12:34.796953+00'),
	('cacdb21c-5c37-438b-a663-be37c4db743b', 'SK-GTK-26-00046', NULL, '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Bbybbbb', '9609755220', '1998-10-04', 'FEMALE', 'Syari', '162e0db6-feb9-44ea-9476-483c844f4956', 'aa0bd8fb-c54f-472f-ab2b-9d0361cd0392', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, '', NULL, 'eb0b7646-2cf2-485a-b2b5-a5787b1a792c', 'NONE', '2026-09-29 11:27:06.142+00', 'ADVOCATE_ASSIGNED', false, NULL, NULL, '2026-09-29 11:22:49.855531+00', '2026-09-29 11:27:03.74716+00'),
	('2ffee2fc-1fc0-47ff-a104-1edee09aa0bb', 'SK-GTK-26-00047', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '837cce7d-b165-42d1-b6c8-7bcbcce502d1', 'Lorem Ipsum', '9898989898', '1995-10-12', 'FEMALE', 'Gangtok', '162e0db6-feb9-44ea-9476-483c844f4956', '1061ce0c-c230-47cc-b6d0-226e17acffbc', '162e0db6-feb9-44ea-9476-483c844f4956', NULL, '', NULL, NULL, 'NONE', NULL, 'SUBMITTED', false, NULL, NULL, '2026-10-06 09:56:13.722464+00', '2026-10-06 09:56:13.722464+00');


--
-- Data for Name: advocate_case_action_log; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: advocate_change_request; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: advocate_district_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."advocate_district_mapping" ("advocate_id", "district_id", "is_primary_district") VALUES
	('3cc31969-af68-4be9-bc9d-8e69bd810811', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('47e0c7b9-eb0e-43ee-9776-89d161a02aec', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('365e9eca-06b6-4cd8-85dc-bfd96a013bad', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('71fce84b-4ac1-42b6-868d-b2448a8109d6', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('4be9c9ee-bdfc-4284-a85e-9f11e7c36e65', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('9a69156c-e8fe-4499-8dcc-0220163e4a2f', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('2f4fad71-8c19-4fef-9fec-f7ecf2334937', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('a8ddba32-ba22-4c8b-8a0a-b77ca8c56b9e', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('c416cbe7-0df7-4ced-ae54-485745b1f983', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('71ab48ae-0765-4462-9b13-185ffd482323', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('f94da927-1386-41ae-ab23-5be9a6e57348', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('129b3db0-3889-46d7-bf7b-0b4dc5892446', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('a6420833-f7d1-4ffe-999f-154933c96d58', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('ce44b191-b634-43ca-b9a2-57de646c1199', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('4bb8be65-61b4-457b-b803-8ea7982f579c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e1aea0f2-32b5-4b07-995d-e2e60397d2e7', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('52a891d6-19c2-4012-92b7-9aa8e85a229b', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('743a1a8b-5df8-4c86-a0c3-71340d53f7c9', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('0d1ec98f-2081-46a4-b056-741832a3bf5d', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('01459d67-7440-4504-aa92-e9817b1ef0f9', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('30600c29-ff94-4063-a58f-16a8cabcbf18', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('ce28cd72-4827-401c-acbd-63bb8546c8ab', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7b887b9f-0053-407a-bfe6-9cbc604e6dfb', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('5dddbef4-c331-4079-9811-d1f9c67532ff', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('4ba0e616-c860-441f-98d0-ec922e30e94c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('8c2d2159-6311-4767-96ff-6b081f848790', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('45006a5e-b692-4384-ad8c-d19774b8332a', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('a7a23a34-95b7-45e3-b4ba-83c818bb9845', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e09be191-c4ed-46cd-baf8-ddbfbc8c3795', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('760af78b-cb95-4979-a68a-945a6259d824', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('8f7becf8-46c3-4ad8-8066-a555e3aa741a', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('5a3f8477-27f7-41d2-a450-c91ff35b6129', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('b26940f6-600e-42a6-8c21-cdbcbfaa9f31', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('5917a59c-be5e-4b0d-81f3-fb3f3a35e8d8', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('192d6451-4aa3-467b-85d1-df0a945504ae', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('b457a954-d9fa-4fc9-a4a5-e947c5e56b52', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('249f2753-af1a-47af-9637-66b345d862bf', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('31f20f6e-ad1a-47c9-9155-1590bd8426ff', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('a24dda9a-c186-44f0-a9a1-0844bef8adf8', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('6c2b9354-df63-433a-942e-4d83ba1107cb', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('bfe83cda-4e4e-404b-9f2c-c1609677a522', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('c8552373-0e18-488c-ac5c-18ea669797a7', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e981d992-17c6-400a-8415-3808d4791b9a', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('216e4773-084e-43cb-bcb9-e15765bc80b4', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('0a2aaf01-e97b-4a81-9a78-038a245bd591', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e364a60d-225f-4659-b102-ee7fb4524576', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('8324444d-8abb-4481-81d8-f8975508a8d0', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('775931d3-7d51-4b50-a6f2-83035b67e981', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7b644435-39b4-456a-8344-63e0b3703b2a', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('72865741-f50b-4909-8fe2-d100c8f2c190', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('0ab123d9-2981-461f-8cc8-7b99d3d728b3', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('cdf38621-a2ad-45ed-bb62-be290918401f', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7c4e4213-1b45-4126-b738-432095f1ab68', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('0fcf4042-9c6c-4bad-a876-2f2ae74b916e', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('2ad8fc0d-3116-4a33-b677-08526310ee66', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('3eb732ee-305f-4262-937d-00d1ade93ffe', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('b75e621a-cc77-4150-9589-cd9d9835b4b5', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('33f403cb-9ac5-411e-8bff-40c6f1804e25', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e958e42a-2fef-4ecb-ad22-ec00c5a84609', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('b218d666-d6f8-4b3b-ad08-12299ee7b4da', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('91af4a2c-533e-4e91-9751-0ba012d63901', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7e9e7290-88d8-4160-b333-bcd2f280cbf4', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('383e6c0a-0f9e-4ccf-923b-9369f4d1f8f3', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e97e137b-fb9a-4190-a702-791a4799da95', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('6f949782-cae9-4a0d-83ca-e22f275fd298', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('c2224fe5-1990-4c40-a7e9-c0292c7a139a', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e62b226d-5c6a-48c9-bfb6-35e32ffacd22', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('18130a28-381f-44b3-b5a7-db1f6bf23b24', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7d6d13e6-dbf0-4e1f-9e9b-a3b86f9e9855', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('bf12131d-e7a0-4673-ad25-73d8bd12fbb2', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('6c83dc20-86ce-4a4e-a0e8-fba088d23b8c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('9075d78d-cf57-47ba-b808-4d247ca0af20', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('23eba25f-a8f8-4922-9847-e309eef00035', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('c67957aa-38a9-4895-a554-b57f134cf420', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('0580a207-9583-45bc-9210-983c482d49f1', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('c664bc2b-b36a-4744-a582-46bbc709ec13', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('ac9545da-d7c7-4836-b959-84c36e81f618', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('dd56e08a-bb7c-48c8-9105-9e02a164ad46', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7343470c-5155-454c-8e55-a364a8d5e36d', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('29e5481a-fff3-4678-9fd7-65906d2a5efc', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('af24afbc-9c73-4062-9356-9c9c4288fe02', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('fda0c4e6-d653-49e2-9052-ba2b10a38669', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('ec0823bf-6210-4982-ab1a-68275260af3f', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('2b5c284d-b589-4f31-9298-14b9ebfab138', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('f4b5a16e-43cb-4f8b-b565-6aebaed71cf1', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('1289c18b-2ef8-46f1-9b8f-722608dcace3', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('d3c4213d-8732-49c1-a40d-f8384015218d', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('5d6e5023-6ae2-4217-ac03-585fa24fc0e5', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('501625d4-d369-4723-bb15-0aeba6320706', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('fb1c8e4a-dbd2-4aca-ae49-4568b831e7e1', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('3f74e2dc-3018-4938-b863-2d0779bf92cb', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('71b69a3d-8769-4e2b-bf9d-2e6aaac873c2', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('7d6c25a4-520e-4588-bd47-5073ea02cf94', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e9bee74e-69b4-4031-ada2-dc1f2fda8856', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('1e0db796-ff41-4f62-98ed-b7521073d660', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('b5642866-54dc-4a17-a511-956d3eb5d82b', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('3b935a8d-d1ae-4def-9557-1c7c8c5940a7', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('729263a5-e525-4eca-965a-10bc3bbda6e4', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('232de221-2305-4521-818f-f511734f0765', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('eac2de39-3571-493b-966d-66f015eea38c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('e78365da-a472-4995-bc8d-aa361365a95f', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('28be4e46-04bf-4aae-b676-4b678d9b5ae7', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('14851c75-4f6e-49fb-a4f2-470646c877a3', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('d41942db-a78a-4818-b846-d6bf112403f0', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('957ba8a5-2612-47d3-998b-725c728b285c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('eb0b7646-2cf2-485a-b2b5-a5787b1a792c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('09b035a7-a012-4d86-aecb-3bf4652d482c', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('24b026ec-f83f-47cb-b1fa-61c7b53b7f1e', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('94174336-97cc-4af6-8fd3-eec6245fea83', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('d6c86a70-8535-4125-b977-57ae2b0cf6d8', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('ae483326-e09a-49de-9eeb-6d43afd1b1f3', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('0205ca0a-ae6e-4251-b280-9b1c4fd47a51', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('2acdccf4-99fc-4b14-be90-66555fec0585', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('a5f08483-0e2d-4f8e-af80-401c19be3e6a', '162e0db6-feb9-44ea-9476-483c844f4956', true),
	('dcded46c-c064-4311-b8ee-97f988885275', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('c5948df5-0515-4eeb-bb58-2e6ff19edee1', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('e57a0f2f-449a-4979-827d-93110aa4ecb5', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('6eb277ca-5443-4f46-b9be-c29892f65f34', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('856f1190-9334-4e8b-a114-a30cd7ed6303', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('d7ea0389-65ee-47b3-8710-7d843b1aebfa', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('5d4cf8cb-57fc-4a49-8d05-470de6b92617', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('506a1e45-98dd-4bdf-ad98-9e28dee1043c', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('d5f11d17-5d0e-4b91-a8c7-3b35ff5500c5', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('ff3996d2-ab6e-4444-a557-c785c68cbe97', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('4515f1d2-dd05-4d02-9aec-ef554624fd49', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('548bfa56-84cb-4ad3-97a1-a661cda4ffd0', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('abbec3f8-52ef-4264-a5c5-7e34ef51a55a', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('9871a0d7-91fc-4ade-9762-0848f36ba322', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('b343613e-76d1-41b0-8ec4-6adda5d58bc8', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('52897e4b-6561-4600-93bb-d76e896b3cda', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('9548f89b-a2c9-421a-98ad-daa9d9fd2183', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('a585da07-09e6-4c76-9779-6f69937d5d9b', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('1a7078bd-d10a-49eb-b768-abd31a651bf1', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('18e154b7-afb5-41fc-8513-33d5f57346ef', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('0a678b26-52c5-48c8-88a8-86f5aeb48c73', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('b46940c9-5aa0-4fa4-b6d4-fd0c16206c03', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('92508178-5a0d-41d2-8e88-d2e77d29c5fa', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('adf0f298-eee7-446d-b6a2-63b27527e69c', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('0c725ba4-2c47-448f-b156-1970047664d7', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('29560d25-ccb0-4fce-ba0a-289c40fc940f', '7c7faa9f-4cbb-450d-9046-15ef51430cd9', true),
	('156e9966-f359-4f51-9a4b-f6c9fb8e12b2', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', true),
	('754bf6e3-e2cd-4caa-896b-dfdd66e8f4c6', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', true),
	('01f92d6e-8b2e-4587-9fc0-4716a1d0ab87', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', true),
	('d9303d66-90a4-4885-9dd1-65b1dda7b4af', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', true),
	('1d955daf-831d-44d2-9f1e-8e31fb3c24fd', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', true),
	('1734c51d-0a3d-46e3-9873-ddad0fc3d5f2', '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', true),
	('43ea5784-4f73-4c88-8296-1fdb8ed035a7', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('15efb1d0-6cc0-456b-91da-3e4774eb822c', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('52424eb8-af69-4612-be06-9d6ca3aed0e4', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('44745f9e-8523-41a6-8447-3e3e410f95af', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('99945423-f6a3-4473-843d-86e4e087f72d', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('43043778-16a6-4c02-af0a-33c96ca0bd58', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('0f34ca16-1d4f-47b6-af0f-241bd6ef517d', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('e348aa85-a0d6-4640-bdd3-37eb2f6cf5a5', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('eddd64bf-c286-47da-a59e-57b8f6ce821a', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('ab2ee49f-82d3-402d-9cc0-31fc0691c9af', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('c326bc7b-cc25-4f3d-9b0d-b694cc59b776', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('f163011a-d0c8-413a-99da-56a4c841afcf', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('da531982-fb02-458f-beb6-0b1bdbfe2899', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('e7ad8118-6719-4929-8d0e-6ca74f4a2cc6', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('5e0a0029-9c6a-4e61-8f3c-7b31af0e4f6b', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('da38eabe-c936-4b63-9f9a-7511b6789d5e', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('ea1480ea-09da-487c-8722-f7697620675b', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('1a37d603-6c89-43fb-a69b-0dbac3f30d29', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('40fe53f6-dff7-40cc-a445-118db8efb3a8', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('d3040a0d-f051-473d-b887-959dadeb9848', 'd434b194-4038-4342-b475-0f1ef7b44ae4', true),
	('59c6f67a-51e4-4703-8840-07c174acf755', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('02399d3b-c5ab-48a4-a499-301673d67f97', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('b6afa929-c1b6-4dc0-9fa1-2a9d2ec15039', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('e111e115-13fd-4092-bde8-6f276bdd77b9', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('a58be060-9342-4499-9c8f-5cf6ea342db3', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('26ed624a-2d03-4f62-822a-5f1544b8e464', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('a0ecf165-3717-4a40-9e97-943726399ee8', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('5a5484b0-da4b-4a28-b183-8e390147b9b3', '771eac9c-c0b1-4b1b-acfa-658163c4a82f', true),
	('58c7fc77-9e56-49a9-a663-f7a79ba5eedf', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('a5d997d3-13c4-4342-a876-46071d9aae5a', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('644b4d19-9fac-4e3f-9537-dbc2b94de67a', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('64ce6976-f204-41d9-8104-29eeb2a0120d', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('70509556-8bcb-46f0-8b6f-3ea17142a292', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('be42dd2a-2bba-42f5-a509-5aebccf49f39', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('1c2ad25d-c6db-4d44-bf7b-9c2c79f380e9', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('f2769f50-d0ce-4768-b3f3-886806c9a18f', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('80e2a118-c63e-4dea-871c-512db17a5139', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true),
	('b37ceb97-a500-441b-99d3-7c2f083a86d4', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', true);


--
-- Data for Name: document_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."document_master" ("id", "document_code", "document_name", "description", "is_active", "created_at") VALUES
	('e9ac3de5-068a-4e3b-8351-af22a7c6f5a1', 'DRIVING_LICENCE', 'Driving Licence', 'Motor vehicle driving licence', true, '2026-08-14 11:05:55.727665+00'),
	('05cffb0c-2ae7-469f-918c-9208720dd9d9', 'INCOME_CERTIFICATE', 'Income Certificate', 'Government issued annual income certificate', true, '2026-08-14 11:05:55.727665+00'),
	('a899b9db-3898-4a99-ad7c-ebe8ab9eecc8', 'CASTE_CERTIFICATE', 'Caste Certificate', 'SC/ST/OBC community status certificate', true, '2026-08-14 11:05:55.727665+00'),
	('8b5e97fc-8f41-4562-bec4-01f4482f442f', 'DISABILITY_CERTIFICATE', 'Disability Certificate', 'Medical certificate of disability', true, '2026-08-14 11:05:55.727665+00'),
	('4cc059bf-3167-4143-866c-9abaff5e2b1f', 'INDUSTRIAL_WORKER_ID', 'Industrial Worker Identity Card', 'Proof of employment in industrial sector', true, '2026-08-14 11:05:55.727665+00'),
	('877e46ba-089c-4ce0-953a-43fdd4ad2ed7', 'DEATH_CERTIFICATE', 'Death Certificate', 'Official death registration certificate', true, '2026-08-14 11:05:55.727665+00'),
	('8119b64f-d2a9-4190-9db2-b5be34c75fa2', 'MARRIAGE_CERTIFICATE', 'Marriage Certificate', 'Legal marriage registration document', true, '2026-08-14 11:05:55.727665+00'),
	('9a357f9d-dcef-48e2-a2e0-47afbf0698fa', 'LEGAL_HEIR_CERTIFICATE', 'Legal Heir Certificate', 'Certificate establishing legal heirs', true, '2026-08-14 11:05:55.727665+00'),
	('c5a99b97-54e5-4dcb-b85e-ba76b57cda37', 'POLICE_FIR', 'Police FIR (First Information Report)', 'Copy of police FIR or complaint acknowledgment', true, '2026-08-14 11:05:55.727665+00'),
	('1874033d-0b5d-4f97-a657-6ee1c4724261', 'MEDICAL_CERTIFICATE', 'Medical Certificate', 'Hospital or medical officer report', true, '2026-08-14 11:05:55.727665+00'),
	('2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'IDENTIFICATION_DOCUMENT', 'Identification Document (Voter, Aadhar)', 'A government-approved identification document (e.g., Aadhaar, Voter ID, Passport).', true, '2026-08-16 14:18:31.149889+00'),
	('3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'AGE_PROOF_DOCUMENT', 'Birth/School Certificate', 'Official birth registration certificate or school certificate', true, '2026-08-14 11:05:55.727665+00');


--
-- Data for Name: application_document; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."application_document" ("id", "application_id", "document_id", "file_url", "file_name", "file_size_in_bytes", "is_verified", "verified_by", "uploaded_at") VALUES
	('bd423646-9ba0-4325-b0cd-9efb13576ce0', '4879def6-dfd6-4d4a-bda0-acb3d4916df4', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Document+1', 'demo_1.png', 204800, false, NULL, '2026-08-16 14:33:09.879909+00'),
	('8f58bc56-d711-4385-993d-9c6e37ac9c66', '4879def6-dfd6-4d4a-bda0-acb3d4916df4', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Document+2', 'demo_2.png', 204800, false, NULL, '2026-08-16 14:33:09.879909+00'),
	('c2bdb87c-843d-491b-ba26-c36cbcef36f7', '463991a4-cf51-47df-a98a-d98b49591b7f', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Document+1', 'demo_1.png', 204800, false, NULL, '2026-08-16 14:33:09.879909+00'),
	('32518dc7-326f-41c6-94cb-a1697bf691a4', '463991a4-cf51-47df-a98a-d98b49591b7f', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Document+2', 'demo_2.png', 204800, false, NULL, '2026-08-16 14:33:09.879909+00'),
	('809bde4d-4171-42ab-92cd-6d61971a362a', '8e4e380d-f49e-4248-951e-0453f39d7545', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A', 'app_document_A.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('b8d1253d-8c54-4683-937c-0d8a0c73ebb3', '8e4e380d-f49e-4248-951e-0453f39d7545', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B', 'app_document_B.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('cd80b54b-940f-4dae-9469-4d2a79cd8a19', 'c0c66157-f2d6-42ae-b587-27292cc074a6', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A', 'app_document_A.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('3780288a-d92d-4700-bf20-b3c07bcc8bad', 'c0c66157-f2d6-42ae-b587-27292cc074a6', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B', 'app_document_B.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('f8c12a8e-787c-4f21-9a2b-e2a5be071a9b', 'f10bf085-13e5-450b-9150-f7d134863908', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A', 'app_document_A.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('57633cf1-895a-4655-b359-74b33bf00ab2', 'f10bf085-13e5-450b-9150-f7d134863908', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B', 'app_document_B.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('bf06ff6e-fb08-4958-bcb9-821bf188b645', '8ca4fd2a-d85d-4465-9567-50a2242e8f98', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A', 'app_document_A.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('3822013a-1d12-4e37-83bf-02b44702108a', '8ca4fd2a-d85d-4465-9567-50a2242e8f98', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B', 'app_document_B.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('629a3567-6806-41af-a538-50f289fb428d', 'a6501732-9bd7-44bb-b89f-459643f37f5a', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A', 'app_document_A.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('b50bda4b-a9f7-455d-adc8-9ed7777c60ee', 'a6501732-9bd7-44bb-b89f-459643f37f5a', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B', 'app_document_B.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('5dd2f7b1-ef64-4fd1-803b-c3cf30089c1d', '81ee9973-ce8a-4475-92cd-1da7b60faee1', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+A', 'app_document_A.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('6f8a4c77-5c02-4ffa-b0d7-d66fa3f2c5bf', '81ee9973-ce8a-4475-92cd-1da7b60faee1', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'https://via.placeholder.com/900x1200.png?text=Demo+Applicant+Doc+B', 'app_document_B.png', 204800, false, NULL, '2026-08-16 13:38:41.727609+00'),
	('f9f068d0-ce3f-4af3-aec0-0660b510c221', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/c3274220-be04-4678-8154-0da267fe3ac9/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-08-16 16:17:27.438771+00'),
	('22b6918e-1f0b-48f7-bedd-b0b732f7ec96', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'draft-uploads/c3274220-be04-4678-8154-0da267fe3ac9/INCOME_CERTIFICATE.jpg', 'INCOME_CERTIFICATE.jpg', NULL, false, NULL, '2026-08-16 16:17:27.810055+00'),
	('0e31f117-a8c5-440e-b7f1-19c0f5a76682', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/826427ff-5d71-410a-b0a1-b643a5df748e/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-08-31 08:47:06.83508+00'),
	('ad6ce8a8-82c5-4814-b47d-7e4952b49e00', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'draft-uploads/826427ff-5d71-410a-b0a1-b643a5df748e/INCOME_CERTIFICATE.jpg', 'INCOME_CERTIFICATE.jpg', NULL, false, NULL, '2026-08-31 08:47:07.51552+00'),
	('8f8225f4-52b7-4714-a34b-2809322474e1', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', '9a357f9d-dcef-48e2-a2e0-47afbf0698fa', 'draft-uploads/826427ff-5d71-410a-b0a1-b643a5df748e/LEGAL_HEIR_CERTIFICATE.jpg', 'LEGAL_HEIR_CERTIFICATE.jpg', NULL, false, NULL, '2026-08-31 08:47:07.966532+00'),
	('9e360917-2c1c-4534-ba1c-41b1728044cb', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/dddadf8e-78b4-4fda-96bf-a740b8601be4/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-01 03:24:47.674641+00'),
	('9e6e8f73-6e46-4975-8d99-42e5b2de82c8', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'draft-uploads/dddadf8e-78b4-4fda-96bf-a740b8601be4/INCOME_CERTIFICATE.jpg', 'INCOME_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-01 03:24:48.100399+00'),
	('9dfedded-dd73-4ae8-b52b-14a6ffdb4191', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', '9a357f9d-dcef-48e2-a2e0-47afbf0698fa', 'draft-uploads/dddadf8e-78b4-4fda-96bf-a740b8601be4/LEGAL_HEIR_CERTIFICATE.jpg', 'LEGAL_HEIR_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-01 03:24:48.471933+00'),
	('84c67b72-9d05-422a-b88d-5edc93921d9b', '4879def6-dfd6-4d4a-bda0-acb3d4916df4', 'e9ac3de5-068a-4e3b-8351-af22a7c6f5a1', 'draft-uploads/RLS-PROBE-G/probe.jpg', 'probe-G.jpg', NULL, false, NULL, '2026-09-01 07:47:35.267091+00'),
	('afbced61-9ae1-43e0-bc95-adc0ae3ea6fe', 'd36069f1-81fc-460e-b5b5-8076df522fc3', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/8b768b73-56f9-403d-b35c-05c30788e4d6/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-01 07:53:52.89598+00'),
	('796b1a62-2d17-4238-b284-5ba72e4866f7', '657d406f-7b21-4fd7-a473-d3a8adfbdbc9', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/38184240-10c9-42ab-8a10-fbf19cd56c0d/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-01 07:59:53.726901+00'),
	('e554b501-cfdb-4b4f-9365-531b30e88494', 'eccd9ae5-6dd6-4b47-a0e7-034305426197', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/9530fa50-ba21-40b0-8074-c5a8d3a267e8/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-01 08:55:20.346743+00'),
	('ab2ac7c8-bef8-457d-b032-723b04770147', '2f55a346-859a-4318-a451-baaced3605ec', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', 'draft-uploads/4fe322b4-9067-4a3d-9296-0de6354fda2d/AGE_PROOF_DOCUMENT.jpg', 'AGE_PROOF_DOCUMENT.jpg', NULL, false, NULL, '2026-09-01 09:21:14.14954+00'),
	('78f5f8af-6481-418c-bfd8-32f7643bbd62', '9b345236-cbc2-4887-a7a5-1dad2a209fd3', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/acd754b5-13dd-4d10-92b9-107cf044b3e3/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-03 10:37:11.431982+00'),
	('b57a1ef0-5e9a-4304-9a6b-475b19d03ac9', '9b345236-cbc2-4887-a7a5-1dad2a209fd3', '9a357f9d-dcef-48e2-a2e0-47afbf0698fa', 'draft-uploads/acd754b5-13dd-4d10-92b9-107cf044b3e3/LEGAL_HEIR_CERTIFICATE.jpg', 'LEGAL_HEIR_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-03 10:37:11.431982+00'),
	('a946d603-8d44-4448-a8ee-ecc26726d642', 'd5855490-a80a-4dc3-a13b-5b7686255475', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/e1a38c3f-0ef7-4774-9647-e1ee984dc0bd/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-10 07:44:56.74573+00'),
	('ee31a20f-b753-4c05-ac2a-f2f5f1a3f572', 'd5855490-a80a-4dc3-a13b-5b7686255475', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'draft-uploads/e1a38c3f-0ef7-4774-9647-e1ee984dc0bd/INCOME_CERTIFICATE.jpg', 'INCOME_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-10 07:44:56.74573+00'),
	('18cc8b02-1eb4-41f2-a82d-31cbc30427e7', 'd5855490-a80a-4dc3-a13b-5b7686255475', '9a357f9d-dcef-48e2-a2e0-47afbf0698fa', 'draft-uploads/e1a38c3f-0ef7-4774-9647-e1ee984dc0bd/LEGAL_HEIR_CERTIFICATE.jpg', 'LEGAL_HEIR_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-10 07:44:56.74573+00'),
	('55e3c0c4-890b-4a4d-b3ea-c625898d54e0', '0d0158c8-3df9-4a4a-b776-8608c603c166', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/23bec60c-b235-49ac-837c-89db818cbc0b/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-13 14:17:13.892594+00'),
	('a311be01-7fbe-4bb9-9d3f-90646ab69800', '0d0158c8-3df9-4a4a-b776-8608c603c166', '05cffb0c-2ae7-469f-918c-9208720dd9d9', 'draft-uploads/23bec60c-b235-49ac-837c-89db818cbc0b/INCOME_CERTIFICATE.jpg', 'INCOME_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-13 14:17:13.892594+00'),
	('739bf9f0-7b3c-48cb-bbfe-703ae14f1c6a', '5ddefe95-fba8-4456-9ed6-9e44883f0297', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/cebf1f5f-32dd-4949-a475-e67ad9e1dc77/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-29 09:06:39.169764+00'),
	('e7de602d-997f-4c42-ad40-8ac7dbb1f9d9', '0e9e54f4-bc7e-40ec-b9c6-f70adaacecfa', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/91279e82-ffbb-4d31-a2e4-98d37bdc8763/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-29 09:48:09.140501+00'),
	('57644774-9bff-4d1d-a721-96e7b15e091f', '0e9e54f4-bc7e-40ec-b9c6-f70adaacecfa', 'a899b9db-3898-4a99-ad7c-ebe8ab9eecc8', 'draft-uploads/91279e82-ffbb-4d31-a2e4-98d37bdc8763/CASTE_CERTIFICATE.jpg', 'CASTE_CERTIFICATE.jpg', NULL, false, NULL, '2026-09-29 09:48:09.140501+00'),
	('e749bdf0-3498-4be3-bde2-67d25b5e6837', 'cacdb21c-5c37-438b-a663-be37c4db743b', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/3235ef46-3117-4355-9256-ce6e04f8cb18/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-09-29 11:22:50.512431+00'),
	('6b0f3538-0dab-44ca-8c61-20e50b4eb227', '2ffee2fc-1fc0-47ff-a104-1edee09aa0bb', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', 'draft-uploads/aa281925-d46c-4a28-abfb-b2da0715ec96/IDENTIFICATION_DOCUMENT.jpg', 'IDENTIFICATION_DOCUMENT.jpg', NULL, false, NULL, '2026-10-06 09:56:14.684009+00'),
	('00546fb8-07de-4d24-ba13-4ae4ebcf2127', '2ffee2fc-1fc0-47ff-a104-1edee09aa0bb', '9a357f9d-dcef-48e2-a2e0-47afbf0698fa', 'draft-uploads/aa281925-d46c-4a28-abfb-b2da0715ec96/LEGAL_HEIR_CERTIFICATE.jpg', 'LEGAL_HEIR_CERTIFICATE.jpg', NULL, false, NULL, '2026-10-06 09:56:14.684009+00');


--
-- Data for Name: application_forward_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."application_forward_log" ("id", "application_id", "from_district_id", "to_district_id", "forwarded_by_id", "reason", "forwarded_at") VALUES
	('1e31e432-f86d-4f5d-88d5-30947d427873', 'd5855490-a80a-4dc3-a13b-5b7686255475', '162e0db6-feb9-44ea-9476-483c844f4956', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', 'District transfer', '2026-09-10 11:26:09.936072+00'),
	('bde3e58b-9f12-4972-a511-381bbc8d5441', 'd5855490-a80a-4dc3-a13b-5b7686255475', '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6', 'd434b194-4038-4342-b475-0f1ef7b44ae4', 'ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', 'District transfer', '2026-09-10 15:29:35.106655+00');


--
-- Data for Name: application_status_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."application_status_history" ("id", "application_id", "previous_status", "new_status", "changed_by_id", "remarks", "created_at") VALUES
	('141ffa47-b97e-4699-a938-8283e8789ebc', '8e4e380d-f49e-4248-951e-0453f39d7545', 'SUBMITTED', 'ADVOCATE_ASSIGNED', 'f60352e9-33a0-40f2-98f4-b79fe2795050', 'Advocate assigned', '2026-08-16 14:08:41.727609+00'),
	('22debbb8-8125-4f1b-b37d-ae68de5347ff', 'c0c66157-f2d6-42ae-b587-27292cc074a6', 'SUBMITTED', 'SUBMITTED', 'f60352e9-33a0-40f2-98f4-b79fe2795050', 'Status updated', '2026-08-16 14:08:41.727609+00'),
	('e808a573-fda7-41f2-a17d-71f55c5b05d7', 'f10bf085-13e5-450b-9150-f7d134863908', 'SUBMITTED', 'REJECTED', 'f60352e9-33a0-40f2-98f4-b79fe2795050', 'Application rejected', '2026-08-16 14:08:41.727609+00'),
	('4977cbc2-24ae-4697-a30a-eef62afe64f5', '8ca4fd2a-d85d-4465-9567-50a2242e8f98', 'SUBMITTED', 'UNDER_REVIEW', '6903780c-c138-463e-af24-35991d1c2add', 'Moved to UNDER_REVIEW', '2026-08-16 14:08:41.727609+00'),
	('e57d56f8-d973-42d6-947d-61ad08381cde', 'a6501732-9bd7-44bb-b89f-459643f37f5a', 'SUBMITTED', 'WITHDRAWN', '6903780c-c138-463e-af24-35991d1c2add', 'Application withdrawn by citizen', '2026-08-16 14:08:41.727609+00'),
	('08213ae3-3c37-4b81-93f6-105314725216', '81ee9973-ce8a-4475-92cd-1da7b60faee1', 'SUBMITTED', 'RESOLVED', '6903780c-c138-463e-af24-35991d1c2add', 'Application resolved', '2026-08-16 14:08:41.727609+00'),
	('087ebb4c-d317-4710-a304-580139315294', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'ADVOCATE_ASSIGNED', 'RESOLVED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-16 19:30:18.356362+00'),
	('7851c4cd-6246-41cd-a051-c9d782f00d51', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'RESOLVED', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-16 19:30:36.291151+00'),
	('960b9bc0-2d8a-4851-b529-cbcc6d07afbc', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'ADVOCATE_ASSIGNED', 'RESOLVED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-16 19:44:01.654429+00'),
	('b243ffae-3db0-4629-98e8-2a476495a795', 'c0c66157-f2d6-42ae-b587-27292cc074a6', 'SUBMITTED', 'UNDER_REVIEW', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-19 10:15:10.632982+00'),
	('5a62cadc-cd3e-4467-bb45-87e9e9730b97', 'c0c66157-f2d6-42ae-b587-27292cc074a6', 'UNDER_REVIEW', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-19 10:15:26.827635+00'),
	('38cf956d-3b4a-4516-8602-77c8083099e2', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-08-31 08:47:06.213664+00'),
	('1d0bb939-51d3-4b5d-ab79-ab04e575908a', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', 'SUBMITTED', 'UNDER_REVIEW', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-31 08:49:44.172353+00'),
	('ef5659c6-72af-492a-9332-23428722e5f6', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', 'UNDER_REVIEW', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-08-31 08:50:35.846029+00'),
	('255dde48-edcf-40d6-8981-45719b94ebc7', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-09-01 03:24:46.902076+00'),
	('f1f9095e-2b99-4f13-997f-7ba9cae46706', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', 'SUBMITTED', 'UNDER_REVIEW', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-01 06:26:51.935902+00'),
	('b0d00db5-81ca-460f-9918-3652f80d6daa', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', 'UNDER_REVIEW', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-01 06:27:29.611809+00'),
	('67932e6c-a550-43ec-af8d-e59d2f58088b', 'd36069f1-81fc-460e-b5b5-8076df522fc3', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-09-01 07:53:52.373208+00'),
	('8e9f0d71-f5ef-497e-bab0-a7dbfe9ccf1e', '9b345236-cbc2-4887-a7a5-1dad2a209fd3', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-09-03 10:37:11.020871+00'),
	('bc9c4c03-0f82-43ba-af1f-dae2b8bdc142', '9b345236-cbc2-4887-a7a5-1dad2a209fd3', 'SUBMITTED', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-03 10:38:41.032248+00'),
	('5b79320a-4a02-4d64-8052-4ab3f6c3a5de', 'd5855490-a80a-4dc3-a13b-5b7686255475', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-09-10 07:44:56.081356+00'),
	('fb57e2f1-e7de-488e-b700-d465c1b224df', 'd5855490-a80a-4dc3-a13b-5b7686255475', 'SUBMITTED', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-10 10:41:51.697082+00'),
	('af79da3b-3820-4058-bcd7-e00c6dcff557', 'd5855490-a80a-4dc3-a13b-5b7686255475', 'SUBMITTED', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-10 10:41:52.108897+00'),
	('2f60fd6c-ab55-425c-a179-20d107eaad8d', '0d0158c8-3df9-4a4a-b776-8608c603c166', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-09-13 14:17:13.121315+00'),
	('a979e99e-07e8-45ab-8be5-22d54c61fe7a', '5ddefe95-fba8-4456-9ed6-9e44883f0297', 'SUBMITTED', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-29 09:12:35.099004+00'),
	('c8e4d5f2-ff08-4b2e-bafd-57579d512423', 'cacdb21c-5c37-438b-a663-be37c4db743b', 'SUBMITTED', 'ADVOCATE_ASSIGNED', '8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', NULL, '2026-09-29 11:27:04.273677+00'),
	('2128aca4-5b9e-42e7-95b9-d49cdcfe2071', '2ffee2fc-1fc0-47ff-a104-1edee09aa0bb', NULL, 'SUBMITTED', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', NULL, '2026-10-06 09:56:13.722464+00');


--
-- Data for Name: case_type_document_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."case_type_document_map" ("case_type_id", "document_id", "is_required") VALUES
	('1061ce0c-c230-47cc-b6d0-226e17acffbc', '9a357f9d-dcef-48e2-a2e0-47afbf0698fa', true);


--
-- Data for Name: legal_aid_category_document_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."legal_aid_category_document_map" ("category_id", "document_id", "is_required") VALUES
	('c8211997-2ac3-44cf-873b-949c2a44f431', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('6d4367bd-b8ba-4509-935a-d56e3501ed6d', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('ec9e7d1a-b486-4a33-afc6-1b3cb465c6cc', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('f3595cfc-9d99-4e1f-89be-b0186267de66', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('777165d6-14a6-4f91-92a6-34714498c49f', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('5793c5e6-9236-4dfd-8b82-fbb3d82dc092', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('196987de-5894-4a5a-9e0f-ddf23f50df12', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('837cce7d-b165-42d1-b6c8-7bcbcce502d1', '2d30eaa3-ae5c-419c-9962-e13ad6a9333e', true),
	('37dbfb26-af99-4ea8-a756-c668bf7abe2a', '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e', true),
	('5793c5e6-9236-4dfd-8b82-fbb3d82dc092', 'a899b9db-3898-4a99-ad7c-ebe8ab9eecc8', true),
	('6d4367bd-b8ba-4509-935a-d56e3501ed6d', '8b5e97fc-8f41-4562-bec4-01f4482f442f', true),
	('f3595cfc-9d99-4e1f-89be-b0186267de66', '05cffb0c-2ae7-469f-918c-9208720dd9d9', true);


--
-- Data for Name: modules; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."modules" ("id", "code", "permission_code", "label", "route", "icon", "section", "group_label", "display_order", "is_active", "created_at", "updated_at") VALUES
	('f05c45ed-de26-4495-8871-ce7df1cedc68', 'applications', 'applications.view', 'Applications', '/applications', 'lucide:clipboard-list', 'ADMINISTRATION', NULL, 30, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 07:45:22.979084+00'),
	('d4664898-61cf-425a-a110-e354552a555e', 'users', 'users.view', 'Users', '/admin/users', 'tabler:users', 'ADMINISTRATION', NULL, 10, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('8599f0f9-5fc1-4824-b966-06a5e0f86da5', 'dashboard', 'dashboard.view', 'Dashboard', '/dashboard', 'tabler:home', 'HOME', NULL, 1, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('9926569c-43f5-4d19-afdb-f0d3560dd45a', 'advocates', 'advocates.view', 'Advocates', '/advocates', 'tabler:briefcase', 'ADMINISTRATION', NULL, 20, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('87480402-dcc5-47c7-bc2c-ad3d640f2fb7', 'md-case-types', 'master_data.view', 'Case Types', '/admin/master-data/case-types', 'tabler:briefcase', 'ADMINISTRATION', 'Master Data', 50, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('3cd5659a-dee6-41fa-b361-3e30041b0c1b', 'md-states', 'master_data.view', 'States', '/admin/master-data/states', 'tabler:map', 'ADMINISTRATION', 'Master Data', 10, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('5608d36c-06a8-4c14-a84d-493c3ae44f7e', 'md-talukas', 'master_data.view', 'Talukas', '/admin/master-data/talukas', 'tabler:map-pin', 'ADMINISTRATION', 'Master Data', 30, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('15c218c3-8001-44e9-8f71-fe883a9f3b39', 'md-districts', 'master_data.view', 'Districts', '/admin/master-data/districts', 'tabler:map-pin', 'ADMINISTRATION', 'Master Data', 20, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('f255eb38-7dc7-4f17-a168-ffc886c1b579', 'md-documents', 'master_data.view', 'Documents', '/admin/master-data/documents', 'tabler:file', 'ADMINISTRATION', 'Master Data', 60, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('7a9ec222-7ef0-48bf-b17f-a88f6fff3745', 'md-case-type-doc', 'master_data.view', 'Case Type Document Map', '/admin/master-data/case-type-document-map', 'tabler:link', 'ADMINISTRATION', 'Master Data', 80, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('8ce436e5-5a35-498d-849c-3d47eb90fe86', 'md-category-doc', 'master_data.view', 'Category Document Map', '/admin/master-data/category-document-map', 'tabler:link', 'ADMINISTRATION', 'Master Data', 70, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('cc10859d-8892-4cac-937f-e6c208d00e42', 'role-modules', 'roles.view', 'Role Modules', '/admin/modules', 'tabler:list-check', 'ADMINISTRATION', NULL, 60, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00'),
	('75ea2325-5639-451e-ba5b-be41dc76043f', 'md-categories', 'master_data.view', 'Legal Aid Categories', '/admin/master-data/categories', 'tabler:layout-grid', 'ADMINISTRATION', 'Master Data', 40, true, '2026-09-07 11:40:05.396483+00', '2026-09-09 09:51:26.526448+00');


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."notifications" ("id", "user_id", "created_at", "body", "title", "application_id", "type", "is_read") VALUES
	('522849eb-88c1-4e09-aad2-cc8972109987', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:20:02.961355+00', 'Your application SK-PAK-26-00012 has been resolved.', 'Application Resolved', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('f239f468-c1e9-47bc-8d10-5c4187aa4b87', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:19:20.337168+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('6695ddc0-e3bd-40de-8b18-e8df39fc2fa1', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:02:11.29334+00', 'Your application SK-PAK-26-00012 is now under review.', 'Application Under Review', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('dea5b8d6-8958-414b-b713-147ac17a20d1', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:02:44.273212+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('2d75786a-b40d-462d-b268-342d6b1ff6e0', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:03:08.336714+00', 'Your application SK-PAK-26-00012 has been resolved.', 'Application Resolved', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('f7b1eb88-e534-4331-9f16-6437341dec54', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:03:28.221052+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('a70ae85a-2be4-4b5d-a0b8-b6ec9b473a47', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:07:12.199595+00', 'Your application SK-PAK-26-00012 has been resolved.', 'Application Resolved', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('3a60f929-51a3-4269-9a23-a40616632b6e', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:11:36.333885+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('5e8143e6-990d-40bc-8192-4d3d218fb378', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:14:13.358168+00', 'Your application SK-PAK-26-00012 has been resolved.', 'Application Resolved', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('2a997da4-0b63-4a5e-86e8-e06978f35aa5', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:38:16.965361+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', true),
	('9bed36cb-b65b-4fa3-bf64-a3f3264844ac', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 18:56:48.898468+00', 'Your application SK-PAK-26-00012 is now under review.', 'Application Under Review', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', false),
	('1e3958bc-df5c-4835-b2a6-9869d42b8f4d', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 19:21:07.134743+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', false),
	('375ff43f-7186-40a8-a21f-dd4fdac27999', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 19:30:18.356362+00', 'Your application SK-PAK-26-00012 has been resolved.', 'Application Resolved', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', false),
	('69275ad5-77a3-40ed-a6be-0f15c482885f', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 19:30:36.291151+00', 'An advocate has been assigned to your application SK-PAK-26-00012.', 'Advocate Assigned', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', false),
	('4a11eb53-8bba-4c52-8324-b19f8ce19b57', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-16 19:44:01.654429+00', 'Your application SK-PAK-26-00012 has been resolved.', 'Application Resolved', 'f6d48913-53f1-4ffe-93a8-24dd6fc9a102', 'application_status_update', false),
	('775d962a-5cbb-498c-94ff-bdedc21ff698', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-19 10:15:10.632982+00', 'Your application LA-20260816-7dfba7c1 is now under review.', 'Application Under Review', 'c0c66157-f2d6-42ae-b587-27292cc074a6', 'application_status_update', false),
	('c4a2529a-2d48-4e00-b040-60b71bdf38c1', 'f60352e9-33a0-40f2-98f4-b79fe2795050', '2026-08-19 10:15:26.827635+00', 'An advocate has been assigned to your application LA-20260816-7dfba7c1.', 'Advocate Assigned', 'c0c66157-f2d6-42ae-b587-27292cc074a6', 'application_status_update', false),
	('64a0c129-8ce6-4115-ae81-461df3bdceee', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-08-31 08:50:35.846029+00', 'An advocate has been assigned to your application SK-GTK-26-00013.', 'Advocate Assigned', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', 'application_status_update', true),
	('78f81ff0-a78f-41a4-9664-c4956ad0c86e', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-08-31 08:47:06.213664+00', 'Your application SK-GTK-26-00013 has been submitted successfully.', 'Application Submitted', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', 'application_status_update', true),
	('ee8ace16-81b9-4855-bfce-a2608ae10a79', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-08-31 08:49:44.172353+00', 'Your application SK-GTK-26-00013 is now under review.', 'Application Under Review', 'd111f2fa-fad0-4dd0-82e2-caffa7fdf0a3', 'application_status_update', true),
	('d474c5b2-1731-435f-aa23-2cea516feb94', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-01 03:24:46.902076+00', 'Your application SK-GTK-26-00014 has been submitted successfully.', 'Application Submitted', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', 'application_status_update', true),
	('68385fe5-8668-405d-b5c0-7c971b5b3845', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-01 06:26:51.935902+00', 'Your application SK-GTK-26-00014 is now under review.', 'Application Under Review', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', 'application_status_update', false),
	('293d49f1-adcb-4797-930a-cf076768831f', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-01 06:27:29.611809+00', 'An advocate has been assigned to your application SK-GTK-26-00014.', 'Advocate Assigned', 'ed73bb49-ef85-4dd3-aa0f-1e48140fdf1f', 'application_status_update', false),
	('2f080c80-b5f0-41a0-bd2b-68af4fd220f6', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-01 07:53:52.373208+00', 'Your application SK-GTK-26-00027 has been submitted successfully.', 'Application Submitted', 'd36069f1-81fc-460e-b5b5-8076df522fc3', 'application_status_update', false),
	('51700d2d-b555-40ef-bbc4-0a603b9026ed', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-03 10:37:11.020871+00', 'Your application SK-GTK-26-00031 has been submitted successfully.', 'Application Submitted', '9b345236-cbc2-4887-a7a5-1dad2a209fd3', 'application_status_update', false),
	('3c830284-d8db-424d-9c13-f3047a252df8', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-03 10:38:41.032248+00', 'An advocate has been assigned to your application SK-GTK-26-00031.', 'Advocate Assigned', '9b345236-cbc2-4887-a7a5-1dad2a209fd3', 'application_status_update', false),
	('f1b3f563-626c-4ab4-887d-66b8a89089dd', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-10 10:41:51.697082+00', 'An advocate has been assigned to your application SK-GTK-26-00034.', 'Advocate Assigned', 'd5855490-a80a-4dc3-a13b-5b7686255475', 'application_status_update', true),
	('f8e64843-010e-4742-ac41-dc637ee79e23', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-10 07:44:56.081356+00', 'Your application SK-GTK-26-00034 has been submitted successfully.', 'Application Submitted', 'd5855490-a80a-4dc3-a13b-5b7686255475', 'application_status_update', true),
	('2f22e612-0dd3-4ae2-897b-a72f9263cb6e', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-09-13 14:17:13.121315+00', 'Your application SK-GTK-26-00043 has been submitted successfully.', 'Application Submitted', '0d0158c8-3df9-4a4a-b776-8608c603c166', 'application_status_update', false),
	('47b029f1-4748-4296-950f-f2ec7db0c9cb', '7d6cf0f7-41ff-4095-ac26-8386242ee00d', '2026-10-06 09:56:13.722464+00', 'Your application SK-GTK-26-00047 has been submitted successfully.', 'Application Submitted', '2ffee2fc-1fc0-47ff-a104-1edee09aa0bb', 'application_status_update', false);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."roles" ("id", "code", "name", "description", "is_active", "is_system", "created_at", "updated_at") VALUES
	('79a6d608-17c3-4669-aa59-25d0de2cf6d4', 'CITIZEN', 'Citizen', 'Citizen portal access', true, true, '2026-08-12 08:40:05.448217+00', '2026-09-07 10:45:17.611202+00'),
	('e94b47ed-936d-425e-a917-a2e5adc1a4df', 'SUPER_ADMIN', 'Super Administrator', 'Full system access', true, true, '2026-08-12 08:40:05.448217+00', '2026-09-07 10:45:17.611202+00'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'administrator', 'Administrator', 'Full CMS administration across all modules.', true, true, '2026-09-07 10:45:17.611202+00', '2026-09-07 11:01:36.876234+00'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'state_admin', 'State Administrator', 'State-level administration of users, advocates and applications.', true, true, '2026-08-12 08:40:05.448217+00', '2026-09-07 11:01:36.876234+00'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'district_admin', 'District Administrator', 'District-level administration of advocates and applications.', true, true, '2026-08-12 08:40:05.448217+00', '2026-09-07 11:01:36.876234+00'),
	('379f40e1-6222-417b-9b79-66cb6d290d0d', 'advocate', 'Advocate', 'Assigned-case management.', true, true, '2026-08-12 08:40:05.448217+00', '2026-09-07 11:01:36.876234+00'),
	('acefa6e2-b1a2-4ffb-adca-dfa2361bd96a', 'staff', 'Staff', 'Application intake and follow-up support.', true, true, '2026-08-12 08:40:05.448217+00', '2026-09-07 11:01:36.876234+00');


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."role_permissions" ("role_id", "permission_code") VALUES
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'master_data.delete'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'master_data.update'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'master_data.create'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'master_data.view'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'applications.delete'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'applications.update'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'applications.create'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'applications.view'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'advocates.delete'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'advocates.update'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'advocates.create'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'advocates.view'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'admin_scopes.manage'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'admin_scopes.view'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'roles.update'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'roles.view'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'users.delete'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'users.update'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'users.create'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'users.view'),
	('5dbf3f50-12e0-4aaa-b787-c9bbf9245872', 'dashboard.view'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'applications.update'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'applications.create'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'advocates.update'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'advocates.create'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'advocates.view'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'users.update'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'users.view'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'applications.view'),
	('b9439c55-dcd6-4534-9454-bb2c324fd8da', 'dashboard.view'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'applications.update'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'applications.create'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'advocates.update'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'advocates.create'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'advocates.view'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'applications.view'),
	('dc8fbd0f-5681-4141-b591-8d535436f745', 'dashboard.view'),
	('379f40e1-6222-417b-9b79-66cb6d290d0d', 'applications.update'),
	('379f40e1-6222-417b-9b79-66cb6d290d0d', 'advocates.view'),
	('379f40e1-6222-417b-9b79-66cb6d290d0d', 'applications.view'),
	('379f40e1-6222-417b-9b79-66cb6d290d0d', 'dashboard.view'),
	('acefa6e2-b1a2-4ffb-adca-dfa2361bd96a', 'advocates.view'),
	('acefa6e2-b1a2-4ffb-adca-dfa2361bd96a', 'applications.update'),
	('acefa6e2-b1a2-4ffb-adca-dfa2361bd96a', 'applications.create'),
	('acefa6e2-b1a2-4ffb-adca-dfa2361bd96a', 'applications.view'),
	('acefa6e2-b1a2-4ffb-adca-dfa2361bd96a', 'dashboard.view');


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_roles" ("user_id", "role_id", "created_at", "assigned_by") VALUES
	('f60352e9-33a0-40f2-98f4-b79fe2795050', '79a6d608-17c3-4669-aa59-25d0de2cf6d4', '2026-09-07 10:45:17.611202+00', NULL),
	('4a451781-317b-41b0-b7d7-b2183204febd', 'e94b47ed-936d-425e-a917-a2e5adc1a4df', '2026-09-07 10:45:17.611202+00', NULL),
	('22d7227d-4705-4657-a6bd-3efd86df22f0', '79a6d608-17c3-4669-aa59-25d0de2cf6d4', '2026-09-07 10:45:17.611202+00', NULL),
	('08d3a553-becb-414a-959b-b4128059f0b4', 'dc8fbd0f-5681-4141-b591-8d535436f745', '2026-09-07 10:45:17.611202+00', NULL),
	('68fe332c-25a5-4d47-a713-b2aea2f06d06', 'dc8fbd0f-5681-4141-b591-8d535436f745', '2026-09-07 10:45:17.611202+00', NULL),
	('79a64c73-e2d6-4596-ade4-18cf376b4a69', 'dc8fbd0f-5681-4141-b591-8d535436f745', '2026-09-07 10:45:17.611202+00', NULL),
	('8a2d51e9-dfde-477c-b8d0-3bbf449f67b3', 'b9439c55-dcd6-4534-9454-bb2c324fd8da', '2026-09-07 10:45:17.611202+00', NULL),
	('ae87ed75-c82e-4eb9-b80d-fd7ee6c0abd5', 'dc8fbd0f-5681-4141-b591-8d535436f745', '2026-09-07 10:45:17.611202+00', NULL),
	('d47c0484-3a48-49b9-a614-7fdf92c6c980', 'dc8fbd0f-5681-4141-b591-8d535436f745', '2026-09-07 10:45:17.611202+00', NULL),
	('f5c4ef6d-632c-4c91-bfd8-944db57db1c6', 'dc8fbd0f-5681-4141-b591-8d535436f745', '2026-09-07 10:45:17.611202+00', NULL),
	('6903780c-c138-463e-af24-35991d1c2add', '79a6d608-17c3-4669-aa59-25d0de2cf6d4', '2026-09-07 10:45:17.611202+00', NULL),
	('7d6cf0f7-41ff-4095-ac26-8386242ee00d', '79a6d608-17c3-4669-aa59-25d0de2cf6d4', '2026-09-07 10:45:17.611202+00', NULL);


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

INSERT INTO "supabase_functions"."hooks" ("id", "hook_table_id", "hook_name", "created_at", "request_id") VALUES
	(1, 18392, 'send_notification_webhook', '2026-08-16 18:02:11.29334+00', 1),
	(2, 18392, 'send_notification_webhook', '2026-08-16 18:02:44.273212+00', 2),
	(3, 18392, 'send_notification_webhook', '2026-08-16 18:03:08.336714+00', 3),
	(4, 18392, 'send_notification_webhook', '2026-08-16 18:03:28.221052+00', 4),
	(5, 18392, 'send_notification_webhook', '2026-08-16 18:07:12.199595+00', 5),
	(6, 18392, 'send_notification_webhook', '2026-08-16 18:11:36.333885+00', 6),
	(7, 18392, 'send_notification_webhook', '2026-08-16 18:14:13.358168+00', 7),
	(8, 18392, 'send_notification_webhook', '2026-08-16 18:19:20.337168+00', 8),
	(9, 18392, 'send_notification_webhook', '2026-08-16 18:20:02.961355+00', 9),
	(10, 18392, 'send_notification_webhook', '2026-08-16 18:38:16.965361+00', 10),
	(11, 18392, 'send_notification_webhook', '2026-08-16 18:56:48.898468+00', 11),
	(12, 18392, 'send_notification_webhook', '2026-08-16 19:21:07.134743+00', 12),
	(13, 18392, 'send_notification_webhook', '2026-08-16 19:30:18.356362+00', 13),
	(14, 18392, 'send_notification_webhook', '2026-08-16 19:30:36.291151+00', 14),
	(15, 18392, 'send_notification_webhook', '2026-08-16 19:44:01.654429+00', 15),
	(16, 18392, 'send_notification_webhook', '2026-08-19 10:15:10.632982+00', 16),
	(17, 18392, 'send_notification_webhook', '2026-08-19 10:15:26.827635+00', 17),
	(18, 18392, 'send_notification_webhook', '2026-08-31 08:47:06.213664+00', 1),
	(19, 18392, 'send_notification_webhook', '2026-08-31 08:49:44.172353+00', 2),
	(20, 18392, 'send_notification_webhook', '2026-08-31 08:50:35.846029+00', 3),
	(21, 18392, 'send_notification_webhook', '2026-09-01 03:24:46.902076+00', 4),
	(22, 18392, 'send_notification_webhook', '2026-09-01 06:26:51.935902+00', 5),
	(23, 18392, 'send_notification_webhook', '2026-09-01 06:27:29.611809+00', 6),
	(24, 18392, 'send_notification_webhook', '2026-09-01 07:53:52.373208+00', 7),
	(25, 18392, 'send_notification_webhook', '2026-09-03 10:37:11.020871+00', 8),
	(26, 18392, 'send_notification_webhook', '2026-09-03 10:38:41.032248+00', 9),
	(27, 18392, 'send_notification_webhook', '2026-09-10 07:44:56.081356+00', 10),
	(28, 18392, 'send_notification_webhook', '2026-09-10 10:41:51.697082+00', 11),
	(29, 18392, 'send_notification_webhook', '2026-09-13 14:17:13.121315+00', 12),
	(30, 18392, 'send_notification_webhook', '2026-10-06 09:56:13.722464+00', 1);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 130, true);


--
-- Name: application_tracking_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."application_tracking_seq"', 47, true);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 30, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict Ozw4SrdDchdJ6xnbLSn5OqyxGIEfsqTZTdzapWsZiItVFakPePKYH6q7DFjJZgY

RESET ALL;
