<details><summary>Datu bāzes modelis</summary>

![ER](database-model.png)

</details>

## Shēma attestation_provider

Attestation provider schema for digimaks. Contains data regarding attestation instances and records.

### Tabula attestation_provider.credential_issuances

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **character varying** | **26** | **Jā** | **generate_ulid()** | **Auto-generated primary key** |
| credential_identifier | character varying | 512 | Nē |  | Credential Identifier in the issuer metadata |
| format | character varying | 20 | Jā |  | 'mso_mdoc' or 'dc+sd-jwt' |
| doctype_vct | character varying | 100 | Jā |  | doctype for mdoc, vct for SD-JWT VC |
| issued_at | timestamp with time zone |  | Jā |  | Credential issuance time |
| expires_at | timestamp with time zone |  | Jā |  | Credential expiration time |
| revoked_at | timestamp with time zone |  | Nē |  | Timestamp of credential revocation |
| active | boolean |  | Jā | true | Should be set to false when revoked or expired |
| holder_identifier_value | character varying | 100 | Nē |  | Credential holder identification string for finding credentials to be revoked |
| holder_identifier_type | character varying | 20 | Nē |  | User identifier type (Based on ETSI identifiers, example: 'PNOLV', etc.) |
| holder_given_name | character varying | 100 | Nē |  | Credential holder given name for auditing purposes |
| holder_family_name | character varying | 100 | Nē |  | Credential holder family name for auditing purposes |
| wallet_provider | character varying | 512 | Nē |  | Wallet provider ID |
| wallet_status_type | character varying | 20 | Nē |  | Wallet status issuer type ('identifier_list' or 'status_list') |
| wallet_status_uri | text |  | Nē |  | Wallet status URI |
| wallet_status_index | integer |  | Nē |  | Wallet status 'idx' (for Status List type) or 'id' (for Identifier List type) |
| date_created | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Timestamp when record was created |
| date_modified | timestamp with time zone |  | Nē |  | Timestamp of last modification |
| install_status | character varying | 26 | Jā |  | Status 'installed' is set if the wallet sends acknowledgment of credential acceptance (not mandatory for wallets) |
| install_message | character varying | 300 | Nē |  | Message retrieved from the wallet, if wallet sends an acknowledgement |

### Tabula attestation_provider.revocation_info

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **bigint** |  | **Jā** | **Ģenerēta** | **Auto-generated primary key** |
| credential_issuance_id | character varying | 26 | Jā |  | Reference to respective credential issuance record (atsauce uz [attestation_provider.credential_issuances.id](#tabula-attestation_providercredential_issuances)) |
| status_list_uri | character varying | 1024 | Jā |  | Status list URI |
| status_list_idx | integer |  | Jā |  | Index value in the status list |
| active | boolean |  | Jā | true | Should be set to false when credential is revoked or expired to exclude from DB index |

### Funkcijas un procedūras

* Procedūra `attestation_provider.record_credential_issuance (IN pi_data jsonb, INOUT po_data jsonb) record`

Records a new credential issuance with optional revocation tracking.

* Procedūra `attestation_provider.update_install_status (IN pi_data jsonb, INOUT po_data jsonb) record`

Updates the installation status and message for a credential (acknowledgment from wallet).

## Shēma audit

### Tabula audit.person_data_requests

Personas datu audits

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **bigint** |  | **Jā** | **Ģenerēta** | **Ieraksta identifikators** |
| timestamp | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Laika zīmogs |
| req_person_id | character varying | 250 | Nē |  | Datu pieprasītāja identifikators |
| req_person_code | character varying | 50 | Nē |  | Datu pieprasītāja personas kods |
| person_code | character varying | 50 | Jā |  | Personas kods |
| action_code | character varying | 50 | Jā |  | Darbības kods |
| action_id | bigint |  | Nē |  | Darbības saistītais identifikators |
| ip_address | inet |  | Nē |  | Pieprasītāja IP adrese |
| req_data | jsonb |  | Nē |  | Papildus datu pieprasītāja dati (firstName, lastName) |
| client_code | character varying | 250 | Nē |  | Izsaucēja klienta identifikators |

### Funkcijas un procedūras

* Procedūra `audit.audit_person_data (IN pi_data text, INOUT po_data text) record`

Personas datu audita ieraksta izveidošana autorizētam lietotājam

* Procedūra `audit.audit_person_data (IN pi_req_person_id character varying, IN pi_req_person_code character varying, IN pi_req_person_first_name character varying, IN pi_req_person_last_name character varying, IN pi_req_org_regnum character varying, IN pi_req_org_title character varying, IN pi_person_code character varying, IN pi_action_code character varying, IN pi_action_id bigint, IN pi_ip_address inet) `

Personas datu audita ieraksta izveidošana

* Procedūra `audit.create_audit_partition (IN pi_for_date date) `

Personas datu audita tabulas nodalījuma izveidošana norādītajam datumam

* Funkcija `audit.get_legal_entity_prefix (number_length integer) varchar`

Juridiskās personas koda prefikss

* Funkcija `audit.get_physical_person_prefix () varchar`

Fiziskās personas koda prefikss

* Procedūra `audit.insert_person_data_request (IN pi_data audit.person_data_requests) `

Saglabā personas datu pieprasījumu

## Shēma session

Session schema.

### Funkcijas un procedūras

* Procedūra `session.create (IN pi_id character varying, IN pi_user_id character varying, IN pi_user_code character varying, IN pi_given_name character varying, IN pi_family_name character varying, IN pi_role_code character varying, IN pi_ip_addr inet) `

Initializes the user session state.

* Funkcija `session.get_user_data () record`

Returns the user data for the current session.

## Shēma util

### Funkcijas un procedūras

* Funkcija `util.to_date (pi_date character varying) date`

String datuma konvertēšana uz date

* Funkcija `util.to_timestamp (pi_date character varying) timestamp`

String datuma konvertēšana uz timestamp without time zone

* Funkcija `util.to_timestamp_with_tz (pi_date character varying) timestamptz`

String datuma konvertēšana uz timestamp with time zone

## Shēma wallet_provider

Wallet provider schema for digimaks. Contains data regarding wallet instances and accounts.

### Tabula wallet_provider.accounts

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **character varying** | **26** | **Jā** | **generate_ulid()** | **Auto-generated primary key** |
| active | boolean |  | Jā | true | True if active, false if soft deleted by user or system |
| given_name | character varying | 100 | Nē |  | User given name if known |
| family_name | character varying | 100 | Nē |  | User family name if known |
| date_created | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Timestamp when record was created |
| date_modified | timestamp with time zone |  | Nē |  | Timestamp of last modification |

### Tabula wallet_provider.instances

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **character varying** | **26** | **Jā** | **generate_ulid()** | **Auto-generated primary key** |
| account_id | character varying | 26 | Nē |  | Reference to user account (atsauce uz [wallet_provider.accounts.id](#tabula-wallet_provideraccounts)) |
| hardware_key_tag | character varying | 50 | Jā |  | Wallet HW secured key tag for WU identification. Taken from attestation.Result.HardwareKeyTag in POST /wallet/instance. |
| public_key | text |  | Jā |  | Public part of the wallet identification key. Taken from attestation.Result.PublicKey in POST /wallet/instance. |
| fid | character varying | 255 | Nē |  | Firebase identifier |
| wscd_anchor_hash | character varying | 64 | Jā |  | A digest of all data protected by device Verified Boot, should be always the same |
| wscd_type | character varying | 50 | Jā |  | Android: 'TrustedEnvironment' vai 'StrongBox'; iOS: 'SECURE_ENCLAVE' |
| device_label | character varying | 32 | Jā |  | User given Device name from deviceLabel string in POST /wallet/instance. User SHALL BE able to change this name. For Android - manufacturer + model |
| hardware_identifiers | jsonb |  | Nē |  | Device identifiers from deviceIdentifiers array in POST /wallet/instance. At least manufacturer and model shall be added, if available |
| active | boolean |  | Jā | true | Set false when the instance is revoked |
| date_created | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Instance creation time |
| date_modified | timestamp with time zone |  | Nē |  | Record last update time |
| revoked_at | timestamp with time zone |  | Nē |  | Timestamp of instance revocation |

### Tabula wallet_provider.parameters

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **name** | **character varying** | **64** | **Jā** |  | **Parameter name** |
| value | character varying | 128 | Jā |  | Parameter value |
| last_changed | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Timestamp of last modification |

### Tabula wallet_provider.revocation_info

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **bigint** |  | **Jā** | **Ģenerēta** | **Auto-generated primary key** |
| instance_id | character varying | 26 | Jā |  | Reference to wallet instance record (atsauce uz [wallet_provider.instances.id](#tabula-wallet_providerinstances)) |
| status_list_uri | character varying | 128 | Jā |  | Revocation index list URI |
| status_list_idx | integer |  | Jā |  | Index value in the revocation index list |
| wua_expires_at | timestamp with time zone |  | Jā |  | Expiration timestamp of respective WUA |
| active | boolean |  | Jā | true | Should be set to false after wallet revocation or WUA expiration to to exclude from index |

### Tabula wallet_provider.user_contact_info

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **bigint** |  | **Jā** | **Ģenerēta** | **Auto-generated primary key** |
| account_id | character varying | 26 | Jā |  | Reference to user account (atsauce uz [wallet_provider.accounts.id](#tabula-wallet_provideraccounts)) |
| contact_type | character varying | 50 | Jā |  | Types: 'EMAIL', 'PHONE' |
| value | character varying | 100 | Jā |  | Phone number, address etc |
| date_created | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Timestamp when record was created |
| date_modified | timestamp with time zone |  | Nē |  | Timestamp of last modification |
| active | boolean |  | Jā | true | True if active, false if deleted by user |

### Tabula wallet_provider.user_identifiers

| Nosaukums | Tips | Garums | Obligāts | Noklusētā vērtība | Apraksts |
| --------- | ---- | ------ | -------- | ----------------- | -------- |
| **id** | **bigint** |  | **Jā** | **Ģenerēta** | **Auto-generated primary key** |
| account_id | character varying | 26 | Jā |  | Reference to user account (atsauce uz [wallet_provider.accounts.id](#tabula-wallet_provideraccounts)) |
| identifier_type | character varying | 50 | Jā |  | User identifier type (Based on ETSI identifiers, example: 'PNOLV', etc.) |
| value | character varying | 100 | Jā |  | User identifier value |
| valid | boolean |  | Jā | true | If false, it can not be used though is still visible for user as inactive |
| date_created | timestamp with time zone |  | Jā | CURRENT_TIMESTAMP | Timestamp when record was created |
| date_modified | timestamp with time zone |  | Nē |  | Timestamp of last modification |
| active | boolean |  | Jā | true | False if deleted by user or system |

### Funkcijas un procedūras

* Procedūra `wallet_provider.allocate_revocation_index (IN pi_params jsonb, OUT po_result jsonb) record`

Allocates and stores revocation index for WUA (Wallet Unit Attestation). Returns existing allocation if already present.

* Funkcija `wallet_provider.allocate_revocation_index_f (params jsonb) jsonb`

* Procedūra `wallet_provider.create_instance (IN pi_data jsonb, INOUT po_data jsonb) record`

Creates a new wallet provider instance and returns its metadata.

* Procedūra `wallet_provider.delete_inactive_instances (IN pi_data jsonb, INOUT po_data jsonb) record`

Soft-deletes anonymous wallet instances older than the configured threshold.

* Funkcija `wallet_provider.get_account_data (pi_account_id character varying) jsonb`

Returns wallet account profile data with identifiers and contacts.

* Funkcija `wallet_provider.get_account_id_by_code (pi_value character varying) varchar`

Finds a wallet account by personal code identifier.

* Funkcija `wallet_provider.get_account_id_by_guid (pi_value character varying) varchar`

Finds a wallet account by ULID/GUID.

* Procedūra `wallet_provider.get_active_revocation_indices (IN pi_params jsonb, OUT po_result jsonb) record`

Returns all revoked wallet instances (active=false) with their status list indices for status list generation. Used by status list service to build revocation bit arrays.

* Funkcija `wallet_provider.get_active_revocation_indices_f (params jsonb) jsonb`

* Procedūra `wallet_provider.get_instance_by_tag (IN pi_data jsonb, INOUT po_data jsonb) record`

Returns wallet instance metadata with optional account profile by hardware key tag.

* Funkcija `wallet_provider.get_instance_data (pi_hardware_key_tag character varying) jsonb`

Returns wallet instance metadata for the provided hardware key tag.

* Procedūra `wallet_provider.get_instance_list (IN pi_data jsonb, INOUT po_data jsonb) record`

Returns active wallet instances for the specified account.

* Procedūra `wallet_provider.get_public_key (IN pi_data jsonb, INOUT po_data jsonb) record`

Returns the public key and optional account profile for a wallet instance.

* Procedūra `wallet_provider.get_revocation_status (IN pi_params jsonb, OUT po_result jsonb) record`

Retrieves revocation status and status list information for a wallet instance.

* Funkcija `wallet_provider.get_revocation_status_f (params jsonb) jsonb`

* Procedūra `wallet_provider.relink_instance_account (IN pi_data jsonb, INOUT po_data jsonb) record`

Ensures a wallet instance is linked to the account matching the current authenticated identity, creating/updating the account and relinking the instance if it changed.

* Procedūra `wallet_provider.revoke_instance (IN pi_params jsonb, OUT po_result jsonb) record`

Revokes a wallet instance by setting active=false and revoked_at timestamp. Deactivates revocation_info entries to mark them as revoked in status lists.

* Funkcija `wallet_provider.revoke_instance_f (params jsonb) jsonb`

* Procedūra `wallet_provider.save_account (IN pi_data jsonb, INOUT po_data jsonb) record`

Creates or updates wallet account profile data.

