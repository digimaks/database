ALTER TABLE audit.person_data_requests
  ADD COLUMN client_code varchar(250);
COMMENT ON COLUMN audit.person_data_requests.client_code
    IS 'Izsaucēja klienta identifikators';
