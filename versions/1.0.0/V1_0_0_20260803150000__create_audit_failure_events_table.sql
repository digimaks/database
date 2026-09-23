-- SPDX-License-Identifier: EUPL-1.2

-- ponytail: no partitioning yet, unlike audit.person_data_requests. Add
-- date-partitioning (mirroring audit.create_audit_partition) if/when error
-- volume makes a single unpartitioned table a retention or query problem.
CREATE TABLE IF NOT EXISTS audit.failure_events (
    id               bigserial   NOT NULL,
    occurred_at      timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    service          varchar(100) NOT NULL,
    endpoint         varchar(255) NOT NULL,
    error_message    text,
    status_code      integer     NOT NULL,
    app_instance_id  varchar(100),
    CONSTRAINT failure_events_pkey PRIMARY KEY (id)
);
ALTER TABLE audit.failure_events OWNER TO digimaks;

COMMENT ON TABLE audit.failure_events IS 'Kļūdu atbilžu audits (kurš serviss, endpoint, kļūda, statuss, app instance)';
COMMENT ON COLUMN audit.failure_events.occurred_at IS 'Laika zīmogs';
COMMENT ON COLUMN audit.failure_events.service IS 'Servisa identifikators, kur kļūda radās';
COMMENT ON COLUMN audit.failure_events.endpoint IS 'Endpoint (route path), kurā kļūda radās';
COMMENT ON COLUMN audit.failure_events.error_message IS 'Kļūdas ziņojums';
COMMENT ON COLUMN audit.failure_events.status_code IS 'HTTP atbildes statusa kods';
COMMENT ON COLUMN audit.failure_events.app_instance_id IS 'X-App-Instance-Id galvenes vērtība';
